//
//  PasscodeSettingsTableViewController.m
//  Medxnote
//
//  Created by Jan Nemecek on 1/18/17.
//  Copyright © 2017 Open Whisper Systems. All rights reserved.
//

#import "PasscodeSettingsTableViewController.h"
#import "ABPadLockScreenSetupViewController.h"
#import "ABPadLockScreenViewController.h"
#import "MedxPasscodeManager.h"
#import "ActionSheetPicker.h"

typedef NS_ENUM(NSUInteger, PasscodeSettingsAction) {
    PasscodeSettingsActionNone,
    PasscodeSettingsActionEnablePasscode,
    PasscodeSettingsActionDisablePasscode,
    PasscodeSettingsActionChangePasscode
};

@interface PasscodeSettingsTableViewController () <ABPadLockScreenSetupViewControllerDelegate, ABPadLockScreenViewControllerDelegate>

@property (nonatomic, strong) UITableViewCell *enablePasscodeCell;
@property (nonatomic, strong) UISwitch *enablePasscodeSwitch;
@property (nonatomic, strong) UITableViewCell *timeoutCell;
@property (nonatomic, strong) UITableViewCell *clearHistoryLogCell;

@property PasscodeSettingsAction action;

@end

@implementation PasscodeSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.action = PasscodeSettingsActionNone;
    [self.navigationController.navigationBar setTranslucent:NO];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (instancetype)init {
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)loadView {
    [super loadView];
    
    self.title = @"Passcode Settings";
    
    // Enable Screen Security Cell
    self.enablePasscodeCell                = [[UITableViewCell alloc] init];
    self.enablePasscodeCell.textLabel.text = @"Enable Passcode";
    
    self.enablePasscodeSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [self.enablePasscodeSwitch setOn:[MedxPasscodeManager isPasscodeEnabled]];
    [self.enablePasscodeSwitch addTarget:self
                                        action:@selector(didToggleSwitch:)
                              forControlEvents:UIControlEventTouchUpInside];
    
    self.enablePasscodeCell.accessoryView          = self.enablePasscodeSwitch;
    self.enablePasscodeCell.userInteractionEnabled = YES;
    
    // Display timeout
    self.timeoutCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"TimeoutCell"];
    self.timeoutCell.textLabel.text = @"Passcode Timeout";
    [self refreshTimeoutCell];
    
    // Clear History Log Cell
    self.clearHistoryLogCell                = [[UITableViewCell alloc] init];
    self.clearHistoryLogCell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            return self.enablePasscodeCell;
        case 1:
            [self refreshPasscodeCell];
            return self.clearHistoryLogCell;
        case 2:
            return self.timeoutCell;
        default:
            return [UITableViewCell new];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    switch (indexPath.row) {
        case 1:
            self.action = PasscodeSettingsActionChangePasscode;
            [self showPasscodeViewWithAlert:true];
            break;
        case 2:
            if ([MedxPasscodeManager isPasscodeEnabled]) {
                [self showTimeoutOptions];
            }
            break;
        default:
            break;
    }
}

- (void)refreshPasscodeCell {
    self.clearHistoryLogCell.textLabel.text = [MedxPasscodeManager isPasscodeEnabled] ? @"Change passcode" : @"Setup a passcode";
}

- (void)refreshTimeoutCell {
    if ([MedxPasscodeManager isPasscodeEnabled]) {
        NSString *suffix = [MedxPasscodeManager inactivityTimeoutInMinutes].integerValue == 1 ? @"minute" : @"minutes";
        NSString *minutes = [MedxPasscodeManager inactivityTimeoutInMinutes].stringValue;
        self.timeoutCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", minutes, suffix];
    } else {
        self.timeoutCell.detailTextLabel.text = @"Disabled";
    }
}

#pragma mark - Actions

- (void)didToggleSwitch:(UISwitch *)sender {
    [sender setOn:!sender.isOn];
    if ([MedxPasscodeManager isPasscodeEnabled]) {
        self.action = PasscodeSettingsActionDisablePasscode;
        [self showPasscodeViewWithAlert:false];
    } else {
        self.action = PasscodeSettingsActionEnablePasscode;
        [self showPasscodeCreationScreen];
    }
}

