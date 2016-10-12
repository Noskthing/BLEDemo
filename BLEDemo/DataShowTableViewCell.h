//
//  DataShowTableViewCell.h
//  BLEDemo
//
//  Created by ml on 2016/10/12.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataShowTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *key;
@property (weak, nonatomic) IBOutlet UILabel *value;
@property (weak, nonatomic) IBOutlet UILabel *className;

@end
