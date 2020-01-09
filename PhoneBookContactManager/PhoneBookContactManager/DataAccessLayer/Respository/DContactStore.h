//
//  DContactStore.h
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/18/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DContactDTO.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^loadContactCallback)(NSMutableArray * _Nullable contactDTOArray, NSError *_Nullable error);
typedef void(^loadImageCallback)(NSData *_Nullable image, NSError *_Nullable error);
typedef void(^writeContactCallback)(NSError *_Nullable error,NSString *_Nullable identifier);

@interface DContactStore : NSObject

@property NSMutableArray        *loadContactCallbackArray;
@property NSMutableArray        *callbackQueueArray;
@property NSMutableDictionary   *callbackDictionary;
@property dispatch_queue_t      serialTaskQueue;
@property dispatch_queue_t      concurentReadWriteQueue;
@property BOOL                  isLoadingContact;

+ (instancetype) sharedInstance;

- (instancetype) init;

- (void)checkAuthorizeStatus:(void(^) (BOOL granted, NSError *error)) callback;

//read method
- (void)loadContactWithCallback: (loadContactCallback _Nonnull) callback onQueue:(dispatch_queue_t _Nullable) callbackQueue;

- (void)responseContactForCallback: (NSError * _Nullable) error contactDTOArray: (NSMutableArray * _Nullable) contacts;

- (void)loadImageForIdentifier:(NSString*) identifier withCallback:(loadImageCallback _Nonnull) callback;

//write method
- (void)deleteContactForIdentifier:(NSString*) identifier withCallback:(writeContactCallback) callback;

- (void)addNewContact:(DContactDTO*) contact :(NSData *_Nullable) image withCallback:(writeContactCallback) callback;

- (void)updateContact:(DContactDTO*) contact :(NSData *_Nullable) image withCallback:(writeContactCallback) callback;

@end

NS_ASSUME_NONNULL_END
