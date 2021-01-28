//
//  ChannelCell.m
//  TalkPlusSample
//
//  Created by hnroh on 2021/01/20.
//

#import "ChannelCell.h"

@implementation ChannelCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.messageView.layer.cornerRadius = 10;
}

@end
