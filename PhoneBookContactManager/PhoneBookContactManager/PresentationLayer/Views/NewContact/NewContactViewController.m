//
//  NewContactViewController.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/25/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import "NewContactViewController.h"
#import "PhoneTableView.h"

@interface NewContactViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UITextField *tfFirstName;
@property (weak, nonatomic) IBOutlet UITextField *tfMiddleName;
@property (weak, nonatomic) IBOutlet UITextField *tfLastName;
@property (weak, nonatomic) IBOutlet UIButton *btnAddPhoto;
@property (nonatomic) UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *addPhonebutton;
@property (weak, nonatomic) IBOutlet UIStackView *addPhoneStackView;
@property (weak, nonatomic) IBOutlet UIView *addPhoneLine;
@property (weak, nonatomic) IBOutlet UIView *phoneView;

@property (weak, nonatomic) IBOutlet PhoneTableView *phoneTableView;
@property (nonatomic) NSMutableArray* phoneModelArray;

@property UIImagePickerController *imagePicker;

@property (nonatomic) BOOL isAvatarChange;
@property (nonatomic) NewContactViewModel *viewModel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneTableViewContrains;

@end

@implementation NewContactViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUp];
}

- (void)setUp {
    self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.width/2;
    self.isAvatarChange = NO;
    
    self.imagePicker = [UIImagePickerController new];
    self.imagePicker.delegate = self;
    
    self.viewModel = [NewContactViewModel new];
    self.viewModel.delegate = self;
    
    _phoneModelArray = [[NSMutableArray alloc] init];
    _phoneTableView.dataSource = self;
    _phoneTableView.phoneTableViewContrains = _phoneTableViewContrains;
    
    self.saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 30)];
    [self.saveButton setTitle:@"save" forState:UIControlStateNormal];
    [self.saveButton setTitleColor:UIColor.brownColor forState:UIControlStateHighlighted];
    [self.saveButton setTitleColor:UIColor.grayColor forState:UIControlStateDisabled];
    [self.saveButton setTitleColor:_btnAddPhoto.titleLabel.textColor forState:UIControlStateNormal];
    [self.saveButton addTarget:self action:@selector(saveClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.saveButton];
    
    self.navigationItem.rightBarButtonItem = barButtonItem;
    [self.view addSubview:self.saveButton];
    
    [self.addPhonebutton setTitleColor:UIColor.greenColor forState:UIControlStateHighlighted];

    switch (self.editContactModel.action) {
        case AddNewContact:
            [self setUpAddNewContact];
            break;
            
        case ViewDetailContact:
            [self setUpViewDetail];
            break;
            
        default:
            break;
    }
    [_phoneTableView reloadData];
}

