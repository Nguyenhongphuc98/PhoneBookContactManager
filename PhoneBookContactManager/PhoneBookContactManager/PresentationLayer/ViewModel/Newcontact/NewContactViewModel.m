//
//  NewContactViewModel.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/25/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import "NewContactViewModel.h"

@implementation NewContactViewModel

- (void)addNewContact:(ContactModel *_Nonnull)model :(NSData*)imageData {
    if (model == nil) {
        NSAssert(model != nil, @"Param 'model' should be nonnull");
        return;
    }
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BContactStore *contactStore = [BContactStore new];
        BContactModel *newContact = [self convertContactModelToBContactModel:model];
        
        [contactStore addNewContact:newContact :imageData withCallback:^(NSError * _Nullable error, NSString * _Nullable identifier) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([self.delegate respondsToSelector:@selector(onAddNewContactFail)])
                        [self.delegate onAddNewContactFail];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([self.delegate respondsToSelector:@selector(onAddNewContactSuccess:)])
                        [self.delegate onAddNewContactSuccess:identifier];
                });
            }
        }];
    });
}

- (void)updateContact:(ContactModel *_Nonnull)model :(NSData *)imageData {
    if(model == nil) {
        NSAssert(model != nil, @"Param 'model' should be nonnull");
        return;
    }
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BContactStore *contactStore = [BContactStore new];
        BContactModel *contactNeedUpdate = [self convertContactModelToBContactModel:model];
        
        //save to store cache
        //UIImage *image = [[UIImage alloc] initWithData:imageData];
        //        if (image)
        //            [[CacheStore sharedInstance] setImage:image for:contactNeedUpdate.identifier];
        
        [contactStore updateContact:contactNeedUpdate :imageData withCallback:^(NSError * _Nullable error, NSString * _Nullable identifier) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([self.delegate respondsToSelector:@selector(onUpdateContactFail)])
                        [self.delegate onUpdateContactFail];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([self.delegate respondsToSelector:@selector(onUpdateContactSuccess:)])
                        [self.delegate onUpdateContactSuccess:identifier];
                });
            }
        }];
    });
}

-(BContactModel*) convertContactModelToBContactModel:(ContactModel*)model {
    if (model == nil) {
        NSAssert(model != nil, @"Param 'model' should be nonnull");
        return nil;
    }
    
    BContactModel *newContact = [BContactModel new];
    newContact.identifier = model.identifier;
    newContact.givenName = model.givenName;
    newContact.familyName = model.familyName;
    newContact.middleName = model.middleName;
    newContact.phoneNumberArray = model.phoneNumberArray;
    return newContact;
}
@end
