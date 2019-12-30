//
//  EditingContactModel.h
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/30/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    ViewDetailContact = 0,
    AddNewContact,
    EditContact,
} ContactAction;

@interface EditingContactModel : NSObject
@property ContactAction action;
@property NSIndexPath *indexPath;
@property ContactModel* contactModel;
@end

NS_ASSUME_NONNULL_END
