//
//  SignalsViewController.m
//  Signal
//
//  Created by Dylan Bourgeois on 27/10/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.
//

#import "InboxTableViewCell.h"
#import "UIUtil.h"

#import "InCallViewController.h"
#import "MessagesViewController.h"
#import "NSDate+millisecondTimeStamp.h"
#import "OWSContactsManager.h"
#import "PreferencesUtil.h"
#import "SignalsViewController.h"
#import "TSAccountManager.h"
#import "TSDatabaseView.h"
#import "TSGroupThread.h"
#import "TSMessagesManager+sendMessages.h"
#import "TSStorageManager.h"
#import "VersionMigrations.h"
#import "MessageComposeTableViewController.h"
#import "TSMessageAdapter.h"
#import "SearchResult.h"

#import <YapDatabase/YapDatabaseViewChange.h>
#import "YapDatabaseViewConnection.h"

@import AudioToolbox;

#define CELL_HEIGHT 72.0f
#define HEADER_HEIGHT 44.0f

static NSString *const kShowSignupFlowSegue = @"showSignupFlow";

@interface SignalsViewController () <UISearchBarDelegate>

@property (nonatomic, strong) YapDatabaseConnection *editingDbConnection;
@property (nonatomic, strong) YapDatabaseConnection *uiDatabaseConnection;
@property (nonatomic, strong) YapDatabaseViewMappings *threadMappings;
@property (nonatomic) CellState viewingThreadsIn;
@property (nonatomic) long inboxCount;
@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) id previewingContext;
@property BOOL isSendingUnsent;

// search
@property (nonatomic, strong) YapDatabaseViewMappings *messageMappings;
@property UISearchController *searchController;
@property NSArray <TSThread *> *threads;
@property NSMutableArray *results;
@property NSMutableDictionary *memberNameCache;

@end

@implementation SignalsViewController

- (void)awakeFromNib {
    [[Environment getCurrent] setSignalsViewController:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.results = [NSMutableArray new];
    self.memberNameCache = [NSMutableDictionary new];
    [self tableViewSetUp];

    self.editingDbConnection = TSStorageManager.sharedManager.newDatabaseConnection;

    [self.uiDatabaseConnection beginLongLivedReadTransaction];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(yapDatabaseModified:)
                                                 name:TSUIDatabaseConnectionDidUpdateNotification
                                               object:nil];
    [self selectedInbox:self];

    [[[Environment getCurrent] contactsManager]
            .getObservableContacts watchLatestValue:^(id latestValue) {
      [self.tableView reloadData];
    }
                                           onThread:[NSThread mainThread]
                                     untilCancelled:nil];

    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[
        NSLocalizedString(@"WHISPER_NAV_BAR_TITLE", nil),
        NSLocalizedString(@"ARCHIVE_NAV_BAR_TITLE", nil)
    ]];

    [self.segmentedControl addTarget:self
                              action:@selector(swappedSegmentedControl)
                    forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.segmentedControl;
    [self.segmentedControl setSelectedSegmentIndex:0];


    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] &&
        (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)) {
        [self registerForPreviewingWithDelegate:self sourceView:self.tableView];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendUnsentMessages)
                                                 name:@"InternetNowReachable"
                                               object:nil];
    [self setupSearch];
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
              viewControllerForLocation:(CGPoint)location {
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];

    if (indexPath) {
        [previewingContext setSourceRect:[self.tableView rectForRowAtIndexPath:indexPath]];

        MessagesViewController *vc = [[MessagesViewController alloc] initWithNibName:nil bundle:nil];
        TSThread *thread           = [self threadForIndexPath:indexPath];
        [vc configureForThread:thread keyboardOnViewAppearing:NO];
        [vc peekSetup];

        return vc;
    } else {
        return nil;
    }
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
     commitViewController:(UIViewController *)viewControllerToCommit {
    MessagesViewController *vc = (MessagesViewController *)viewControllerToCommit;
    [vc popped];

    [self.navigationController pushViewController:vc animated:NO];
}

- (void)composeNew {
    [self composeNewWithSender:nil];
}

- (void)forwardImage:(UIImage*)image {
    [self composeNewWithSender:image];
}

