//
//  PasscodeHelper.h
//  Medxnote
//
//  Created by Jan Nemecek on 6/9/17.
//  Copyright © 2017 Open Whisper Systems. All rights reserved.
//

typedef NS_ENUM(NSUInteger, PasscodeHelperAction) {
    PasscodeHelperActionCheckPasscode,
    PasscodeHelperActionEnablePasscode,
    PasscodeHelperActionDisablePasscode,
    PasscodeHelperActionChangePasscode
};

#import <UIKit/UIKit.h>

@interface PasscodeHelper : NSObject

- (void)initiateAction:(PasscodeHelperAction)action from:(UIViewController *)vc completion:(void (^)())completion;

@end
