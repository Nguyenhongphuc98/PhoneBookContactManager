//
//  ContactTableViewCell.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/23/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import "ContactTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "CacheStore.h"
#import "BContactStore.h"

@interface ContactTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *contactAvatar;
@property (weak, nonatomic) IBOutlet UILabel *contactDisplayName;

@end

@implementation ContactTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _contactAvatar.layer.cornerRadius = 25;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)fillData:(ContactModel*) model{
    
    //try to get data from cacheStore
    UIImage *__block cacheImage = [[CacheStore sharedInstance] getImagefor:model.identifier];
    
    if(cacheImage){
        self.contactAvatar.image = cacheImage;
    }
    else
    {
        //try to get from device
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[[BContactStore alloc] init] loadImageForIdentifier:model.identifier withHandle:^(NSData * _Nullable image, NSError * _Nullable error) {
                if(!error && image)
                {
                    UIImage * imageFromDevice =[[UIImage alloc] initWithData:image];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.contactAvatar.image = imageFromDevice;
                    });
                    
                    //save to store cache
                    [[CacheStore sharedInstance] setImage:imageFromDevice for:model.identifier];
                }
                else
                {
                    UIImage * __block imageFromText;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //create avatar with text and save to cache
                        imageFromText = [self drawText:[model avatarName]];
                        self.contactAvatar.image = imageFromText;
                        
                        //save to store cache
                        [[CacheStore sharedInstance] setImage:imageFromText for:model.identifier];
                    });
                }
            }];
        });
        
    }
    
    [self.contactDisplayName setText:[model fullName]];
}

- (UIImage*) drawText:(NSString*) text{
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    nameLabel.text = text;
    nameLabel.backgroundColor = UIColor.greenColor;
    nameLabel.textAlignment=NSTextAlignmentCenter;
    
    UIGraphicsBeginImageContextWithOptions(nameLabel.bounds.size, nameLabel.opaque, 1.0);
    [[nameLabel layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end