- (void)setUpAddNewContact {
    [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [self.saveButton setEnabled:NO];
    [_phoneTableView allowEditting:YES];
}

- (void)setUpViewDetail {
    [self.saveButton setTitle:@"Edit" forState:UIControlStateNormal];
    
    if(self.editContactModel.contactModel != nil) {
        self.tfFirstName.userInteractionEnabled = NO;
        self.tfMiddleName.userInteractionEnabled = NO;
        self.tfLastName.userInteractionEnabled = NO;
        self.btnAddPhoto.hidden = YES;
        
        self.tfFirstName.text = self.editContactModel.contactModel.givenName;
        self.tfMiddleName.text = self.editContactModel.contactModel.middleName;
        self.tfLastName.text = self.editContactModel.contactModel.familyName;
        
        for (NSString* phoneNumber in _editContactModel.contactModel.phoneNumberArray) {
            PhoneModel* phoneModel;
            if ([_phoneModelArray count] == 0)
                phoneModel = [[PhoneModel alloc] initWithType:@"Home" andPhone:phoneNumber];
            else
                phoneModel = [[PhoneModel alloc] initWithType:@"work" andPhone:phoneNumber];
            [_phoneModelArray addObject:phoneModel];
        }
        [_phoneTableView reloadData];
        
        self.avatarImage.image = [[CacheStore sharedInstance] getImagefor:self.editContactModel.contactModel.identifier];
    }
}

- (IBAction)firstNameChange:(id)sender {
    [self resetSaveButton];
}
- (IBAction)secondNamechange:(id)sender {
    [self resetSaveButton];
}
- (IBAction)lastNameChange:(id)sender {
    [self resetSaveButton];
}

- (IBAction)onAddPhone:(id)sender {
    //add to phone array
    PhoneModel* phone;
    if ([_phoneModelArray count] == 0)
        phone = [[PhoneModel alloc] initWithType:@"Home" andPhone:@""];
    else
        phone = [[PhoneModel alloc] initWithType:@"Work" andPhone:@""];

    [_phoneModelArray addObject:phone];
    [_phoneTableView reloadData];
}

- (IBAction)changePhoto:(id)sender {
    [self.imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

- (void)saveClick {
    switch (self.editContactModel.action) {
        case AddNewContact:
            [self saveNewContactToDevice];
            break;
            
        case ViewDetailContact:
            [self prepareForEditcontact];
            break;
            
        case EditContact:
            [self editContactToDevice];
            break;
        default:
            break;
    }
}

- (void)saveNewContactToDevice {
    if(!self.isHavePermission) {
        DeniedViewController *viewDenied = [self.storyboard instantiateViewControllerWithIdentifier:@"DeniedViewController"];
        [self.navigationController presentViewController:viewDenied animated:YES completion:nil];
        return;
    }
    NSString *firstName =([self.tfFirstName.text isEqualToString:@""])?@"":self.tfFirstName.text;
    NSString *secondName =([self.tfMiddleName.text isEqualToString:@""])?@"":self.tfMiddleName.text;
    NSString *lastName =([self.tfLastName.text isEqualToString:@""])?@"":self.tfLastName.text;
    NSString *workPhone = @"";
    NSString *homePhone = @"";
    if ([self.phoneModelArray count] > 1) {
        workPhone =([[self.phoneModelArray[1] phoneNumber] isEqualToString:@""])? @"": [self.phoneModelArray[1] phoneNumber];
    }
    if ([self.phoneModelArray count] > 0) {
        homePhone = ([[self.phoneModelArray[0] phoneNumber] isEqualToString:@""])? @"": [self.phoneModelArray[0] phoneNumber];
    }
    
    NSData *imageData = nil;
    if (self.isAvatarChange)
        imageData = UIImagePNGRepresentation( self.avatarImage.image);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *phoneArray =[NSMutableArray new];
        if (![homePhone isEqualToString:@""])
            [phoneArray addObject:homePhone];

        if (![workPhone isEqualToString:@""])
            [phoneArray addObject:workPhone];
        
        ContactModel *newContact = [ContactModel new];
        newContact.givenName = firstName;
        newContact.middleName = secondName;
        newContact.familyName = lastName;
        newContact.phoneNumberArray = phoneArray;
        
        self.editContactModel.contactModel = [[ContactModel alloc] initWithContactModel:newContact];
        [self.viewModel addNewContact:self.editContactModel.contactModel :imageData];
    });
}

- (void)prepareForEditcontact {
    self.editContactModel.action = EditContact;
    [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
    
    [_phoneTableView allowEditting:YES];
    self.tfFirstName.userInteractionEnabled = YES;
    self.tfMiddleName.userInteractionEnabled = YES;
    self.tfLastName.userInteractionEnabled = YES;
    self.btnAddPhoto.hidden = NO;
    [self.btnAddPhoto setTitle:@"Edit" forState:UIControlStateNormal];
}

- (void)editContactToDevice {
    if (!self.isHavePermission) {
        DeniedViewController *viewDenied = [self.storyboard instantiateViewControllerWithIdentifier:@"DeniedViewController"];
        [self.navigationController presentViewController:viewDenied animated:YES completion:nil];
        return;
    }
    NSString *firstName =([self.tfFirstName.text isEqualToString:@""])?@"":self.tfFirstName.text;
    NSString *secondName =([self.tfMiddleName.text isEqualToString:@""])?@"":self.tfMiddleName.text;
    NSString *lastName =([self.tfLastName.text isEqualToString:@""])?@"":self.tfLastName.text;
    NSString *workPhone = @"";
    NSString *homePhone = @"";
    if ([self.phoneModelArray count] > 1) {
        workPhone =([[self.phoneModelArray[1] phoneNumber] isEqualToString:@""])? @"": [self.phoneModelArray[1] phoneNumber];
    }
    if ([self.phoneModelArray count] > 0) {
        homePhone = ([[self.phoneModelArray[0] phoneNumber] isEqualToString:@""])? @"": [self.phoneModelArray[0] phoneNumber];
    }
    
    NSData *imageData = nil;
    if (self.isAvatarChange)
        imageData = UIImagePNGRepresentation( self.avatarImage.image);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *phoneArray =[NSMutableArray new];
        if (![homePhone isEqualToString:@""])
            [phoneArray addObject:homePhone];

        if (![workPhone isEqualToString:@""])
            [phoneArray addObject:workPhone];
        
        ContactModel *newContact = self.editContactModel.contactModel;
        newContact.givenName = firstName;
        newContact.middleName = secondName;
        newContact.familyName = lastName;
        newContact.phoneNumberArray = phoneArray;
        
        newContact.fullName   = [NSString stringWithFormat:@"%@ %@ %@",newContact.givenName,newContact.middleName,newContact.familyName];
        
        
        newContact.avatarName = [ContactModel generateAvatarName:newContact.givenName :newContact.familyName];
        newContact.avatarName = [newContact.avatarName uppercaseString];
        if ([newContact.fullName isEqualToString:@"  "])
            newContact.fullName = @"No name";
        
        [self.viewModel updateContact:self.editContactModel.contactModel :imageData];
    });
}

