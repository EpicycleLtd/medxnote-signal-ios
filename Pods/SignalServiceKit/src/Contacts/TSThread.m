//  Created by Frederic Jacobs on 16/11/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.

#import "TSThread.h"
#import "TSDatabaseView.h"
#import "TSIncomingMessage.h"
#import "TSInteraction.h"
#import "TSOutgoingMessage.h"
#import "TSStorageManager.h"
#import "TSNetworkManager.h"
#import "TSGroupThread.h"
#import "SignalRecipient.h"
#import "ContactsUpdater.h"
#import "TSAccountManager.h"
#import "TextSecureKitEnv.h"

@interface TSThread ()

@property (nonatomic, retain) NSDate *creationDate;
@property (nonatomic, copy) NSDate *archivalDate;
@property (nonatomic, retain) NSDate *lastMessageDate;
@property (nonatomic, copy) NSString *messageDraft;

- (TSInteraction *)lastInteraction;

@end

@implementation TSThread

+ (NSString *)collection {
    return @"TSThread";
}

- (instancetype)initWithUniqueId:(NSString *)uniqueId {
    self = [super initWithUniqueId:uniqueId];

    if (self) {
        _archivalDate    = nil;
        _lastMessageDate = nil;
        _creationDate    = [NSDate date];
        _messageDraft    = nil;
    }

    return self;
}

- (void)remove
{
    [[self dbConnection] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *_Nonnull transaction) {
        [self removeWithTransaction:transaction];
    }];
}

- (void)removeWithTransaction:(YapDatabaseReadWriteTransaction *)transaction
{
    [super removeWithTransaction:transaction];

    __block NSMutableArray<NSString *> *interactionIds = [[NSMutableArray alloc] init];
    [self enumerateInteractionsWithTransaction:transaction
                                    usingBlock:^(TSInteraction *interaction, YapDatabaseReadTransaction *transaction) {
                                        [interactionIds addObject:interaction.uniqueId];
                                    }];

    for (NSString *interactionId in interactionIds) {
        // This might seem redundant since we're fetching the interaction twice, once above to get the uniqueIds
        // and then again here. The issue is we can't remove them within the enumeration (you can't mutate an
        // enumeration source), but we also want to avoid instantiating an entire threads worth of Interaction objects
        // at once. This way we only have a threads worth of interactionId's.
        TSInteraction *interaction = [TSInteraction fetchObjectWithUniqueID:interactionId transaction:transaction];
        [interaction removeWithTransaction:transaction];
    }
}

#pragma mark To be subclassed.

- (BOOL)isGroupThread {
    NSAssert(false, @"An abstract method on TSThread was called.");
    return FALSE;
}

- (NSString *)name {
    NSAssert(FALSE, @"Should be implemented in subclasses");
    return nil;
}

- (UIImage *)image {
    return nil;
}

#pragma mark Interactions

/**
 * Iterate over this thread's interactions
 */
- (void)enumerateInteractionsWithTransaction:(YapDatabaseReadWriteTransaction *)transaction
                                  usingBlock:(void (^)(TSInteraction *interaction,
                                                 YapDatabaseReadTransaction *transaction))block
{
    void (^interactionBlock)(NSString *, NSString *, id, id, NSUInteger, BOOL *) = ^void(NSString *_Nonnull collection,
        NSString *_Nonnull key,
        id _Nonnull object,
        id _Nonnull metadata,
        NSUInteger index,
        BOOL *_Nonnull stop) {

        TSInteraction *interaction = object;
        block(interaction, transaction);
    };

    YapDatabaseViewTransaction *interactionsByThread = [transaction ext:TSMessageDatabaseViewExtensionName];
    [interactionsByThread enumerateRowsInGroup:self.uniqueId usingBlock:interactionBlock];
}

- (NSUInteger)numberOfInteractions
{
    __block NSUInteger count;
    [[self dbConnection] readWithBlock:^(YapDatabaseReadTransaction *_Nonnull transaction) {
        YapDatabaseViewTransaction *interactionsByThread = [transaction ext:TSMessageDatabaseViewExtensionName];
        count = [interactionsByThread numberOfItemsInGroup:self.uniqueId];
    }];
    return count;
}

- (BOOL)hasUnreadMessages {
    TSInteraction *interaction = self.lastInteraction;
    BOOL hasUnread = NO;

    if ([interaction isKindOfClass:[TSIncomingMessage class]]) {
        hasUnread = ![(TSIncomingMessage *)interaction wasRead];
    }

    return hasUnread;
}

