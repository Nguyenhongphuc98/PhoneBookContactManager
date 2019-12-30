//
//  BContactStore.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/23/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import "BContactStore.h"

@implementation BContactStore

- (void)checkAuthorizeStatus:(void (^)(BOOL, NSError * _Nonnull))callBack{
    [[DContactStore sharedInstance] checkAuthorizeStatus:^(BOOL granted, NSError * _Nonnull error) {
        callBack(granted,error);
    }];
}

- (void)loadContactWithCompleteHandle:(loadBusinessContactCompleteHandle)callback{
    [[DContactStore sharedInstance] loadContactWithCompleteHandle:^(NSMutableArray * _Nullable contactDTOArray, NSError * _Nullable error) {
        if(error){
            callback(nil,error);
        }
        else{
            NSMutableArray *BContactModelArray = [[NSMutableArray alloc] init];
            for (DContactDTO * contactDTO in contactDTOArray) {
                [BContactModelArray addObject:[[BContactModel alloc] initWithDContactDTO: contactDTO]];
            }
            
            callback(BContactModelArray,nil);
        }
    }];
}

-(void) loadImageForIdentifier:(NSString *)identifier withHandle: (loadImageCompleteHandle) callback{
    if(callback ==nil)
        return;
    
    [[DContactStore sharedInstance] loadImageForIdentifier:identifier withHandle:^(NSData * _Nullable image, NSError * _Nullable error) {
        callback(image,error);
    }];
}

- (void)deleteContactWithIdentifier:(NSString *)identifier andHandle:(writeContactCompleteHandle)callback{
    if(callback ==nil)
        return;

    [[DContactStore sharedInstance] deleteContactWithIdentifier:identifier andHandle:^(NSError * _Nullable error, NSString* identifier) {
        callback(error,identifier);
    }];
}

- (void)addNewContact:(BContactModel *)contact :(NSData *)image andHandle:(writeContactCompleteHandle)callback{
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // convert to DcontactDTO
        DContactDTO *newContact = [self convertBcontactToDcontactDTO:contact];
        
        [[DContactStore sharedInstance] addNewContact:newContact :image andHandle:^(NSError * _Nullable error, NSString* identifier) {
            callback(error,identifier);
        }];
    });
}

- (void)updateContact:(BContactModel *)contact :(NSData *)image andHandle:(writeContactCompleteHandle)callback{
    DContactDTO *updateContact = [self convertBcontactToDcontactDTO:contact];
    [[DContactStore sharedInstance] updateContact:updateContact :image andHandle:^(NSError * _Nullable error, NSString * _Nullable identifier) {
        callback(error,identifier);
    }];
}

-(DContactDTO*) convertBcontactToDcontactDTO:(BContactModel*) contact{
    if(contact == nil)
        return nil;
    
    DContactDTO *newContact = [DContactDTO new];
    newContact.identifier = contact.identifier;
    newContact.familyName = contact.familyName;
    newContact.middleName = contact.middleName;
    newContact.givenName  = contact.givenName;
    newContact.phoneNumberArray = contact.phoneNumberArray;
    return newContact;
}

@end