- (void)composeNewWithSender:(id)sender {
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    [self performSegueWithIdentifier:@"composeNew" sender:sender];
}

- (void)swappedSegmentedControl {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self selectedInbox:nil];
    } else {
        [self selectedArchive:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkIfEmptyView];

    [self updateInboxCountLabel];
    [[self tableView] reloadData];
    [self updateSearchMapping];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![TSAccountManager isRegistered]) {
        [self performSegueWithIdentifier:kShowSignupFlowSegue sender:self];
    }
}

- (void)tableViewSetUp {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)sendUnsentMessages {
    if (self.isSendingUnsent) { return; }
    self.isSendingUnsent = true;
    NSLog(@"will send unsent messages");
    
    dispatch_group_t group = dispatch_group_create();
    
    for (NSUInteger i = 0; i < [self.threadMappings numberOfItemsInSection:0]; i++) {
        TSThread *thread = [self threadForIndexPath:[NSIndexPath indexPathForRow:(NSInteger)i inSection:0]];
        [self.uiDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            YapDatabaseViewMappings *messageMappings =
            [[YapDatabaseViewMappings alloc] initWithGroups:@[thread.uniqueId] view:TSMessageDatabaseViewExtensionName];
            [messageMappings updateWithTransaction:transaction];
            YapDatabaseViewTransaction *viewTransaction = [transaction ext:TSMessageDatabaseViewExtensionName];
            NSParameterAssert(viewTransaction != nil);
            NSParameterAssert(messageMappings != nil);
            
            // check all messages in this thread
            NSUInteger numberOfItemsInSection = [messageMappings numberOfItemsInSection:0];
            for (NSUInteger j = 0; j<numberOfItemsInSection; j++) {
                TSInteraction *interaction = [viewTransaction objectAtRow:j inSection:0 withMappings:messageMappings];
                TSMessageAdapter *adapter = (TSMessageAdapter *)[TSMessageAdapter messageViewDataWithInteraction:interaction inThread:thread];
                if (adapter.messageType != TSOutgoingMessageAdapter) { continue; }
                TSOutgoingMessage *message = (TSOutgoingMessage *)adapter;
                if (message.messageState == TSOutgoingMessageStateUnsent) {
                    dispatch_group_enter(group);
                    [[TSMessagesManager sharedManager] sendMessage:(TSOutgoingMessage *)interaction inThread:thread success:^{
                        NSLog(@"sent unsent message %@", message);
                        dispatch_group_leave(group);
                    } failure:^{
                        NSLog(@"failed to send unsent message %@", message);
                        dispatch_group_leave(group);
                    }];
                }
            }
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"all offline sending tasks done!");
        self.isSendingUnsent = false;
    });
}

#pragma mark - Search

- (void)setupSearch {
    // search controller
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
    self.searchController.dimsBackgroundDuringPresentation = false;
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = self.searchController;
    } else {
        self.searchController.hidesNavigationBarDuringPresentation = false;
        self.tableView.tableHeaderView = self.searchController.searchBar;
    }
}

- (void)updateSearchMapping {
    NSMutableArray *threads = [NSMutableArray new];
    NSMutableArray *threadIds = [NSMutableArray new];
    for (NSUInteger i = 0; i < [self.threadMappings numberOfItemsInSection:0]; i++) {
        TSThread *thread = [self threadForIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [threads addObject:thread];
        [threadIds addObject:thread.uniqueId];
    }
    self.threads = threads.copy;
    
    // mappings
    self.messageMappings =
    [[YapDatabaseViewMappings alloc] initWithGroups:threadIds.copy view:TSMessageDatabaseViewExtensionName];
    [self.uiDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        [self.messageMappings updateWithTransaction:transaction];
    }];
    NSLog(@"total messages %ld", [self.messageMappings numberOfItemsInAllGroups]);
}

