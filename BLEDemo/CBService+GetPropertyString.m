//
//  CBService+GetPropertyString.m
//  BLETest
//
//  Created by ml on 16/8/19.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import "CBService+GetPropertyString.h"

@implementation CBService (GetPropertyString)

#define SERVICE_AND_CHARACTERISTIC_NAMES_PLIST      @"ServiceAndCharacteristicNames"

#define UNKNOWN_SERVICE                             @"Unknown Service"

- (NSString *)getServiceNameForUUID
{
    NSDictionary *allServicesAndCharacteristicsDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:SERVICE_AND_CHARACTERISTIC_NAMES_PLIST ofType:@"plist"]];
    
    NSString *serviceName = [allServicesAndCharacteristicsDict objectForKey:self.UUID.UUIDString];
    
    if (serviceName.length < 1)
    {
        serviceName = UNKNOWN_SERVICE;
    }
    return serviceName;
}

@end
