//
//  ContactTableError.h
//  PhoneBookContactManager
//
//  Created by CPU11716 on 1/10/20.
//  Copyright © 2020 CPU11716. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum :NSUInteger {
    DENIED = 0,
    FAIL,
    ACCEPT,
    SUCCESS,
} ContaactTableCallbackCode;

@interface ContactTableCallbackInfor : NSObject
@property ContaactTableCallbackCode code;
@property NSString *message;
@end

NS_ASSUME_NONNULL_END