- (void)searchForText:(NSString *)searchText {
    NSString *text = searchText.lowercaseString;
    NSMutableArray *results = [NSMutableArray new];
    for (TSThread *thread in self.threads) {
        // check thread name
        if ([thread.name.lowercaseString containsString:text]) {
            SearchResult *result = [SearchResult new];
            result.thread = thread;
            [results addObject:result];
        }
        if (thread.isGroupThread) {
            TSGroupThread *group = (TSGroupThread *)thread;
            for (NSString *memberId in group.groupModel.groupMemberIds) {
                NSString *memberName = self.memberNameCache[memberId];
                // if member name is not cached, get from contacts manager
                if (!memberName) {
                    memberName = [[Environment getCurrent].contactsManager nameStringForPhoneIdentifier:memberId];
                    self.memberNameCache[memberId] = memberName;
                }
                if ([memberName.lowercaseString containsString:text]) {
                    SearchResult *result = [SearchResult new];
                    result.thread = thread;
                    [results addObject:result];
                    break;
                }
            }
        }
        
        // search messages
        NSInteger count = [self.messageMappings numberOfItemsInGroup:thread.uniqueId];
        for (NSInteger i = 0; i < count; i++) {
            // TODO: we can also store this index in search result so we can scroll to the appropriate message
            TSInteraction *interaction = [self interactionForGroup:thread.uniqueId index:i];
            if ([interaction isKindOfClass:[TSIncomingMessage class]]) {
                TSIncomingMessage *message = (TSIncomingMessage *)interaction;
                if ([message.body.lowercaseString containsString:text]) {
                    SearchResult *result = [SearchResult new];
                    result.interaction = message;
                    result.thread = thread;
                    [results addObject:result];
                }
            } else if ([interaction isKindOfClass:[TSOutgoingMessage class]]) {
                TSOutgoingMessage *message = (TSOutgoingMessage *)interaction;
                if ([message.body.lowercaseString containsString:text]) {
                    SearchResult *result = [SearchResult new];
                    result.interaction = message;
                    result.thread = thread;
                    [results addObject:result];
                }
            }
        }
    }
    NSLog(@"found %ld results", results.count);
    [self.results removeAllObjects];
    [self.results addObjectsFromArray:results];
    [self.tableView reloadData];
}

- (TSInteraction *)interactionForGroup:(NSString *)group index:(NSInteger) index {
    __block TSInteraction *message = nil;
    [self.uiDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        YapDatabaseViewTransaction *viewTransaction = [transaction ext:TSMessageDatabaseViewExtensionName];
        message = [viewTransaction objectAtIndex:index inGroup:group];
//        message = [viewTransaction objectAtRow:indexPath.row inSection:indexPath.section withMappings:self.messageMappings];
    }];
    
    return message;
}

- (BOOL)isSearching {
    return self.searchController.searchBar.text.length > 0;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isSearching) {
        return 1;
    }
    return (NSInteger)[self.threadMappings numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearching) {
        return self.results.count;
    }
    return (NSInteger)[self.threadMappings numberOfItemsInSection:(NSUInteger)section];
}

- (InboxTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSearching) {
        InboxTableViewCell *cell =
        [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InboxTableViewCell class])];
        if (!cell) {
            cell = [InboxTableViewCell inboxTableViewCell];
        }
        SearchResult *result = self.results[indexPath.row];
        [cell configureWithThread:result.thread];
        
        if ([result.interaction isKindOfClass:[TSIncomingMessage class]]) {
            TSIncomingMessage *message = (TSIncomingMessage *)result.interaction;
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.snippetLabel.text = message.body;
            });
        } else if ([result.interaction isKindOfClass:[TSOutgoingMessage class]]) {
            TSOutgoingMessage *message = (TSOutgoingMessage *)result.interaction;
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.snippetLabel.text = message.body;
            });
        }
        return cell;
    }
    InboxTableViewCell *cell =
        [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InboxTableViewCell class])];
    TSThread *thread = [self threadForIndexPath:indexPath];

    if (!cell) {
        cell = [InboxTableViewCell inboxTableViewCell];
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [cell configureWithThread:thread];
    });

    if ((unsigned long)indexPath.row == [self.threadMappings numberOfItemsInSection:0] - 1) {
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
    }

    return cell;
}

- (TSThread *)threadForIndexPath:(NSIndexPath *)indexPath {
    __block TSThread *thread = nil;
    [self.uiDatabaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
      thread = [[transaction extension:TSThreadDatabaseViewExtensionName] objectAtIndexPath:indexPath
                                                                               withMappings:self.threadMappings];
    }];

    return thread;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

