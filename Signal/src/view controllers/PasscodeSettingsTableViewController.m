//
//  PasscodeSettingsTableViewController.m
//  Medxnote
//
//  Created by Jan Nemecek on 1/18/17.
//  Copyright © 2017 Open Whisper Systems. All rights reserved.
//

#import "PasscodeSettingsTableViewController.h"
#import "MedxPasscodeManager.h"
#import "ActionSheetPicker.h"
#import "UIViewController+Medxnote.h"
#import "PasscodeHelper.h"

@interface PasscodeSettingsTableViewController ()

@property (nonatomic, strong) UITableViewCell *enablePasscodeCell;
@property (nonatomic, strong) UISwitch *enablePasscodeSwitch;
@property (nonatomic, strong) UITableViewCell *timeoutCell;
@property (nonatomic, strong) UITableViewCell *clearHistoryLogCell;

@property PasscodeHelper *passcodeHelper;

@end

@implementation PasscodeSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.passcodeHelper = [[PasscodeHelper alloc] init];
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
    self.enablePasscodeSwitch.enabled = ![[NSBundle mainBundle].infoDictionary[@"MedxnoteForcePasscode"] boolValue];
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
            [self.passcodeHelper initiateAction:PasscodeHelperActionChangePasscode from:self completion:^{
                // no need to do anything
            }];
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
        [self.passcodeHelper initiateAction:PasscodeHelperActionDisablePasscode from:self completion:^{
            [self.enablePasscodeSwitch setOn:false animated:true];
            [self refreshPasscodeCell];
            [self refreshTimeoutCell];
        }];
    } else {
        [self.passcodeHelper initiateAction:PasscodeHelperActionEnablePasscode from:self completion:^{
            [self.enablePasscodeSwitch setOn:true animated:true];
            [self refreshPasscodeCell];
            [self refreshTimeoutCell];
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

@end
