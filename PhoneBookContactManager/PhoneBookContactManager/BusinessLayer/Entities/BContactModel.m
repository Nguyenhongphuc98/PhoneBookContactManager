//
//  BContactModel.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/23/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import "BContactModel.h"

@implementation BContactModel

- (instancetype)initWithDContactDTO:(DContactDTO *)contactDTO {
    if (contactDTO == nil) {
        NSLog(@"contactDTO is nil");
        return nil;
    }
    
    self = [super init];
    if (self) {
        _phoneNumberArray = [[NSMutableArray alloc] init];
        
        _identifier = [contactDTO identifier];
        _givenName  = [contactDTO givenName];
        _middleName = [contactDTO middleName];
        _familyName = [contactDTO familyName];
        
        NSString *firstName  = (contactDTO.givenName != nil)? contactDTO.givenName : @"";
        NSString *secondName = (contactDTO.middleName != nil)? contactDTO.middleName : @"";
        NSString *lastName   = (contactDTO.familyName != nil)? contactDTO.familyName : @"";
        _fullName   = [NSString stringWithFormat:@"%@ %@ %@",firstName,secondName,lastName];
        
        if ([[contactDTO phoneNumberArray] count]>0) {
            if ([self.fullName isEqualToString:@"  "])
                self.fullName = [[contactDTO phoneNumberArray] objectAtIndex:0];

            for (NSString *number in [contactDTO phoneNumberArray]) {
                [_phoneNumberArray addObject:[number copy]];
            }
        }
        
        if ([self.fullName isEqualToString:@"  "])
            self.fullName = @"No name";
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", self.fullName];
}
@end
