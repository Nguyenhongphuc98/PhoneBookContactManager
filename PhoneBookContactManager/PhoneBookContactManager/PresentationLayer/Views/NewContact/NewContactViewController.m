//
//  NewContactViewController.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/25/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import "NewContactViewController.h"

@interface NewContactViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnSaveContact;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UIButton *btnAddPhone;
@property (weak, nonatomic) IBOutlet UITextField *textFieldHomePhone;
@property (weak, nonatomic) IBOutlet UITextField *textFieldWorkPhone;
@property (weak, nonatomic) IBOutlet UITextField *tfFirstName;
@property (weak, nonatomic) IBOutlet UITextField *tfMiddleName;
@property (weak, nonatomic) IBOutlet UITextField *tfLastName;
@property (weak, nonatomic) IBOutlet UIButton *btnAddPhoto;
@property (weak, nonatomic) IBOutlet UILabel *lbHome;
@property (weak, nonatomic) IBOutlet UILabel *lbWork;

@property UIImagePickerController *imagePicker;

@property (nonatomic) NSInteger countClickAddPhone;
@property (nonatomic) BOOL isAvatarChange;
@property (nonatomic) NewContactViewModel *viewModel;

@end

@implementation NewContactViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUp];
}

-(void) setUp{
    self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.width/2;
    self.countClickAddPhone = 0;
    self.isAvatarChange = NO;
    
    self.imagePicker = [UIImagePickerController new];
    self.imagePicker.delegate = self;
    
    self.viewModel = [NewContactViewModel new];
    self.viewModel.delegate = self;

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
}

-(void) setUpAddNewContact{
    [self.btnSaveContact setTitle:@"Save" forState:UIControlStateNormal];
    [self.btnSaveContact setEnabled:NO];
    self.textFieldHomePhone.hidden = YES;
    self.textFieldWorkPhone.hidden = YES;
    self.lbHome.hidden = YES;
    self.lbWork.hidden = YES;
}

