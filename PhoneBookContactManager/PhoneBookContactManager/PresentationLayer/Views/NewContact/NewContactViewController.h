//
//  NewContactViewController.h
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/25/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewContactViewModel.h"
#import "EditingContactModel.h"
#import "CacheStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface NewContactViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate,NewContactObserver>
@property EditingContactModel * editContactModel;

@end

NS_ASSUME_NONNULL_END
