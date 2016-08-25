//
//  CBPeripheralExt.h
//  BLETest
//
//  Created by ml on 16/8/18.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheralExt : NSObject


@property (nonatomic, retain)CBPeripheral		*mPeripheral;


@property (nonatomic, retain)NSDictionary		*mAdvertisementData;


@property (nonatomic, retain)NSNumber           *mRSSI;


- (NSString *)getPeripheralName;

- (NSString *)getRSSI;

- (NSString *)getUUIDString;

- (NSString *)getServiceCount;
@end
