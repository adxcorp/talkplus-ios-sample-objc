//
//  MainCell.m
//  TalkPlusSample
//
//  Created by hnroh on 2021/01/19.
//

#import "MainCell.h"

@implementation MainCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.unreadCountView.layer.cornerRadius = self.unreadCountView.frame.size.height / 2;
    self.unreadCountView.layer.masksToBounds = YES;
}

@end
