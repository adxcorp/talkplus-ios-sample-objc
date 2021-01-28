//
//  NSDate+Extension.m
//  TalkPlusSample
//
//  Created by hnroh on 2021/01/19.
//

#import "NSDate+Extension.h"

@implementation NSDate (Extension)

+ (instancetype)milliseconds:(long)milliseconds {
    double time = milliseconds / 1000;
    return [NSDate dateWithTimeIntervalSince1970:time];
}

- (NSString *)toFormat:(NSString *)format {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.locale = [NSLocale currentLocale];
    formatter.dateFormat = format;
    
    return [formatter stringFromDate:self];
}
@end
