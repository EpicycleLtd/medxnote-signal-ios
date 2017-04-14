//
//  InlineKeyboard.h
//  Medxnote
//
//  Created by Jan Nemecek on 13/4/17.
//  Copyright © 2017 Open Whisper Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InlineKeyboardDelegate <NSObject>

- (void)tappedInlineKeyboardCell:(NSDictionary *)cell;

@end

@interface InlineKeyboard : NSObject
    
@property (nonatomic, weak) id<InlineKeyboardDelegate> delegate;
@property UICollectionView *collectionView;
    
- (instancetype)initWithAnswers:(NSArray *)answers;

@end
