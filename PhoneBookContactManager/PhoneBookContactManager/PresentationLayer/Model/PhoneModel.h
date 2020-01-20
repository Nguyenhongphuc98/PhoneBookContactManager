//
//  PhoneModel.h
//  PhoneBookContactManager
//
//  Created by CPU11716 on 1/20/20.
//  Copyright © 2020 CPU11716. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PhoneModelProtocol <NSObject>

@property NSString* phoneType;
@property NSString* phoneNumber;

@end

@interface PhoneModel : NSObject <PhoneModelProtocol>
@property NSString* phoneType;
@property NSString* phoneNumber;

- (instancetype) initWithType:(NSString*)type andPhone:(NSString*)phone;
@end

NS_ASSUME_NONNULL_END
