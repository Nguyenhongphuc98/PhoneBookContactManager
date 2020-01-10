//
//  ContactHomeViewModel.h
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/23/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BContactStore.h"
#import "ContactModel.h"
#import "EditingContactModel.h"
#import "ContactTableView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CHViewModelObserver <NSObject>
@required
-(void) loadDataComplete;

-(void) deleteContactSuccess:(NSIndexPath*) indexPath removeSection:(BOOL) isRemoveSection;
-(void) deleteContactFail;

-(void) showPermisionDenied;
-(void) showFailToLoadContact;
@end

@interface ContactHomeViewModel : NSObject
@property (weak,nonatomic) id<CHViewModelObserver> delegate;

- (instancetype)init;

- (void)requestPermision;

- (void)loadContactFromBussinessLayer;

- (void)searchWithString:(NSString*) keyToSearch;

- (void)addNewContact:(EditingContactModel*) editContactModel;

- (void)editContact:(EditingContactModel*) editContactModel;

- (NSMutableDictionary*)contactsDictionaryForTableView;

- (void)removeContactModel:(ContactModel*) model withCallback:(contactTableCallback) callback;
@end

NS_ASSUME_NONNULL_END
