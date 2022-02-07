//
//  ImagePickerManager.m
//  TalkPlusSample
//
//  Created by hnroh on 2022/02/04.
//

#import "ImagePickerManager.h"

#import <Photos/Photos.h>

@interface ImagePickerManager () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation ImagePickerManager

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    if (@available(iOS 11.0, *)) {
        if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
            NSURL *imageURL = info[UIImagePickerControllerImageURL];
            NSString *imagePath = imageURL.path;
            
            if (self.completionBlock) {
                self.completionBlock(image, imagePath);
            }
            
            [picker dismissViewControllerAnimated:YES completion:nil];
            
            return;
        }
    }
    
    NSURL *documentURLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    NSURL *imageURL = [documentURLs URLByAppendingPathComponent:@"image.jpg"];
    NSString *imagePath = imageURL.path;
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    [imageData writeToFile:imagePath atomically:YES];
    
    if (self.completionBlock) {
        self.completionBlock(image, imagePath);
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                       style:UIBarButtonItemStyleDone
                                                                                      target:nil
                                                                                      action:nil];
}

#pragma mark - Show

- (void)showImagePickerWithViewController:(UIViewController *)viewController sourceType:(UIImagePickerControllerSourceType)sourceType completionHandler:(ImagePickerCompletionHandler)completionHandler {
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        __weak typeof(self) weakSelf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            __typeof__(self) strongSelf = weakSelf;
            
            if (@available(iOS 14.0, *)) {
                if ([PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite] == PHAuthorizationStatusAuthorized) {
                    strongSelf.completionBlock = completionHandler;
                    [strongSelf imagePickerWithViewController:viewController sourceType:sourceType];
                    
                } else {
                    [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite
                                                               handler:^(PHAuthorizationStatus status) {
                        if (status == PHAuthorizationStatusAuthorized) {
                            [strongSelf showImagePickerWithViewController:viewController sourceType:sourceType completionHandler:completionHandler];
                        }
                    }];
                }
                
            } else {
                if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
                    strongSelf.completionBlock = completionHandler;
                    [strongSelf imagePickerWithViewController:viewController sourceType:sourceType];
                    
                } else {
                    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                        if (status == PHAuthorizationStatusAuthorized) {
                            [strongSelf showImagePickerWithViewController:viewController sourceType:sourceType completionHandler:completionHandler];
                        }
                    }];
                }
            }
        });
    } else {
        NSLog(@"ERROR");
    }
}

- (void)imagePickerWithViewController:(UIViewController *)viewController sourceType:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    [viewController presentViewController:imagePickerController
                                 animated:YES
                               completion:nil];
}

@end
