//
//  InviteViewController.m
//  TalkPlusSample
//
//  Created by hnroh on 2021/01/19.
//

#import "InviteViewController.h"

#import "UIViewController+Extension.h"

@interface InviteViewController ()

@property (nonatomic, strong) NSMutableArray<NSString *> *users;

@end

@implementation InviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Invite";
    self.navigationItem.rightBarButtonItems = @[ [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction)],
                                                 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction)] ];
    
    self.users = [NSMutableArray array];
}

#pragma mark - Action

- (void)addAction {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add User" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"User ID";
    }];
    
    __weak typeof(self) weakSelf = self;
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *userId = [alert.textFields.firstObject.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (userId.length > 0) {
            [weakSelf.users addObject:userId];
            [weakSelf.tableView reloadData];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:addAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)doneAction {
    if ([self.channelType isEqualToString:TP_CHANNEL_TYPE_PRIVATE]) {
        if (self.users.count > 0) {
            [self createChannel];
            
        } else {
            [self showToast:@"유저를 추가해주세요."];
        }
        
    } else {
        [self createChannel];
    }
}

#pragma mark - Channel

- (void)createChannel {
    __weak typeof(self) weakSelf = self;
    [[TalkPlus sharedInstance] createChannelWithUserIds:self.users channelId:nil reuseChannel:YES maxCount:20 hideMessagesBeforeJoin:NO channelType:self.channelType channelName:self.channelName invitationCode:self.invitationCode imageUrl:nil metaData:nil success:^(TPChannel *tpChannel) {
        [weakSelf performSegueWithIdentifier:@"UnwindToMain" sender:nil];
        
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
    cell.textLabel.text = self.users[indexPath.row];
    
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
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [weakSelf.users removeObjectAtIndex:indexPath.row];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }];
    
    return @[delete];
}

@end
