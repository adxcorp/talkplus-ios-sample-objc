//
//  MemberViewController.m
//  TalkPlusSample
//
//  Created by hnroh on 2021/01/20.
//

#import "MemberViewController.h"

@interface MemberViewController ()

@end

@implementation MemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Member Info";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
}

#pragma mark - Action

- (void)addAction:(UIBarButtonItem *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add User" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"User ID";
    }];
    
    __weak typeof(self) weakSelf = self;
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *userId = [alert.textFields.firstObject.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (userId.length > 0) {
            [weakSelf addMemberWithUserId:userId];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:addAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Member

- (void)addMemberWithUserId:(NSString *)userId {
    __weak typeof(self) weakSelf = self;
    [[TalkPlus sharedInstance] addMemberToChannel:self.channel userId:userId success:^(TPChannel *tpChannel) {
        weakSelf.channel = tpChannel;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@", userId];
        NSArray<TPUser *> *addUser = [tpChannel.getMembers filteredArrayUsingPredicate:predicate];
        [weakSelf.users addObject:addUser.firstObject];
        [weakSelf.tableView reloadData];
        
    } failure:^(int errorCode, NSError *error) {
    }];
}

- (void)removeMemberWithUesrId:(NSString *)userId indexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    [[TalkPlus sharedInstance] removeMemberToChannel:self.channel userId:userId success:^(TPChannel *tpChannel) {
        [weakSelf.users removeObjectAtIndex:indexPath.row];
        
        [weakSelf.tableView beginUpdates];
        [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [weakSelf.tableView endUpdates];

    } failure:^(int errorCode, NSError *error) {
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    TPUser *user = self.users[indexPath.row];
    
    cell.textLabel.text = user.getUsername;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *index) {
        NSString *userId = weakSelf.users[index.row].getUserId;
        [weakSelf removeMemberWithUesrId:userId indexPath:index];
    }];
    
    return @[delete];
}

@end
