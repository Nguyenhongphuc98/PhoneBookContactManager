//
//  DContactStore.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/18/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import "DContactStore.h"

@implementation DContactStore

+(instancetype) sharedInstance {
    static DContactStore *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        sharedInstance= [[DContactStore alloc] init];
    });
    
    return sharedInstance;
}

-(instancetype) init {
    self=[super init];
    
    if(self){
        _loadContactCallbackArray   = [[NSMutableArray alloc] init];
        _callbackQueueArray         = [[NSMutableArray alloc] init];
        _callbackDictionary         = [[NSMutableDictionary alloc] init];
        _serialTaskQueue            = dispatch_queue_create("main task queue", DISPATCH_QUEUE_SERIAL);
        _concurentReadWriteQueue    = dispatch_queue_create("readwrite queue", DISPATCH_QUEUE_CONCURRENT); //allow mutil read avatar, block write with dispatch barries
        _isLoadingContact = NO;
    }
    
    return self;
}

-(void) checkAuthorizeStatus:(void (^)(BOOL, NSError * _Nullable)) callback {
    
    CNEntityType entityType = CNEntityTypeContacts;
    CNAuthorizationStatus authorizationStatus=[CNContactStore authorizationStatusForEntityType:entityType];
    
    switch (authorizationStatus) {
        case CNAuthorizationStatusNotDetermined:
        {
            CNContactStore *contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:entityType completionHandler:^(BOOL granted, NSError * _Nullable error) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                     callback(granted,error);
                });
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

-(void) loadContactWithCallback:(loadContactCallback)callback onQueue:(dispatch_queue_t) callbackQueue {
    
    //block nil can make crash app
    if(callback == nil) {
        
        return;
    }
    
    dispatch_async(_serialTaskQueue, ^{
        
        //add block to array to transfer later
        if(callbackQueue == nil){
            [self.loadContactCallbackArray addObject:callback];
        }else {
            //check cb queue exists
            NSString *queueName = [[NSString alloc] initWithFormat: @"%s", dispatch_queue_get_label(callbackQueue)];
            if([self.callbackQueueArray containsObject:callbackQueue]){
                [[self.callbackDictionary objectForKey:queueName] addObject:callback];
            }else {
                [self.callbackQueueArray addObject:callbackQueue];
                NSMutableArray *cbArr = [NSMutableArray new];
                [cbArr addObject:callback];
                [self.callbackDictionary setObject:cbArr forKey:queueName];
            }
        }
        
        //don't load contact when have other thread is loading from device or transfer data to callbaclk
        if(self.isLoadingContact)
            return;
        
        self.isLoadingContact = YES;
        
        //loading on other thead to don't have wait to add block to completeHandle array
        //just read one time -> don't worry about concurrent queue
        dispatch_async(self.concurentReadWriteQueue, ^{
            if([CNContactStore class])
            {
                CNContactStore *contactStore = [[CNContactStore alloc] init];
                NSArray *keysToFetch = @[CNContactIdentifierKey,
                                         CNContactFamilyNameKey,
                                         CNContactMiddleNameKey,
                                         CNContactGivenNameKey,
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

-(void) responseContactForCallback:(NSError * _Nullable)error contactDTOArray:(NSMutableArray * _Nullable) contacts {
    
    //transfer on one queue (serial task queue) with addblock to make sure no block added when transfering
    dispatch_async(self.serialTaskQueue, ^{
        
        //using for transfer and avoid remove object needed when remove object from contacts (async)
        NSMutableArray * contactForTransferArray =[[NSMutableArray alloc] init];
        if(contacts!=nil){
            contactForTransferArray = [contacts copy];
        }
        
        //response for request don't have queue
        for (loadContactCallback callback in self.loadContactCallbackArray) {
            if(callback!=nil){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    callback(contactForTransferArray,error);
                });
            }else
                NSLog(@"callback == nill");
        }
        
        //response on special queue
        for (dispatch_queue_t queue in self.callbackQueueArray) {
            NSString *queueName = [[NSString alloc] initWithFormat: @"%s", dispatch_queue_get_label(queue)];
            NSMutableArray *cbArray = [self.callbackDictionary objectForKey:queueName];
            
            for (loadContactCallback callback in cbArray) {
                if(callback!=nil){
                    dispatch_async(queue, ^{
                        callback(contactForTransferArray,error);
                    });
                }else
                    NSLog(@"callback == nill");
            }
        }
        
        //refesh data for next time
        [self.loadContactCallbackArray removeAllObjects];
        [self.callbackQueueArray removeAllObjects];
        [self.callbackDictionary removeAllObjects];
        self.isLoadingContact = NO;
    });
}

- (void)loadImageForIdentifier:(NSString *)identifier withCallback:(loadImageCallback _Nonnull)callback {
    
    if(callback == nil || identifier == nil)
        return;
    
    // allow multi read
    dispatch_async(self.concurentReadWriteQueue, ^{
        CNContactStore *contactStore = [CNContactStore new];
        NSError *loadImageError;
        
        CNContact *contact = [contactStore unifiedContactWithIdentifier:identifier keysToFetch:@[CNContactImageDataKey] error:&loadImageError];
        if(loadImageError){
            callback(nil,loadImageError);
        }else
            callback([contact imageData],nil);
    });
}

//write method ===================================================
- (void)deleteContactForIdentifier:(NSString *)identifier  withCallback:(nonnull writeContactCallback) callback {
    if(identifier==nil || callback == nil)
        return;
    
    dispatch_async(self.concurentReadWriteQueue, ^{
        CNContactStore *contactStore = [CNContactStore new];
        NSError *__block deleteError;
        
        CNContact *contact = [contactStore unifiedContactWithIdentifier:identifier keysToFetch:@[CNContactPhoneNumbersKey] error:&deleteError];
        if(deleteError) {
            callback(deleteError,nil);
        } else {
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

- (void)addNewContact:(DContactDTO *)contact :(NSData*) image withCallback:(nonnull writeContactCallback) callback {
    
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
            }else
                callback(addcontactError,nil);
            });
    });
}

- (void)updateContact:(DContactDTO *)contact :(NSData *)image withCallback:(nonnull writeContactCallback) callback {
    if(contact == nil || callback == nil)
        return;
    
    dispatch_barrier_sync(self.concurentReadWriteQueue, ^{
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
        }else
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
