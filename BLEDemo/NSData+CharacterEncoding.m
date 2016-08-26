//
//  NSData+CharacterEncoding.m
//  Tools
//
//  Created by ml on 16/8/24.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import "NSData+CharacterEncoding.h"

@implementation NSData (CharacterEncoding)

-(NSString *)convertDataToString
{
    NSMutableString *string = [NSMutableString stringWithString:@""];
    
    for (int i = 0; i < self.length; i++)
    {
        unsigned char byte;
        [self getBytes:&byte range:NSMakeRange(i, 1)];
        
        if (byte >= 32 && byte < 127)
        {
            [string appendFormat:@"%c", byte];
        }
        
    }
    return string;
}


+(NSMutableData *)dataFromHexString:(NSString *)string
{
    NSMutableData *data = [NSMutableData new];
    NSCharacterSet *hexSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF "] invertedSet];
    
    // Check whether the string is a valid hex string. Otherwise return empty data
    if ([string rangeOfCharacterFromSet:hexSet].location == NSNotFound)
    {
        
        string = [string lowercaseString];
        unsigned char whole_byte;
        char byte_chars[3] = {'\0','\0','\0'};
        int i = 0;
        int length = (int)string.length;
        
        while (i < length-1)
        {
            char c = [string characterAtIndex:i++];
            
            if (c < '0' || (c > '9' && c < 'a') || c > 'f')
                continue;
            byte_chars[0] = c;
            byte_chars[1] = [string characterAtIndex:i++];
            whole_byte = strtol(byte_chars, NULL, 16);
            [data appendBytes:&whole_byte length:1];
        }
    }
    return data;
}
@end
