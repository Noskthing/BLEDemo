//
//  CBService+GetPropertyString.h
//  BLETest
//
//  Created by ml on 16/8/19.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBService (GetPropertyString)

- (NSString *)getServiceNameForUUID;

@end
