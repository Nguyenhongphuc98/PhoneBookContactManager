//
//  PhoneTableview.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 1/20/20.
//  Copyright © 2020 CPU11716. All rights reserved.
//

#import "PhoneTableView.h"
#import "PhoneTableViewCell.h"
@interface PhoneTableView()
@property (nonatomic, weak) UITableView* tableview;
@property (nonatomic) NSMutableArray* phoneModelArray;
@end

@implementation PhoneTableView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUp];
}

- (void)setUp {
    _isCanEdit = NO;
    UITableView *tableview = [[UITableView alloc] initWithFrame:self.bounds];
    tableview.dataSource = self;
    tableview.delegate = self;
    tableview.allowsSelection = YES;
    
    tableview.editing = NO;
    tableview.allowsSelectionDuringEditing = YES;
    tableview.clipsToBounds = YES;
    tableview.rowHeight = 40;
    tableview.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:tableview];
    self.tableview = tableview;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableview]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(tableview)]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableview]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(tableview)]];
    
    UINib *nib = [UINib nibWithNibName:@"PhoneTableViewCell" bundle:nil];
    [self.tableview registerNib:nib forCellReuseIdentifier:@"PhoneTableViewCell"];
    UINib *nib2 = [UINib nibWithNibName:@"PhoneAcitonTableViewCell" bundle:nil];
    [self.tableview registerNib:nib2 forCellReuseIdentifier:@"PhoneAcitonTableViewCell"];
}

- (void)allowEditting:(BOOL)isAllow {
    _tableview.editing = isAllow;
    _isCanEdit = isAllow;
    [self reloadData];
}

- (void)reloadData {
    if ([_dataSource respondsToSelector:@selector(phoneModelForPhoneTableView:)]) {
        _phoneModelArray = [_dataSource phoneModelForPhoneTableView:self];
    }
    [_tableview reloadData];
}

//dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_phoneModelArray count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PhoneTableViewCell *cell;
    if (indexPath.row < [_phoneModelArray count]) {
        cell = (PhoneTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"PhoneTableViewCell" forIndexPath:indexPath];
        [cell fillData: [_phoneModelArray objectAtIndex:indexPath.row]];
    } else
        cell = (PhoneTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"PhoneAcitonTableViewCell" forIndexPath:indexPath];
    
    return cell;
}

//delegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [_phoneModelArray count]) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [UIView animateWithDuration:2 animations:^{
            [self.phoneModelArray removeObjectAtIndex:indexPath.row];

            [self.tableview beginUpdates];
            [self.tableview deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableview endUpdates];
        }];
        _phoneTableViewContrains.constant = ([_phoneModelArray count] + 1) * 40.0;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isCanEdit == NO || indexPath.row < [_phoneModelArray count]) {
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [_phoneModelArray count]) {
        //add to phone array
        PhoneModel* phone;
        if ([_phoneModelArray count] == 0)
            phone = [[PhoneModel alloc] initWithType:@"Home" andPhone:@""];
        else
            phone = [[PhoneModel alloc] initWithType:@"Work" andPhone:@""];

        [_phoneModelArray addObject:phone];
        [self.tableview beginUpdates];
        [self.tableview insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableview endUpdates];
        _phoneTableViewContrains.constant = ([_phoneModelArray count] + 1) * 40.0;
    }
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}
@end
