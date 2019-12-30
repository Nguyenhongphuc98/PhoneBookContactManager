//
//  DContactStore.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/18/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import "DContactStore.h"

@implementation DContactStore

+(instancetype) sharedInstance{
    static DContactStore *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        sharedInstance= [[DContactStore alloc] init];
    });
    
    return sharedInstance;
}

-(instancetype) init{
    self=[super init];
    
    if(self){
        _loadContactCompleteHandleArray = [[NSMutableArray alloc] init];
        _serialTaskQueue = dispatch_queue_create("main task queue", DISPATCH_QUEUE_SERIAL);
        _concurentReadWriteQueue = dispatch_queue_create("readwrite queue", DISPATCH_QUEUE_CONCURRENT); //allow mutil read avatar, block write with dispatch barries
        _isLoadingContact = NO;
    }
    
    return self;
}

-(void) checkAuthorizeStatus:(void (^)(BOOL, NSError * _Nullable))callback{
    
    CNEntityType entityType = CNEntityTypeContacts;
    CNAuthorizationStatus authorizationStatus=[CNContactStore authorizationStatusForEntityType:entityType];
    
    switch (authorizationStatus) {
        case CNAuthorizationStatusNotDetermined:
        {
            CNContactStore *contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:entityType completionHandler:^(BOOL granted, NSError * _Nullable error) {
                callback(granted,error);
            }];
            break;
        }
            
        case CNAuthorizationStatusAuthorized:
        {
            callback(YES,nil);
            break;
        }
            
        case CNAuthorizationStatusDenied:
        {
            callback(NO,nil);
            break;
        }
            
        case CNAuthorizationStatusRestricted:
        {
            callback(NO,nil);
            break;
        }
            
        default:
            callback(NO,nil);
            break;
    }
}

-(void) loadContactWithCompleteHandle:(loadContactCompleteHandle)callback{
    
    //block nil can make crash app
    if(callback==nil)
        return;
    
    dispatch_async(_serialTaskQueue, ^{
        
        //add block to array to transfer later
        [self.loadContactCompleteHandleArray addObject:callback];
        
        //don't load contact when have other thread is loading from device or transfer data to callbaclk
        if(self.isLoadingContact)
            return;
        
        self.isLoadingContact=YES;
        
        NSLog(@"loading data....");
        
        //loading on other thead to don't have wait to add block to completeHandle array
        //just read one time -> don't worry about concurrent queue
        dispatch_async(self.concurentReadWriteQueue, ^{
            if([CNContactStore class])
            {
                CNContactStore *contactStore = [[CNContactStore alloc] init];
                NSArray *keysToFetch = @[CNContactIdentifierKey,
                                         CNContactFamilyNameKey, //ten
                                         CNContactMiddleNameKey, //ten dem
                                         CNContactGivenNameKey,  //ho
                                         CNContactPhoneNumbersKey,
                                         CNContactImageDataKey];
                
                CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
                fetchRequest.predicate = nil;
                NSError *errorFetchContact;
                
                NSMutableArray *contactArray =[[NSMutableArray alloc] init];
                BOOL resultEnumerate = [contactStore enumerateContactsWithFetchRequest:fetchRequest error:&errorFetchContact usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
                    
                    if(errorFetchContact == nil && contact != nil){
                        DContactDTO *contactDTO = [[DContactDTO alloc] initWithCNContact:contact];
                        [contactArray addObject:contactDTO];
                    }
                }];
                
                if(resultEnumerate==YES)
                    [self responseContactForCallback:nil contactDTOArray:contactArray];
                else
                    [self responseContactForCallback:errorFetchContact contactDTOArray:nil];
            }
        });
    });
}

-(void) responseContactForCallback:(NSError * _Nullable)error contactDTOArray:(NSMutableArray * _Nullable)contacts{
    
    //transfer on one queue (serial task queue) with addblock to make sure no block added when transfering
    dispatch_async(self.serialTaskQueue, ^{
        
        //using for transfer and avoid remove object needed when remove object from contacts (async)
        NSMutableArray * contactForTransferArray =[[NSMutableArray alloc] init];
        if(contacts!=nil){
            contactForTransferArray = [contacts copy];
        }
        
        for (loadContactCompleteHandle callback in self.loadContactCompleteHandleArray) {
            if(callback!=nil){
                //NSLog(@"callback!= nill");
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    callback(contactForTransferArray,error);
                });
            }
            else
                NSLog(@"callback == nill");
        }
        
        //refesh data for next time
        [self.loadContactCompleteHandleArray removeAllObjects];
        self.isLoadingContact = NO;
    });
}

- (void)loadImageForIdentifier:(NSString *)identifier withHandle:(loadImageCompleteHandle)callback{
    
    if(callback == nil)
        return;
    
    // allow multi read
    dispatch_async(self.concurentReadWriteQueue, ^{
        CNContactStore *contactStore = [CNContactStore new];
        NSError *loadImageError;
        
        CNContact *contact = [contactStore unifiedContactWithIdentifier:identifier keysToFetch:@[CNContactImageDataKey] error:&loadImageError];
        if(loadImageError){
            callback(nil,loadImageError);
        }
        else
            callback([contact imageData],nil);
    });
}

