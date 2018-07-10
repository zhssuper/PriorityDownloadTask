//
//  DownloadTaskManager.m
//  DownloadDemo
//
//  Created by Carmine on 2018/7/9.
//  Copyright © 2018年 Carmine. All rights reserved.
//

#import "DownloadTaskManager.h"
#import <AFNetworking/AFNetworking.h>
#import "DLModel.h"

static DownloadTaskManager * __manager;

@interface DownloadTaskManager ()


@property (nonatomic, strong) AFHTTPSessionManager * sessionManager;
@property (nonatomic, strong) NSDictionary * progressDic;
@property (nonatomic, strong) NSDictionary * completeDic;
@property (nonatomic, strong) NSMutableDictionary * taskDic; // 手动管理


@end

// http://devstreaming.apple.com/videos/wwdc/2014/402xxgg8o88ulsr/402/402_hd_introduction_to_swift.mov
@implementation DownloadTaskManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __manager = [[DownloadTaskManager alloc]init];
        __manager.sessionManager = [[AFHTTPSessionManager alloc]init]; // 使用缺省的超时时间 60s
        __manager.taskDic = [NSMutableDictionary dictionary];
        __manager.progressDic = @{};
        __manager.completeDic = @{};
    });
    return __manager;
}

- (void)download:(DLModel *)model progress:(progressCallback)progressHandler complete:(completeCallback)completeHandler {
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:model.url]];
    NSURLSessionDownloadTask * task = [_sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //
        float percent = downloadProgress.completedUnitCount/(float)downloadProgress.totalUnitCount;
        progressHandler(percent);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //
        NSString *savePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:savePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"-----下载完成-----");
        NSLog(@"filename:%@", response.suggestedFilename);
        completeHandler(model._id);
        [self removeTaskWithId:model._id];
        [self resumeAllTasks];
    }];
    // 加入下载队列
    [_taskDic setValue:task forKey:model._id];
    [task resume];
}

- (void)removeTaskWithId:(NSString *)taskId {
    [_taskDic removeObjectForKey:taskId];
}

- (void)topTaskWithId:(NSString *)taskId {
    [self.taskDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        //
        NSURLSessionDownloadTask * task = (NSURLSessionDownloadTask *)obj;
        if ([key isEqualToString:taskId]) {
            if (task.state == NSURLSessionTaskStateSuspended) {
                // 恢复指定的task，忽略running和completed状态
                [task resume];
                NSLog(@"task:%@ resumed.", key);
            }
        } else {
            if (task.state == NSURLSessionTaskStateRunning) {
                // 暂停其他正在运行的task
                [task suspend];
                NSLog(@"task:%@ suspended.", key);
            }
        }
    }];
}

- (void)resumeAllTasks {
    [self.taskDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        //
        NSURLSessionDownloadTask * task = (NSURLSessionDownloadTask *)obj;
        if (task.state == NSURLSessionTaskStateSuspended) {
            // 恢复指定的task，忽略running和completed状态
            [task resume];
            NSLog(@"[resume all]task:%@ resumed.", key);
        }
    }];
}

@end
