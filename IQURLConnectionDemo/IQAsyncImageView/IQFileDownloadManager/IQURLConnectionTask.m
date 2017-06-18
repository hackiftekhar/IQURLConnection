//
// IQURLConnectionTask.m
// https://github.com/hackiftekhar/IQAsyncImageView
// Copyright (c) 2013-14 Iftekhar Qurashi.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "IQURLConnectionTask.h"
#import "IQURLConnection.h"
#import "IQDataCache.h"

NSString *const IQURLConnectionTaskDidFinishNotification      =   @"IQURLConnectionTaskDidFinishNotification";

@implementation IQURLConnectionTask
{
    NSMutableSet *uploadProgressTargets;
    NSMutableSet *downloadProgressTargets;
    NSMutableSet *completionTargets;
    
    __block IQURLConnection *_connection;
    
    NSData *_dataToResume;
}

@synthesize paused = _paused;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        uploadProgressTargets       = [[NSMutableSet alloc] init];
        downloadProgressTargets     = [[NSMutableSet alloc] init];
        completionTargets           = [[NSMutableSet alloc] init];
        _paused = YES;
    }
    return self;
}

-(void)start
{
    _paused = NO;
    _status = IQURLConnectionTaskStatusPreparing;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.fileURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:300];

    _connection = [[IQURLConnection alloc] initWithRequest:request isBackgroundTask:NO resumeData:_dataToResume responseBlock:NULL uploadProgressBlock:^(CGFloat progress) {
        
        _uploadProgress = progress;
        _status = IQURLConnectionTaskStatusUploading;
        
        for (NSInvocation *invocation in uploadProgressTargets)
        {
            [invocation setArgument:&progress atIndex:2];
            [invocation invoke];
        }
        
    } downloadProgressBlock:^(CGFloat progress) {
        
        _downloadProgress = progress;
        _status = IQURLConnectionTaskStatusDownloading;
        
        for (NSInvocation *invocation in downloadProgressTargets)
        {
            [invocation setArgument:&progress atIndex:2];
            [invocation invoke];
        }
        
    } completionBlock:^(NSData * _Nullable result, NSError * _Nullable error) {
        
        if ([error code] == NSURLErrorCancelled)
        {
            _status = IQURLConnectionTaskStatusPaused;
            _dataToResume = result;
        }
        else
        {
            if (result && error == nil)
            {
                _status = IQURLConnectionTaskStatusDownloaded;
                [[IQDataCache sharedCache] storeData:result forURL:self.fileURL.absoluteString];
            }
            else
            {
                _status = IQURLConnectionTaskStatusFailed;
            }
            
            _connection = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:IQURLConnectionTaskDidFinishNotification object:self];
        }
        
        for (NSInvocation *invocation in completionTargets)
        {
            [invocation setArgument:&result atIndex:2];
            [invocation setArgument:&error atIndex:3];
            [invocation invoke];
        }
    }];

    [_connection start];
}

-(BOOL)isPaused
{
    return _paused;
}

-(void)pause
{
    [_connection cancel];
    _paused = YES;
}

-(void)resume
{
    [self start];
    
    for (NSInvocation *invocation in downloadProgressTargets)
    {
        [invocation setArgument:&_downloadProgress atIndex:2];
        [invocation invoke];
    }
}

-(void)cancel
{
    [_connection cancel];
    _connection = nil;
    _dataToResume = nil;
    [uploadProgressTargets removeAllObjects];
    [downloadProgressTargets removeAllObjects];
    [completionTargets removeAllObjects];
}

- (void)addTarget:(id)target action:(SEL)action forTaskEvents:(IQTaskEvents)taskEvents
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
    invocation.target = target;
    invocation.selector = action;
    
    switch (taskEvents)
    {
        case IQTaskEventUploadProgress:     [uploadProgressTargets addObject:invocation];   break;
        case IQTaskEventDownloadProgress:   [downloadProgressTargets addObject:invocation]; break;
        case IQTaskEventFinish:             [completionTargets addObject:invocation];       break;
    }
}

- (void)removeTarget:(id)target action:(SEL)action forTaskEvents:(IQTaskEvents)taskEvents
{
    NSMutableSet *targets = nil;
    
    switch (taskEvents)
    {
        case IQTaskEventUploadProgress:     targets = uploadProgressTargets;    break;
        case IQTaskEventDownloadProgress:   targets = downloadProgressTargets;  break;
        case IQTaskEventFinish:             targets = completionTargets;        break;
    }

    NSInvocation *invocation = nil;
    
    for (NSInvocation *progressInvocation in targets)
    {
        if ([progressInvocation.target isEqual:target] && progressInvocation.selector == action)
        {
            invocation = progressInvocation;
            break;
        }
    }
    
    if (invocation)
    {
        [targets removeObject:invocation];
    }
}


@end
