//
//  InlineKeyboardCell.m
//  Medxnote
//
//  Created by Jan Nemecek on 13/4/17.
//  Copyright © 2017 Open Whisper Systems. All rights reserved.
//

#import "InlineKeyboardCell.h"
#import "UIColor+HexString.h"

@implementation InlineKeyboardCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
    
- (void)customizeWithDictionary:(NSDictionary *)style {
    UIColor *backgroundColor = [UIColor colorWithHexString:[style[@"bg_color"] stringByReplacingOccurrencesOfString:@"#" withString:@""]];
    UIColor *borderColor = [UIColor colorWithHexString:[style[@"border"] stringByReplacingOccurrencesOfString:@"#" withString:@""]];
    UIColor *textColor = [UIColor colorWithHexString:[style[@"color"] stringByReplacingOccurrencesOfString:@"#" withString:@""]];
    self.contentView.backgroundColor = backgroundColor;
    self.contentView.layer.cornerRadius = 3;
    self.contentView.clipsToBounds = true;
    self.contentView.layer.borderColor = borderColor.CGColor;
    self.contentView.layer.borderWidth = 1.0f;
    self.titleLabel.textColor = textColor;
}

@end
