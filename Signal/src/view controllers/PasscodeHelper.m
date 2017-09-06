//
//  PasscodeHelper.m
//  Medxnote
//
//  Created by Jan Nemecek on 6/9/17.
//  Copyright © 2017 Open Whisper Systems. All rights reserved.
//

#import "PasscodeHelper.h"
#import "TOPasscodeViewController.h"
#import "MedxPasscodeManager.h"
#import "UIViewController+Medxnote.h"
#import "TOPasscodeView.h"
#import "TOPasscodeInputField.h"

@interface PasscodeHelper () <TOPasscodeViewControllerDelegate>

@property (nonatomic, weak) UIViewController *vc;

@property (nonatomic, copy) void (^completion)();
@property NSInteger attempt;
@property NSString *tempCode;
@property PasscodeHelperAction action;

@end

@implementation PasscodeHelper

- (void)initiateAction:(PasscodeHelperAction)action from:(UIViewController *)vc completion:(void (^)())completion {
    self.attempt = 0;
    self.action = action;
    self.vc = vc;
    self.completion = completion;
    [self showPasscodeView];
}

- (void)showPasscodeView {
    TOPasscodeViewController *vc = [[TOPasscodeViewController alloc] initWithStyle:TOPasscodeViewStyleOpaqueDark passcodeType:TOPasscodeTypeCustomAlphanumeric];
    [vc view];
    
    // appearance
    UIColor *medxGreen = [UIColor colorWithRed:65.f/255.f green:178.f/255.f blue:76.f/255.f alpha:1.f];
    vc.backgroundView.backgroundColor = medxGreen;
    vc.passcodeView.titleLabel.textColor = [UIColor whiteColor];
    vc.passcodeView.keypadButtonTextColor = [UIColor whiteColor];
    vc.passcodeView.keypadButtonHighlightedTextColor = [UIColor lightGrayColor];
    vc.passcodeView.inputProgressViewTintColor = [UIColor whiteColor];
    vc.passcodeView.inputField.keyboardAppearance = UIKeyboardAppearanceLight;
    
    vc.delegate = self;
    vc.cancelButton.hidden = _action == PasscodeHelperActionCheckPasscode || _action == PasscodeHelperActionChangePasscode;
    switch (self.action) {
        case PasscodeHelperActionChangePasscode:
            switch (_attempt) {
                case 0:
                    vc.passcodeView.titleLabel.text = @"Enter old passcode";
                    break;
                case 1:
                    vc.passcodeView.titleLabel.text = @"Enter new passcode";
                    break;
                case 2:
                    vc.passcodeView.titleLabel.text = @"Repeat new passcode";
                    break;
                default:
                    break;
            }
            break;
        case PasscodeHelperActionEnablePasscode:
            vc.passcodeView.titleLabel.text = _attempt == 0 ? @"Enter new passcode" : @"Repeat new passcode";
            break;
        case PasscodeHelperActionDisablePasscode:
            vc.passcodeView.titleLabel.text = @"Enter passcode";
            break;
        default:
            break;
    }
    
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    BOOL showAlert = _action == PasscodeHelperActionEnablePasscode && _attempt == 0;
    [self.vc presentViewController:vc animated:YES completion:^{
        if (showAlert) {
            [vc showPasscodeAlert];
        }
    }];
}

#pragma mark - TOPasscodeViewController

- (BOOL)passcodeViewController:(TOPasscodeViewController *)passcodeViewController isCorrectCode:(NSString *)code {
    if (code.length < 6) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Your PIN must contain a minimum of 6 alphanumeric characters" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [passcodeViewController presentViewController:alertController animated:true completion:nil];
        return false;
    }
    
    switch (_action) {
        case PasscodeHelperActionEnablePasscode:
                if (_attempt == 0) {
                    self.tempCode = code;
                }
                return self.attempt == 0 ? true : [self.tempCode isEqualToString:code];
            break;
        case PasscodeHelperActionChangePasscode:
            switch (_attempt) {
                case 0:
                    break;
                case 1:
                    self.tempCode = code;
                    return true;
                case 2:
                    return [self.tempCode isEqualToString:code];
            }
            break;
        case PasscodeHelperActionCheckPasscode: {
            BOOL isCorrect = [[MedxPasscodeManager passcode] isEqualToString:code];
            if (!isCorrect) {
                self.attempt++;
            } else {
                break;
            }
            switch (_attempt) {
                case 9: {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"If you enter your PIN incorrectly again, the app will lock and will have to be deleted and reinstalled to restore access to the service" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    [alertController addAction:okAction];
                    [passcodeViewController presentViewController:alertController animated:true completion:nil];
                    break;
                }
                case 10: {
                    [MedxPasscodeManager setLockoutEnabled];
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"The app has been disabled due to too many invalid passcode attempts. Please delete and reinstall the app to regain access" preferredStyle:UIAlertControllerStyleAlert];
                    [passcodeViewController presentViewController:alertController animated:YES completion:nil];
                    return false;
                }
                default:
                    break;
            }
            break;
        }
        case PasscodeHelperActionDisablePasscode:
            // no need to handle anything
            break;
    }
    
    return [[MedxPasscodeManager passcode] isEqualToString:code];
}

- (void)didTapCancelInPasscodeViewController:(TOPasscodeViewController *)passcodeViewController {
    [passcodeViewController dismissViewControllerAnimated:true completion:nil];
    self.attempt = 0;
    self.vc = nil;
    self.completion = nil;
}

- (void)didInputCorrectPasscodeInPasscodeViewController:(TOPasscodeViewController *)passcodeViewController {
    [passcodeViewController dismissViewControllerAnimated:true completion:nil];
    switch (_action) {
        case PasscodeHelperActionEnablePasscode:
            if (_attempt == 1) {
                [MedxPasscodeManager storePasscode:self.tempCode];
                _completion();
            } else {
                _attempt++;
                [self showPasscodeView];
            }
            break;
        case PasscodeHelperActionCheckPasscode:
            _completion();
            break;
        case PasscodeHelperActionChangePasscode:
            if (_attempt == 2) {
                [MedxPasscodeManager storePasscode:self.tempCode];
                _completion();
            } else {
                _attempt++;
                [self showPasscodeView];
            }
            break;
        case PasscodeHelperActionDisablePasscode:
            [MedxPasscodeManager storePasscode:nil];
            self.completion();
            break;
    }
}

@end
