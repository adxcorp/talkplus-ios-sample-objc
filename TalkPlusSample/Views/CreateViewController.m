//
//  CreateViewController.m
//  TalkPlusSample
//
//  Created by hnroh on 2021/01/19.
//

#import "CreateViewController.h"
#import "InviteViewController.h"

#import "UIViewController+Extension.h"

@interface CreateViewController ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UITextField *codeTextField;

@end

@implementation CreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Create";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(nextAction)];
    
    if ([self.channelType isEqualToString:TP_CHANNEL_TYPE_PRIVATE]) {
        self.titleLabel.text = @"Private Channel";
        [self.codeTextField setHidden:YES];
        
    } else if ([self.channelType isEqualToString:TP_CHANNEL_TYPE_PUBLIC]) {
        self.titleLabel.text = @"Public Channel";
        [self.codeTextField setHidden:YES];
        
    } else if ([self.channelType isEqualToString:TP_CHANNEL_TYPE_INVITATION_ONLY]) {
        self.titleLabel.text = @"Invitation Code Channel";
        [self.codeTextField setHidden:NO];
    }
}

#pragma mark - Action

- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)nextAction {
    if ([self.channelType isEqualToString:TP_CHANNEL_TYPE_INVITATION_ONLY]) {
        NSString *code = [self.codeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (code.length == 0) {
            [self showToast:@"Invitation Code를 입력하세요."];
            
        } else {
            [self performSegueWithIdentifier:@"SegueInvite" sender:nil];
        }
        
    } else {
        [self performSegueWithIdentifier:@"SegueInvite" sender:nil];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SegueInvite"]) {
        InviteViewController *inviteViewController = segue.destinationViewController;
        inviteViewController.channelType = self.channelType;
        inviteViewController.channelName = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        inviteViewController.invitationCode = [self.codeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
}

@end
