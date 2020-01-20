//
//  PhoneTableview.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 1/20/20.
//  Copyright © 2020 CPU11716. All rights reserved.
//

#import "PhoneTableView.h"
@interface PhoneTableView()
@property (nonatomic, weak) UITableView *tableview;
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
    UITableView *tableview = [[UITableView alloc] initWithFrame:self.bounds];
    tableview.dataSource = self;
    tableview.delegate = self;
    
    [tableview setEditing:YES];
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
    
    UINib *nib = [UINib nibWithNibName:@"phoneTableViewCell" bundle:nil];
    [self.tableview registerNib:nib forCellReuseIdentifier:@"phoneTableViewCell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"phoneTableViewCell" forIndexPath:indexPath];
    
    return cell;
}


//delegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
@end
