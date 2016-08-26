//
//  CBManager.h
//  BLETest
//
//  Created by ml on 16/8/18.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBPeripheralExt.h"
#import <UIKit/UIKit.h>


@protocol CBManagerDiscoveryDelegate <NSObject>

@required

/**
 *  this method is invoked when CBManager find new  perioheral. u need use [CBManager sharedManager].foundPeripherals to get new data source.
 */
- (void)discoveryNewPeripheral;

/**
 *  this method is invoked when  u disconnect peripheral success
 */
- (void)disconnectPeripheral;

@optional

/**
 *  current bluetooth state
 *
 *  @param state this method is invoked when ur phone's bluetooth state changed
 */
- (void)bluetoothStateUpdateToState:(BOOL)state;

@end


@protocol CBManagerCurrentPeripheralDelegte <NSObject> //copy CBPeripheralDelegate

@optional
/*!
 *  @method peripheral:didDiscoverCharacteristicsForService:error:
 *
 *  @param peripheral	The peripheral providing this information.
 *  @param service		The <code>CBService</code> object containing the characteristic(s).
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverCharacteristics:forService: @/link call. If the characteristic(s) were read successfully,
 *						they can be retrieved via <i>service</i>'s <code>characteristics</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;

/*!
 *  @method peripheral:didUpdateValueForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method is invoked after a @link readValueForCharacteristic: @/link call, or upon receipt of a notification/indication.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

/*!
 *  @method peripheral:didWriteValueForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a {@link writeValue:forCharacteristic:type:} call, when the <code>CBCharacteristicWriteWithResponse</code> type is used.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

/*!
 *  @method peripheral:didUpdateNotificationStateForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link setNotifyValue:forCharacteristic: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

/*!
 *  @method peripheral:didDiscoverDescriptorsForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link discoverDescriptorsForCharacteristic: @/link call. If the descriptors were read successfully,
 *							they can be retrieved via <i>characteristic</i>'s <code>descriptors</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

/*!
 *  @method peripheral:didUpdateValueForDescriptor:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param descriptor		A <code>CBDescriptor</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link readValueForDescriptor: @/link call.
 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error;

@end


typedef void(^ConnectPeripheralCompletionBlock)(BOOL result,NSError * error);

typedef void(^DiscoverServiceCharactersCompletionBlock)(BOOL result,NSError * error);


@interface CBManager : NSObject

#define  CBManagerGet [CBManager sharedManager]

/**
 *  save peripheral have been founded.
 */
@property (nonatomic,retain,readonly) NSMutableArray<CBPeripheralExt *> * foundPeripherals;

/**
 *  save currentConnectPeripheral's services
 */
@property (nonatomic,retain,readonly) NSMutableArray<CBService *> * services;

/**
 *  save currentService's characters
 */
@property (nonatomic,retain,readonly) NSMutableArray<CBCharacteristic *> * characteristics;

/**
 *  save currentCharacteristic's descriptors
 */
@property (nonatomic,retain,readonly) NSMutableArray<CBDescriptor *> *descriptors;

/**
 *  when u connect phripheral successful CBManager will save it as currentConnectPeripheral
 */
@property (nonatomic,retain) CBPeripheral * currentConnectPeripheral;

/**
 *  u can save service which is selected
 */
@property (nonatomic,retain) CBService * currentService;

@property (nonatomic,retain) CBCharacteristic * currentCharacteristic;

/**
 *  plist file .save service's and characters's names.
 */
@property (nonatomic,strong,readonly) NSMutableDictionary * serviceUUIDDict;

@property (nonatomic,retain) id <CBManagerDiscoveryDelegate> discoveryDlegate;

@property (nonatomic,retain) id <CBManagerCurrentPeripheralDelegte> currentPeripheralDelegate;

+ (instancetype)sharedManager;

- (void)startScan;

- (void)stopScan;

/**
 *  claer current found peripheral and start scan again
 */
- (void)refreshPeripherals;

/**
 *  Method about connect peripheral.
 *
 *  @param peripheral  peripheral which u want to connect
 *  @param completionHandler invoked when u connect peripheral success
 */
- (void)connectPeripheral:(CBPeripheral*)peripheral CompletionBlock:(ConnectPeripheralCompletionBlock)completionHandler;

/**
 *  u can disconnect currentConnectPeripheral
 */
- (void)disconnectPeripheral;


- (void)connectService:(CBService *)service CompletionBlock:(DiscoverServiceCharactersCompletionBlock)block;


@end