- (void)showPasscodeViewWithAlert:(BOOL)showAlert {
    if (![MedxPasscodeManager isPasscodeEnabled]) {
        self.action = PasscodeSettingsActionEnablePasscode;
        [self showPasscodeCreationScreen];
    } else {
        ABPadLockScreenViewController *lockScreen = [[ABPadLockScreenViewController alloc] initWithDelegate:self complexPin:YES];
        [lockScreen setAllowedAttempts:20];
        
        lockScreen.modalPresentationStyle = UIModalPresentationFullScreen;
        lockScreen.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self presentViewController:lockScreen animated:YES completion:^{
            if (showAlert) {
                [self showPasscodeAlertOnVC:lockScreen];
            }
        }];
    }
}

- (void)showTimeoutOptions {
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Inactivity Timeout" datePickerMode:UIDatePickerModeCountDownTimer selectedDate:nil doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
        NSNumber *number = selectedDate;
        NSLog(@"new timeout: %@", number);
        [MedxPasscodeManager storeInactivityTimeout:number];
        [self refreshTimeoutCell];
    } cancelBlock:^(ActionSheetDatePicker *picker) {
        //
    } origin:self.view];
    // preselect currently selected time
    datePicker.countDownDuration = [MedxPasscodeManager inactivityTimeout].integerValue;
    
    // done button
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:nil action:nil];
    [doneButton setTintColor:[UIColor blackColor]];
    [datePicker setDoneButton:doneButton];
    
    // cancel button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:nil action:nil];
    [cancelButton setTintColor:[UIColor blackColor]];
    [datePicker setCancelButton:cancelButton];
    
    [datePicker showActionSheetPicker];
}

- (void)showPasscodeAlertOnVC:(UIViewController*)vc {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"If you forget your PIN or enter it incorrectly 20 times, you will have to delete and reinstall the Medxnote app to restore access to the service" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [vc presentViewController:alertController animated:true completion:nil];
}

#pragma mark - ABPadLockScreenSetupViewControllerDelegate Methods

- (void)pinSet:(NSString *)pin padLockScreenSetupViewController:(ABPadLockScreenSetupViewController *)padLockScreenViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    [MedxPasscodeManager storePasscode:pin];
    [self.enablePasscodeSwitch setOn:true animated:true];
    [self refreshPasscodeCell];
    [self refreshTimeoutCell];
    self.action = PasscodeSettingsActionNone;
}

- (void)unlockWasCancelledForPadLockScreenViewController:(ABPadLockScreenAbstractViewController *)padLockScreenViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)unlockWasCancelledForSetupViewController:(ABPadLockScreenAbstractViewController *)padLockScreenViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ABLockScreenDelegate Methods

- (BOOL)padLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController validatePin:(NSString*)pin {
    return [[MedxPasscodeManager passcode] isEqualToString:pin];
}

- (void)unlockWasSuccessfulForPadLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController {
    [self dismissViewControllerAnimated:NO completion:^{
        switch (self.action) {
            case PasscodeSettingsActionDisablePasscode:
                [self.enablePasscodeSwitch setOn:false animated:true];
                [MedxPasscodeManager storePasscode:nil];
                [self refreshPasscodeCell];
                [self refreshTimeoutCell];
                break;
            case PasscodeSettingsActionChangePasscode:
                [self showPasscodeCreationScreen];
                break;
            default:
                break;
        }
        self.action = PasscodeSettingsActionNone;
    }];
}

- (void)unlockWasUnsuccessful:(NSString *)falsePin afterAttemptNumber:(NSInteger)attemptNumber padLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController
{
    NSLog(@"Failed attempt number %ld with pin: %@", (long)attemptNumber, falsePin);
}

- (void)showPasscodeCreationScreen {
    ABPadLockScreenSetupViewController *lockScreen = [[ABPadLockScreenSetupViewController alloc] initWithDelegate:self complexPin:YES subtitleLabelText:@"Please enter new passcode"];
    lockScreen.tapSoundEnabled = YES;
    lockScreen.errorVibrateEnabled = YES;
    
    lockScreen.modalPresentationStyle = UIModalPresentationPopover;
    lockScreen.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:lockScreen animated:NO completion:^{
        [self showPasscodeAlertOnVC:lockScreen];
    }];
}

@end
