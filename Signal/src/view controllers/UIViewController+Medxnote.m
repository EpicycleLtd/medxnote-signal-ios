//
//  UIViewController+Medxnote.m
//  Medxnote
//
//  Created by Jan Nemecek on 14/7/17.
//  Copyright © 2017 Open Whisper Systems. All rights reserved.
//

#import "UIViewController+Medxnote.h"
#import "ABPadLockScreenSetupViewController.h"
#import "ABPadLockScreenViewController.h"

@implementation UIViewController (Medxnote)

- (void)showPasscodeAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Please set up an App PIN Lock. If you forget your PIN or enter it incorrectly 20 times, you will have to delete and reinstall the app to restore access to the service" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)showPasscodeCreationScreen {
    ABPadLockScreenSetupViewController *lockScreen = [[ABPadLockScreenSetupViewController alloc] initWithDelegate:self complexPin:YES subtitleLabelText:@"Please enter new passcode"];
    lockScreen.tapSoundEnabled = YES;
    lockScreen.errorVibrateEnabled = YES;
    
    lockScreen.modalPresentationStyle = UIModalPresentationPopover;
    lockScreen.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:lockScreen animated:NO completion:^{
        [lockScreen showPasscodeAlert];
    }];
}

@end
