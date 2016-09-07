//
//  CBPeripheral+WriteValue.m
//  BLEProject
//
//  Created by ml on 16/9/7.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import "CBPeripheral+WriteValue.h"

@implementation CBPeripheral (WriteValue)

-(void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic
{
    if ((characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) != 0)
    {
        [self writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
   
    }
    else
    {
        [self writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }
}
@end
