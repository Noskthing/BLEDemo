//
//  CBManager.m
//  BLETest
//
//  Created by ml on 16/8/18.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import "CBManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "ResourceHandler.h"

@interface CBManager() <CBCentralManagerDelegate, CBPeripheralDelegate>
{
    NSMutableArray * _peripheralListArray;
}

@property (nonatomic,copy)ConnectPeripheralCompletionBlock connectPeripheralCompletionBlock;

@property (nonatomic,copy) DiscoverServiceCharactersCompletionBlock discoverServiceCharactersCompletionBlock;

@property (nonatomic,strong)CBCentralManager * centralManager;

@end

@implementation CBManager


+ (id)sharedManager
{
    static CBManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

#define k_SERVICE_UUID_PLIST_NAME @"ServiceUUIDPList"
-(instancetype)init
{
    if (self = [super init])
    {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        _peripheralListArray = [NSMutableArray array];
        _foundPeripherals = [NSMutableArray array];
        _services = [NSMutableArray array];
        _descriptors = [NSMutableArray array];
        _serviceUUIDDict = [NSMutableDictionary dictionaryWithDictionary:[ResourceHandler getItemsFromPropertyList:k_SERVICE_UUID_PLIST_NAME]];
        _characteristics = [NSMutableArray array];
    }
    return self;
}

-(void)startScan
{
    if((NSInteger)[_centralManager state] == CBCentralManagerStatePoweredOn)
    {
        if ([_discoveryDlegate respondsToSelector:@selector(bluetoothStateUpdateToState:)])
        {
            [_discoveryDlegate bluetoothStateUpdateToState:YES];
        }

        NSDictionary *options=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],CBCentralManagerScanOptionAllowDuplicatesKey, nil];
        [_centralManager scanForPeripheralsWithServices:nil options:options];
    }
    else if ([_centralManager state] == CBCentralManagerStateUnsupported)
    {
        NSLog(@"can not support ble");
    }
}

-(void)stopScan
{
    [_centralManager stopScan];
}

- (void) clearDevices
{
//    NSLog(@"clear");
    [_peripheralListArray removeAllObjects];
    [_foundPeripherals removeAllObjects];
    [_services removeAllObjects];
    [_descriptors removeAllObjects];
    [_characteristics removeAllObjects];
}

#pragma mark    -central delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch ((NSInteger)[_centralManager state])
    {
        case CBCentralManagerStatePoweredOff:
        {
            [self clearDevices];
            /* Tell user to power ON BT for functionality, but not on first run - the Framework will alert in that instance. */
            //Show Alert
//            [self redirectToRootviewcontroller];
            [_discoveryDlegate bluetoothStateUpdateToState:NO];
            break;
        }
            
        case CBCentralManagerStateUnauthorized:
        {
            /* Tell user the app is not allowed. */
            NSLog(@"CBCentralManagerStateUnauthorized");
            break;
        }
            
        case CBCentralManagerStateUnknown:
        {
            /* Bad news, let's wait for another event. */
            NSLog(@"CBCentralManagerStateUnknown");
            break;
        }
            
        case CBCentralManagerStatePoweredOn:
        {
//            [cbDiscoveryDelegate bluetoothStateUpdatedToState:YES];
            [self startScan];
            break;
        }
            
        case CBCentralManagerStateResetting:
        {
            [self clearDevices];
            break;
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (![_peripheralListArray containsObject:peripheral])
    {
        //连接态
        if (peripheral.state == CBPeripheralStateConnected)
        {
            return;
        }
        
        CBPeripheralExt *newPeriPheral = [[CBPeripheralExt alloc] init];
        newPeriPheral.mPeripheral = [peripheral copy];
        newPeriPheral.mAdvertisementData = [advertisementData copy];
        newPeriPheral.mRSSI = [RSSI copy];
        [_peripheralListArray addObject:peripheral];
        [_foundPeripherals addObject:newPeriPheral];
        [_discoveryDlegate discoveryNewPeripheral];
    }
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self cancelTimeOutAlert];
    
    _currentConnectPeripheral = peripheral;
    _currentConnectPeripheral.delegate = self ;
    [_currentConnectPeripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self cancelTimeOutAlert];
    _connectPeripheralCompletionBlock(NO,error);
}

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self cancelTimeOutAlert];
    /*  Check whether the disconnection is done by the device */
    if (error == nil)
    {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"deviceDisconnectedAlert" forKey:NSLocalizedDescriptionKey];
        NSError *disconnectError = [NSError errorWithDomain:@"domain" code:100 userInfo:errorDetail];

        _connectPeripheralCompletionBlock(NO,disconnectError);
    }
    else
    {
//        isTimeOutAlert = NO;
        
        // Checking whether the disconnected device has pending firmware upgrade
        if (error != nil)
        {
            NSMutableDictionary *errorDict = [NSMutableDictionary dictionary];
            [errorDict setValue:[NSString stringWithFormat:@"%@%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey],@"firmwareUpgradePendingMessage"] forKey:NSLocalizedDescriptionKey];
            
            NSError *disconnectionError = [NSError errorWithDomain:@"domain" code:100 userInfo:errorDict];
            _connectPeripheralCompletionBlock(NO,disconnectionError);
        }
        else
            _connectPeripheralCompletionBlock(NO,error);
    }
    
    [self redirectToRootviewcontroller];
    [self refreshPeripherals];
    
    if (_discoveryDlegate)
    {
        [_discoveryDlegate disconnectPeripheral];
    }
}

#pragma mark    -peripheral delegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    
    [self cancelTimeOutAlert];
    if(error == nil)
    {
        if ([peripheral.name isEqualToString:_currentConnectPeripheral.name])
        {
            _services = [peripheral.services mutableCopy];
        }
        _connectPeripheralCompletionBlock(YES,error);
    }
    else
    {
        _connectPeripheralCompletionBlock(NO,error);
    }
    
}

