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

@end

@implementation MessageInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setup dismiss button
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = dismissButton;
    
    // TODO: date formatting
    // 14:20:14 06/01/2017
    // -> 6 Jan 2017, 14:20:14 GMT+00:00
}

- (void)dismiss {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.receipts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoCell" forIndexPath:indexPath];;
    NSString *value = self.receipts[indexPath.row];
    NSString *title = @"";
    NSString *string = @"";
    switch (indexPath.row) {
        case 0: {
            // sent
            NSArray<NSString*> *strings = [value componentsSeparatedByString:@"\n"];
            string = [strings.lastObject stringByReplacingOccurrencesOfString:@"Sent: " withString:@""];
            title = NSLocalizedString(@"Sent", nil);
            break;
        }
        case 1: {
            // delivered
            string = [value stringByReplacingOccurrencesOfString:@"Delivered: " withString:@""];
            title = NSLocalizedString(@"Received", nil);
            break;
        }
        case 2: {
            // read
            string = [value stringByReplacingOccurrencesOfString:@"Read: " withString:@""];;
            title = NSLocalizedString(@"Read", nil);
            break;
        }
        default:
            break;
    }
    cell.textLabel.text = title.capitalizedString;
    cell.detailTextLabel.text = string;
    return cell;
}

@end
