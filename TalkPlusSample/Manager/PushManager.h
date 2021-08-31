//
//  PushManager.h
//  TalkPlusSample
//
//  Created by hnroh on 2021/08/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PushManager : NSObject

+ (instancetype)sharedInstance;
- (void)registerForRemoteNotifications:(UIApplication *)application;
- (void)registerFCMToken;

@end

NS_ASSUME_NONNULL_END
