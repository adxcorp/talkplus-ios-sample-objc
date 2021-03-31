//
//  ChannelViewController.m
//  TalkPlusSample
//
//  Created by hnroh on 2021/01/20.
//

#import "ChannelViewController.h"
#import "ChannelCell.h"

#import "MemberViewController.h"

#import "NSDate+Extension.h"

@interface ChannelViewController () <TPChannelDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UIButton *sendButton;
@property (nonatomic, weak) IBOutlet UIView *bottomView;

@property (nonatomic, strong) NSMutableArray<TPMessage *> *messages;
@property (nonatomic, strong) NSString *userId;

@end

@implementation ChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Channel";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more"] style:UIBarButtonItemStylePlain target:self action:@selector(channelAction:)];
    
    self.userId = [[NSUserDefaults standardUserDefaults] stringForKey:@"KeyUserID"];
    
    self.textView.layer.borderWidth = 0.5;
    self.textView.layer.borderColor = [UIColor.grayColor colorWithAlphaComponent:0.5].CGColor;
    self.textView.layer.cornerRadius = 16;
    self.textView.textContainer.lineFragmentPadding = 10;
    self.sendButton.layer.cornerRadius = self.sendButton.frame.size.height / 2;

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGesture];
    
    [[TalkPlus sharedInstance] addChannelDelegate:self tag:@"TPAppDelegate"];
    [self messageListWithLast:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    
    [self markRead];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Action

- (void)channelAction:(UIBarButtonItem *)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    actionSheet.popoverPresentationController.barButtonItem = sender;
    actionSheet.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;

    __weak typeof(self) weakSelf = self;
    NSArray<UIAlertAction *> *actions = @[
        [UIAlertAction actionWithTitle:@"Member Info" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf performSegueWithIdentifier:@"SegueMember" sender:self.channel.getMembers];
        }],
        [UIAlertAction actionWithTitle:@"Copy Channel ID" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIPasteboard.generalPasteboard.string = weakSelf.channel.getChannelId;
        }],
        [UIAlertAction actionWithTitle:@"Leave" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [weakSelf leaveChannel];
        }],
        [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil] ];
    
    for (UIAlertAction *action in actions) {
        [actionSheet addAction:action];
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (IBAction)sendAction:(id)sender {
    [self sendMessage];
}

#pragma mark - Message

- (void)markRead {
    __weak typeof(self) weakSelf = self;
    
    [[TalkPlus sharedInstance] markAsReadChannel:self.channel success:^(TPChannel *tpChannel) {
        weakSelf.channel = tpChannel;
        [weakSelf.tableView reloadData];
        
    } failure:^(int errorCode, NSError *error) {
    }];
}

- (void)messageListWithLast:(TPMessage *)lastMessage {
    __weak typeof(self) weakSelf = self;
    [[TalkPlus sharedInstance] getMessageList:self.channel lastMessage:lastMessage success:^(NSArray<TPMessage *> *tpMessages) {
        if (lastMessage == nil) {
            weakSelf.messages = [NSMutableArray array];
        }
        
        if (tpMessages.count > 0) {
            [weakSelf.messages addObjectsFromArray:[tpMessages reverseObjectEnumerator].allObjects];
        }
        
        if (weakSelf.messages.count > 0) {
            [weakSelf.tableView reloadData];
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:weakSelf.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    } failure:^(int errorCode, NSError *error) {
    }];
}

- (void)sendMessage {
    NSString *text = self.textView.text;
    
    if (text.length > 0) {
        __weak typeof(self) weakSelf = self;
        [[TalkPlus sharedInstance] sendMessage:self.channel text:text type:TP_MESSAGE_TYPE_TEXT metaData:nil success:^(TPMessage *tpMessage) {
            if (tpMessage != nil) {
                [weakSelf addMessage:tpMessage];
                weakSelf.textView.text = nil;
            }
        } failure:^(int errorCode, NSError *error) {
        }];
    }
}

- (void)addMessage:(TPMessage *)message {
    [self.messages addObject:message];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
   
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tableView reloadData];
        [weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
}

- (void)leaveChannel {
    __weak typeof(self) weakSelf = self;
    [[TalkPlus sharedInstance] leaveChannel:self.channel deleteChannelIfEmpty:YES success:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
    } failure:^(int errorCode, NSError *error) {
    }];
}

#pragma mark - Keyboard

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)keyboardWillShowNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    
    if (@available(iOS 11, *)) {
        keyboardHeight -= self.view.safeAreaInsets.bottom;
    }
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.bottomView.transform = CGAffineTransformMakeTranslation(0, -keyboardHeight);
        weakSelf.tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
        
        if (weakSelf.messages.count > 0) {
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
    self.bottomView.transform = CGAffineTransformIdentity;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SegueMember"]) {
        MemberViewController *memberViewController = (MemberViewController *)segue.destinationViewController;
        NSArray<TPUser *> *users = sender;
        memberViewController.users = [NSMutableArray arrayWithArray:users];
        memberViewController.channel = self.channel;
    }
}

#pragma mark - TPChannelDelegate
- (void)memberAdded:(TPChannel *)tpChannel users:(NSArray<TPUser *> *)users {
}

- (void)memberLeft:(TPChannel *)tpChannel users:(NSArray<TPUser *> *)users {
}

- (void)messageReceived:(TPChannel *)tpChannel message:(TPMessage *)tpMessage {
    if ([self.channel.getChannelId isEqualToString:tpChannel.getChannelId]) {
        self.channel = tpChannel;
        [self addMessage:tpMessage];
        [self markRead];
    }
}

- (void)channelChanged:(TPChannel *)tpChannel {
    if ([self.channel.getChannelId isEqualToString:tpChannel.getChannelId]) {
        self.channel = tpChannel;
    }
}

- (void)channelAdded:(TPChannel *)tpChannel {
}

- (void)channelRemoved:(TPChannel *)tpChannel {
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TPMessage *message = self.messages[indexPath.row];
    NSString *senderId = message.getUserId;
    NSString *cellIdentifier = [self.userId isEqualToString:senderId] ? @"ChannelCell" : @"ChannelUserCell";
    
    ChannelCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if ([cellIdentifier isEqualToString:@"ChannelUserCell"]) {
        cell.nameLabel.text = message.getUsername;
    }
    cell.messageLabel.text = message.getText;
    long time = message.getCreatedAt;
    NSDate *date = [NSDate milliseconds:time];
    cell.dateLabel.text = [date toFormat:@"yyyy. MM. dd HH:mm"];
    
    int unreadCount = [self.channel getMessageUnreadCount:message];
    if (unreadCount > 0) {
        cell.unreadCountLabel.text = [NSString stringWithFormat:@"%d", unreadCount];
        
    } else {
        cell.unreadCountLabel.text = nil;
    }
    
    return cell;
}

@end
