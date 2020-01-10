//
//  ContactTableView.h
//  PhoneBookContactManager
//
//  Created by CPU11716 on 1/10/20.
//  Copyright © 2020 CPU11716. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactModel.h"
#import "ContactTableViewCell.h"
#import "ContactTableCallbackInfor.h"
NS_ASSUME_NONNULL_BEGIN
@class ContactTableView;
typedef void(^contactTableCallback)(ContactTableCallbackInfor *_Nullable error);

@protocol ContactTableViewDatasource <NSObject>

@required
- (NSMutableDictionary <NSString*, NSMutableArray<id<ContactModelProtocol>>*> *) contactModelForContactTableView:(ContactTableView*)contactTableView;

@end

@protocol contactTableViewDelegate <NSObject>

@optional
//cho chép làm gì đó trước khi bắt đầu xoá: vd hỏi lại người dùng có muốn xoá...
- (void)acceptDeleteTableCellAt:(NSIndexPath *) indexPath withCallback:(contactTableCallback) callback;
//bắt đầu xoá cell
- (void)willRemoveContactFromContactTableView:(ContactModel*) contactModel withCallback:(contactTableCallback) callback;
- (void)didSelectContact:(ContactModel*)contact;
@end

@interface ContactTableView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<ContactTableViewDatasource> datasource;
@property (nonatomic, weak) id<contactTableViewDelegate> delegate;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
