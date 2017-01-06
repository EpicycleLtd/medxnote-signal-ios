//
//  MessageInfoViewController.m
//  Medxnote
//
//  Created by Jan Nemecek on 1/6/17.
//  Copyright © 2017 Open Whisper Systems. All rights reserved.
//

#import "MessageInfoViewController.h"

@interface MessageInfoViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSDateFormatter *sourceDateFormatter;
@property NSDateFormatter *dateFormatter;

@property NSMutableArray<NSArray*> *displayReceipts;

@end

@implementation MessageInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setup dismiss button
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = dismissButton;
    
    // date formatting
    self.sourceDateFormatter = [[NSDateFormatter alloc] init];
    self.sourceDateFormatter.dateFormat = @"HH:mm:ss dd/MM/yyyy";
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"d MMM yyyy', 'HH:mm:ss' GMT'Z";
    
    // split receipts by user
    self.displayReceipts = [NSMutableArray new];
    NSMutableArray *new = [NSMutableArray new];
    for (NSString *string in self.receipts) {
        if ([string containsString:@"\n"] && [self.receipts indexOfObject:string] > 0) {
            [self.displayReceipts addObject:new.copy];
            new = [NSMutableArray new];
        }
        [new addObject:string];
        
        // end of list
        if ([self.receipts indexOfObject:string] == self.receipts.count-1) {
            [self.displayReceipts addObject:new.copy];
        }
    }
}

- (void)dismiss {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.displayReceipts.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionArray = self.displayReceipts[section];
    return sectionArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *sectionArray = self.displayReceipts[section];
    NSString *string = sectionArray.firstObject;
    return [string componentsSeparatedByString:@"\n"].firstObject;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoCell" forIndexPath:indexPath];
    NSArray *sectionArray = self.displayReceipts[indexPath.section];
    NSString *value = sectionArray[indexPath.row];
    
    //
    NSString *title = @"";
    NSString *dateString = @"";
    switch (indexPath.row) {
        case 0: {
            // sent
            NSArray<NSString*> *strings = [value componentsSeparatedByString:@"\n"];
            dateString = [strings.lastObject stringByReplacingOccurrencesOfString:@"Sent: " withString:@""];
            title = NSLocalizedString(@"Sent", nil);
            break;
        }
        case 1: {
            // delivered
            dateString = [value stringByReplacingOccurrencesOfString:@"Delivered: " withString:@""];
            title = NSLocalizedString(@"Received", nil);
            break;
        }
        case 2: {
            // read
            dateString = [value stringByReplacingOccurrencesOfString:@"Read: " withString:@""];
            title = NSLocalizedString(@"Read", nil);
            break;
        }
        default:
            break;
    }
    NSDate *date = [self.sourceDateFormatter dateFromString:dateString];
    cell.textLabel.text = title.capitalizedString;
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:date];
    return cell;
}

@end
