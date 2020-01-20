//
//  NSLayoutConstraint+Description.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 1/20/20.
//  Copyright © 2020 CPU11716. All rights reserved.
//

#import "NSLayoutConstraint+Description.h"

@implementation NSLayoutConstraint (Description)
-(NSString *)description {
    return [NSString stringWithFormat:@"id: %@, constant: %f", self.identifier, self.constant];
}
@end
