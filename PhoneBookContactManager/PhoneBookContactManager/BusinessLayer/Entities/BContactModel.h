//
//  BContactModel.h
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/23/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DContactDTO.h"

NS_ASSUME_NONNULL_BEGIN

@interface BContactModel : NSObject

@property NSString *identifier;
@property NSString *givenName;
@property NSString *middleName;
@property NSString *familyName;
@property NSString *fullName;
@property NSMutableArray *phoneNumberArray;

- (instancetype)initWithDContactDTO: (DContactDTO*)contactDTO;
- (NSString*)description;

@end

NS_ASSUME_NONNULL_END