#pragma mark Table Swipe to Delete

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
    return;
}


- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction =
        [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                           title:NSLocalizedString(@"TXT_DELETE_TITLE", nil)
                                         handler:^(UITableViewRowAction *action, NSIndexPath *swipedIndexPath) {
                                           [self tableViewCellTappedDelete:swipedIndexPath];
                                         }];

    UITableViewRowAction *archiveAction;
    if (self.viewingThreadsIn == kInboxState) {
        archiveAction = [UITableViewRowAction
            rowActionWithStyle:UITableViewRowActionStyleNormal
                         title:NSLocalizedString(@"ARCHIVE_ACTION", @"Pressing this button moves a thread from the inbox to the archive")
                       handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull tappedIndexPath) {
                         [self archiveIndexPath:tappedIndexPath];
                         [Environment.preferences setHasArchivedAMessage:YES];
                       }];

    } else {
        archiveAction = [UITableViewRowAction
            rowActionWithStyle:UITableViewRowActionStyleNormal
                         title:NSLocalizedString(@"UNARCHIVE_ACTION", @"Pressing this button moves an archived thread from the archive back to the inbox")
                       handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull tappedIndexPath) {
                         [self archiveIndexPath:tappedIndexPath];
                       }];
    }


    return @[ deleteAction, archiveAction ];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - HomeFeedTableViewCellDelegate

- (void)tableViewCellTappedDelete:(NSIndexPath *)indexPath {
    TSThread *thread = [self threadForIndexPath:indexPath];
    if ([thread isKindOfClass:[TSGroupThread class]]) {
        UIAlertController *removingFromGroup = [UIAlertController
            alertControllerWithTitle:[NSString
                                         stringWithFormat:NSLocalizedString(@"GROUP_REMOVING", nil), [thread name]]
                             message:nil
                      preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:removingFromGroup animated:YES completion:nil];

        TSOutgoingMessage *message = [[TSOutgoingMessage alloc] initWithTimestamp:[NSDate ows_millisecondTimeStamp]
                                                                         inThread:thread
                                                                      messageBody:@""
                                                                    attachmentIds:[NSMutableArray new]];
        message.groupMetaMessage = TSGroupMessageQuit;
        [[TSMessagesManager sharedManager] sendMessage:message
            inThread:thread
            success:^{
              [self dismissViewControllerAnimated:YES
                                       completion:^{
                                         [self deleteThread:thread];
                                       }];
            }
            failure:^{
              [self dismissViewControllerAnimated:YES
                                       completion:^{
                                         SignalAlertView(NSLocalizedString(@"GROUP_REMOVING_FAILED", nil),
                                                         NSLocalizedString(@"NETWORK_ERROR_RECOVERY", nil));
                                       }];
            }];
    } else {
        [self deleteThread:thread];
    }
}

- (void)deleteThread:(TSThread *)thread {
    [self.editingDbConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
      [thread removeWithTransaction:transaction];
    }];

    _inboxCount -= (self.viewingThreadsIn == kArchiveState) ? 1 : 0;
    [self checkIfEmptyView];
}

- (void)archiveIndexPath:(NSIndexPath *)indexPath {
    TSThread *thread = [self threadForIndexPath:indexPath];

    BOOL viewingThreadsIn = self.viewingThreadsIn;
    [self.editingDbConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
      viewingThreadsIn == kInboxState ? [thread archiveThreadWithTransaction:transaction]
                                      : [thread unarchiveThreadWithTransaction:transaction];

    }];
    [self checkIfEmptyView];
}

