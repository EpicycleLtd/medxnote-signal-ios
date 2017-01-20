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

+ (BOOL)isLockoutEnabled {
    return [[TSStorageManager sharedManager] boolForKey:@"MedxLockoutFlag" inCollection:TSStorageUserAccountCollection];
}

+ (void)setLockoutEnabled {
    NSLog(@"lockout enabled!");
    YapDatabaseConnection *dbConn = [[TSStorageManager sharedManager] dbConnection];
    
    [dbConn readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:@true
                        forKey:@"MedxLockoutFlag"
                  inCollection:TSStorageUserAccountCollection];
    }];

}

+ (BOOL)isPasscodeEnabled {
    return [[self passcode] length] > 0;
}

+ (NSString *)passcode {
    return [[TSStorageManager sharedManager] stringForKey:@"MedxStoragePasscodeKey" inCollection:TSStorageUserAccountCollection];
}

+ (void)storePasscode:(NSString *)passcode {
    if ([[MedxPasscodeManager inactivityTimeoutInMinutes] isEqualToNumber:@(0)]) {
        // set default value
        NSLog(@"No timeout setting stored, setting default value");
        [self storeInactivityTimeout:@(300)];
    }
    YapDatabaseConnection *dbConn = [[TSStorageManager sharedManager] dbConnection];
    
    [dbConn readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:passcode
                        forKey:@"MedxStoragePasscodeKey"
                  inCollection:TSStorageUserAccountCollection];
    }];
}

+ (NSNumber *)inactivityTimeout {
    return [[TSStorageManager sharedManager] objectForKey:@"MedxStorageTimeoutKey" inCollection:TSStorageUserAccountCollection];
}

+ (NSNumber *)inactivityTimeoutInMinutes {
    NSNumber *timeout = [MedxPasscodeManager inactivityTimeout];
    return @(timeout.integerValue / 60);
}

+ (void)storeInactivityTimeout:(NSNumber *)timeout {
    YapDatabaseConnection *dbConn = [[TSStorageManager sharedManager] dbConnection];
    
    [dbConn readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:timeout
                        forKey:@"MedxStorageTimeoutKey"
                  inCollection:TSStorageUserAccountCollection];
    }];
}

+ (NSDate *)lastActivityTime {
    return [[TSStorageManager sharedManager] objectForKey:@"MedxStorageLastActivityKey" inCollection:TSStorageUserAccountCollection];
}

+ (void)storeLastActivityTime:(NSDate *)date {
    YapDatabaseConnection *dbConn = [[TSStorageManager sharedManager] dbConnection];
    
    [dbConn readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:date
                        forKey:@"MedxStorageLastActivityKey"
                  inCollection:TSStorageUserAccountCollection];
    }];
}

@end
