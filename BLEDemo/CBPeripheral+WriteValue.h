//
//  CBPeripheral+WriteValue.h
//  BLEProject
//
//  Created by ml on 16/9/7.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (WriteValue)

/*!
 *  @method writeValue:forCharacteristic:  use system method writeValue:forCharacteristic:type: and choose type automatic
 *
 *  @param data				The value to write.
 *  @param characteristic	The characteristic whose characteristic value will be written.
 *  @param type				The type of write to be executed.
 *
 *  @discussion				Writes <i>value</i> to <i>characteristic</i>'s characteristic value.
 *							If the <code>CBCharacteristicWriteWithResponse</code> type is specified, {@link peripheral:didWriteValueForCharacteristic:error:}
 *							is called with the result of the write request.
 *							If the <code>CBCharacteristicWriteWithoutResponse</code> type is specified, the delivery of the data is best-effort and not
 *							guaranteed.
 *
 *  @see					peripheral:didWriteValueForCharacteristic:error:
 *	@see					CBCharacteristicWriteType
 */
- (void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic;

@end