- (NSNumber *)updateInboxCountLabel {
    NSUInteger numberOfItems = [[TSMessagesManager sharedManager] unreadMessagesCount];
    NSNumber *badgeNumber    = [NSNumber numberWithUnsignedInteger:numberOfItems];
    NSString *unreadString   = NSLocalizedString(@"WHISPER_NAV_BAR_TITLE", nil);

    if (![badgeNumber isEqualToNumber:@0]) {
        NSString *badgeValue = [badgeNumber stringValue];
        unreadString         = [unreadString stringByAppendingFormat:@" (%@)", badgeValue];
        if (![[_segmentedControl titleForSegmentAtIndex:0] containsString:unreadString]) {
            AudioServicesPlaySystemSound(1315);
        }
    }
    [_segmentedControl setTitle:unreadString forSegmentAtIndex:0];
    [_segmentedControl reloadInputViews];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber.integerValue];

    return badgeNumber;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TSThread *thread = [self threadForIndexPath:indexPath];
    [self presentThread:thread keyboardOnViewAppearing:NO];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)presentThread:(TSThread *)thread keyboardOnViewAppearing:(BOOL)keyboardOnViewAppearing {
    [self presentThread:thread keyboardOnViewAppearing:keyboardOnViewAppearing withData:nil];
}

- (void)presentThread:(TSThread *)thread keyboardOnViewAppearing:(BOOL)keyboardOnViewAppearing withData:(id)data {
    dispatch_async(dispatch_get_main_queue(), ^{
        MessagesViewController *mvc = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:NULL]
                                       instantiateViewControllerWithIdentifier:@"MessagesViewController"];
        
        if (self.presentedViewController) {
            [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
        NSInteger unreadCount = [[TSMessagesManager sharedManager] unreadMessagesInThread:thread];
        mvc.unreadMessages = unreadCount;
        [mvc configureForThread:thread keyboardOnViewAppearing:keyboardOnViewAppearing];
        [mvc handleForwardedData:data];
        [self.navigationController pushViewController:mvc animated:YES];
    });
}

#pragma mark - Search bar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self searchForText:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar setText:nil];
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self.results removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kCallSegue]) {
        InCallViewController *vc = [segue destinationViewController];
        [vc configureWithLatestCall:_latestCall];
        _latestCall = nil;
    }
    if ([segue.identifier isEqualToString:@"composeNew"]) {
        UINavigationController *nav = segue.destinationViewController;
        MessageComposeTableViewController *vc = nav.viewControllers.firstObject;
        // don't pass buttons
        if (![sender isKindOfClass:[UIBarButtonItem class]]) {
            vc.forwardedData = sender;
        }
    }
}

#pragma mark - IBAction

- (IBAction)selectedInbox:(id)sender {
    self.viewingThreadsIn = kInboxState;
    [self changeToGrouping:TSInboxGroup];
}

- (IBAction)selectedArchive:(id)sender {
    self.viewingThreadsIn = kArchiveState;
    [self changeToGrouping:TSArchiveGroup];
}

- (void)changeToGrouping:(NSString *)grouping {
    self.threadMappings =
        [[YapDatabaseViewMappings alloc] initWithGroups:@[ grouping ] view:TSThreadDatabaseViewExtensionName];
    [self.threadMappings setIsReversed:YES forGroup:grouping];

    [self.uiDatabaseConnection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
      [self.threadMappings updateWithTransaction:transaction];

      dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self checkIfEmptyView];
      });
    }];
}

#pragma mark Database delegates

- (YapDatabaseConnection *)uiDatabaseConnection {
    NSAssert([NSThread isMainThread], @"Must access uiDatabaseConnection on main thread!");
    if (!_uiDatabaseConnection) {
        YapDatabase *database = TSStorageManager.sharedManager.database;
        _uiDatabaseConnection = [database newConnection];
        [_uiDatabaseConnection beginLongLivedReadTransaction];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(yapDatabaseModified:)
                                                     name:YapDatabaseModifiedNotification
                                                   object:database];
    }
    return _uiDatabaseConnection;
}

