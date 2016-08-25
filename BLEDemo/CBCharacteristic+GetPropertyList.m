//
//  CBCharacteristic+GetPropertyList.m
//  BLETest
//
//  Created by ml on 16/8/19.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import "CBCharacteristic+GetPropertyList.h"

@implementation CBCharacteristic (GetPropertyList)

/* characteristic properties*/

#define READ        @"Read"
#define WRITE       @"Write"
#define NOTIFY      @"Notify"
#define INDICATE    @"Indicate"

-(NSString *)getPropertyString
{
    NSMutableArray * tmpArray = [NSMutableArray array];
    
    if ((self.properties & CBCharacteristicPropertyRead) != 0)
    {
        [tmpArray addObject:READ];
    }
    if (((self.properties & CBCharacteristicPropertyWrite) != 0) || ((self.properties & CBCharacteristicPropertyWriteWithoutResponse) != 0) )
    {
        [tmpArray addObject:WRITE];
    }
    if ((self.properties & CBCharacteristicPropertyNotify) != 0)
    {
        [tmpArray addObject:NOTIFY];
    }
    if ((self.properties & CBCharacteristicPropertyIndicate) != 0)
    {
        [tmpArray addObject:INDICATE];
    }
    
    __block NSString * str = @"";
    
    [tmpArray enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0)
        {
            str = [str stringByAppendingString:obj];
        }
        else
        {
            str = [str stringByAppendingString:[NSString stringWithFormat:@" And %@",obj]];
        }
    }];
    
    return str;
}

-(NSArray *)getPropertyList
{
    NSMutableArray * array = [NSMutableArray array];
    
    if ((self.properties & CBCharacteristicPropertyRead) != 0)
    {
        [array addObject:READ];
    }
    if (((self.properties & CBCharacteristicPropertyWrite) != 0) || ((self.properties & CBCharacteristicPropertyWriteWithoutResponse) != 0) )
    {
        [array addObject:WRITE];
    }
    if ((self.properties & CBCharacteristicPropertyNotify) != 0)
    {
        [array addObject:NOTIFY];
    }
    if ((self.properties & CBCharacteristicPropertyIndicate) != 0)
    {
        [array addObject:INDICATE];
    }
    
    return [array copy];
}

#define SERVICE_AND_CHARACTERISTIC_NAMES_PLIST      @"ServiceAndCharacteristicNames"
#define UNKNOWN_CHARACTERISTIC                      @"Unknown Characteristic"

-(NSString *)getCharacteristicNameForUUID
{
    NSDictionary *allServicesAndCharacteristicsDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:SERVICE_AND_CHARACTERISTIC_NAMES_PLIST ofType:@"plist"]];
    
    NSString *characteristicName = [allServicesAndCharacteristicsDict objectForKey:self.UUID.UUIDString];
    
    if (characteristicName.length < 1)
    {
        characteristicName = UNKNOWN_CHARACTERISTIC;
    }
    return characteristicName;
}
@end
