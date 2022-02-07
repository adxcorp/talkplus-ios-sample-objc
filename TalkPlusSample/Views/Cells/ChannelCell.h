//
//  ChannelCell.h
//  TalkPlusSample
//
//  Created by hnroh on 2021/01/20.
//

#import <UIKit/UIKit.h>

@interface ChannelCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *unreadCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIView *messageView;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UIImageView *messageImageView;

@end
