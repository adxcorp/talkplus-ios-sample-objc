//
//  MainViewController.m
//  TalkPlusSample
//
//  Created by hnroh on 2021/01/19.
//

#import "MainViewController.h"
#import "MainCell.h"

#import "CreateViewController.h"
#import "ChannelViewController.h"

#import "NSDate+Extension.h"

@interface MainViewController ()

@property (nonatomic, strong) NSMutableArray<TPChannel *> *channels;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"TalkPlus";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(channelAction:)];
    
    [self.tableView.refreshControl addTarget:self action:@selector(reloadChannelList) forControlEvents:UIControlEventValueChanged];
    
    self.channels = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self channelList:nil];
}

#pragma mark - Action

- (void)channelAction:(UIBarButtonItem *)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    actionSheet.popoverPresentationController.barButtonItem = sender;
    actionSheet.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
   
    __weak typeof(self) weakSelf = self;
    NSArray<UIAlertAction *> *actions = @[
        [UIAlertAction actionWithTitle:@"Create Private Channel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf performSegueWithIdentifier:@"SegueCreate" sender:TP_CHANNEL_TYPE_PRIVATE];
        }],
        [UIAlertAction actionWithTitle:@"Create Public Channel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf performSegueWithIdentifier:@"SegueCreate" sender:TP_CHANNEL_TYPE_PUBLIC];
        }],
        [UIAlertAction actionWithTitle:@"Create invitationCode Channel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf performSegueWithIdentifier:@"SegueCreate" sender:TP_CHANNEL_TYPE_INVITATION_ONLY];
        }],
        [UIAlertAction actionWithTitle:@"Join Public Channel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf joinPublicChannel];
        }],
        [UIAlertAction actionWithTitle:@"Join invitationCode Channel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf joinInvitationCodeChannel];
        }],
        [UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [weakSelf logout];
        }],
        [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil] ];
    
    for (UIAlertAction *action in actions) {
        [actionSheet addAction:action];
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark - Channel

- (void)channelList:(TPChannel *)lastChannel {
    [self.tableView.refreshControl endRefreshing];
   
    __weak typeof(self) weakSelf = self;
    [[TalkPlus sharedInstance] getChannelList:lastChannel success:^(NSArray *tpChannelArray) {
        if (lastChannel == nil) {
            [weakSelf.channels removeAllObjects];
        }
        
        [weakSelf.channels addObjectsFromArray:tpChannelArray];
        [weakSelf.tableView reloadData];
        
    } failure:^(int errorCode, NSError *error) {
    }];
}

- (void)reloadChannelList {
    [self channelList:nil];
}

- (void)joinPublicChannel {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Join Public Channel" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Channel ID";
    }];
    
    __weak typeof(self) weakSelf = self;
    UIAlertAction *joinAction = [UIAlertAction actionWithTitle:@"Join" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *channelId = alert.textFields.firstObject.text;
        
        [[TalkPlus sharedInstance] joinChannel:channelId success:^(TPChannel *tpChannel) {
            [weakSelf performSegueWithIdentifier:@"SegueChannel" sender:tpChannel];
            
        } failure:^(int errorCode, NSError *error) {
            
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:joinAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)joinInvitationCodeChannel {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Join invitationCode Channel" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Channel ID";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"InvitationCode";
    }];
    
    UIAlertAction *joinAction = [UIAlertAction actionWithTitle:@"Join" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *channelId = alert.textFields.firstObject.text;
        NSString *invitationCode = alert.textFields.lastObject.text;
       
        __weak typeof(self) weakSelf = self;
        [[TalkPlus sharedInstance] joinChannel:channelId invitationCode:invitationCode success:^(TPChannel *tpChannel) {
            [weakSelf performSegueWithIdentifier:@"SegueChannel" sender:tpChannel];
            
        } failure:^(int errorCode, NSError *error) {
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:joinAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)logout {
    [[TalkPlus sharedInstance] logout:^{
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"KeyUserID"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"KeyUserName"];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } failure:^(int errorCode, NSError *error) {
    }];
}

#pragma mark - Navigation

- (IBAction)unwindToMainWithSegue:(UIStoryboardSegue *)segue {
    [self reloadChannelList];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SegueCreate"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        CreateViewController *createViewController = (CreateViewController *)navigationController.topViewController;
        createViewController.channelType = sender;
        
    } else if ([segue.identifier isEqualToString:@"SegueChannel"]) {
        ChannelViewController *channelViewController = (ChannelViewController *)segue.destinationViewController;
        channelViewController.channel = sender;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.channels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MainCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainCell"];
    TPChannel *channel = self.channels[indexPath.row];
    
    if (channel.getMembers.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        [channel.getMembers enumerateObjectsUsingBlock:^(TPUser *obj, NSUInteger idx, BOOL *stop) {
            [names addObject:obj.getUsername];
        }];
        
        cell.nameLabel.text = [names componentsJoinedByString:@", "];
        
    } else {
        cell.nameLabel.text = nil;
    }
    
    NSString *message = channel.getLastMessage.getText;
    if (message.length > 0) {
        cell.messageLabel.text = message;
        
        long time = channel.getLastMessage.getCreatedAt;
        NSDate *date = [NSDate milliseconds:time];
        cell.dateLabel.text = [date toFormat:@"yyyy. MM. dd HH:mm"];
        
    } else {
        cell.messageLabel.text = @"no message";
        cell.dateLabel.text = nil;
    }
    
    int unreadCount = channel.getUnreadCount;
    if (unreadCount > 0) {
        [cell.unreadCountView setHidden:NO];
        cell.unreadCountLabel.text = [NSString stringWithFormat:@"%d", unreadCount];
        
    } else {
        [cell.unreadCountView setHidden:YES];
        cell.unreadCountLabel.text = nil;
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TPChannel *channel = self.channels[indexPath.row];
    [self performSegueWithIdentifier:@"SegueChannel" sender:channel];
}

@end
