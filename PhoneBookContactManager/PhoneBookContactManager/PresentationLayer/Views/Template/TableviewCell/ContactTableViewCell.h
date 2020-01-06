//
//  ContactTableViewCell.h
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/23/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactTableViewCell : UITableViewCell

-(void) fillData:(ContactModel *_Nonnull) model;
@end

NS_ASSUME_NONNULL_END
