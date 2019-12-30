//
//  DContactDTO.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/18/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import "DContactDTO.h"

@implementation DContactDTO

- (instancetype)initWithCNContact:(CNContact *)cnContact{
    if(cnContact==nil)
    {
        NSLog(@"cnContact is nil");
        return nil;
    }
    
    self=[super init];
    if(self){
        _phoneNumberArray = [[NSMutableArray alloc] init];
        
        _identifier = [cnContact identifier];
        _givenName  = [cnContact givenName];
        _middleName = [cnContact middleName];
        _familyName = [cnContact familyName];
        
        if([[cnContact phoneNumbers] count]>0){
            for (CNLabeledValue *cnLabel in [cnContact phoneNumbers]) {
                NSString *phoneNumber = [cnLabel.value stringValue];
                if([phoneNumber length]>0)
                    [_phoneNumberArray addObject:phoneNumber];
            }
        }
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"name: %@", self.givenName];
}
@end
