//
//  TSMessageReadRequest.m
//  TextSecureKit
//
//  Created by Agocs Imre on 2016-07-25.
//

#import "TSConstants.h"
#import "TSMessageReadRequest.h"

@implementation TSMessageReadRequest

- (TSRequest *)initWithDestination:(NSString *)destination
                      forMessageId:(NSString *)msgid
                             relay:(NSString *)relay {

    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", textSecureReadAPI, destination, msgid];

    if (relay && ![relay isEqualToString:@""]) {
        path = [path stringByAppendingFormat:@"?relay=%@", relay];
    }

    self = [super initWithURL:[NSURL URLWithString:path]];

    [self setHTTPMethod:@"PUT"];

    return self;
}

@end
