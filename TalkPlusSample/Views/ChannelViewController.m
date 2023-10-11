//
//  ChannelViewController.m
//  TalkPlusSample
//
//  Created by hnroh on 2021/01/20.
//

#import "ChannelViewController.h"
#import "ChannelCell.h"

#import "MemberViewController.h"

#import "ImagePickerManager.h"
#import "NSDate+Extension.h"

@interface ChannelViewController () <TPChannelDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *addButton;
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
    
    self.addButton.layer.borderWidth = 0.5;
    self.addButton.layer.borderColor = [UIColor.grayColor colorWithAlphaComponent:0.5].CGColor;
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

- (IBAction)addImageAction:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    actionSheet.popoverPresentationController.barButtonItem = sender;
    actionSheet.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
    __weak typeof(self) weakSelf = self;
    NSArray<UIAlertAction *> *actions = @[
        [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
        }],
        [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }],
        [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil] ];
    
    for (UIAlertAction *action in actions) {
        [actionSheet addAction:action];
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)showImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    __weak typeof(self) weakSelf = self;

    [[ImagePickerManager sharedInstance] showImagePickerWithViewController:self sourceType:sourceType completionHandler:^(UIImage *image, NSString *path) {
        if (path) {
            __typeof__(self) strongSelf = weakSelf;
            NSString *text = strongSelf.textView.text;
            [[TalkPlus sharedInstance] sendFileMessage:strongSelf.channel 
                                                  text:text
                                                  type:TP_MESSAGE_TYPE_TEXT
                                              mentions:@[]
                                       parentMessageId:@""
                                              metaData:nil
                                              filePath:path
                                               success:^(TPMessage *tpMessage) {
                if (tpMessage != nil) {
                    [strongSelf addMessage:tpMessage];
                    strongSelf.textView.text = nil;
                }
            } failure:^(int errorCode, NSError *error) {
                NSLog(@"Error: %@", error.description);
            }];
        }
    }];
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
        
        [[TalkPlus sharedInstance] sendMessage:self.channel 
                                          text:text
                                          type:TP_MESSAGE_TYPE_TEXT
                                      mentions:@[]
                               parentMessageId:@""
                                      metaData:nil
                                       success:^(TPMessage *tpMessage) {
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
- (void)memberAdded:(TPChannel *)tpChannel users:(NSArray<TPMember *> *)users {
    NSLog(@"memberAdded");
}

- (void)memberLeft:(TPChannel *)tpChannel users:(NSArray<TPMember *> *)users {
    NSLog(@"memberLeft");
}

- (void)messageReceived:(TPChannel *)tpChannel message:(TPMessage *)tpMessage {
    NSLog(@"messageReceived");
    if ([self.channel.getChannelId isEqualToString:tpChannel.getChannelId]) {
        self.channel = tpChannel;
        [self addMessage:tpMessage];
        [self markRead];
    }
}

-(void)messageDeleted:(TPChannel *)tpChannel message:(TPMessage *)tpMessage {
    NSLog(@"messageReceived");
}

- (void)channelAdded:(TPChannel *)tpChannel {
    NSLog(@"channelAdded");
}

- (void)channelChanged:(TPChannel *)tpChannel {
    NSLog(@"channelChanged");
    if ([self.channel.getChannelId isEqualToString:tpChannel.getChannelId]) {
        self.channel = tpChannel;
    }
}

- (void)channelRemoved:(TPChannel *)tpChannel {
    NSLog(@"channelRemoved");
}

- (void)publicMemberAdded:(TPChannel *)tpChannel users:(NSArray<TPMember *> *)users {
    NSLog(@"publicMemberAdded");
}

- (void)publicMemberLeft:(TPChannel *)tpChannel users:(NSArray<TPMember *> *)users {
    NSLog(@"publicMemberLeft");
}

- (void)publicChannelAdded:(TPChannel *)tpChannel {
    NSLog(@"publicChannelAdded");
}

- (void)publicChannelChanged:(TPChannel *)tpChannel {
    NSLog(@"publicChannelChanged");
}

- (void)publicChannelRemoved:(TPChannel *)tpChannel {
    NSLog(@"publicChannelRemoved");
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
    
    if (message.getFileUrl != nil && message.getFileUrl.length > 0) {
        NSURL *url = [NSURL URLWithString:message.getFileUrl];
        NSData *data = [NSData dataWithContentsOfURL:url];
        cell.messageImageView.hidden = NO;
        cell.messageImageView.image = [UIImage imageWithData:data];
    } else {
        cell.messageImageView.hidden = YES;
        cell.messageImageView.image = nil;
    }
    
    return cell;
}

@end
