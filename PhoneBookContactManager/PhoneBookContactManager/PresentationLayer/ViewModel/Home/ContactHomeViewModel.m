//
//  ContactHomeViewModel.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/23/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import "ContactHomeViewModel.h"

@interface ContactHomeViewModel()
//@property NSMutableDictionary *contactDictionary;
//@property NSMutableArray *sessitonArray;
//@property NSMutableArray *contactSearchArray;
@property BContactStore *contactStore;
@property dispatch_queue_t serialSearchQueue;
//@property BOOL isSearching;
@property BOOL isNeedReload;

//================
@property NSMutableDictionary *contactDictionary;
@property NSMutableDictionary *contactsDictionaryInSerchMode;
@property BOOL isSearching;

@end

@implementation ContactHomeViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.contactDictionary = [[NSMutableDictionary alloc] init];
        self.contactsDictionaryInSerchMode = [[NSMutableDictionary alloc] init];
        NSMutableArray *contactsInSearchMode = [[NSMutableArray alloc] init];
        [self.contactsDictionaryInSerchMode setObject:contactsInSearchMode forKey:@"Search result"];
//        self.sessitonArray = [[NSMutableArray alloc] init];
//        self.contactSearchArray = [[NSMutableArray alloc] init];
        self.contactStore = [[BContactStore alloc] init];
        self.serialSearchQueue = dispatch_queue_create("search queue", DISPATCH_QUEUE_SERIAL);
        self.isSearching = NO;
        self.isNeedReload = YES;
    }
    return self;
}

- (void)requestPermision {
    [self.contactStore checkAuthorizeStatus:^(BOOL granted, NSError * _Nonnull error) {
        if (granted == NO) {
            NSLog(@"dont have permisson");
            if([[self delegate] respondsToSelector:@selector(showPermisionDenied)]){
                    [self.delegate showPermisionDenied];
            }
            else
                NSLog(@"unresponds to selector");
        } else
            [self loadContactFromBussinessLayer];
    }];
}

- (void)loadContactFromBussinessLayer {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.contactStore loadContactWithCallback:^(NSMutableDictionary * _Nullable dicContacts, NSError * _Nullable error) {
            if (error) {
                if([self.delegate respondsToSelector:@selector(showFailToLoadContact)])
                    [self.delegate showFailToLoadContact];
            } else {
                //clear exists contact
                [self.contactDictionary removeAllObjects];
                self.contactDictionary = dicContacts;
                
                if ([self.delegate respondsToSelector:@selector(loadDataComplete)])
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self.delegate loadDataComplete];
                    });
                else
                    NSLog(@"unresponds to selector");
            }
        }];
    });
    
    self.isNeedReload = NO;
}

- (NSMutableDictionary*)contactsDictionaryForTableView {
    if (self.isSearching)
        return self.contactsDictionaryInSerchMode;
    
    return self.contactDictionary;
}

- (void)removeContactModel:(ContactModel *)model withCallback:(contactTableCallback)callback {
    
    //delete in dictionary
    //if searchmode -> delete in dictionary, else do nothing because deleted in tableview (ref)

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ContactTableCallbackInfor *info = [ContactTableCallbackInfor new];

        [self.contactStore deleteContactForIdentifier:model.identifier withCallback:^(NSError * _Nullable error, NSString *identifier) {
            if (error) {
                info.code = FAIL;
                //show err on UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([self.delegate respondsToSelector:@selector(deleteContactFail)])
                        [self.delegate deleteContactFail];
                    });
            } else {
                info.code = SUCCESS;
                if (self.isSearching) {
                    //delete in dataSource
                    BOOL isFound = NO;
                    for (NSString* section in [self.contactDictionary allKeys]) {
                        NSMutableArray *contacts = [self.contactDictionary objectForKey:section];
                        
                        //delete cell
                        for (ContactModel *contact in contacts) {
                            if ([contact.identifier isEqualToString:model.identifier]) {
                                [[self.contactDictionary objectForKey:section] removeObject:contact];
                                isFound = YES;
                                break;
                            }
                        }
                        
                        //delete section
                        if ([contacts count] == 0) {
                            [self.contactDictionary removeObjectForKey:section];
                        }
                        if (isFound) break;
                    }
                }
            }
            callback(info);
        }];
    });
}

