//
//  MedxPasscodeManager.m
//  Signal
//
//  Created by Upul Abayagunawardhana on 3/7/16.
//  Copyright © 2016 Open Whisper Systems. All rights reserved.
//

#import "MedxPasscodeManager.h"
#import "TSStorageManager.h"

@implementation MedxPasscodeManager

+ (BOOL)isPasscodeEnabled {
    return [[self passcode] length] > 0;
}

+ (NSString *)passcode {
    return [[TSStorageManager sharedManager] stringForKey:@"MedxStoragePasscodeKey" inCollection:TSStorageUserAccountCollection];
}

+ (void)storePasscode:(NSString *)passcode {
    YapDatabaseConnection *dbConn = [[TSStorageManager sharedManager] dbConnection];
    
    [dbConn readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:passcode
                        forKey:@"MedxStoragePasscodeKey"
                  inCollection:TSStorageUserAccountCollection];
    }];
}

@end
