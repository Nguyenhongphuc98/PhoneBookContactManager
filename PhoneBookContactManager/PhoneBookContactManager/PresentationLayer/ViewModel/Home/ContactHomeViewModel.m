//
//  ContactHomeViewModel.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/23/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import "ContactHomeViewModel.h"

@interface ContactHomeViewModel()
@property NSMutableDictionary *contactDictionary;
@property NSMutableArray *sessitonArray;
@property NSMutableArray *contactSearchArray;
@property BContactStore *contactStore;

@property BOOL isSearching;

@end

@implementation ContactHomeViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contactDictionary = [[NSMutableDictionary alloc] init];
        self.sessitonArray = [[NSMutableArray alloc] init];
        self.contactSearchArray = [[NSMutableArray alloc] init];
        self.contactStore = [[BContactStore alloc] init];
        self.isSearching = NO;
    }
    return self;
}

-(void) requestPermision{
    [self.contactStore checkAuthorizeStatus:^(BOOL granted, NSError * _Nonnull error) {
        if(granted == NO){
            NSLog(@"dont have permisson");
            if([[self delegate] respondsToSelector:@selector(showPermisionDenied)]){
                [self.delegate showPermisionDenied];
            }
        }
        else
            [self loadContactFromBussinessLayer];
    }];
    
    
}

- (void)loadContactFromBussinessLayer{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.contactStore loadContactWithCompleteHandle:^(NSMutableArray * _Nullable businesscontactArray, NSError * _Nullable error) {
            if(error){
                [self.delegate showFailToLoadContact];
            }
            else{
                //add contact to dictionary
                for (BContactModel *contact in businesscontactArray) {
                    ContactModel *model = [[ContactModel alloc] initWithBusinessContact:contact];
                    NSString *sessionName;
                    if([[model avatarName] length] == 1)
                        sessionName = [model avatarName];
                    else
                        sessionName = [[model avatarName] substringWithRange:NSMakeRange(1, 1)];
                    
                    //add session
                    if([self.contactDictionary objectForKey:sessionName] == nil){
                        //add new session if not exists
                        NSMutableArray * contactSessionArray = [[NSMutableArray alloc] init];
                        [contactSessionArray addObject:model];
                        [self.contactDictionary setObject:contactSessionArray forKey:sessionName];
                    }
                    else
                        [[self.contactDictionary objectForKey:sessionName] addObject:model];
                }
                
                //sort A->Z
                NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:[self.contactDictionary allKeys]];
                self.sessitonArray = [[NSMutableArray alloc] initWithArray:[tempArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
                
                if([self.delegate respondsToSelector:@selector(loadDataComplete)])
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self.delegate loadDataComplete];
                    });
                
                else
                    NSLog(@"unresponds to selector");
            }
        }];
    });
}

-(void)searchWithString:(NSString *)keyToSearch{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(keyToSearch.length == 0){
            self.isSearching = NO;
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate loadDataComplete];
            });
        }
        else{
            self.isSearching = YES;
            [self.contactSearchArray removeAllObjects];
            
            //search in dictionary
            for (NSMutableArray* session in self.contactDictionary.allValues) {
                for (ContactModel *model in session) {
                    if([model.fullName respondsToSelector:@selector(rangeOfString:)])
                    {
                        NSRange nameRange =[model.fullName rangeOfString:keyToSearch options:NSCaseInsensitiveSearch];
                        if(nameRange.location != NSNotFound){
                            [self.contactSearchArray addObject:model];
                        }
                    }
                }
    
               
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate loadDataComplete];
            });
        }
    });
}

//get method
- (NSString *)getTitleForHeaderInSection:(NSInteger)session{
    if(session>= [self.sessitonArray count])
    {
        NSLog(@"can't get session out of bound");
        return @"";
    }
    
    if(self.isSearching)
        return @"Search result";
    else
        return [self.sessitonArray objectAtIndex:session];
}

- (NSInteger)getNumberOfSection{
    if(self.isSearching)
        return 1;
    
    return [self.sessitonArray count];
}

- (NSInteger)getNumberOfRowInSection:(NSInteger)section{
    if(section>= [self.sessitonArray count])
    {
        NSLog(@"can't get number rows of this session: %ld", section);
        return 0;
    }
    
    if(self.isSearching)
        return [self.contactSearchArray count];
    else
        return [[self.contactDictionary objectForKey:[self.sessitonArray objectAtIndex:section]] count];
}

