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
#import "DeniedViewController.h"
#import "PhoneTableView.h"
#import "PhoneModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NewContactViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, PhoneTableViewDatasource, NewContactObserver>

@property EditingContactModel *editContactModel;
@property (nonatomic) BOOL isHavePermission;

@end

NS_ASSUME_NONNULL_END
