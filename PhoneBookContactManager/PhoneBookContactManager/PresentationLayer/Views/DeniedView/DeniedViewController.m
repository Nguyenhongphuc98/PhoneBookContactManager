//
//  DeniedViewController.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 1/6/20.
//  Copyright © 2020 CPU11716. All rights reserved.
//

#import "DeniedViewController.h"

@interface DeniedViewController ()

@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelbutton;
@end

@implementation DeniedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)dismisCurrentView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)openSettings:(id)sender {
    if([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:)])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

@end
