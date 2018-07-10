//
//  DownloadTaskManager.h
//  DownloadDemo
//
//  Created by Carmine on 2018/7/9.
//  Copyright © 2018年 Carmine. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DLModel;

typedef void (^progressCallback)(float progress);
typedef void (^completeCallback)(NSString * taskId);

@interface DownloadTaskManager : NSObject

+ (instancetype)sharedManager;

- (void)download:(DLModel *)model progress:(progressCallback)progressHandler complete:(completeCallback)completeHandler;

// 提高该id下载任务的优先级，其他任务pause
- (void)topTaskWithId:(NSString *)taskId;

@end
