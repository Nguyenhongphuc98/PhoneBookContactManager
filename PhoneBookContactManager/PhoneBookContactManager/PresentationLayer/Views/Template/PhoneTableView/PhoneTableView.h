//
//  PhoneTableview.h
//  PhoneBookContactManager
//
//  Created by CPU11716 on 1/20/20.
//  Copyright © 2020 CPU11716. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class PhoneTableView;
@protocol PhoneTableViewDatasource <NSObject>

- (NSMutableArray*)phoneModelForPhoneTableView:(PhoneTableView*) tableView;

@end

@interface PhoneTableView : UIView <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,weak) id<PhoneTableViewDatasource> dataSource;
@property (nonatomic) BOOL isCanEdit;
@property (nonatomic) NSLayoutConstraint *phoneTableViewContrains;

- (void)allowEditting:(BOOL)isAllow;
- (void)reloadData;
@end

NS_ASSUME_NONNULL_END
