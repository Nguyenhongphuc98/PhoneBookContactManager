//
//  UIColor+Gradient.h
//  PhoneBookContactManager
//
//  Created by CPU11716 on 1/17/20.
//  Copyright © 2020 CPU11716. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Gradient)

@property NSArray* gradientColorArray;

//contains start & end color of gradient
- (NSArray*)generateRandomColor;

//get random gradient
- (CAGradientLayer*)generateRandomGradient:(UIView*) view;

@end

NS_ASSUME_NONNULL_END