-(void) setUpViewDetail{
    [self.btnSaveContact setTitle:@"Edit" forState:UIControlStateNormal];
    
    if(self.editContactModel.contactModel != nil){
        self.tfFirstName.userInteractionEnabled = NO;
        self.tfMiddleName.userInteractionEnabled = NO;
        self.tfLastName.userInteractionEnabled = NO;
        self.btnAddPhoto.hidden = YES;
        self.btnAddPhone.hidden = YES;
        
        self.tfFirstName.text = self.editContactModel.contactModel.givenName;
        self.tfMiddleName.text = self.editContactModel.contactModel.middleName;
        self.tfLastName.text = self.editContactModel.contactModel.familyName;
        
        if(self.editContactModel.contactModel.phoneNumberArray.count ==2)
        {
            self.textFieldWorkPhone.hidden = NO;
            self.textFieldWorkPhone.text = self.editContactModel.contactModel.phoneNumberArray[1];
        }
        
        if(self.editContactModel.contactModel.phoneNumberArray.count >0)
        {
            self.textFieldHomePhone.hidden = NO;
            self.textFieldHomePhone.text = self.editContactModel.contactModel.phoneNumberArray[0];
        }
        
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

- (IBAction)addPhoneClick:(id)sender {
    NSLog(@"click");
    self.countClickAddPhone ++;
    if(self.countClickAddPhone>2)
        return;

    if(self.countClickAddPhone == 1)
    {
        [UIView animateWithDuration:2 animations:^{
            self.textFieldHomePhone.hidden = NO;
            self.lbHome.hidden = NO;
        }];
        [self resetSaveButton];
    }
    else
    {
        [UIView animateWithDuration:2 animations:^{
            self.textFieldWorkPhone.hidden = NO;
            self.lbWork.hidden = NO;
        }];
    }
}

- (IBAction)changePhoto:(id)sender {
    [self.imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

- (IBAction)saveClick:(id)sender {
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

-(void) saveNewContactToDevice{
    NSString *firstName =([self.tfFirstName.text isEqualToString:@""])?@"":self.tfFirstName.text;
    NSString *secondName =([self.tfMiddleName.text isEqualToString:@""])?@"":self.tfMiddleName.text;
    NSString *lastName =([self.tfLastName.text isEqualToString:@""])?@"":self.tfLastName.text;
    NSString *homePhone =([self.textFieldHomePhone.text isEqualToString:@""])?@"":self.textFieldHomePhone.text;
    NSString *workPhone =([self.textFieldWorkPhone.text isEqualToString:@""])?@"":self.textFieldWorkPhone.text;
    
    NSData *imageData = nil;
    if(self.isAvatarChange)
        imageData = UIImagePNGRepresentation( self.avatarImage.image);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *phoneArray =[NSMutableArray new];
        if(![homePhone isEqualToString:@""])
            [phoneArray addObject:homePhone];
        
        if(![workPhone isEqualToString:@""])
            [phoneArray addObject:workPhone];
        
        ContactModel *newContact = [ContactModel new];
        newContact.givenName = firstName;
        newContact.middleName = secondName;
        newContact.familyName = lastName;
        newContact.phoneNumberArray = phoneArray;
        
        self.editContactModel.contactModel = newContact;
        [self.viewModel addNewContact:newContact :imageData];
    });
}

-(void) prepareForEditcontact{
    self.editContactModel.action = EditContact;
    [self.btnSaveContact setTitle:@"Save" forState:UIControlStateNormal];
    
    self.tfFirstName.userInteractionEnabled = YES;
    self.tfMiddleName.userInteractionEnabled = YES;
    self.tfLastName.userInteractionEnabled = YES;
    self.btnAddPhoto.hidden = NO;
    [self.btnAddPhoto setTitle:@"Change" forState:UIControlStateNormal];
    self.btnAddPhone.hidden = NO;
}

-(void) editContactToDevice{
    NSString *firstName =([self.tfFirstName.text isEqualToString:@""])?@"":self.tfFirstName.text;
    NSString *secondName =([self.tfMiddleName.text isEqualToString:@""])?@"":self.tfMiddleName.text;
    NSString *lastName =([self.tfLastName.text isEqualToString:@""])?@"":self.tfLastName.text;
    NSString *homePhone =([self.textFieldHomePhone.text isEqualToString:@""])?@"":self.textFieldHomePhone.text;
    NSString *workPhone =([self.textFieldWorkPhone.text isEqualToString:@""])?@"":self.textFieldWorkPhone.text;
    
    NSData *imageData = nil;
    if(self.isAvatarChange)
        imageData = UIImagePNGRepresentation( self.avatarImage.image);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *phoneArray =[NSMutableArray new];
        if(![homePhone isEqualToString:@""])
            [phoneArray addObject:homePhone];
        
        if(![workPhone isEqualToString:@""])
            [phoneArray addObject:workPhone];
        
        ContactModel *newContact = [ContactModel new];
        newContact.identifier = self.editContactModel.contactModel.identifier;
        newContact.givenName = firstName;
        newContact.middleName = secondName;
        newContact.familyName = lastName;
        newContact.phoneNumberArray = phoneArray;
        
        self.editContactModel.contactModel = newContact;
        [self.viewModel updateContact:newContact :imageData];
    });
}

-(void) resetSaveButton{
    if([self.tfFirstName.text length] == 0 && [self.tfMiddleName.text length] == 0 &&[self.tfLastName.text length] == 0 && self.isAvatarChange == NO && self.countClickAddPhone == 0)
        [self.btnSaveContact setEnabled:NO];
    else
        [self.btnSaveContact setEnabled:YES];
}

// uiimage view controller delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage* originalImage = nil;
    originalImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if(originalImage==nil)
    {
        originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
    }
    
    self.isAvatarChange = YES;
    [self resetSaveButton];
    self.avatarImage.image = originalImage;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.isAvatarChange = NO;
}


//observer for viewmodel
- (void)onAddNewContactSuccess:(NSString*) identifier{
    self.editContactModel.contactModel.identifier = identifier;
    [self notifyModelChangeToHomeController];
}

- (void)onAddNewContactFail{
    [self showOKMessageWithTitle:@"Fail to save" andMess:@"try later"];
}

- (void)onUpdateContactSuccess:(NSString *)identifier{
    [self notifyModelChangeToHomeController];
}

- (void)onUpdateContactFail{
    [self showOKMessageWithTitle:@"Fail to update" andMess:@"try later"];
}

-(void) notifyModelChangeToHomeController{
    NSDictionary *dic = @{@"keyProcessContact":self.editContactModel};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"processContactNotify" object:self userInfo:dic];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) showOKMessageWithTitle:(NSString *) title andMess:(NSString *) mes{
    UIAlertController *alertDenied = [UIAlertController alertControllerWithTitle:title
                                                                         message:mes
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    [alertDenied addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertDenied animated:YES completion:nil];
}
@end