- (void)resetSaveButton {
    if ([self.tfFirstName.text length] == 0 && [self.tfMiddleName.text length] == 0 && [self.tfLastName.text length] == 0 && self.isAvatarChange == NO)
        [self.saveButton setEnabled:NO];
    else
        [self.saveButton setEnabled:YES];
}

// uiimage view controller delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage* originalImage = nil;
    originalImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if (originalImage == nil) {
        originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    self.isAvatarChange = YES;
    [self resetSaveButton];
    self.avatarImage.image = originalImage;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.isAvatarChange = NO;
}

//phone tableview datasource
- (NSMutableArray *)phoneModelForPhoneTableView:(PhoneTableView *)tableView {
    _phoneTableViewContrains.constant = ([_phoneModelArray count] + 1) * 40.0;
    return _phoneModelArray;
}

//observer for viewmodel
- (void)onAddNewContactSuccess:(NSString*)identifier {
    self.editContactModel.contactModel.identifier = identifier;
    [self notifyModelChangeToHomeController];
}

- (void)onAddNewContactFail {
    [self showOKMessageWithTitle:@"Fail to save" andMess:@"try later"];
}

- (void)onUpdateContactSuccess:(NSString *)identifier {
    [self notifyModelChangeToHomeController];
}

- (void)onUpdateContactFail {
    [self showOKMessageWithTitle:@"Fail to update" andMess:@"try later"];
}

- (void)notifyModelChangeToHomeController {
    NSDictionary *dic = @{@"keyProcessContact":self.editContactModel};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"processContactNotify" object:self userInfo:dic];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showOKMessageWithTitle:(NSString *) title andMess:(NSString *) mes {
    UIAlertController *alertDenied = [UIAlertController alertControllerWithTitle:title
                                                                         message:mes
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    [alertDenied addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertDenied animated:YES completion:nil];
}
@end
