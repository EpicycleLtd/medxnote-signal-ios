//
//  PasscodeHelper.h
//  Medxnote
//
//  Created by Jan Nemecek on 6/9/17.
//  Copyright © 2017 Open Whisper Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TOPasscodeViewController.h"

#define MedxMinimumPasscodeLength 6

typedef NS_ENUM(NSUInteger, PasscodeHelperAction) {
    PasscodeHelperActionCheckPasscode,
    PasscodeHelperActionEnablePasscode,
    PasscodeHelperActionDisablePasscode,
    PasscodeHelperActionChangePasscode
};

@interface PasscodeHelper : NSObject

@property BOOL cancelDisabled;

- (TOPasscodeViewController *)initiateAction:(PasscodeHelperAction)action from:(UIViewController *)vc completion:(void (^)())completion;

@end
