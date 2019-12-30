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

typedef void(^loadContactCompleteHandle)(NSMutableArray * _Nullable contactDTOArray, NSError *_Nullable error);
typedef void(^loadImageCompleteHandle)(NSData *_Nullable image, NSError *_Nullable error);
typedef void(^writeContactCompleteHandle)(NSError *_Nullable error,NSString *_Nullable identifier);

@interface DContactStore : NSObject

@property NSMutableArray *loadContactCompleteHandleArray;
@property dispatch_queue_t serialTaskQueue;
@property dispatch_queue_t concurentReadWriteQueue;
@property BOOL isLoadingContact;

+(instancetype) sharedInstance;

-(instancetype) init;

-(void) checkAuthorizeStatus:(void(^) (BOOL granted, NSError *error)) callback;

//read method
-(void) loadContactWithCompleteHandle: (loadContactCompleteHandle) callback;

-(void) responseContactForCallback: (NSError * _Nullable) error contactDTOArray: (NSMutableArray * _Nullable) contacts;

-(void) loadImageForIdentifier:(NSString*) identifier withHandle:(loadImageCompleteHandle) callback;

//write method
-(void) deleteContactWithIdentifier:(NSString*) identifier andHandle:(writeContactCompleteHandle) callback;

-(void) addNewContact:(DContactDTO*) contact :(NSData *) image andHandle:(writeContactCompleteHandle) callback;

-(void) updateContact:(DContactDTO*) contact :(NSData *) image andHandle:(writeContactCompleteHandle) callback;

@end

NS_ASSUME_NONNULL_END
