//
//  ServiceTableViewCell.h
//  BLEDemo
//
//  Created by ml on 2016/10/11.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServiceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *serviceName;
@property (weak, nonatomic) IBOutlet UILabel *UUIDString;

@end
