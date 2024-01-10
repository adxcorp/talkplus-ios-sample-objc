//
//  LoginViewController.m
//  TalkPlusSample
//
//  Created by hnroh on 2021/01/19.
//

#import "LoginViewController.h"

#import "UIViewController+Extension.h"
#import "PushManager.h"

@interface LoginViewController ()

@property (nonatomic, weak) IBOutlet UITextField *userIdTextField;
@property (nonatomic, weak) IBOutlet UITextField *nicknameTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] stringForKey:@"KeyUserID"];
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"KeyUserName"];

    if (userId.length > 0 && userName.length > 0) {
        self.userIdTextField.text = userId;
        self.nicknameTextField.text = userName;
        
        [self login];
    }
}

#pragma mark - Action

- (IBAction)loginAction:(id)sender {
    [self login];
}

#pragma mark - Login

- (void)login {
    NSString *userId = [self.userIdTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *userName = [self.nicknameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (userId.length > 0 && userName.length > 0) {
        __weak typeof(self) weakSelf = self;
        
        TPLoginParams *params = [[TPLoginParams alloc] initWithLoginType:TPLoginAnonymous userId:userId];
        params.userName = userName;
        //params.translationLanguage = @"ko"
        
        [[TalkPlus sharedInstance] login:params success:^(TPUser *tpUser) {
            [[PushManager sharedInstance] registerFCMToken];
            [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"KeyUserID"];
            [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"KeyUserName"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [weakSelf performSegueWithIdentifier:@"SegueMain" sender:nil];
            
        } failure:^(int errorCode, NSError *error) {
            [weakSelf showToast:@"로그인에 실패하였습니다."];
        }];
    }
}

@end