#pragma mark - characteristic
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID.UUIDString isEqualToString:_currentService.UUID.UUIDString])
    {
        _characteristics = [service.characteristics mutableCopy];
    }
    
    if (_discoverServiceCharactersCompletionBlock)
    {
        if (error)
        {
            _discoverServiceCharactersCompletionBlock(NO,error);
        }
        else
        {
            _discoverServiceCharactersCompletionBlock(YES,error);
        }
        
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([_currentPeripheralDelegate respondsToSelector:@selector(peripheral:didUpdateValueForCharacteristic:error:)])
        [_currentPeripheralDelegate peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([_currentPeripheralDelegate respondsToSelector:@selector(peripheral:didWriteValueForCharacteristic:error:)])
    {
        [_currentPeripheralDelegate peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([characteristic.UUID.UUIDString isEqualToString:_currentCharacteristic.UUID.UUIDString])
    {
        _descriptors = [characteristic.descriptors mutableCopy];
    }
    
    if([_currentPeripheralDelegate respondsToSelector:@selector(peripheral:didDiscoverDescriptorsForCharacteristic:error:)])
    {
        [_currentPeripheralDelegate peripheral:peripheral didDiscoverDescriptorsForCharacteristic:characteristic error:error];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    if([_currentPeripheralDelegate respondsToSelector:@selector(peripheral:didUpdateValueForDescriptor:error:)])
    {
        [_currentPeripheralDelegate peripheral:peripheral didUpdateValueForDescriptor:descriptor error:error];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if ([_currentPeripheralDelegate respondsToSelector:@selector(peripheral:didUpdateNotificationStateForCharacteristic:error:)])
    {
        [_currentPeripheralDelegate peripheral:peripheral didUpdateNotificationStateForCharacteristic:characteristic error:error];
    }
}
#pragma mark    -connect method
-(void)connectPeripheral:(CBPeripheral *)peripheral CompletionBlock:(ConnectPeripheralCompletionBlock)completionHandler
{
    if((NSInteger)[_centralManager state] == CBCentralManagerStatePoweredOn)
    {
        _connectPeripheralCompletionBlock = completionHandler ;
        
        if ([peripheral state] == CBPeripheralStateDisconnected)
        {
            [_centralManager connectPeripheral:peripheral options:nil];
            _currentConnectPeripheral = peripheral;
        }
        else
        {
            [_centralManager cancelPeripheralConnection:peripheral];
        }
        
        [self performSelector:@selector(timeOutMethodForConnect) withObject:nil afterDelay:10.f];
        
    }
}

-(void)disconnectPeripheral
{
    if (_currentConnectPeripheral)
    {
        [_centralManager cancelPeripheralConnection:_currentConnectPeripheral];
        _currentConnectPeripheral = nil;
    }
    //central delegate will clearDevices when u disconnect peripheral
    //    [self clearDevices];
}

-(void)connectService:(CBService *)service CompletionBlock:(DiscoverServiceCharactersCompletionBlock)block
{
    _currentService = service;
    _discoverServiceCharactersCompletionBlock = block;
    
    [_currentConnectPeripheral discoverCharacteristics:nil forService:_currentService];
}

-(void)cancelTimeOutAlert
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeOutMethodForConnect) object:nil];
}

-(void)timeOutMethodForConnect
{
    NSLog(@"time out");
    [self disconnectPeripheral];
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:@"connectionTimeOutAlert" forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:@"domain" code:100 userInfo:errorDetail];
    [self refreshPeripherals];
    _connectPeripheralCompletionBlock(NO,error);
}

- (void)refreshPeripherals
{
    //清空已存设备并重新开始搜索服务
    [self clearDevices];
    [[CBManager sharedManager] stopScan];
    [[CBManager sharedManager] startScan];
}

-(void)redirectToRootviewcontroller
{
    if(_discoveryDlegate)
    {
        [[(UIViewController *)_discoveryDlegate navigationController] popToRootViewControllerAnimated:YES];
    }
//    else if(cbCharacteristicDelegate)
//    {
//        [[(UIViewController*)cbCharacteristicDelegate navigationController] popToRootViewControllerAnimated:YES];
//    }
}
@end

