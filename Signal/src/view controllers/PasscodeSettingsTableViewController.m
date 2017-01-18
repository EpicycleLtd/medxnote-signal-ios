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

@interface PasscodeSettingsTableViewController () <ABPadLockScreenSetupViewControllerDelegate, ABPadLockScreenViewControllerDelegate>

@property (nonatomic, strong) UITableViewCell *enablePasscodeCell;
@property (nonatomic, strong) UISwitch *enablePasscodeSwitch;
@property (nonatomic, strong) UITableViewCell *timeoutCell;
@property (nonatomic, strong) UITableViewCell *clearHistoryLogCell;

@end

@implementation PasscodeSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    self.timeoutCell.detailTextLabel.text = [MedxPasscodeManager inactivityTimeoutInMinutes].stringValue;
    
    // Clear History Log Cell
    self.clearHistoryLogCell                = [[UITableViewCell alloc] init];
    //self.clearHistoryLogCell.textLabel.text = NSLocalizedString(@"SETTINGS_CLEAR_HISTORY", @"");
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
            self.clearHistoryLogCell.textLabel.text = [MedxPasscodeManager isPasscodeEnabled] ? @"Change passcode" : @"Setup a passcode";
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
            [self showPasscodeView];
            break;
        case 2:
            [self showTimeoutOptions];
            break;
        default:
            break;
    }
}

#pragma mark - Actions

- (void)didToggleSwitch:(UISwitch *)sender {
    [sender setOn:!sender.isOn];
    if ([MedxPasscodeManager isPasscodeEnabled]) {
        // TODO: ask for passcode to turn off
    } else {
        // TODO: start passcode creation process if no passcode exists
    }
}

- (void)showPasscodeView {
    if (![MedxPasscodeManager isPasscodeEnabled]) {
        ABPadLockScreenSetupViewController *lockScreen = [[ABPadLockScreenSetupViewController alloc] initWithDelegate:self complexPin:YES subtitleLabelText:@"Please enter new passcode"];
        lockScreen.tapSoundEnabled = YES;
        lockScreen.errorVibrateEnabled = YES;
        
        lockScreen.modalPresentationStyle = UIModalPresentationPopover;
        lockScreen.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self presentViewController:lockScreen animated:NO completion:nil];
        
    } else {
        ABPadLockScreenViewController *lockScreen = [[ABPadLockScreenViewController alloc] initWithDelegate:self complexPin:YES];
        [lockScreen setAllowedAttempts:3];
        
        lockScreen.modalPresentationStyle = UIModalPresentationFullScreen;
        lockScreen.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self presentViewController:lockScreen animated:YES completion:nil];
    }
}

- (void)showTimeoutOptions {
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Inactivity Timeout" datePickerMode:UIDatePickerModeCountDownTimer selectedDate:nil doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
        NSNumber *number = selectedDate;
        NSLog(@"new timeout: %@", number);
        [MedxPasscodeManager storeInactivityTimeout:number];
        self.timeoutCell.detailTextLabel.text = [MedxPasscodeManager inactivityTimeoutInMinutes].stringValue;
    } cancelBlock:^(ActionSheetDatePicker *picker) {
        //
    } origin:self.view];
    
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

#pragma mark - ABPadLockScreenSetupViewControllerDelegate Methods

- (void)pinSet:(NSString *)pin padLockScreenSetupViewController:(ABPadLockScreenSetupViewController *)padLockScreenViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    [MedxPasscodeManager storePasscode:pin];
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
        ABPadLockScreenSetupViewController *lockScreen = [[ABPadLockScreenSetupViewController alloc] initWithDelegate:self complexPin:YES subtitleLabelText:@"Please enter new passcode"];
        lockScreen.tapSoundEnabled = YES;
        lockScreen.errorVibrateEnabled = YES;
        
        lockScreen.modalPresentationStyle = UIModalPresentationPopover;
        lockScreen.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self presentViewController:lockScreen animated:NO completion:nil];
    }];
}

- (void)unlockWasUnsuccessful:(NSString *)falsePin afterAttemptNumber:(NSInteger)attemptNumber padLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController
{
    NSLog(@"Failed attempt number %ld with pin: %@", (long)attemptNumber, falsePin);
}

@end
