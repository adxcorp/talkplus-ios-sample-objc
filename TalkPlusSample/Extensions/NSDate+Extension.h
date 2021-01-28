//
//  NSDate+Extension.h
//  TalkPlusSample
//
//  Created by hnroh on 2021/01/19.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extension)

+ (instancetype)milliseconds:(long)milliseconds;
- (NSString *)toFormat:(NSString *)format;

@end
