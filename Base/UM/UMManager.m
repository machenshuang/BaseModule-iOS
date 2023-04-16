//
//  UMManager.m
//  Common
//
//  Created by 马陈爽 on 2022/5/14.
//

#import "UMManager.h"

//导入UMCommon的OC的头文件
#import <UMCommon/UMCommon.h>
//导入UMAnalytics的OC的头文件
#import <UMCommon/MobClick.h>

#if DEBUG
//导入UMCommonLog的OC的头文件(如需加入日志库 把此注释打开)
//#import <UMCommonLog/UMCommonLogManager.h>
#endif

static UMManager *instance = nil;

@implementation UMManager

+ (instancetype) shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)registerSDKForUMKey:(NSString *)umKey shortVersion:(NSString *)shortVersion buildVersion:(NSString *)buildVersion
{
    [UMConfigure initWithAppkey:umKey channel:@"App Store"];
    [UMConfigure setEncryptEnabled:YES];
    #if DEBUG
    //[UMConfigure setLogEnabled:YES];
    #endif
}



@end
