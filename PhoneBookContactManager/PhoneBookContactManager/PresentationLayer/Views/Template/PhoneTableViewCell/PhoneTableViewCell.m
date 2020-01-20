//
//  PhoneTableViewCell.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 1/20/20.
//  Copyright © 2020 CPU11716. All rights reserved.
//

#import "PhoneTableViewCell.h"
@interface PhoneTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *phoneTypeLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (nonatomic) id<PhoneModelProtocol> model;

@end

@implementation PhoneTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)fillData:(id<PhoneModelProtocol>)model {
    _model = model;
    [_phoneTypeLabel setText:model.phoneType];
    [_phoneNumberTextField setText:model.phoneNumber];
}

- (IBAction)didChangePhoneNumber:(id)sender {
    [_model setPhoneNumber:_phoneNumberTextField.text];
}
@end
