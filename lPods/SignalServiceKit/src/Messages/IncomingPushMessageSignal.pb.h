// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import <ProtocolBuffers/ProtocolBuffers.h>

// @@protoc_insertion_point(imports)

@class Content;
@class ContentBuilder;
@class IncomingPushMessageSignal;
@class IncomingPushMessageSignalBuilder;
@class PredefinedAnswers;
@class PredefinedAnswersBuilder;
@class PushMessageContent;
@class PushMessageContentAttachmentPointer;
@class PushMessageContentAttachmentPointerBuilder;
@class PushMessageContentBuilder;
@class PushMessageContentGroupContext;
@class PushMessageContentGroupContextBuilder;
@class SyncMessage;
@class SyncMessageBuilder;
@class SyncMessageContacts;
@class SyncMessageContactsBuilder;
@class SyncMessageGroups;
@class SyncMessageGroupsBuilder;
@class SyncMessageRead;
@class SyncMessageReadBuilder;
@class SyncMessageRequest;
@class SyncMessageRequestBuilder;
@class SyncMessageSent;
@class SyncMessageSentBuilder;


typedef NS_ENUM(SInt32, IncomingPushMessageSignalType) {
  IncomingPushMessageSignalTypeUnknown = 0,
  IncomingPushMessageSignalTypeCiphertext = 1,
  IncomingPushMessageSignalTypeKeyExchange = 2,
  IncomingPushMessageSignalTypePrekeyBundle = 3,
  IncomingPushMessageSignalTypeReceipt = 5,
  IncomingPushMessageSignalTypeRead = 6,
};

BOOL IncomingPushMessageSignalTypeIsValidValue(IncomingPushMessageSignalType value);
NSString *NSStringFromIncomingPushMessageSignalType(IncomingPushMessageSignalType value);

typedef NS_ENUM(SInt32, PushMessageContentFlags) {
  PushMessageContentFlagsEndSession = 1,
};

BOOL PushMessageContentFlagsIsValidValue(PushMessageContentFlags value);
NSString *NSStringFromPushMessageContentFlags(PushMessageContentFlags value);

typedef NS_ENUM(SInt32, PushMessageContentGroupContextType) {
  PushMessageContentGroupContextTypeUnknown = 0,
  PushMessageContentGroupContextTypeUpdate = 1,
  PushMessageContentGroupContextTypeDeliver = 2,
  PushMessageContentGroupContextTypeQuit = 3,
};

BOOL PushMessageContentGroupContextTypeIsValidValue(PushMessageContentGroupContextType value);
NSString *NSStringFromPushMessageContentGroupContextType(PushMessageContentGroupContextType value);

typedef NS_ENUM(SInt32, SyncMessageRequestType) {
  SyncMessageRequestTypeUnknown = 0,
  SyncMessageRequestTypeContacts = 1,
  SyncMessageRequestTypeGroups = 2,
};

BOOL SyncMessageRequestTypeIsValidValue(SyncMessageRequestType value);
NSString *NSStringFromSyncMessageRequestType(SyncMessageRequestType value);


@interface IncomingPushMessageSignalRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

#define IncomingPushMessageSignal_type @"type"
#define IncomingPushMessageSignal_source @"source"
#define IncomingPushMessageSignal_sourceDevice @"sourceDevice"
#define IncomingPushMessageSignal_relay @"relay"
#define IncomingPushMessageSignal_timestamp @"timestamp"
#define IncomingPushMessageSignal_message @"message"
#define IncomingPushMessageSignal_content @"content"
#define IncomingPushMessageSignal_deliveryTimestamp @"deliveryTimestamp"
@interface IncomingPushMessageSignal : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasTimestamp_:1;
  BOOL hasDeliveryTimestamp_:1;
  BOOL hasSource_:1;
  BOOL hasRelay_:1;
  BOOL hasMessage_:1;
  BOOL hasContent_:1;
  BOOL hasSourceDevice_:1;
  BOOL hasType_:1;
  UInt64 timestamp;
  UInt64 deliveryTimestamp;
  NSString* source;
  NSString* relay;
  NSData* message;
  NSData* content;
  UInt32 sourceDevice;
  IncomingPushMessageSignalType type;
}
- (BOOL) hasType;
- (BOOL) hasSource;
- (BOOL) hasSourceDevice;
- (BOOL) hasRelay;
- (BOOL) hasTimestamp;
- (BOOL) hasMessage;
- (BOOL) hasContent;
- (BOOL) hasDeliveryTimestamp;
@property (readonly) IncomingPushMessageSignalType type;
@property (readonly, strong) NSString* source;
@property (readonly) UInt32 sourceDevice;
@property (readonly, strong) NSString* relay;
@property (readonly) UInt64 timestamp;
@property (readonly, strong) NSData* message;
@property (readonly, strong) NSData* content;
@property (readonly) UInt64 deliveryTimestamp;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (IncomingPushMessageSignalBuilder*) builder;
+ (IncomingPushMessageSignalBuilder*) builder;
+ (IncomingPushMessageSignalBuilder*) builderWithPrototype:(IncomingPushMessageSignal*) prototype;
- (IncomingPushMessageSignalBuilder*) toBuilder;

