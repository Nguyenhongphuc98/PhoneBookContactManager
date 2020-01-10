//
//  ShowContactsVC.h
//  PhoneBookContactManager
//
//  Created by CPU11716 on 1/10/20.
//  Copyright © 2020 CPU11716. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactTableView.h"
#import "ContactHomeViewModel.h"
#import "NewContactViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeContactViewController : UIViewController <ContactTableViewDatasource, contactTableViewDelegate, CHViewModelObserver, UISearchBarDelegate>

@end

NS_ASSUME_NONNULL_END
