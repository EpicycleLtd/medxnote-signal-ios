//
//  QRCodeViewController.h
//  Medxnote
//
//  Created by Jan Nemecek on 1/6/17.
//  Copyright © 2017 Open Whisper Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QRCodeViewDelegate <NSObject>

- (void)didFinishScanningQRCodeWithString:(NSString*)string;

@end

@interface QRCodeViewController : UIViewController

@property (weak, nonatomic) id<QRCodeViewDelegate> delegate;

@end
