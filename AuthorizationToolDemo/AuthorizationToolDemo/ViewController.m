//
//  ViewController.m
//  AuthorizationToolDemo
//
//  Created by admin on 2017/8/30.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "ViewController.h"
#import "AuthorizationTool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)getPhotoAuthorization:(id)sender {
    [AuthorizationTool getPhotoAuthorizationStatusWithSuccessBlock:^{
        NSLog(@"获取相册权限成功，在这里就可以打开相册了");
    }];
}

- (IBAction)getContactAuthorization:(id)sender {
    [AuthorizationTool getContactAuthorizationStatusWithSuccessBlock:^{
        NSLog(@"获取通讯录权限成功，在这里就可以获取系统联系人信息了");
    }];
}


@end
