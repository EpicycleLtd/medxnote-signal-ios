//
//  TSMessageReadRequest.h
//  TextSecureKit
//
//  Created by Imre Agocs on 2016-07-25
//

#import "TSRequest.h"

@interface TSMessageReadRequest : TSRequest

- (TSRequest *)initWithDestination:(NSString *)Destination
                      forMessageId:(NSString *)messageId
                             relay:(NSString *)relay;

@end
