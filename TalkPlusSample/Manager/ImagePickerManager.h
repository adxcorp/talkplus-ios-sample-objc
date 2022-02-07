//
//  ImagePickerManager.h
//  TalkPlusSample
//
//  Created by hnroh on 2022/02/04.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef void(^ImagePickerCompletionHandler)(UIImage *_Nullable image, NSString *_Nullable path);

@interface ImagePickerManager : NSObject

@property (nonatomic, copy) ImagePickerCompletionHandler completionBlock;

+ (instancetype)sharedInstance;

- (void)showImagePickerWithViewController:(UIViewController *)viewController
                               sourceType:(UIImagePickerControllerSourceType)sourceType
                        completionHandler:(ImagePickerCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
