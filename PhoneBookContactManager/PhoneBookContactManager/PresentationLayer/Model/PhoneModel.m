//
//  PhoneModel.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 1/20/20.
//  Copyright © 2020 CPU11716. All rights reserved.
//

#import "PhoneModel.h"


@implementation PhoneModel

- (instancetype) initWithType:(NSString*)type andPhone:(NSString*)phone {
    self = [super init];
    if (self) {
        _phoneType = type;
        _phoneNumber = phone;
    }
    return self;
}
@end
