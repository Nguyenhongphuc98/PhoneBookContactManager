//
//  DContactDTO.h
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/18/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>

NS_ASSUME_NONNULL_BEGIN

@interface DContactDTO : NSObject

@property NSString *identifier;
@property NSString *givenName;
@property NSString *middleName;
@property NSString *familyName;
@property NSMutableArray *phoneNumberArray;

-(instancetype) initWithCNContact: (CNContact*) cnContact;
-(NSString*) description;

@end

NS_ASSUME_NONNULL_END
