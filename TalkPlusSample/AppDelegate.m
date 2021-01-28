//
//  AppDelegate.m
//  TalkPlusSample
//
//  Created by hnroh on 2021/01/19.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[TalkPlus sharedInstance] initWithAppId:@"875bd0c3-83eb-4086-b7ba-a1a8b05a26fe"];
    
    return YES;
}

@end
