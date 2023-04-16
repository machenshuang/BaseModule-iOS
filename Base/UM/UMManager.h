//
//  UMManager.h
//  Common
//
//  Created by 马陈爽 on 2022/5/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UMManager : NSObject

+ (instancetype)shared;

- (void)registerSDKForUMKey:(NSString *)umKey shortVersion:(NSString *)shortVersion buildVersion:(NSString *)buildVersion;

@end

NS_ASSUME_NONNULL_END
