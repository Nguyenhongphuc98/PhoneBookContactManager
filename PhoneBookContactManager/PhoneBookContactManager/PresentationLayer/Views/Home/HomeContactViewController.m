//
//  ShowContactsVC.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 1/10/20.
//  Copyright © 2020 CPU11716. All rights reserved.
//

#import "HomeContactViewController.h"

@interface HomeContactViewController ()
@property (weak, nonatomic) IBOutlet ContactTableView *contactTableView;
@property (strong, nonatomic) ContactHomeViewModel *viewModel;
@property (weak, nonatomic) IBOutlet UISearchBar *contactSearchbar;
@property (weak, nonatomic) IBOutlet UIStackView *permisionDeniedSV;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addNewContactButton;

@property BOOL isContactsLoaded;
@end

@implementation HomeContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    //add observer for newcontact viewcontroller
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNewContactViewControllerdismis:) name:@"processContactNotify" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"processContactNotify" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.isContactsLoaded) {
        [self requestAccessContactInDevice];
    }
}

- (void)setUp {
    self.isContactsLoaded = NO;
    [self.permisionDeniedSV setHidden:YES];
    self.viewModel = [ContactHomeViewModel new];
    self.viewModel.delegate = self;
    
    self.contactTableView.datasource = self;
    self.contactTableView.delegate = self;
}

- (void) requestAccessContactInDevice {
    [self.viewModel requestPermision];
}
- (IBAction)addNewContact:(id)sender {
    EditingContactModel *editcontactModel = [EditingContactModel new];
    editcontactModel.action = AddNewContact;
    NewContactViewController *addContactVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NewContactViewController"];
    addContactVC.editContactModel = editcontactModel;
    addContactVC.isHavePermission = self.permisionDeniedSV.hidden;
    
    [self.navigationController pushViewController:addContactVC animated:YES];
}
- (IBAction)onOpenSettings:(id)sender {
    if([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:)])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
}

- (void)processNewContactViewControllerdismis:(NSNotification*)notification {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EditingContactModel *editContactModel = [notification.userInfo objectForKey:@"keyProcessContact"];
        if(editContactModel.contactModel == nil)
            return;
        
        switch (editContactModel.action) {
            case AddNewContact:
                [self.viewModel addNewContact:editContactModel];
                break;
                
            case EditContact:
                [self.viewModel editContact:editContactModel];
                break;
                
            default:
                break;
        }
    });
}

//delegate contacttableView
- (NSMutableDictionary *)contactModelForContactTableView:(ContactTableView *)contactTableView {
    return [self.viewModel contactsDictionaryForTableView];
}

- (void)acceptDeleteTableCellAt:(NSIndexPath *)indexPath withCallback:(nonnull contactTableCallback)callback {

    UIAlertController *alertWarring = [UIAlertController alertControllerWithTitle:@"Delete contact"
                                                                            message:@"Are you sure to delete this contact"
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"YES"
                                                    style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action){
                                                        ContactTableCallbackInfor *info = [ContactTableCallbackInfor new];
                                                        info.code = ACCEPT;
                                                        callback(info);
                                                    }];
    [alertWarring addAction:actionOk];
        
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"NO"
                                                            style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action){
                                                             ContactTableCallbackInfor *info = [ContactTableCallbackInfor new];
                                                             info.code = DENIED;
                                                             callback(info);
                                                         }];
    [alertWarring addAction:actionCancel];
        
    [self presentViewController:alertWarring animated:YES completion:nil];
}

- (void)willRemoveContactFromContactTableView:(ContactModel *)contactModel withCallback:(nonnull contactTableCallback)callback {
    [self.viewModel removeContactModel:contactModel withCallback:callback];
}

- (void)didSelectContact:(ContactModel *)contact {
    EditingContactModel *editcontactModel = [EditingContactModel new];
    editcontactModel.action = ViewDetailContact;
    editcontactModel.contactModel = contact;
    editcontactModel.oldSection = [contact getSection];
    
    NewContactViewController *addContactVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NewContactViewController"];
    addContactVC.editContactModel = editcontactModel;
    addContactVC.isHavePermission = self.permisionDeniedSV.hidden;
    addContactVC.isHavePermission = YES;
    
    [self.navigationController pushViewController:addContactVC animated:YES];
}

//UISearchbar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.viewModel searchWithString:searchText];
}

//observer viewmodel
- (void)loadDataComplete {
    [self.contactTableView reloadData];
    self.isContactsLoaded = YES;
    NSLog(@"complete");
}

- (void)deleteContactFail {
    
}

- (void)deleteContactSuccess:(NSIndexPath *)indexPath removeSection:(BOOL)isRemoveSection {
    //dont need to to
}

- (void)showPermisionDenied {
    self.addNewContactButton.enabled = NO;
    [self.permisionDeniedSV setHidden:NO];
    [self.contactTableView setHidden:YES];
}

- (void)showFailToLoadContact {
    
}
@end
