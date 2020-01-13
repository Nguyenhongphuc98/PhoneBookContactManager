//
//  NewContactViewModel.h
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/25/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BContactStore.h"
#include "ContactModel.h"
#import "CacheStore.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NewContactObserver <NSObject>

- (void)onAddNewContactSuccess:(NSString *)identifier;
- (void)onAddNewContactFail;

- (void)onUpdateContactSuccess:(NSString *)identifier;
- (void)onUpdateContactFail;

@end

@interface NewContactViewModel : NSObject

@property (weak,nonatomic) id<NewContactObserver> delegate;

- (void)addNewContact:(ContactModel *_Nonnull)model :(NSData*)imageData;

- (void)updateContact:(ContactModel *_Nonnull)model :(NSData*)imageData;
@end

NS_ASSUME_NONNULL_END
