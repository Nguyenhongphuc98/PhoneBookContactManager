//
//  BContactStore.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/23/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import "BContactStore.h"

@implementation BContactStore

- (void)checkAuthorizeStatus:(void (^)(BOOL, NSError * _Nonnull)) callback {
    if(callback == nil) {
        NSAssert(callback != nil, @"Param 'callback' should be a nonnull value.");
        return;
    }
    
    [[DContactStore sharedInstance] checkAuthorizeStatus:^(BOOL granted, NSError * _Nonnull error) {
        callback(granted,error);
    }];
}

- (void)loadContactWithCallback:(dictionaryContactCallback) callback {
    if(callback == nil) {
        NSAssert(callback != nil, @"Param 'callback' should be a nonnull value.");
        return;
    }
    
    dispatch_queue_t businessQueue = dispatch_queue_create("from busseness", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(businessQueue, ^{
        [[DContactStore sharedInstance] loadContactWithCallback:^(NSMutableArray * _Nullable contactDTOArray, NSError * _Nullable error) {
            if(error) {
                callback(nil, error);
            } else {
                NSMutableArray *BContactModelArray = [[NSMutableArray alloc] init];
                for (DContactDTO * contactDTO in contactDTOArray) {
                    [BContactModelArray addObject:[[BContactModel alloc] initWithDContactDTO: contactDTO]];
                }
                
                //add contact to dictionary
                NSMutableDictionary *contactDictionary = [NSMutableDictionary new];
                
                for (BContactModel *contact in BContactModelArray) {
                    ContactModel *model = [[ContactModel alloc] initWithBusinessContact:contact];
                    NSString *sessionName;
                    if([[model avatarName] length] == 1)
                        sessionName = [model avatarName];
                    else
                        sessionName = [[model avatarName] substringWithRange:NSMakeRange(1, 1)];
                    
                    //add session
                    if([contactDictionary objectForKey:sessionName] == nil) {
                        //add new session if not exists
                        NSMutableArray * contactSessionArray = [[NSMutableArray alloc] init];
                        [contactSessionArray addObject:model];
                        [contactDictionary setObject:contactSessionArray forKey:sessionName];
                    } else
                        [[contactDictionary objectForKey:sessionName] addObject:model];
                }
                
                callback(contactDictionary, nil);
            }
        } onQueue:businessQueue];
    });
}

- (void)loadImageForIdentifier:(NSString *)identifier withCallback:(loadImageCallback _Nonnull) callback {
    if (identifier == nil || callback == nil) {
        NSAssert(identifier != nil, @"Param 'identifier' should be a nonnull value.");
        NSAssert(callback != nil, @"Param 'callback' should be a nonnull value.");
        return;
    }
    
    [[DContactStore sharedInstance] loadImageForIdentifier:identifier withCallback:^(NSData * _Nullable image, NSError * _Nullable error) {
        callback(image,error);
    }];
}

- (void)deleteContactForIdentifier:(NSString *)identifier withCallback:(nonnull writeContactCallback) callback {
    if (identifier == nil || callback == nil) {
        NSAssert(identifier != nil, @"Param 'identifier' should be a nonnull value.");
        NSAssert(callback != nil, @"Param 'callback' should be a nonnull value.");
        return;
    }

    [[DContactStore sharedInstance] deleteContactForIdentifier:identifier withCallback:^(NSError * _Nullable error, NSString * _Nullable identifier) {
        callback(error,identifier);
    }];
}

- (void)addNewContact:(BContactModel *)contact :(NSData *)image withCallback:(nonnull writeContactCallback) callback {
    if (contact == nil || callback == nil) {
        NSAssert(contact != nil, @"Param 'contact' should be a nonnull value.");
        NSAssert(callback != nil, @"Param 'callback' should be a nonnull value.");
        return;
    }
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // convert to DcontactDTO
        DContactDTO *newContact = [self convertBcontactToDcontactDTO:contact];
        
        [[DContactStore sharedInstance] addNewContact:newContact :image withCallback:^(NSError * _Nullable error, NSString * _Nullable identifier) {
            callback(error,identifier);
        }];
    });
}

- (void)updateContact:(BContactModel *)contact :(NSData *)image withCallback:(nonnull writeContactCallback) callback {
    if (contact == nil || callback == nil) {
        NSAssert(contact != nil, @"Param 'contact' should be a nonnull value.");
        NSAssert(callback != nil, @"Param 'callback' should be a nonnull value.");
        return;
    }
    
    DContactDTO *updateContact = [self convertBcontactToDcontactDTO:contact];
    [[DContactStore sharedInstance] updateContact:updateContact :image withCallback:^(NSError * _Nullable error, NSString * _Nullable identifier) {
         callback(error,identifier);
    }];
}

- (DContactDTO*)convertBcontactToDcontactDTO:(BContactModel*)contact {
    if (contact == nil) {
        NSAssert(contact != nil, @"Param 'contact' should be a nonnull value.");
        return nil;
    }
    
    DContactDTO *newContact = [DContactDTO new];
    newContact.identifier = contact.identifier;
    newContact.familyName = contact.familyName;
    newContact.middleName = contact.middleName;
    newContact.givenName  = contact.givenName;
    newContact.phoneNumberArray = contact.phoneNumberArray;
    return newContact;
}

@end
