//
//  NSData+CharacterEncoding.h
//  Tools
//
//  Created by ml on 16/8/24.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (CharacterEncoding)

- (NSString *)convertDataToString;

+ (NSMutableData *)dataFromHexString:(NSString *)string;
@end
