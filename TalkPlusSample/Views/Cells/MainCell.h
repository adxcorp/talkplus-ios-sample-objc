//
//  MainCell.h
//  TalkPlusSample
//
//  Created by hnroh on 2021/01/19.
//

#import <UIKit/UIKit.h>

@interface MainCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIView *unreadCountView;
@property (nonatomic, weak) IBOutlet UILabel *unreadCountLabel;

@end
