//
//  HomeContactViewController.h
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/23/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactHomeViewModel.h"
#import "NewContactViewController.h"
#import "ContactTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeContactViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate,CHViewModelObserver>

@end

NS_ASSUME_NONNULL_END
