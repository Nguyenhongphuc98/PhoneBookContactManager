//
//  PhoneTableViewCell.h
//  PhoneBookContactManager
//
//  Created by CPU11716 on 1/20/20.
//  Copyright © 2020 CPU11716. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhoneTableViewCell : UITableViewCell

- (void)fillData:(id<PhoneModelProtocol>)model;
@end

NS_ASSUME_NONNULL_END
