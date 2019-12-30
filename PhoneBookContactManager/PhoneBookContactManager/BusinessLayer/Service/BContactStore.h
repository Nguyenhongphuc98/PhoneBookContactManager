//
//  BContactStore.h
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/23/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DContactStore.h"
#import "BContactModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^loadBusinessContactCompleteHandle)(NSMutableArray * _Nullable businesscontactArray, NSError *_Nullable error);

@interface BContactStore : NSObject

-(void) checkAuthorizeStatus:(void(^) (BOOL granted, NSError *error)) callBack;

-(void) loadContactWithCompleteHandle: (loadBusinessContactCompleteHandle) callback;

-(void) loadImageForIdentifier:(NSString *)identifier withHandle: (loadImageCompleteHandle) callback;

- (void)deleteContactWithIdentifier:(NSString *)identifier andHandle:(nonnull writeContactCompleteHandle)callback;

-(void) addNewContact:(BContactModel*) contact :(NSData *) image andHandle:(writeContactCompleteHandle) callback;

-(void) updateContact:(BContactModel*) contact :(NSData *) image andHandle:(writeContactCompleteHandle) callback;
@end

NS_ASSUME_NONNULL_END