- (void)markAllAsReadWithTransaction:(YapDatabaseReadWriteTransaction *)transaction {
    YapDatabaseViewTransaction *viewTransaction = [transaction ext:TSUnreadDatabaseViewExtensionName];
    NSMutableArray *array                       = [NSMutableArray array];
    [viewTransaction
        enumerateRowsInGroup:self.uniqueId
                  usingBlock:^(
                      NSString *collection, NSString *key, id object, id metadata, NSUInteger index, BOOL *stop) {
                    [array addObject:object];
                  }];
    //NSLog([TSAccountManager localNumber]);
    for (TSIncomingMessage *message in array) {
        message.read = YES;
        
        

        
        
        
        __block NSError *latestError;
        TSThread *thread = [TSThread self];
        NSString * dest = @"";
        
        if (self.isGroupThread){
            dest = message.authorId;
            
        } else {
            TSInteraction *interaction = [TSInteraction fetchObjectWithUniqueID:message.uniqueId transaction:transaction];
            dest = [interaction.uniqueThreadId substringFromIndex:1];
        }
        NSString * msgid = [NSString stringWithFormat:@"%lld",message.timestamp];
 /*       if (self.isGroupThread){
            TSGroupThread *thread = (TSGroupThread *)self;
            
           // NSArray *groupRecipients     =  thread.groupModel.groupMemberIds;
    
            for ( NSString *member in thread.groupModel.groupMemberIds){
                if (![[TSAccountManager localNumber] isEqualToString:member]) {
                    [[TSNetworkManager sharedManager]
                     makeRequest:[[TSMessageReadRequest alloc] initWithDestination:member forMessageId:msgid relay:@""]
                     success:^(NSURLSessionDataTask *task, id responseObject) {NSLog(@"success");}
                     failure:^(NSURLSessionDataTask *task, id responseObject) {NSLog(@"failure");}];
                }
            }
        }else{
  */
        
    
            [[TSNetworkManager sharedManager]
             makeRequest:[[TSMessageReadRequest alloc] initWithDestination:dest forMessageId:msgid relay:@""]
             success:^(NSURLSessionDataTask *task, id responseObject) {
                 
                 NSLog(@"success");
                 
             }
             failure:^(NSURLSessionDataTask *task, id responseObject) {NSLog(@"failure");}];
    //    }
       // TSGroupThread *thread = [TSThread fetchObjectWithUniqueID:self.uniqueId transaction:transaction];
      //  for ( NSString *member in thread.groupModel.groupMemberIds){
      //      NSLog(member);
      //  }
        /*
        TSGroupThread *groupThread = (TSGroupThread *)thread;
        NSMutableArray<SignalRecipient *> *recipients = [NSMutableArray array];
        for (NSString *recipientId in groupThread.groupModel.groupMemberIds) {
            __block SignalRecipient *recipient;
            [self.dbConnection readWithBlock:^(YapDatabaseReadTransaction *_Nonnull transaction) {
                recipient = [SignalRecipient recipientWithTextSecureIdentifier:recipientId withTransaction:transaction];
            }];
            
            
            if (!recipient) {
                [[self contactUpdater] synchronousLookup:recipientId
                                                 success:^(SignalRecipient *newRecipient) {
                                                     [recipients addObject:newRecipient];
                                                 }
                                                 failure:^(NSError *error) {
#warning Ignore sending message to him?
                                                     latestError = error;
                                                 }];
            } else {
                [recipients addObject:recipient];
            }
        }
        */
        //for (SignalRecipient *rec in recipients) {
            // we don't need to send the message to ourselves, but otherwise we send
            //if (![[rec uniqueId] isEqualToString:contactIdentifier]) {
              //  [futures addObject:[self sendMessageFuture:message recipient:rec inThread:thread]];
            //}
    //        NSLog(rec);
            
 //       }


   /*     if ([thread isKindOfClass:[TSGroupThread class]]) {
            TSGroupThread *groupThread = (TSGroupThread *)thread;
            [self getRecipients:groupThread.groupModel.groupMemberIds
                        success:^(NSArray<SignalRecipient *> *recipients) {
                            [self groupSend:recipients
                                    Message:message
                                   inThread:thread
                                    success:successCompletionBlock
                                    failure:failedCompletionBlock];
                        }
                        failure:^(NSError *error) {
                            DDLogError(@"Failure to retreive group recipient.");
                            [self saveMessage:message withState:TSOutgoingMessageStateUnsent];
                        }];
        } else {*/
            //TSGroupThread.
            //__block TSInteraction *interaction;
        //    TSInteraction *interaction = [TSInteraction fetchObjectWithUniqueID:message.uniqueId transaction:transaction];
          //  interaction.
        
            //NSString * zzz = [interaction.uniqueThreadId substringFromIndex:1];
            // TSRequest *rr = [[TSMessageReadRequest alloc] initWithDestination:zzz forMessageId:msgid relay:@""];
            //[[TSNetworkManager sharedManager] makeRequest:rr];
            //[[TSNetworkManager sharedManager] makeRequest:attachmentRequest];
            // //TSMessagesManager  *ss =[[TSMessagesManager sharedManager] init  ];
            //[ rr sendReadReceipt:zzz];
        
           // NSLog(@"before");
   //     }
        
        
        
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        NSDate *readTime = [NSDate dateWithTimeIntervalSince1970:timeStamp];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm:ss dd/MM/YYYY"];
        NSString *readTimeString = [dateFormatter stringFromDate: readTime];
        NSString *senderName =
              [[TextSecureKitEnv sharedEnv].contactsManager nameStringForPhoneIdentifier:dest];
        NSString *formatedTime = [NSString stringWithFormat: @"Read: %@", readTimeString];
        
        message.receipts[[NSString stringWithFormat:@"%@_%@_3", senderName, dest]] = formatedTime;
        
        
        [message saveWithTransaction:transaction];
    }
}