- (ContactModel *)getModel:(NSInteger)section :(NSInteger)row{
    
    if([self isInValidSection:section andRow:row])
        return nil;
   
    if(self.isSearching)
        return [self.contactSearchArray objectAtIndex:row];
    else
    {
        NSString * sesctionKey = [self.sessitonArray objectAtIndex:section];
        return [[self.contactDictionary objectForKey:sesctionKey] objectAtIndex:row];
    }
}

- (void)removeCellAt:(NSInteger)section andRow:(NSInteger)row{
    
    if(self.isSearching == NO)
    {
        if([self isInValidSection:section andRow:row])
            return;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString * sectionKey = [self.sessitonArray objectAtIndex:section];
            ContactModel *contactNeedDelete = [[self.contactDictionary objectForKey:sectionKey] objectAtIndex:row];
            [self.contactStore deleteContactWithIdentifier:contactNeedDelete.identifier andHandle:^(NSError * _Nullable error, NSString* identifier) {
                if(error){
                    //show err on UI
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if([self.delegate respondsToSelector:@selector(deleteContactFail)])
                            [self.delegate deleteContactFail];
                    });
                }
                else{
                    //delete from data source
                    [[self.contactDictionary objectForKey:sectionKey] removeObjectAtIndex:row];
                    //update in fo on UI
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if([self.delegate respondsToSelector:@selector(deleteContactSuccess:removeSection:)])
                        {
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                            [self.delegate deleteContactSuccess:indexPath removeSection:NO];
                        }
                    });
                }
                
            }];
        });
    }
    else
    {
        [self removeCellInSearchMode:section andRow:row];
    }
}

-(void) removeCellInSearchMode:(NSInteger)section andRow:(NSInteger)row{
    //delete in device
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ContactModel *contactNeedDelete = [self.contactSearchArray objectAtIndex:row];
        [self.contactStore deleteContactWithIdentifier:contactNeedDelete.identifier andHandle:^(NSError * _Nullable error, NSString* identifier) {
            if(error){
                //show err on UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([self.delegate respondsToSelector:@selector(deleteContactFail)])
                        [self.delegate deleteContactFail];
                });
            }
            else{
                //delete in searching list
                [self.contactSearchArray removeObjectAtIndex:row];
                
                //delete in dictionary
                NSString *sectionName;
                if([[contactNeedDelete avatarName] length] == 1)
                    sectionName = [contactNeedDelete avatarName];
                else
                    sectionName = [[contactNeedDelete avatarName] substringWithRange:NSMakeRange(1, 1)];
                
                //get contact in this section
                ContactModel *ct;
                for (int i=0; i<[[self.contactDictionary objectForKey:sectionName] count]; i++) {
                    ct = [[self.contactDictionary objectForKey:sectionName] objectAtIndex:i];
                    if([ct.identifier isEqualToString:contactNeedDelete.identifier])
                    {
                        [[self.contactDictionary objectForKey:sectionName] removeObjectAtIndex:i];
                        break;
                    }
                }
                
                //if don't have any cell in this section -> delete section in data source (dic +keyArr)
                if([[self.contactDictionary objectForKey:sectionName] count] == 0)
                {
                    [self.contactDictionary removeObjectForKey:sectionName];
                    for (NSString *section in self.sessitonArray) {
                        if([section isEqualToString:sectionName])
                        {
                            [self.sessitonArray removeObject:section];
                            break;
                        }
                    }
                }
                
                
                //update info on UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([self.delegate respondsToSelector:@selector(deleteContactSuccess:removeSection:)])
                    {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                        [self.delegate deleteContactSuccess:indexPath removeSection:NO];
                    }
                });
            }
            
        }];
    });
}

- (void)removeSection:(NSInteger)section{
    
    if(self.isSearching == NO)
    {
        NSString * sectionKey = [self.sessitonArray objectAtIndex:section];
        
        //if just have 1 cell in this session
        if([[self.contactDictionary objectForKey:sectionKey] count] == 1)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString * sectionKey = [self.sessitonArray objectAtIndex:section];
                ContactModel *contactNeedDelete = [[self.contactDictionary objectForKey:sectionKey] objectAtIndex:0];
                [self.contactStore deleteContactWithIdentifier:contactNeedDelete.identifier andHandle:^(NSError * _Nullable error, NSString *identifier) {
                    if(error){
                        //show err on UI
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if([self.delegate respondsToSelector:@selector(deleteContactFail)])
                                [self.delegate deleteContactFail];
                        });
                    }
                    else{
                        //delete from data source
                        [[self.contactDictionary objectForKey:sectionKey] removeAllObjects];
                        [self.contactDictionary removeObjectForKey:sectionKey];
                        [self.sessitonArray removeObjectAtIndex:section];
                        //update in fo on UI
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if([self.delegate respondsToSelector:@selector(deleteContactSuccess:removeSection:)])
                            {
                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
                                [self.delegate deleteContactSuccess:indexPath removeSection:YES];
                            }
                        });
                    }
                    
                }];
            });
            
        }
        else
            NSLog(@"can't remove session when contain multi cells");
    }
    else
    {
        //delete in search mode : just have only 1 section and 1 row
        [self removeCellInSearchMode:0 andRow:0];
        NSLog(@"deleting section...");
    }
}

