//
//  AuthorizationTool.m
//  test
//
//  Created by admin on 2017/8/28.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "AuthorizationTool.h"
#import <Photos/Photos.h>
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import <CoreLocation/CoreLocation.h>
#import <EventKit/EventKit.h>


#define iOS7 ([UIDevice currentDevice].systemVersion.floatValue >= 7.0)
#define iOS8 ([UIDevice currentDevice].systemVersion.floatValue >= 8.0)
#define iOS9 ([UIDevice currentDevice].systemVersion.floatValue >= 9.0)
#define iOS10 ([UIDevice currentDevice].systemVersion.floatValue >= 10.0)

@implementation AuthorizationTool

static NSDictionary *authorizationDic;

+ (void)load {
    authorizationDic = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Authorization"];
}

+ (UIViewController *)activityViewController {
    __block UIWindow *normalWindow = [UIApplication sharedApplication].keyWindow;
    NSArray *windows = [UIApplication sharedApplication].windows;
    if (normalWindow.windowLevel != UIWindowLevelNormal) {
        [windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.windowLevel == UIWindowLevelNormal) {
                normalWindow = obj;
                *stop = YES;
            }
        }];
    }
    
    return [self nextTopForViewController:normalWindow.rootViewController];
}

+ (UIViewController *)nextTopForViewController:(UIViewController *)inViewController {
    while (inViewController.presentedViewController) {
        inViewController = inViewController.presentedViewController;
    }
    
    if ([inViewController isKindOfClass:[UITabBarController class]]) {
        UIViewController *selectedVC = [self nextTopForViewController:((UITabBarController *)inViewController).selectedViewController];
        return selectedVC;
    } else if ([inViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *selectedVC = [self nextTopForViewController:((UINavigationController *)inViewController).visibleViewController];
        return selectedVC;
    } else {
        return inViewController;
    }
}


+ (void)getPhotoAuthorizationStatusWithSuccessBlock:(void(^)())block {
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    if (authStatus == PHAuthorizationStatusRestricted || authStatus == PHAuthorizationStatusDenied) {
        [self showMessageWithKey:@"photo"];
    } else if (authStatus == PHAuthorizationStatusAuthorized) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block();
        });
    } else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) block();
                });
            }
        }];
    }
}

+ (void)getCameraAuthorizationStatusWithSuccessBlock:(void(^)())block {
    [self getMediaAuthorizationStatusWithMediaType:AVMediaTypeVideo successBlock:block];
}

+ (void)getAudioAuthorizationStatusWithSuccessBlock:(void(^)())block {
    [self getMediaAuthorizationStatusWithMediaType:AVMediaTypeAudio successBlock:block];
}

+ (void)getMediaAuthorizationStatusWithMediaType:(NSString *)type successBlock:(void(^)())block{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:type];
    if(status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted){
        NSString *key = [type isEqualToString:AVMediaTypeVideo]? @"camera": @"audio";
        [self showMessageWithKey:key];
    } else if(status == AVAuthorizationStatusAuthorized) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block();
        });
    } else {
        [AVCaptureDevice requestAccessForMediaType:type completionHandler:^(BOOL granted) {
            if(granted){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) block();
                });
            }
        }];
    }
}



+ (void)getEventAuthorizationStatusWithSuccessBlock:(void(^)())block {
    [self getEntityAuthorizationStatusWithEntityType:EKEntityTypeEvent successBlock:block];
}

+ (void)getReminderAuthorizationStatusWithSuccessBlock:(void(^)())block {
    [self getEntityAuthorizationStatusWithEntityType:EKEntityTypeReminder successBlock:block];
}

+ (void)getEntityAuthorizationStatusWithEntityType:(EKEntityType)type successBlock:(void(^)())block {
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:type];
    if(status == EKAuthorizationStatusRestricted || status == EKAuthorizationStatusDenied){
        NSString *key = (type == EKEntityTypeEvent)? @"event": @"reminder";
        [self showMessageWithKey:key];
    } else if(status == EKAuthorizationStatusAuthorized) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block();
        });
    } else {
        EKEventStore *store = [[EKEventStore alloc] init];
        [store requestAccessToEntityType:type completion:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) block();
                });
            }
        }];
    }
}

+ (void)getContactAuthorizationStatusWithSuccessBlock:(void(^)())block {
    if (iOS9) {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (status == CNAuthorizationStatusRestricted || status == CNAuthorizationStatusDenied) {
            [self showMessageWithKey:@"contact"];
        } else if (status == CNAuthorizationStatusAuthorized){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) block();
            });
        } else {
            CNContactStore *contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (block) block();
                    });
                }
            }];
        }
    } else {
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        if (status == kABAuthorizationStatusRestricted || status == kABAuthorizationStatusDenied) {
             [self showMessageWithKey:@"contact"];
        } else if (status == kABAuthorizationStatusAuthorized){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) block();
            });
        } else {
            ABAddressBookRef addressBook = ABAddressBookCreate();
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (block) block();
                    });
                }
            });
        }
    }
}

+ (void)showMessageWithKey:(NSString *)key {
    NSDictionary *dic = authorizationDic[key];
    if (!dic) dic = authorizationDic[@"common"];
    if (!dic) return;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:dic[@"title"] message:dic[@"message"] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancel];
    UIAlertAction *go = [UIAlertAction actionWithTitle:@"前往" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([UIApplication.sharedApplication canOpenURL:url]) {
            [UIApplication.sharedApplication openURL:url];
        }
    }];
    [alert addAction:go];
    [self.activityViewController presentViewController:alert animated:YES completion:nil];
}
@end