+ (IncomingPushMessageSignal*) parseFromData:(NSData*) data;
+ (IncomingPushMessageSignal*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (IncomingPushMessageSignal*) parseFromInputStream:(NSInputStream*) input;
+ (IncomingPushMessageSignal*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (IncomingPushMessageSignal*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (IncomingPushMessageSignal*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface IncomingPushMessageSignalBuilder : PBGeneratedMessageBuilder {
@private
  IncomingPushMessageSignal* resultIncomingPushMessageSignal;
}

- (IncomingPushMessageSignal*) defaultInstance;

- (IncomingPushMessageSignalBuilder*) clear;
- (IncomingPushMessageSignalBuilder*) clone;

- (IncomingPushMessageSignal*) build;
- (IncomingPushMessageSignal*) buildPartial;

- (IncomingPushMessageSignalBuilder*) mergeFrom:(IncomingPushMessageSignal*) other;
- (IncomingPushMessageSignalBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (IncomingPushMessageSignalBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasType;
- (IncomingPushMessageSignalType) type;
- (IncomingPushMessageSignalBuilder*) setType:(IncomingPushMessageSignalType) value;
- (IncomingPushMessageSignalBuilder*) clearType;

- (BOOL) hasSource;
- (NSString*) source;
- (IncomingPushMessageSignalBuilder*) setSource:(NSString*) value;
- (IncomingPushMessageSignalBuilder*) clearSource;

- (BOOL) hasSourceDevice;
- (UInt32) sourceDevice;
- (IncomingPushMessageSignalBuilder*) setSourceDevice:(UInt32) value;
- (IncomingPushMessageSignalBuilder*) clearSourceDevice;

- (BOOL) hasRelay;
- (NSString*) relay;
- (IncomingPushMessageSignalBuilder*) setRelay:(NSString*) value;
- (IncomingPushMessageSignalBuilder*) clearRelay;

- (BOOL) hasTimestamp;
- (UInt64) timestamp;
- (IncomingPushMessageSignalBuilder*) setTimestamp:(UInt64) value;
- (IncomingPushMessageSignalBuilder*) clearTimestamp;

- (BOOL) hasMessage;
- (NSData*) message;
- (IncomingPushMessageSignalBuilder*) setMessage:(NSData*) value;
- (IncomingPushMessageSignalBuilder*) clearMessage;

- (BOOL) hasContent;
- (NSData*) content;
- (IncomingPushMessageSignalBuilder*) setContent:(NSData*) value;
- (IncomingPushMessageSignalBuilder*) clearContent;

- (BOOL) hasDeliveryTimestamp;
- (UInt64) deliveryTimestamp;
- (IncomingPushMessageSignalBuilder*) setDeliveryTimestamp:(UInt64) value;
- (IncomingPushMessageSignalBuilder*) clearDeliveryTimestamp;
@end

#define Content_dataMessage @"dataMessage"
#define Content_syncMessage @"syncMessage"
@interface Content : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasDataMessage_:1;
  BOOL hasSyncMessage_:1;
  PushMessageContent* dataMessage;
  SyncMessage* syncMessage;
}
- (BOOL) hasDataMessage;
- (BOOL) hasSyncMessage;
@property (readonly, strong) PushMessageContent* dataMessage;
@property (readonly, strong) SyncMessage* syncMessage;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (ContentBuilder*) builder;
+ (ContentBuilder*) builder;
+ (ContentBuilder*) builderWithPrototype:(Content*) prototype;
- (ContentBuilder*) toBuilder;

+ (Content*) parseFromData:(NSData*) data;
+ (Content*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (Content*) parseFromInputStream:(NSInputStream*) input;
+ (Content*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (Content*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (Content*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface ContentBuilder : PBGeneratedMessageBuilder {
@private
  Content* resultContent;
}

- (Content*) defaultInstance;

- (ContentBuilder*) clear;
- (ContentBuilder*) clone;

- (Content*) build;
- (Content*) buildPartial;

- (ContentBuilder*) mergeFrom:(Content*) other;
- (ContentBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (ContentBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasDataMessage;
- (PushMessageContent*) dataMessage;
- (ContentBuilder*) setDataMessage:(PushMessageContent*) value;
- (ContentBuilder*) setDataMessageBuilder:(PushMessageContentBuilder*) builderForValue;
- (ContentBuilder*) mergeDataMessage:(PushMessageContent*) value;
- (ContentBuilder*) clearDataMessage;

- (BOOL) hasSyncMessage;
- (SyncMessage*) syncMessage;
- (ContentBuilder*) setSyncMessage:(SyncMessage*) value;
- (ContentBuilder*) setSyncMessageBuilder:(SyncMessageBuilder*) builderForValue;
- (ContentBuilder*) mergeSyncMessage:(SyncMessage*) value;
- (ContentBuilder*) clearSyncMessage;
@end

#define PushMessageContent_body @"body"
#define PushMessageContent_attachments @"attachments"
#define PushMessageContent_group @"group"
#define PushMessageContent_flags @"flags"
#define PushMessageContent_pa @"pa"
@interface PushMessageContent : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasBody_:1;
  BOOL hasGroup_:1;
  BOOL hasPa_:1;
  BOOL hasFlags_:1;
  NSString* body;
  PushMessageContentGroupContext* group;
  PredefinedAnswers* pa;
  UInt32 flags;
  NSMutableArray * attachmentsArray;
}
- (BOOL) hasBody;
- (BOOL) hasGroup;
- (BOOL) hasFlags;
- (BOOL) hasPa;
@property (readonly, strong) NSString* body;
@property (readonly, strong) NSArray<PushMessageContentAttachmentPointer*> * attachments;
@property (readonly, strong) PushMessageContentGroupContext* group;
@property (readonly) UInt32 flags;
@property (readonly, strong) PredefinedAnswers* pa;
- (PushMessageContentAttachmentPointer*)attachmentsAtIndex:(NSUInteger)index;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PushMessageContentBuilder*) builder;
+ (PushMessageContentBuilder*) builder;
+ (PushMessageContentBuilder*) builderWithPrototype:(PushMessageContent*) prototype;
- (PushMessageContentBuilder*) toBuilder;

+ (PushMessageContent*) parseFromData:(NSData*) data;
+ (PushMessageContent*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PushMessageContent*) parseFromInputStream:(NSInputStream*) input;
+ (PushMessageContent*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PushMessageContent*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PushMessageContent*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

#define AttachmentPointer_id @"id"
#define AttachmentPointer_contentType @"contentType"
#define AttachmentPointer_key @"key"
#define AttachmentPointer_size @"size"
#define AttachmentPointer_thumbnail @"thumbnail"
#define AttachmentPointer_digest @"digest"
@interface PushMessageContentAttachmentPointer : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasId_:1;
  BOOL hasContentType_:1;
  BOOL hasKey_:1;
  BOOL hasThumbnail_:1;
  BOOL hasDigest_:1;
  BOOL hasSize_:1;
  UInt64 id;
  NSString* contentType;
  NSData* key;
  NSData* thumbnail;
  NSData* digest;
  UInt32 size;
}
- (BOOL) hasId;
- (BOOL) hasContentType;
- (BOOL) hasKey;
- (BOOL) hasSize;
- (BOOL) hasThumbnail;
- (BOOL) hasDigest;
@property (readonly) UInt64 id;
@property (readonly, strong) NSString* contentType;
@property (readonly, strong) NSData* key;
@property (readonly) UInt32 size;
@property (readonly, strong) NSData* thumbnail;
@property (readonly, strong) NSData* digest;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PushMessageContentAttachmentPointerBuilder*) builder;
+ (PushMessageContentAttachmentPointerBuilder*) builder;
+ (PushMessageContentAttachmentPointerBuilder*) builderWithPrototype:(PushMessageContentAttachmentPointer*) prototype;
- (PushMessageContentAttachmentPointerBuilder*) toBuilder;

+ (PushMessageContentAttachmentPointer*) parseFromData:(NSData*) data;
+ (PushMessageContentAttachmentPointer*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PushMessageContentAttachmentPointer*) parseFromInputStream:(NSInputStream*) input;
+ (PushMessageContentAttachmentPointer*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PushMessageContentAttachmentPointer*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PushMessageContentAttachmentPointer*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PushMessageContentAttachmentPointerBuilder : PBGeneratedMessageBuilder {
@private
  PushMessageContentAttachmentPointer* resultAttachmentPointer;
}

- (PushMessageContentAttachmentPointer*) defaultInstance;

- (PushMessageContentAttachmentPointerBuilder*) clear;
- (PushMessageContentAttachmentPointerBuilder*) clone;

- (PushMessageContentAttachmentPointer*) build;
- (PushMessageContentAttachmentPointer*) buildPartial;

- (PushMessageContentAttachmentPointerBuilder*) mergeFrom:(PushMessageContentAttachmentPointer*) other;
- (PushMessageContentAttachmentPointerBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PushMessageContentAttachmentPointerBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasId;
- (UInt64) id;
- (PushMessageContentAttachmentPointerBuilder*) setId:(UInt64) value;
- (PushMessageContentAttachmentPointerBuilder*) clearId;

- (BOOL) hasContentType;
- (NSString*) contentType;
- (PushMessageContentAttachmentPointerBuilder*) setContentType:(NSString*) value;
- (PushMessageContentAttachmentPointerBuilder*) clearContentType;

- (BOOL) hasKey;
- (NSData*) key;
- (PushMessageContentAttachmentPointerBuilder*) setKey:(NSData*) value;
- (PushMessageContentAttachmentPointerBuilder*) clearKey;

- (BOOL) hasSize;
- (UInt32) size;
- (PushMessageContentAttachmentPointerBuilder*) setSize:(UInt32) value;
- (PushMessageContentAttachmentPointerBuilder*) clearSize;

- (BOOL) hasThumbnail;
- (NSData*) thumbnail;
- (PushMessageContentAttachmentPointerBuilder*) setThumbnail:(NSData*) value;
- (PushMessageContentAttachmentPointerBuilder*) clearThumbnail;

- (BOOL) hasDigest;
- (NSData*) digest;
- (PushMessageContentAttachmentPointerBuilder*) setDigest:(NSData*) value;
- (PushMessageContentAttachmentPointerBuilder*) clearDigest;
@end

#define GroupContext_id @"id"
#define GroupContext_type @"type"
#define GroupContext_name @"name"
#define GroupContext_members @"members"
#define GroupContext_avatar @"avatar"
@interface PushMessageContentGroupContext : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasName_:1;
  BOOL hasAvatar_:1;
  BOOL hasId_:1;
  BOOL hasType_:1;
  NSString* name;
  PushMessageContentAttachmentPointer* avatar;
  NSData* id;
  PushMessageContentGroupContextType type;
  NSMutableArray * membersArray;
}
- (BOOL) hasId;
- (BOOL) hasType;
- (BOOL) hasName;
- (BOOL) hasAvatar;
@property (readonly, strong) NSData* id;
@property (readonly) PushMessageContentGroupContextType type;
@property (readonly, strong) NSString* name;
@property (readonly, strong) NSArray * members;
@property (readonly, strong) PushMessageContentAttachmentPointer* avatar;
- (NSString*)membersAtIndex:(NSUInteger)index;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PushMessageContentGroupContextBuilder*) builder;
+ (PushMessageContentGroupContextBuilder*) builder;
+ (PushMessageContentGroupContextBuilder*) builderWithPrototype:(PushMessageContentGroupContext*) prototype;
- (PushMessageContentGroupContextBuilder*) toBuilder;

+ (PushMessageContentGroupContext*) parseFromData:(NSData*) data;
+ (PushMessageContentGroupContext*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PushMessageContentGroupContext*) parseFromInputStream:(NSInputStream*) input;
+ (PushMessageContentGroupContext*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PushMessageContentGroupContext*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PushMessageContentGroupContext*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PushMessageContentGroupContextBuilder : PBGeneratedMessageBuilder {
@private
  PushMessageContentGroupContext* resultGroupContext;
}

- (PushMessageContentGroupContext*) defaultInstance;

- (PushMessageContentGroupContextBuilder*) clear;
- (PushMessageContentGroupContextBuilder*) clone;

- (PushMessageContentGroupContext*) build;
- (PushMessageContentGroupContext*) buildPartial;

- (PushMessageContentGroupContextBuilder*) mergeFrom:(PushMessageContentGroupContext*) other;
- (PushMessageContentGroupContextBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PushMessageContentGroupContextBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasId;
- (NSData*) id;
- (PushMessageContentGroupContextBuilder*) setId:(NSData*) value;
- (PushMessageContentGroupContextBuilder*) clearId;

- (BOOL) hasType;
- (PushMessageContentGroupContextType) type;
- (PushMessageContentGroupContextBuilder*) setType:(PushMessageContentGroupContextType) value;
- (PushMessageContentGroupContextBuilder*) clearType;

- (BOOL) hasName;
- (NSString*) name;
- (PushMessageContentGroupContextBuilder*) setName:(NSString*) value;
- (PushMessageContentGroupContextBuilder*) clearName;

- (NSMutableArray *)members;
- (NSString*)membersAtIndex:(NSUInteger)index;
- (PushMessageContentGroupContextBuilder *)addMembers:(NSString*)value;
- (PushMessageContentGroupContextBuilder *)setMembersArray:(NSArray *)array;
- (PushMessageContentGroupContextBuilder *)clearMembers;

- (BOOL) hasAvatar;
- (PushMessageContentAttachmentPointer*) avatar;
- (PushMessageContentGroupContextBuilder*) setAvatar:(PushMessageContentAttachmentPointer*) value;
- (PushMessageContentGroupContextBuilder*) setAvatarBuilder:(PushMessageContentAttachmentPointerBuilder*) builderForValue;
- (PushMessageContentGroupContextBuilder*) mergeAvatar:(PushMessageContentAttachmentPointer*) value;
- (PushMessageContentGroupContextBuilder*) clearAvatar;
@end

@interface PushMessageContentBuilder : PBGeneratedMessageBuilder {
@private
  PushMessageContent* resultPushMessageContent;
}

- (PushMessageContent*) defaultInstance;

- (PushMessageContentBuilder*) clear;
- (PushMessageContentBuilder*) clone;

- (PushMessageContent*) build;
- (PushMessageContent*) buildPartial;

- (PushMessageContentBuilder*) mergeFrom:(PushMessageContent*) other;
- (PushMessageContentBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PushMessageContentBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasBody;
- (NSString*) body;
- (PushMessageContentBuilder*) setBody:(NSString*) value;
- (PushMessageContentBuilder*) clearBody;

- (NSMutableArray<PushMessageContentAttachmentPointer*> *)attachments;
- (PushMessageContentAttachmentPointer*)attachmentsAtIndex:(NSUInteger)index;
- (PushMessageContentBuilder *)addAttachments:(PushMessageContentAttachmentPointer*)value;
- (PushMessageContentBuilder *)setAttachmentsArray:(NSArray<PushMessageContentAttachmentPointer*> *)array;
- (PushMessageContentBuilder *)clearAttachments;

- (BOOL) hasGroup;
- (PushMessageContentGroupContext*) group;
- (PushMessageContentBuilder*) setGroup:(PushMessageContentGroupContext*) value;
- (PushMessageContentBuilder*) setGroupBuilder:(PushMessageContentGroupContextBuilder*) builderForValue;
- (PushMessageContentBuilder*) mergeGroup:(PushMessageContentGroupContext*) value;
- (PushMessageContentBuilder*) clearGroup;

- (BOOL) hasFlags;
- (UInt32) flags;
- (PushMessageContentBuilder*) setFlags:(UInt32) value;
- (PushMessageContentBuilder*) clearFlags;

- (BOOL) hasPa;
- (PredefinedAnswers*) pa;
- (PushMessageContentBuilder*) setPa:(PredefinedAnswers*) value;
- (PushMessageContentBuilder*) setPaBuilder:(PredefinedAnswersBuilder*) builderForValue;
- (PushMessageContentBuilder*) mergePa:(PredefinedAnswers*) value;
- (PushMessageContentBuilder*) clearPa;
@end

#define PredefinedAnswers_type @"type"
#define PredefinedAnswers_data @"data"
@interface PredefinedAnswers : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasData_:1;
  BOOL hasType_:1;
  NSString* data;
  UInt32 type;
}
- (BOOL) hasType;
- (BOOL) hasData;
@property (readonly) UInt32 type;
@property (readonly, strong) NSString* data;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PredefinedAnswersBuilder*) builder;
+ (PredefinedAnswersBuilder*) builder;
+ (PredefinedAnswersBuilder*) builderWithPrototype:(PredefinedAnswers*) prototype;
- (PredefinedAnswersBuilder*) toBuilder;

+ (PredefinedAnswers*) parseFromData:(NSData*) data;
+ (PredefinedAnswers*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PredefinedAnswers*) parseFromInputStream:(NSInputStream*) input;
+ (PredefinedAnswers*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PredefinedAnswers*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PredefinedAnswers*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PredefinedAnswersBuilder : PBGeneratedMessageBuilder {
@private
  PredefinedAnswers* resultPredefinedAnswers;
}

- (PredefinedAnswers*) defaultInstance;

- (PredefinedAnswersBuilder*) clear;
- (PredefinedAnswersBuilder*) clone;

- (PredefinedAnswers*) build;
- (PredefinedAnswers*) buildPartial;

- (PredefinedAnswersBuilder*) mergeFrom:(PredefinedAnswers*) other;
- (PredefinedAnswersBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PredefinedAnswersBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasType;
- (UInt32) type;
- (PredefinedAnswersBuilder*) setType:(UInt32) value;
- (PredefinedAnswersBuilder*) clearType;

- (BOOL) hasData;
- (NSString*) data;
- (PredefinedAnswersBuilder*) setData:(NSString*) value;
- (PredefinedAnswersBuilder*) clearData;
@end

#define SyncMessage_sent @"sent"
#define SyncMessage_contacts @"contacts"
#define SyncMessage_groups @"groups"
#define SyncMessage_request @"request"
#define SyncMessage_read @"read"
@interface SyncMessage : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasSent_:1;
  BOOL hasContacts_:1;
  BOOL hasGroups_:1;
  BOOL hasRequest_:1;
  SyncMessageSent* sent;
  SyncMessageContacts* contacts;
  SyncMessageGroups* groups;
  SyncMessageRequest* request;
  NSMutableArray * readArray;
}
- (BOOL) hasSent;
- (BOOL) hasContacts;
- (BOOL) hasGroups;
- (BOOL) hasRequest;
@property (readonly, strong) SyncMessageSent* sent;
@property (readonly, strong) SyncMessageContacts* contacts;
@property (readonly, strong) SyncMessageGroups* groups;
@property (readonly, strong) SyncMessageRequest* request;
@property (readonly, strong) NSArray<SyncMessageRead*> * read;
- (SyncMessageRead*)readAtIndex:(NSUInteger)index;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (SyncMessageBuilder*) builder;
+ (SyncMessageBuilder*) builder;
+ (SyncMessageBuilder*) builderWithPrototype:(SyncMessage*) prototype;
- (SyncMessageBuilder*) toBuilder;

+ (SyncMessage*) parseFromData:(NSData*) data;
+ (SyncMessage*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SyncMessage*) parseFromInputStream:(NSInputStream*) input;
+ (SyncMessage*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SyncMessage*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (SyncMessage*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

#define Sent_destination @"destination"
#define Sent_timestamp @"timestamp"
#define Sent_message @"message"
@interface SyncMessageSent : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasTimestamp_:1;
  BOOL hasDestination_:1;
  BOOL hasMessage_:1;
  UInt64 timestamp;
  NSString* destination;
  PushMessageContent* message;
}
- (BOOL) hasDestination;
- (BOOL) hasTimestamp;
- (BOOL) hasMessage;
@property (readonly, strong) NSString* destination;
@property (readonly) UInt64 timestamp;
@property (readonly, strong) PushMessageContent* message;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (SyncMessageSentBuilder*) builder;
+ (SyncMessageSentBuilder*) builder;
+ (SyncMessageSentBuilder*) builderWithPrototype:(SyncMessageSent*) prototype;
- (SyncMessageSentBuilder*) toBuilder;

+ (SyncMessageSent*) parseFromData:(NSData*) data;
+ (SyncMessageSent*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SyncMessageSent*) parseFromInputStream:(NSInputStream*) input;
+ (SyncMessageSent*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SyncMessageSent*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (SyncMessageSent*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface SyncMessageSentBuilder : PBGeneratedMessageBuilder {
@private
  SyncMessageSent* resultSent;
}

- (SyncMessageSent*) defaultInstance;

- (SyncMessageSentBuilder*) clear;
- (SyncMessageSentBuilder*) clone;

- (SyncMessageSent*) build;
- (SyncMessageSent*) buildPartial;

- (SyncMessageSentBuilder*) mergeFrom:(SyncMessageSent*) other;
- (SyncMessageSentBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (SyncMessageSentBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasDestination;
- (NSString*) destination;
- (SyncMessageSentBuilder*) setDestination:(NSString*) value;
- (SyncMessageSentBuilder*) clearDestination;

- (BOOL) hasTimestamp;
- (UInt64) timestamp;
- (SyncMessageSentBuilder*) setTimestamp:(UInt64) value;
- (SyncMessageSentBuilder*) clearTimestamp;

- (BOOL) hasMessage;
- (PushMessageContent*) message;
- (SyncMessageSentBuilder*) setMessage:(PushMessageContent*) value;
- (SyncMessageSentBuilder*) setMessageBuilder:(PushMessageContentBuilder*) builderForValue;
- (SyncMessageSentBuilder*) mergeMessage:(PushMessageContent*) value;
- (SyncMessageSentBuilder*) clearMessage;
@end

#define Contacts_blob @"blob"
@interface SyncMessageContacts : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasBlob_:1;
  PushMessageContentAttachmentPointer* blob;
}
- (BOOL) hasBlob;
@property (readonly, strong) PushMessageContentAttachmentPointer* blob;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (SyncMessageContactsBuilder*) builder;
+ (SyncMessageContactsBuilder*) builder;
+ (SyncMessageContactsBuilder*) builderWithPrototype:(SyncMessageContacts*) prototype;
- (SyncMessageContactsBuilder*) toBuilder;

+ (SyncMessageContacts*) parseFromData:(NSData*) data;
+ (SyncMessageContacts*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SyncMessageContacts*) parseFromInputStream:(NSInputStream*) input;
+ (SyncMessageContacts*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SyncMessageContacts*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (SyncMessageContacts*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface SyncMessageContactsBuilder : PBGeneratedMessageBuilder {
@private
  SyncMessageContacts* resultContacts;
}

- (SyncMessageContacts*) defaultInstance;

- (SyncMessageContactsBuilder*) clear;
- (SyncMessageContactsBuilder*) clone;

- (SyncMessageContacts*) build;
- (SyncMessageContacts*) buildPartial;

- (SyncMessageContactsBuilder*) mergeFrom:(SyncMessageContacts*) other;
- (SyncMessageContactsBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (SyncMessageContactsBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasBlob;
- (PushMessageContentAttachmentPointer*) blob;
- (SyncMessageContactsBuilder*) setBlob:(PushMessageContentAttachmentPointer*) value;
- (SyncMessageContactsBuilder*) setBlobBuilder:(PushMessageContentAttachmentPointerBuilder*) builderForValue;
- (SyncMessageContactsBuilder*) mergeBlob:(PushMessageContentAttachmentPointer*) value;
- (SyncMessageContactsBuilder*) clearBlob;
@end

#define Groups_blob @"blob"
@interface SyncMessageGroups : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasBlob_:1;
  PushMessageContentAttachmentPointer* blob;
}
- (BOOL) hasBlob;
@property (readonly, strong) PushMessageContentAttachmentPointer* blob;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (SyncMessageGroupsBuilder*) builder;
+ (SyncMessageGroupsBuilder*) builder;
+ (SyncMessageGroupsBuilder*) builderWithPrototype:(SyncMessageGroups*) prototype;
- (SyncMessageGroupsBuilder*) toBuilder;

+ (SyncMessageGroups*) parseFromData:(NSData*) data;
+ (SyncMessageGroups*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SyncMessageGroups*) parseFromInputStream:(NSInputStream*) input;
+ (SyncMessageGroups*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SyncMessageGroups*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (SyncMessageGroups*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface SyncMessageGroupsBuilder : PBGeneratedMessageBuilder {
@private
  SyncMessageGroups* resultGroups;
}

- (SyncMessageGroups*) defaultInstance;

- (SyncMessageGroupsBuilder*) clear;
- (SyncMessageGroupsBuilder*) clone;

- (SyncMessageGroups*) build;
- (SyncMessageGroups*) buildPartial;

- (SyncMessageGroupsBuilder*) mergeFrom:(SyncMessageGroups*) other;
- (SyncMessageGroupsBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (SyncMessageGroupsBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasBlob;
- (PushMessageContentAttachmentPointer*) blob;
- (SyncMessageGroupsBuilder*) setBlob:(PushMessageContentAttachmentPointer*) value;
- (SyncMessageGroupsBuilder*) setBlobBuilder:(PushMessageContentAttachmentPointerBuilder*) builderForValue;
- (SyncMessageGroupsBuilder*) mergeBlob:(PushMessageContentAttachmentPointer*) value;
- (SyncMessageGroupsBuilder*) clearBlob;
@end

#define Request_type @"type"
@interface SyncMessageRequest : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasType_:1;
  SyncMessageRequestType type;
}
- (BOOL) hasType;
@property (readonly) SyncMessageRequestType type;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (SyncMessageRequestBuilder*) builder;
+ (SyncMessageRequestBuilder*) builder;
+ (SyncMessageRequestBuilder*) builderWithPrototype:(SyncMessageRequest*) prototype;
- (SyncMessageRequestBuilder*) toBuilder;

+ (SyncMessageRequest*) parseFromData:(NSData*) data;
+ (SyncMessageRequest*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SyncMessageRequest*) parseFromInputStream:(NSInputStream*) input;
+ (SyncMessageRequest*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SyncMessageRequest*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (SyncMessageRequest*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface SyncMessageRequestBuilder : PBGeneratedMessageBuilder {
@private
  SyncMessageRequest* resultRequest;
}

- (SyncMessageRequest*) defaultInstance;

- (SyncMessageRequestBuilder*) clear;
- (SyncMessageRequestBuilder*) clone;

- (SyncMessageRequest*) build;
- (SyncMessageRequest*) buildPartial;

- (SyncMessageRequestBuilder*) mergeFrom:(SyncMessageRequest*) other;
- (SyncMessageRequestBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (SyncMessageRequestBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasType;
- (SyncMessageRequestType) type;
- (SyncMessageRequestBuilder*) setType:(SyncMessageRequestType) value;
- (SyncMessageRequestBuilder*) clearType;
@end

#define Read_sender @"sender"
#define Read_timestamp @"timestamp"
@interface SyncMessageRead : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasTimestamp_:1;
  BOOL hasSender_:1;
  UInt64 timestamp;
  NSString* sender;
}
- (BOOL) hasSender;
- (BOOL) hasTimestamp;
@property (readonly, strong) NSString* sender;
@property (readonly) UInt64 timestamp;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (SyncMessageReadBuilder*) builder;
+ (SyncMessageReadBuilder*) builder;
+ (SyncMessageReadBuilder*) builderWithPrototype:(SyncMessageRead*) prototype;
- (SyncMessageReadBuilder*) toBuilder;

+ (SyncMessageRead*) parseFromData:(NSData*) data;
+ (SyncMessageRead*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SyncMessageRead*) parseFromInputStream:(NSInputStream*) input;
+ (SyncMessageRead*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SyncMessageRead*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (SyncMessageRead*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface SyncMessageReadBuilder : PBGeneratedMessageBuilder {
@private
  SyncMessageRead* resultRead;
}

- (SyncMessageRead*) defaultInstance;

- (SyncMessageReadBuilder*) clear;
- (SyncMessageReadBuilder*) clone;

- (SyncMessageRead*) build;
- (SyncMessageRead*) buildPartial;

- (SyncMessageReadBuilder*) mergeFrom:(SyncMessageRead*) other;
- (SyncMessageReadBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (SyncMessageReadBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (NSString*) sender;
- (SyncMessageReadBuilder*) setSender:(NSString*) value;
- (SyncMessageReadBuilder*) clearSender;

- (BOOL) hasTimestamp;
- (UInt64) timestamp;
- (SyncMessageReadBuilder*) setTimestamp:(UInt64) value;
- (SyncMessageReadBuilder*) clearTimestamp;
@end

@interface SyncMessageBuilder : PBGeneratedMessageBuilder {
@private
  SyncMessage* resultSyncMessage;
}

- (SyncMessage*) defaultInstance;

- (SyncMessageBuilder*) clear;
- (SyncMessageBuilder*) clone;

- (SyncMessage*) build;
- (SyncMessage*) buildPartial;

- (SyncMessageBuilder*) mergeFrom:(SyncMessage*) other;
- (SyncMessageBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (SyncMessageBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSent;
- (SyncMessageSent*) sent;
- (SyncMessageBuilder*) setSent:(SyncMessageSent*) value;
- (SyncMessageBuilder*) setSentBuilder:(SyncMessageSentBuilder*) builderForValue;
- (SyncMessageBuilder*) mergeSent:(SyncMessageSent*) value;
- (SyncMessageBuilder*) clearSent;

- (BOOL) hasContacts;
- (SyncMessageContacts*) contacts;
- (SyncMessageBuilder*) setContacts:(SyncMessageContacts*) value;
- (SyncMessageBuilder*) setContactsBuilder:(SyncMessageContactsBuilder*) builderForValue;
- (SyncMessageBuilder*) mergeContacts:(SyncMessageContacts*) value;
- (SyncMessageBuilder*) clearContacts;

- (BOOL) hasGroups;
- (SyncMessageGroups*) groups;
- (SyncMessageBuilder*) setGroups:(SyncMessageGroups*) value;
- (SyncMessageBuilder*) setGroupsBuilder:(SyncMessageGroupsBuilder*) builderForValue;
- (SyncMessageBuilder*) mergeGroups:(SyncMessageGroups*) value;
- (SyncMessageBuilder*) clearGroups;

- (BOOL) hasRequest;
- (SyncMessageRequest*) request;
- (SyncMessageBuilder*) setRequest:(SyncMessageRequest*) value;
- (SyncMessageBuilder*) setRequestBuilder:(SyncMessageRequestBuilder*) builderForValue;
- (SyncMessageBuilder*) mergeRequest:(SyncMessageRequest*) value;
- (SyncMessageBuilder*) clearRequest;

- (NSMutableArray<SyncMessageRead*> *)read;
- (SyncMessageRead*)readAtIndex:(NSUInteger)index;
- (SyncMessageBuilder *)addRead:(SyncMessageRead*)value;
- (SyncMessageBuilder *)setReadArray:(NSArray<SyncMessageRead*> *)array;
- (SyncMessageBuilder *)clearRead;
@end


// @@protoc_insertion_point(global_scope)