//write method ===================================================
- (void)deleteContactWithIdentifier:(NSString *)identifier andHandle:(nonnull writeContactCompleteHandle)callback{
    if(identifier==nil || callback == nil)
        return;
    
    dispatch_async(self.concurentReadWriteQueue, ^{
        CNContactStore *contactStore = [CNContactStore new];
        NSError *__block deleteError;
        
        CNContact *contact = [contactStore unifiedContactWithIdentifier:identifier keysToFetch:@[CNContactPhoneNumbersKey] error:&deleteError];
        if(deleteError){
            callback(deleteError,nil);
        }
        else
        {
            //excute delete on this contact
            dispatch_barrier_async(self.concurentReadWriteQueue, ^{
                CNSaveRequest * saveRequest = [CNSaveRequest new];
                [saveRequest deleteContact:[contact mutableCopy]];
                BOOL excuteResult = [contactStore executeSaveRequest:saveRequest error:&deleteError];
                if(excuteResult)
                     callback(nil,identifier);
                else
                     callback(deleteError,nil);
            });
        }
        
    });
}

- (void)addNewContact:(DContactDTO *)contact :(NSData*) image andHandle:(writeContactCompleteHandle)callback{
    
    if(contact == nil || callback == nil)
        return;
    
    dispatch_async(self.concurentReadWriteQueue, ^{
        CNContactStore *contactStore = [CNContactStore new];
        NSError *__block addcontactError;
        
        //create contact with origin format
        CNMutableContact *newContact = [CNMutableContact new];
        newContact.givenName = contact.givenName;
        newContact.middleName = contact.middleName;
        newContact.familyName = contact.familyName;
        
        if(image)
        newContact.imageData = image;
        
        NSMutableArray *labelArray = [self genratePhoneNumberArray:contact];
        if(labelArray != nil)
            newContact.phoneNumbers = labelArray;
        
        //excute save on this contact
        dispatch_barrier_async(self.concurentReadWriteQueue, ^{
            CNSaveRequest * saveRequest = [CNSaveRequest new];
            [saveRequest addContact:newContact toContainerWithIdentifier:nil];
            BOOL excuteResult = [contactStore executeSaveRequest:saveRequest error:&addcontactError];
            if(excuteResult)
            {
                if([newContact isKeyAvailable:CNContactIdentifierKey])
                    callback(nil,[newContact identifier]);
                else
                    callback(nil,nil);
            }
            else
                callback(addcontactError,nil);
            });
    });
}

- (void)updateContact:(DContactDTO *)contact :(NSData *)image andHandle:(writeContactCompleteHandle)callback{
    if(contact == nil || callback == nil)
        return;
    
    dispatch_async(self.concurentReadWriteQueue, ^{
        CNContactStore *contactStore = [CNContactStore new];
        
        NSError *__block updateError;
        NSArray *keysToFetch = @[CNContactIdentifierKey,
                                 CNContactFamilyNameKey, //ten
                                 CNContactMiddleNameKey, //ten dem
                                 CNContactGivenNameKey,  //ho
                                 CNContactPhoneNumbersKey,
                                 CNContactImageDataKey];
        
        CNContact *cnContact = [contactStore unifiedContactWithIdentifier:contact.identifier keysToFetch:keysToFetch error:&updateError];
        if(updateError){
            callback(updateError,nil);
        }
        else
        {
            CNMutableContact *newContact = [cnContact mutableCopy];
            newContact.givenName = contact.givenName;
            newContact.middleName = contact.middleName;
            newContact.familyName = contact.familyName;
            
            if(image)
                newContact.imageData = image;
            
            NSMutableArray *labelArray = [self genratePhoneNumberArray:contact];
            if(labelArray != nil)
                newContact.phoneNumbers = labelArray;
            
            //excute update on this contact
            dispatch_barrier_async(self.concurentReadWriteQueue, ^{
                CNSaveRequest * saveRequest = [CNSaveRequest new];
                [saveRequest updateContact:newContact];
                BOOL excuteResult = [contactStore executeSaveRequest:saveRequest error:&updateError];
                if(excuteResult)
                    callback(nil,contact.identifier);
                else
                    callback(updateError,nil);
            });
            
        }
    });
}

-(NSMutableArray*) genratePhoneNumberArray:(DContactDTO *) contact{
    if(contact == nil)
        return nil;
    
    CNLabeledValue *homePhone;
    CNLabeledValue *workPhone;
    NSMutableArray *labelArray =[NSMutableArray new];
    
    if(contact.phoneNumberArray.count ==1 ){
        homePhone = [CNLabeledValue labeledValueWithLabel:CNLabelHome value:[CNPhoneNumber phoneNumberWithStringValue:contact.phoneNumberArray[0]]];
        [labelArray addObject:homePhone];
    }
    
    if(contact.phoneNumberArray.count ==2 ){
        homePhone = [CNLabeledValue labeledValueWithLabel:CNLabelHome value:[CNPhoneNumber phoneNumberWithStringValue:contact.phoneNumberArray[0]]];
        [labelArray addObject:homePhone];
        
        workPhone = [CNLabeledValue labeledValueWithLabel:CNLabelWork value:[CNPhoneNumber phoneNumberWithStringValue:contact.phoneNumberArray[1]]];
        [labelArray addObject:workPhone];
    }
    
    return labelArray;
}
@end
