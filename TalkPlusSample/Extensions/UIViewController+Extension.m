//
//  UIViewController+Extension.m
//  TalkPlusSample
//
//  Created by hnroh on 2021/01/20.
//

#import "UIViewController+Extension.h"

@implementation UIViewController (Extension)

- (void)showToast:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    alert.view.alpha = 0.6;
    alert.view.layer.cornerRadius = 10;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf presentViewController:alert animated:YES completion:nil];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}

@end
