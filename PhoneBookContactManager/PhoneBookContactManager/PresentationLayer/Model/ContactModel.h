//
//  ContactModel.h
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/23/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BContactModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactModel : NSObject

@property NSString *identifier;
@property NSString *avatarName;
@property NSString *givenName;
@property NSString *middleName;
@property NSString *familyName;
@property NSString *fullName;
@property NSMutableArray *phoneNumberArray;

-(instancetype) initWithBusinessContact: (BContactModel*) contactModel;
-(instancetype) initWithContactModel: (ContactModel*) contactModel;
-(NSString*) description;
@end

NS_ASSUME_NONNULL_END