- (void)addNewContact:(EditingContactModel *)editContactModel{
    if(editContactModel == nil)
        return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ContactModel *model = [[ContactModel alloc] initWithContactModel: editContactModel.contactModel];
        
        NSString *sessionName;
        if([[model avatarName] length] == 1)
            sessionName = [model avatarName];
        else
            sessionName = [[model avatarName] substringWithRange:NSMakeRange(1, 1)];
        
        //add session
        if([self.contactDictionary objectForKey:sessionName] == nil){
            //add new session if not exists
            NSMutableArray * contactSessionArray = [[NSMutableArray alloc] init];
            [contactSessionArray addObject:model];
            [self.contactDictionary setObject:contactSessionArray forKey:sessionName];
            
            //re sort A->Z session
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:[self.contactDictionary allKeys]];
            self.sessitonArray = [[NSMutableArray alloc] initWithArray:[tempArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
        }
        else
            [[self.contactDictionary objectForKey:sessionName] addObject:model];
        
        if([self.delegate respondsToSelector:@selector(loadDataComplete)])
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate loadDataComplete];
            });
        
        else
            NSLog(@"unresponds to selector");
    });
    
}

- (void)editContact:(EditingContactModel *)editContactModel{
    if(editContactModel == nil)
        return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        ContactModel *model = [[ContactModel alloc] initWithContactModel: editContactModel.contactModel];
        if(self.isSearching == NO)
        {
            if([self isInValidSection:editContactModel.indexPath.section andRow:editContactModel.indexPath.row])
                return;
            
            NSString *sessionName = [self.sessitonArray objectAtIndex:editContactModel.indexPath.section];
            
            [[self.contactDictionary objectForKey:sessionName] replaceObjectAtIndex:editContactModel.indexPath.row withObject: model];
        }
       else
       {
           //update model after searching
           //update model searching
           for (ContactModel *m in self.contactSearchArray) {
               if([m.identifier isEqualToString:editContactModel.contactModel.identifier])
               {
                   m.avatarName = model.avatarName;
                   m.fullName   = model.fullName;
                   m.givenName  = model.givenName;
                   m.middleName = model.middleName;
                   m.familyName = model.familyName;
                   m.phoneNumberArray = model.phoneNumberArray;
                   break;
               }
           }
           
           //update model in dictionary
           //get contact in this section
           NSString *sectionName;
           if([[model avatarName] length] == 1)
               sectionName = [model avatarName];
           else
               sectionName = [[model avatarName] substringWithRange:NSMakeRange(1, 1)];
           
           for (ContactModel *mDic in [self.contactDictionary objectForKey:sectionName]) {
               if([mDic.identifier isEqualToString:model.identifier])
               {
                   mDic.avatarName = model.avatarName;
                   mDic.fullName   = model.fullName;
                   mDic.givenName  = model.givenName;
                   mDic.middleName = model.middleName;
                   mDic.familyName = model.familyName;
                   mDic.phoneNumberArray = model.phoneNumberArray;
                   break;
               }
           }
       }
        
        if([self.delegate respondsToSelector:@selector(loadDataComplete)])
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate loadDataComplete];
            });
        
        else
            NSLog(@"unresponds to selector");
    });
}

-(BOOL) isInValidSection:(NSInteger)section andRow:(NSInteger)row{
    if(!self.isSearching)
    {
        if(section>= [self.sessitonArray count])
        {
            NSLog(@"session out of bound %ld", section);
            return YES;
        }
        
        NSString * sessionKey = [self.sessitonArray objectAtIndex:section];
        if([[self.contactDictionary objectForKey:sessionKey] count]<= row)
        {
            NSLog(@"row out of boud - sesson:%ld - row: %ld", section,row);
            return YES;
        }
    }
    else{
        //in searching mode
        if([self.contactSearchArray count] <= row)
        {
            NSLog(@"row out of bound  - row: %ld", row);
            return YES;
        }
    }
    
    return NO;
}
@end

