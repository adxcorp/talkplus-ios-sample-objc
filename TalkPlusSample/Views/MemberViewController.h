//
//  MemberViewController.h
//  TalkPlusSample
//
//  Created by hnroh on 2021/01/20.
//

#import <UIKit/UIKit.h>

@interface MemberViewController : UITableViewController

@property (nonatomic, strong) TPChannel *channel;
@property (nonatomic, strong) NSMutableArray<TPUser *> *users;

@end