- (void)yapDatabaseModified:(NSNotification *)notification {
    NSArray *notifications  = [self.uiDatabaseConnection beginLongLivedReadTransaction];
    NSArray *sectionChanges = nil;
    NSArray *rowChanges     = nil;

    [[self.uiDatabaseConnection ext:TSThreadDatabaseViewExtensionName] getSectionChanges:&sectionChanges
                                                                              rowChanges:&rowChanges
                                                                        forNotifications:notifications
                                                                            withMappings:self.threadMappings];

    if ([sectionChanges count] == 0 && [rowChanges count] == 0) {
        return;
    }

    [self.tableView beginUpdates];

    for (YapDatabaseViewSectionChange *sectionChange in sectionChanges) {
        switch (sectionChange.type) {
            case YapDatabaseViewChangeDelete: {
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionChange.index]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeInsert: {
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionChange.index]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeUpdate:
            case YapDatabaseViewChangeMove:
                break;
        }
    }

    for (YapDatabaseViewRowChange *rowChange in rowChanges) {
        switch (rowChange.type) {
            case YapDatabaseViewChangeDelete: {
                [self.tableView deleteRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                _inboxCount += (self.viewingThreadsIn == kArchiveState) ? 1 : 0;
                break;
            }
            case YapDatabaseViewChangeInsert: {
                [self.tableView insertRowsAtIndexPaths:@[ rowChange.newIndexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                _inboxCount -= (self.viewingThreadsIn == kArchiveState) ? 1 : 0;
                break;
            }
            case YapDatabaseViewChangeMove: {
                [self.tableView deleteRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView insertRowsAtIndexPaths:@[ rowChange.newIndexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeUpdate: {
                [self.tableView reloadRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }

    [self.tableView endUpdates];
    [self updateInboxCountLabel];
    [self checkIfEmptyView];
}


- (IBAction)unwindSettingsDone:(UIStoryboardSegue *)segue {
}

- (IBAction)unwindMessagesView:(UIStoryboardSegue *)segue {
}

- (void)checkIfEmptyView {
    [_tableView setHidden:NO];
    if (self.viewingThreadsIn == kInboxState && [self.threadMappings numberOfItemsInGroup:TSInboxGroup] == 0) {
        [self setEmptyBoxText];
        [_tableView setHidden:YES];
    } else if (self.viewingThreadsIn == kArchiveState &&
               [self.threadMappings numberOfItemsInGroup:TSArchiveGroup] == 0) {
        [self setEmptyBoxText];
        [_tableView setHidden:YES];
    }
}

- (void)setEmptyBoxText {
    _emptyBoxLabel.textColor     = [UIColor grayColor];
    _emptyBoxLabel.font          = [UIFont ows_regularFontWithSize:18.f];
    _emptyBoxLabel.textAlignment = NSTextAlignmentCenter;
    _emptyBoxLabel.numberOfLines = 4;

    NSString *firstLine  = @"";
    NSString *secondLine = @"";

    if (self.viewingThreadsIn == kInboxState) {
        if ([Environment.preferences getHasSentAMessage]) {
            firstLine  = NSLocalizedString(@"EMPTY_INBOX_FIRST_TITLE", @"");
            secondLine = NSLocalizedString(@"EMPTY_INBOX_FIRST_TEXT", @"");
        } else {
            firstLine  = NSLocalizedString(@"EMPTY_ARCHIVE_FIRST_TITLE", @"");
            secondLine = NSLocalizedString(@"EMPTY_ARCHIVE_FIRST_TEXT", @"");
        }
    } else {
        if ([Environment.preferences getHasArchivedAMessage]) {
            firstLine  = NSLocalizedString(@"EMPTY_INBOX_TITLE", @"");
            secondLine = NSLocalizedString(@"EMPTY_INBOX_TEXT", @"");
        } else {
            firstLine  = NSLocalizedString(@"EMPTY_ARCHIVE_TITLE", @"");
            secondLine = NSLocalizedString(@"EMPTY_ARCHIVE_TEXT", @"");
        }
    }
    NSMutableAttributedString *fullLabelString =
        [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", firstLine, secondLine]];

    [fullLabelString addAttribute:NSFontAttributeName
                            value:[UIFont ows_boldFontWithSize:15.f]
                            range:NSMakeRange(0, firstLine.length)];
    [fullLabelString addAttribute:NSFontAttributeName
                            value:[UIFont ows_regularFontWithSize:14.f]
                            range:NSMakeRange(firstLine.length + 1, secondLine.length)];
    [fullLabelString addAttribute:NSForegroundColorAttributeName
                            value:[UIColor blackColor]
                            range:NSMakeRange(0, firstLine.length)];
    [fullLabelString addAttribute:NSForegroundColorAttributeName
                            value:[UIColor ows_darkGrayColor]
                            range:NSMakeRange(firstLine.length + 1, secondLine.length)];
    _emptyBoxLabel.attributedText = fullLabelString;
}

@end
