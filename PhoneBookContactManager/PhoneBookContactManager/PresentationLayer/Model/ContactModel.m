//
//  ContactModel.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/23/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import "ContactModel.h"

@implementation ContactModel

- (instancetype)initWithBusinessContact:(BContactModel *)contactModel {
    if(contactModel == nil) {
        NSAssert(contactModel != nil, @"Param 'contactModel' should be nonnull");
        return nil;
    }
    
    self=[super init];
    if(self) {
        _phoneNumberArray = [[NSMutableArray alloc] init];
        
        _identifier = [contactModel identifier];
        _givenName  = [contactModel givenName];
        _middleName = [contactModel middleName];
        _familyName = [contactModel familyName];
        _fullName   = [contactModel fullName];
        _avatarName = [self generateAvatarName:_givenName :_familyName];
        _avatarName = [_avatarName uppercaseString];
        
        if([[contactModel phoneNumberArray] count]>0) {
            for (NSString *number in [contactModel phoneNumberArray]) {
                [_phoneNumberArray addObject:[number copy]];
            }
        }
    }
    
    return self;
}

- (instancetype)initWithContactModel:(ContactModel *)contactModel {
    if(contactModel == nil) {
        NSAssert(contactModel != nil, @"Param 'contactModel' should be nonnull");
        return nil;
    }
    
    self=[super init];
    if(self) {
        _phoneNumberArray = [[NSMutableArray alloc] init];
        
        _identifier = [contactModel identifier];
        _givenName  = [contactModel givenName];
        _middleName = [contactModel middleName];
        _familyName = [contactModel familyName];
        _fullName   = [NSString stringWithFormat:@"%@ %@ %@",_givenName,_middleName,_familyName];
        
        
        _avatarName = [self generateAvatarName:_givenName :_familyName];
        _avatarName = [_avatarName uppercaseString];
        
        if([[contactModel phoneNumberArray] count]>0) {
            if([self.fullName isEqualToString:@"  "])
                self.fullName = [[contactModel phoneNumberArray] objectAtIndex:0];
            
            for (NSString *number in [contactModel phoneNumberArray]) {
                [_phoneNumberArray addObject:[number copy]];
            }
        }
        
        if([self.fullName isEqualToString:@"  "])
            self.fullName = @"No name";
    }
    
    return self;
}

- (NSString *)generateAvatarName: (NSString *) firstName :(NSString*) lastName {
    NSString *first = (firstName == nil)? @"" : firstName;
    NSString *last  = (lastName == nil)? @"" : lastName;
    
    if(![first isEqualToString:@""] && ![last isEqualToString:@""])
        return [[NSString alloc] initWithFormat:@"%c%c",[first characterAtIndex:0],[last characterAtIndex:0]];
    
    if(![first isEqualToString:@""])
        return [[NSString alloc] initWithFormat:@"%c",[first characterAtIndex:0]];
    
    if(![last isEqualToString:@""])
        return [[NSString alloc] initWithFormat:@"%c",[last characterAtIndex:0]];
    
    return @"*";
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", self.fullName];
}

@end