-(void)searchWithString:(NSString *)keyToSearch {
    dispatch_async(self.serialSearchQueue, ^{
        if (keyToSearch.length == 0) {
            self.isSearching = NO;
            
            if(self.isNeedReload)
                [self loadContactFromBussinessLayer];
        } else {
            self.isSearching = YES;
            [[self.contactsDictionaryInSerchMode objectForKey:@"Search result"] removeAllObjects];
            
            //search in dictionary
            for (NSMutableArray* session in self.contactDictionary.allValues) {
                for (ContactModel *model in session) {
                    if([model.fullName respondsToSelector:@selector(rangeOfString:)]) {
                        NSRange nameRange =[model.fullName rangeOfString:keyToSearch options:NSCaseInsensitiveSearch];
                        if(nameRange.location != NSNotFound) {
                            [[self.contactsDictionaryInSerchMode objectForKey:@"Search result"] addObject:model];
                        }
                    }
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(loadDataComplete)])
                [self.delegate loadDataComplete];
        });
    });
}

- (void)addNewContact:(EditingContactModel *)editContactModel {
    if (editContactModel == nil) {
        NSAssert(editContactModel != nil, @"Param 'editContactModel' should be a nonnull value.");
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ContactModel *model = editContactModel.contactModel;
        NSString *sessionName = [model getSection];
        
        //add session
        if ([self.contactDictionary objectForKey:sessionName] == nil) {
            //add new session if not exists
            NSMutableArray * contactSessionArray = [[NSMutableArray alloc] init];
            [contactSessionArray addObject:model];
            [self.contactDictionary setObject:contactSessionArray forKey:sessionName];
            
        } else
            [[self.contactDictionary objectForKey:sessionName] addObject:model];
        
        if ([self.delegate respondsToSelector:@selector(loadDataComplete)])
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate loadDataComplete];
            });
        else
            NSLog(@"unresponds to selector");
    });
    
}

- (void)editContact:(EditingContactModel *)editContactModel {
    if (editContactModel == nil) {
        NSAssert(editContactModel != nil, @"Param 'editContactModel' should be nonnull.");
        return;
    }
    
    //remove from old data and add to new section if needed
    ContactModel *model = editContactModel.contactModel;
    if (![editContactModel.oldSection isEqualToString:[model getSection]]) {
        BOOL isFound = NO;
        for (NSString* section in [self.contactDictionary allKeys]) {
            NSMutableArray *contacts = [self.contactDictionary objectForKey:section];
            
            //delete ui cell
            for (ContactModel *contact in contacts) {
                if ([contact.identifier isEqualToString:model.identifier]) {
                    [[self.contactDictionary objectForKey:section] removeObject:contact];
                    isFound = YES;
                    break;
                }
            }
            
            //delete section
            if ([contacts count] == 0) {
                [self.contactDictionary removeObjectForKey:section];
            }
            if (isFound) break;
        }
        
        [self addNewContact:editContactModel];
    } else {
        if([self.delegate respondsToSelector:@selector(loadDataComplete)])
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate loadDataComplete];
            });
        else
            NSLog(@"unresponds to selector");
    }
}

- (BOOL)isInValidSection:(NSInteger)section andRow:(NSInteger)row {
    if (!self.isSearching) {
        NSInteger numOfSection = [[self.contactDictionary allKeys] count];
        if(section >= numOfSection) {
            NSAssert(section < numOfSection, @"Param 'section' out of bound. Section = %ld", section);
            return YES;
        }
    } else {
        //in searching mode
        NSInteger numOfContacts = [[self.contactsDictionaryInSerchMode objectForKey:@"Search result"] count];
        if(numOfContacts <= row) {
            NSAssert(row < numOfContacts, @"Param 'row' out of bound. Row = %ld", row);
            return YES;
        }
    }
    return NO;
}
@end