- (ContactsUpdater *)contactUpdater {
    return [ContactsUpdater sharedUpdater];
}

- (TSInteraction *) lastInteraction {
    __block TSInteraction *last;
    [TSStorageManager.sharedManager.dbConnection readWithBlock:^(YapDatabaseReadTransaction *transaction){
        last = [[transaction ext:TSMessageDatabaseViewExtensionName] lastObjectInGroup:self.uniqueId];
    }];
    return (TSInteraction *)last;
}

- (NSDate *)lastMessageDate {
    if (_lastMessageDate) {
        return _lastMessageDate;
    } else {
        return _creationDate;
    }
}

- (NSString *)lastMessageLabel {
    if (self.lastInteraction == nil) {
        return @"";
    } else {
        return [self lastInteraction].description;
    }
}

- (void)updateWithLastMessage:(TSInteraction *)lastMessage transaction:(YapDatabaseReadWriteTransaction *)transaction {
    NSDate *lastMessageDate = lastMessage.date;

    if ([lastMessage isKindOfClass:[TSIncomingMessage class]]) {
        TSIncomingMessage *message = (TSIncomingMessage *)lastMessage;
        lastMessageDate            = message.receivedAt;
    }

    if (!_lastMessageDate || [lastMessageDate timeIntervalSinceDate:self.lastMessageDate] > 0) {
        _lastMessageDate = lastMessageDate;

        [self saveWithTransaction:transaction];
    }
}

#pragma mark Archival

- (NSDate *)archivalDate {
    return _archivalDate;
}

- (void)archiveThreadWithTransaction:(YapDatabaseReadWriteTransaction *)transaction {
    [self archiveThreadWithTransaction:transaction referenceDate:[NSDate date]];
}

- (void)archiveThreadWithTransaction:(YapDatabaseReadWriteTransaction *)transaction referenceDate:(NSDate *)date {
    [self markAllAsReadWithTransaction:transaction];
    _archivalDate = date;

    [self saveWithTransaction:transaction];
}

- (void)unarchiveThreadWithTransaction:(YapDatabaseReadWriteTransaction *)transaction {
    _archivalDate = nil;
    [self saveWithTransaction:transaction];
}

#pragma mark Drafts

- (NSString *)currentDraftWithTransaction:(YapDatabaseReadTransaction *)transaction {
    TSThread *thread = [TSThread fetchObjectWithUniqueID:self.uniqueId transaction:transaction];
    if (thread.messageDraft) {
        return thread.messageDraft;
    } else {
        return @"";
    }
}

- (void)setDraft:(NSString *)draftString transaction:(YapDatabaseReadWriteTransaction *)transaction {
    TSThread *thread    = [TSThread fetchObjectWithUniqueID:self.uniqueId transaction:transaction];
    thread.messageDraft = draftString;
    [thread saveWithTransaction:transaction];
}

@end
