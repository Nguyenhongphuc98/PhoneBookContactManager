//
//  RoundButton.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 1/6/20.
//  Copyright © 2020 CPU11716. All rights reserved.
//

#import "RoundButton.h"

@interface RoundButton()
@property (nonatomic) UIColor *backgroundNormalState;
@property (nonatomic) UIColor *backgroundHightLightState;
@end

@implementation RoundButton

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundNormalState = [UIColor colorWithRed:3/255.0 green:169/255.0 blue:252/255.0 alpha:1];
    self.backgroundHightLightState = [UIColor colorWithRed:3/255.0 green:202/255.0 blue:252/255.0 alpha:1];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.layer.cornerRadius = self.frame.size.height/2;
    [self setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.backgroundColor = self.backgroundNormalState;
}

- (void)setHighlighted:(BOOL)highlighted {
    if(highlighted)
        self.backgroundColor = self.backgroundHightLightState;
    else
        self.backgroundColor = self.backgroundNormalState;
}
@end
