//
//  NSArray+judge.m
//  Tools
//
//  Created by ml on 2016/10/11.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import "NSArray+judge.h"
#import <objc/runtime.h>

@implementation NSArray (judge)

+(void)load
{
    @autoreleasepool
    {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            /* objectAtIndex */
            [self class:objc_getClass("__NSArrayM") exchangeImplementation:@selector(objectAtIndex:) Implementation:@selector(swizzling_mutableArrayObjectAtIndex:)];
            
            [self class:objc_getClass("__NSArrayI") exchangeImplementation:@selector(objectAtIndex:) Implementation:@selector(swizzling_arrayObjectAtIndex:)];
            
            /* addObject: */
            [self class:objc_getClass("__NSArrayM") exchangeImplementation:@selector(addObject:) Implementation:@selector(swizzling_addObject:)];
        });
        
    }
}

#pragma mark    objectAtIndex:
- (id)swizzling_arrayObjectAtIndex:(NSUInteger)index
{
    if (self.count == 0)
    {
        return nil;
    }
    
    if (index > self.count - 1)
    {
        index = self.count - 1;
    }
    
    return [self swizzling_arrayObjectAtIndex:index];
}

- (id)swizzling_mutableArrayObjectAtIndex:(NSUInteger)index
{
    if (self.count == 0)
    {
        return nil;
    }
    
    if (index > self.count - 1)
    {
        index = self.count - 1;
    }
    
    return [self swizzling_mutableArrayObjectAtIndex:index];
}

#pragma mark    addObject:
- (void)swizzling_addObject:(id)object
{
    if (object)
    {
        [self swizzling_addObject:object];
    }
}

#pragma mark    swizzling method
+ (void)class:(Class)class exchangeImplementation:(SEL)originalSelector Implementation:(SEL)newSelector
{
    Method originalaMethod = class_getInstanceMethod(class, originalSelector);
    Method newMethod = class_getInstanceMethod(class, newSelector);
    
    
    if (class_addMethod(class, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
    {
        class_replaceMethod(class, newSelector, method_getImplementation(originalaMethod), method_getTypeEncoding(originalaMethod));
    }
    else
    {
        method_exchangeImplementations(originalaMethod, newMethod);
    }
}


@end
