//
//  HomeContactViewController.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/23/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import "HomeContactViewController.h"

@interface HomeContactViewController ()
@property (weak, nonatomic) IBOutlet UITableView *contactTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *contactSearchbar;
@property (weak, nonatomic) IBOutlet UILabel *infoLable;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addNewContactButton;

@property (strong,nonatomic) ContactHomeViewModel* viewModel;
@property BOOL isContactLoaded;
@property BOOL isrefused;

@end

@implementation HomeContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUp];
    //add observer for newcontact viewcontroller
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNewContactViewControllerdismis:) name:@"processContactNotify" object:nil];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(!self.isContactLoaded)
        [self requestAccessContactInDevice];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"processContactNotify" object:nil];
}

-(void) setUp{
    UINib *nib = [UINib nibWithNibName:@"ContactTableViewCell" bundle:nil];
    [_contactTableView registerNib:nib forCellReuseIdentifier:@"ContactTableViewCell"];
    
    [self.infoLable setHidden:YES];
    self.isContactLoaded = NO;
    self.isrefused = NO;
    
    self.viewModel = [[ContactHomeViewModel alloc] init];
    self.viewModel.delegate = self;
}

-(void) requestAccessContactInDevice{
    [self.viewModel requestPermision];
}

-(void) deleteContactAtIndex:(NSIndexPath*) indexPath{
    //check session
    if([self.viewModel getNumberOfRowInSection:indexPath.section] == 1 && indexPath.row == 0)
        [self.viewModel removeSection:indexPath.section];
    else
        [self.viewModel removeCellAt:indexPath.section andRow:indexPath.row];
}

-(void) showAlertActionOkWith:(NSString *_Nonnull) title message:(NSString *_Nonnull) msg{
    UIAlertController *alertDenied = [UIAlertController alertControllerWithTitle:title
                                                                         message:msg
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    [alertDenied addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertDenied animated:YES completion:nil];
}
- (IBAction)addNewContact:(id)sender {
    EditingContactModel *editcontactModel = [EditingContactModel new];
    editcontactModel.action = AddNewContact;
    NewContactViewController *addContactVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NewContactViewController"];
    addContactVC.editContactModel = editcontactModel;
    
    [self.navigationController pushViewController:addContactVC animated:YES];
}

-(void) processNewContactViewControllerdismis:(NSNotification*) notification{
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

//tableview datasource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.viewModel getTitleForHeaderInSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.viewModel getNumberOfSection];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   return [self.viewModel getNumberOfRowInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ContactTableViewCell *cell = (ContactTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ContactTableViewCell" forIndexPath:indexPath];
    [cell fillData:[self.viewModel getModel:indexPath.section :indexPath.row]];

    return cell;
}


//tableview delegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
   if(editingStyle == UITableViewCellEditingStyleDelete)
   {
       //ask to delete
       UIAlertController *alertWarring = [UIAlertController alertControllerWithTitle:@"Delete contact"
                                                                                message:@"Are you sure to delete this contact"
                                                                         preferredStyle:UIAlertControllerStyleAlert];

       UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"YES"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action){
                                                            [self deleteContactAtIndex:indexPath];
                                                        }];
       [alertWarring addAction:actionOk];
       
       UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"NO"
                                                          style:UIAlertActionStyleDefault
                                                        handler:nil];
       [alertWarring addAction:actionCancel];
       
       [self presentViewController:alertWarring animated:YES completion:nil];
   }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    [self.contactTableView setEditing:editing animated:animated];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    EditingContactModel *editcontactModel = [EditingContactModel new];
    editcontactModel.action = ViewDetailContact;
    editcontactModel.contactModel = [self.viewModel getModel:indexPath.section :indexPath.row];
    editcontactModel.indexPath = indexPath;
    
    NewContactViewController *addContactVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NewContactViewController"];
    addContactVC.editContactModel = editcontactModel;
    
    [self.navigationController pushViewController:addContactVC animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//UISearchbar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.viewModel searchWithString:searchText];
}


//observer contact home view model
-(void) loadDataComplete{
    [self.contactTableView reloadData];
    self.isContactLoaded = YES;
}

- (void)showPermisionDenied{
    if(self.isrefused){
        //[self showAlertActionOkWith:@"Permision denied" message:@"Open setings to allow read contacts from device"];
        [self.infoLable setHidden:NO];
        [self.contactTableView setHidden:YES];
    }
    else {
        DeniedViewController *viewDenied = [self.storyboard instantiateViewControllerWithIdentifier:@"DeniedViewController"];
        [self.navigationController presentViewController:viewDenied animated:YES completion:nil];
        self.isrefused = YES;
    }
}

- (void)showFailToLoadContact{
    [self showAlertActionOkWith:@"Error" message:@"Can't load contact, unknow error."];
}

- (void)deleteContactSuccess:(NSIndexPath *)indexPath removeSection:(BOOL)isRemoveSection{
    if(isRemoveSection)
    {
        [self.contactTableView beginUpdates];
        [self.contactTableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationLeft];
        [self.contactTableView endUpdates];
    }
   else
   {
       
       [self.contactTableView beginUpdates];
       [self.contactTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
       [self.contactTableView endUpdates];
   }
}

- (void)deleteContactFail{
    [self showAlertActionOkWith:@"Error" message:@"Can't delete contact, try later."];
}

@end

