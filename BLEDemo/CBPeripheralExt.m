//
//  CBPeripheralExt.m
//  BLETest
//
//  Created by ml on 16/8/18.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import "CBPeripheralExt.h"

@interface CBPeripheralExt ()<CBPeripheralDelegate>

@end

@implementation CBPeripheralExt

-(instancetype)init
{
    if (self = [super init])
    {
        self.isShowAdvertisementData = NO;
    }
    return self;
}
-(void)setMPeripheral:(CBPeripheral *)mPeripheral
{
    _mPeripheral = mPeripheral;
    _mPeripheral.delegate = self;
}

-(NSString *)getPeripheralName
{
    NSString *bleName ;
    
    if ([self.mAdvertisementData valueForKey:CBAdvertisementDataLocalNameKey] != nil)
    {
        bleName = [self.mAdvertisementData valueForKey:CBAdvertisementDataLocalNameKey];
    }
    
    // If the peripheral name is not found in advertisement data, then check whether it is there in peripheral object. If it's not found then assign it as unknown peripheral
    
    if(bleName.length < 1 )
    {
        if (self.mPeripheral.name.length > 0)
            bleName = self.mPeripheral.name;
        else
            bleName = @"unknownPeripheral";
    }
    
    return bleName;
}

static int kRSSI_UNDEFINED_VALUE = 127;
-(NSString *)getRSSI
{
    NSString *deviceRSSI = [self.mRSSI stringValue];
    
    if(deviceRSSI.length < 1 )
    {
        [self.mPeripheral readRSSI];
        deviceRSSI = [self.mRSSI stringValue];
    }
    
    if([deviceRSSI intValue] >= kRSSI_UNDEFINED_VALUE)
        deviceRSSI = @"undefined";
    else
        deviceRSSI=[NSString stringWithFormat:@"%@ dBm",deviceRSSI];
  
    return deviceRSSI;
}

-(NSString *)getUUIDString
{
    NSString *bleUUID = self.mPeripheral.identifier.UUIDString;
    
    if(bleUUID.length < 1 )
        bleUUID = @"unknownUUID";
    else
        bleUUID = [NSString stringWithFormat:@"UUID: %@",bleUUID];
    
    return bleUUID;
}

-(NSString *)getServiceCount
{
    NSString *bleService
    ;
    NSInteger serViceCount = [[self.mAdvertisementData valueForKey:CBAdvertisementDataServiceUUIDsKey] count];
    
    if(serViceCount < 1 )
        bleService = @"noServices";
    else
        bleService = [NSString stringWithFormat:@" %ld Service Advertised ",(long)serViceCount];
    
    return bleService;
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(nullable NSError *)error NS_AVAILABLE(NA, 8_0)
{
    if(!error)
        _mRSSI = RSSI;
}
@end
