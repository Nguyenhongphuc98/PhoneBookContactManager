//
//  ContactTableView.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 1/10/20.
//  Copyright © 2020 CPU11716. All rights reserved.
//

#import "ContactTableView.h"

@interface ContactTableView()
@property (nonatomic, weak) UITableView *tableview;
@property (nonatomic) NSMutableDictionary *contactsDictionary;
@property (nonatomic) NSMutableArray *sectionArray;

@end

@implementation ContactTableView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
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
    UITableView *tableview = [[UITableView alloc] initWithFrame:self.bounds];
    tableview.dataSource = self;
    tableview.delegate = self;
    
    //[tableview setEditing:YES];
    tableview.clipsToBounds = YES;
    tableview.rowHeight = 60;
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
    
    UINib *nib = [UINib nibWithNibName:@"ContactTableViewCell" bundle:nil];
    [self.tableview registerNib:nib forCellReuseIdentifier:@"ContactTableViewCell"];
}

- (void)setRowHeight:(NSInteger)rowHeight {
    if (self.rowHeight != rowHeight) {
        self.tableview.rowHeight = rowHeight;
       // [self.tableview layoutIfNeeded];
    }
}

- (void)reloadData {
    if ([self.datasource respondsToSelector:@selector(contactModelForContactTableView:)]) {
        self.contactsDictionary = [self.datasource contactModelForContactTableView:self];
        //sort A->Z
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:[self.contactsDictionary allKeys]];
        self.sectionArray = [[NSMutableArray alloc] initWithArray:[tempArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    }
    [self.tableview reloadData];
}

//dataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section >= [self.sectionArray count]) {
        NSAssert(section < [self.sectionArray count], @"Param 'section' out of bound.");
        return @"";
    }
    return [self.sectionArray objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sectionArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section >= [self.sectionArray count]) {
        NSAssert(section < [self.sectionArray count], @"Param 'section' out of bound.");
        return 0;
    }
    return [[self.contactsDictionary objectForKey:[self.sectionArray objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *cell = (ContactTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ContactTableViewCell" forIndexPath:indexPath];
    NSString * sesctionKey = [self.sectionArray objectAtIndex:indexPath.section];
    [cell fillData:[[self.contactsDictionary objectForKey:sesctionKey] objectAtIndex:indexPath.row]];
    return cell;
}

//delegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([self.delegate respondsToSelector:@selector(acceptDeleteTableCellAt:withCallback:)]) {
            ([self.delegate acceptDeleteTableCellAt:indexPath withCallback:^(ContactTableCallbackInfor * _Nullable info) {
                if(info.code == ACCEPT) {
                    [self removeCellAtIndexPath:indexPath];
                }
            }]);
        } else
        // if don't implement that function, default is can delete
        [self removeCellAtIndexPath:indexPath];
    }
}

- (void) removeCellAtIndexPath:(NSIndexPath*)indexPath {
    //remove datasource and ui
    //check session
    NSString *section = [self.sectionArray objectAtIndex:indexPath.section];
    ContactModel *model = [[self.contactsDictionary objectForKey:section] objectAtIndex:indexPath.row];
    NSInteger numOfRows = [self tableView:self.tableview numberOfRowsInSection:indexPath.section];
    
    if ([self.delegate respondsToSelector:@selector(willRemoveContactFromContactTableView:withCallback:)]) {
        [self.delegate willRemoveContactFromContactTableView:model withCallback:^(ContactTableCallbackInfor * _Nullable info) {
            if (info.code == SUCCESS) {
                //delete in dataSource
                BOOL isFound = NO;
                NSArray *arr = [self.contactsDictionary allKeys];
                for (NSString* section in arr) {
                    NSMutableArray *contacts = [self.contactsDictionary objectForKey:section];
                    for (ContactModel *contact in contacts) {
                        if ([contact.identifier isEqualToString:model.identifier]) {
                            [[self.contactsDictionary objectForKey:section] removeObject:contact];
                            isFound = YES;
                            break;
                        }
                    }
                   
                    if ([[self.contactsDictionary objectForKey:section] count] == 0 && ![section isEqualToString:@"Search result"]) {
                        [self.contactsDictionary removeObjectForKey:section];
                        for (NSString* sec in self.sectionArray) {
                            if ([sec isEqualToString:section]) {
                                [self.sectionArray removeObject:sec];
                                break;
                            }
                        }
                    }
                    if (isFound) break;
                }
                
                //detete on UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableview beginUpdates];
                    if (numOfRows == 1 && indexPath.row == 0 && ![section isEqualToString:@"Search result"])
                        [self.tableview deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationLeft];
                    else
                        [self.tableview deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                    [self.tableview endUpdates];
                    [self reloadData];
                });
            }
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(didSelectContact:)]) {
        [self.delegate didSelectContact:[[self.contactsDictionary objectForKey:[self.sectionArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
