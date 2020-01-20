//
//  UIColor+Gradient.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 1/17/20.
//  Copyright © 2020 CPU11716. All rights reserved.
//

#import "UIColor+Gradient.h"
#import <objc/runtime.h>
#include <stdlib.h>

#define UIColorRGB(hexValue) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0xFF00) >> 8))/255.0 blue:((float)(hexValue & 0xFF))/255.0 alpha:1.0]

@implementation UIColor (Gradient)
NSString const *key = @"my.very.unique.key";
- (void)setGradientColorArray:(NSArray*)colorArray {
    objc_setAssociatedObject(self, &key, colorArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray*)gradientColorArray {
     return objc_getAssociatedObject(self, &key);
}

- (NSArray*)generateRandomColor {
    [self setUp];
    int index = arc4random() % ((uint32_t)[self.gradientColorArray count]);
    return [self.gradientColorArray objectAtIndex:index];
}

- (CAGradientLayer *)generateRandomGradient:(UIView*)view {
    [self setUp];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    NSArray *colors = [self generateRandomColor];
    gradient.colors = @[(id)[(UIColor*)[colors objectAtIndex:0] CGColor], (id)[(UIColor*)[colors objectAtIndex:1] CGColor]];
    return gradient;
}

- (void)setUp {
    if (self.gradientColorArray == nil) {
        self.gradientColorArray =@[@[UIColorRGB(0xa0de7e), UIColorRGB(0x54cb68)],
                                   @[UIColorRGB(0x72d5fd), UIColorRGB(0x2a9ef1)],
                                   @[UIColorRGB(0x82b1ff), UIColorRGB(0x665fff)],
                                   @[UIColorRGB(0x00fcfd), UIColorRGB(0x4acccd)],
                                   @[UIColorRGB(0xffcd6a), UIColorRGB(0xffa85c)],
                                   @[UIColorRGB(0xb5b5f7), UIColorRGB(0x9674ec)],
                                   @[UIColorRGB(0xfcc6a3), UIColorRGB(0xef7434)],
                                   @[UIColorRGB(0xe0a2f3), UIColorRGB(0xd669ed)]];
    }
}
@end
