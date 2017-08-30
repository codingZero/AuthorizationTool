//
//  AuthorizationTool.h
//  test
//
//  Created by admin on 2017/8/28.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthorizationTool : NSObject

//获取相册权限
+ (void)getPhotoAuthorizationStatusWithSuccessBlock:(void(^)())block;
//获取相机权限
+ (void)getCameraAuthorizationStatusWithSuccessBlock:(void(^)())block;
//获取麦克风权限
+ (void)getAudioAuthorizationStatusWithSuccessBlock:(void(^)())block;
//获取日程权限
+ (void)getEventAuthorizationStatusWithSuccessBlock:(void(^)())block;
//获取提醒事项权限
+ (void)getRemindAuthorizationStatusWithSuccessBlock:(void(^)())block;
//获取通讯录权限
+ (void)getContactAuthorizationStatusWithSuccessBlock:(void(^)())block;

@end
