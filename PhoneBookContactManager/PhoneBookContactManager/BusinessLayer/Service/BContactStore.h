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
#import "ContactModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^loadBusinessContactCallback)(NSMutableArray * _Nullable businesscontactArray, NSError *_Nullable error);
typedef void(^dictionaryContactCallback)(NSMutableDictionary * _Nullable dicContacts, NSMutableArray * _Nullable sections, NSError *_Nullable error);

@interface BContactStore : NSObject

-(void) checkAuthorizeStatus:(void(^) (BOOL granted, NSError *error)) callBack;

-(void) loadContactWithCallback:(loadBusinessContactCallback) callback;
-(void) loadContactWithCallback2:(dictionaryContactCallback) callback;

-(void) loadImageForIdentifier:(NSString *)identifier withCallback:(loadImageCallback) callback;

-(void) deleteContactForIdentifier:(NSString *)identifier withCallback:(writeContactCallback) callback;

-(void) addNewContact:(BContactModel*) contact :(NSData *) image withCallback:(writeContactCallback) callback;

-(void) updateContact:(BContactModel*) contact :(NSData *) image withCallback:(writeContactCallback) callback;
@end

NS_ASSUME_NONNULL_END
