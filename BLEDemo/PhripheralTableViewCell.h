//
//  PhripheralTableViewCell.h
//  BLEDemo
//
//  Created by ml on 16/8/25.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhripheralTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *serviceCount;
@property (weak, nonatomic) IBOutlet UILabel *RSSI;
@property (weak, nonatomic) IBOutlet UILabel *UUIDString;

@end
