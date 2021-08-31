//
//  PushManager.m
//  TalkPlusSample
//
//  Created by hnroh on 2021/08/27.
//

#import "PushManager.h"

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@import Firebase;

@interface PushManager () <UNUserNotificationCenterDelegate, FIRMessagingDelegate>

@end

@implementation PushManager

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)registerForRemoteNotifications:(UIApplication *)application {
    [FIRApp configure];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge)
                          completionHandler:^(BOOL granted, NSError *error) {
    }];
    
    [application registerForRemoteNotifications];
    
    [FIRMessaging messaging].delegate = self;
}

- (void)registerFCMToken {
    [[FIRMessaging messaging] tokenWithCompletion:^(NSString *token, NSError *error) {
        if (token != nil) {
            [[TalkPlus sharedInstance] registerFCMToken:token success:^{
                NSLog(@"fcmToken register success");
                
            } failure:^(int errorCode, NSError *error) {
                NSLog(@"fcmToken register failure");
            }];
        }
    }];
}

#pragma mark - FIRMessagingDelegate

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(nullable NSString *)fcmToken {
    NSLog(@"fcmToken : %@", fcmToken);
}

@end
