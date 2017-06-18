//
//  IQURLConnection.m
// https://github.com/hackiftekhar/IQURLConnection
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


#import "IQURLConnection.h"

//App Transport Layer Security info.plist key documentation
//https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW44

@interface IQURLConnection ()<NSURLSessionDataDelegate>
{
    NSError *_customError;
    NSMutableData *_data;
}

@property(nonatomic, strong) NSURLSession *session;

@end

@implementation IQURLConnection

#pragma mark - Initializers

+ (nonnull instancetype)sendAsynchronousRequest:(nonnull NSMutableURLRequest *)request
                                  responseBlock:(void (^ __nullable)(NSHTTPURLResponse* _Nullable response))responseBlock
                            uploadProgressBlock:(void (^ __nullable)(CGFloat progress))uploadProgress
                          downloadProgressBlock:(void (^ __nullable)(CGFloat progress))downloadProgress
                              completionHandler:(void (^ __nullable)(NSData* _Nullable result, NSError* _Nullable error))completion
{
    IQURLConnection *asyncRequest = [[IQURLConnection alloc] initWithRequest:request isBackgroundTask:NO resumeData:nil responseBlock:responseBlock uploadProgressBlock:uploadProgress downloadProgressBlock:downloadProgress completionBlock:completion];
    [asyncRequest start];
    
    return asyncRequest;
}

- (instancetype _Nonnull )initWithRequest:(NSMutableURLRequest *_Nonnull)request
                         isBackgroundTask:(BOOL)isBackgroundTask
                               resumeData:(NSData*_Nullable)dataToResume
                            responseBlock:(void (^ __nullable)(NSHTTPURLResponse* _Nullable response))responseBlock
                      uploadProgressBlock:(void (^ __nullable)(CGFloat progress))uploadProgress
                    downloadProgressBlock:(void (^ __nullable)(CGFloat progress))downloadProgress
                          completionBlock:(void (^ __nullable)(NSData* _Nullable result, NSError* _Nullable error))completion
{
    if ([dataToResume length])
    {
        [request addValue:[NSString stringWithFormat: @"bytes=%lu-",(unsigned long)[dataToResume length]] forHTTPHeaderField:@"Range"];
    }
    
    if (self = [super init])
    {
        _isBackgroundTask = isBackgroundTask;
        
        if (isBackgroundTask && request.HTTPBody)
        {
            //Creating directory for saving file
            NSString *documentsDirectory = [[self class] backgroundSessionFilesDirectory];
            
            NSString *fileName = [[NSUUID UUID] UUIDString];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            
            [request.HTTPBody writeToURL:fileURL atomically:YES];
            
            //If file created successfully, then uploading using background session
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
            {
                static int i = 0;
                i++;
                NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
                NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[bundleIdentifier stringByAppendingFormat:@".background%d",i]];
                _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
                
                _task = [_session uploadTaskWithRequest:request fromFile:fileURL];
            }
            //else uploading through default session
            else
            {
                NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
                _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
                _task = [_session uploadTaskWithRequest:request fromData:request.HTTPBody];
            }
        }
        else
        {
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
            _task = [_session dataTaskWithRequest:request];
        }
        
        _uploadProgressBlock = uploadProgress;
        _downloadProgressBlock = downloadProgress;
        _dataCompletionBlock = completion;
        _responseBlock = responseBlock;
        
        _data = [[NSMutableData alloc] initWithData:dataToResume];
    }
    return self;
}

#pragma mark - Getters

+(NSString*)backgroundSessionFilesDirectory
{
    //Creating directory for saving file
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
    NSString *backgroundDirectory = [documentsDirectory stringByAppendingPathComponent:[[[NSBundle mainBundle] bundleIdentifier] stringByAppendingPathComponent:@"background"]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:backgroundDirectory] == NO)
    {
        [fileManager createDirectoryAtPath:backgroundDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return backgroundDirectory;
}


-(NSURLRequest *)originalRequest
{
    return _task.originalRequest;
}

-(NSHTTPURLResponse *)response
{
    if ([_task.response isKindOfClass:[NSHTTPURLResponse class]])
    {
        return (NSHTTPURLResponse*)_task.response;
    }
    else
    {
        return nil;
    }
}

-(CGFloat)downloadProgress
{
    if (_task.countOfBytesExpectedToReceive != 0)
    {
        return ((CGFloat)_task.countOfBytesReceived/(CGFloat)_task.countOfBytesExpectedToReceive);
    }
    else
    {
        return 0;
    }
}

-(CGFloat)uploadProgress
{
    if (_task.countOfBytesExpectedToSend != 0)
    {
        return ((CGFloat)_task.countOfBytesSent/(CGFloat)_task.countOfBytesExpectedToSend);
    }
    else
    {
        return 0;
    }
}

-(NSError *)error
{
    if (_customError)
    {
        return _customError;
    }
    else
    {
        return _task.error;
    }
}

-(NSCachedURLResponse *)cachedURLResponse
{
    return [[NSURLCache sharedURLCache] cachedResponseForRequest:self.originalRequest];
}

-(NSDictionary *)cachedDictionaryResponse
{
    NSData *data = [[self cachedURLResponse] data];
    
    if (data)
    {
        return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        return nil;
    }
}

-(NSData *)responseData
{
    return _data;
}

-(void)sendDownloadProgress:(CGFloat)progress
{
    if (_downloadProgressBlock && progress > 0)
    {
        void (^progressBlock)(CGFloat progress) = _downloadProgressBlock;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if (progressBlock)
            {
                progressBlock(progress);
            }
        }];
    }
}

-(void)sendUploadProgress:(CGFloat)progress
{
    if (_uploadProgressBlock && progress > 0)
    {
        void (^progressBlock)(CGFloat progress) = _uploadProgressBlock;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if (progressBlock)
            {
                progressBlock(progress);
            }
        }];
    }
}

void (^_backgroundSessionCompletionHandler)(void);

+(void)setBackgroundSessionCompletionHandler:(void (^)(void))backgroundSessionCompletionHandler
{
    _backgroundSessionCompletionHandler = backgroundSessionCompletionHandler;
}

+(void (^)(void))backgroundSessionCompletionHandler
{
    return _backgroundSessionCompletionHandler;
}

-(void)sendCompletionData:(NSData*)data error:(NSError*)error
{
    if (_dataCompletionBlock)
    {
        void (^completionBlock)(NSData* _Nullable result, NSError* _Nullable error) = _dataCompletionBlock;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if (completionBlock)
            {
                completionBlock(data,error);
            }
            
            if ([[self class] backgroundSessionCompletionHandler])
            {
                [[self class] backgroundSessionCompletionHandler]();
                [self class].backgroundSessionCompletionHandler = nil;
            }
        }];
    }
}

-(void)sendResponse:(NSHTTPURLResponse*)response
{
    if (_responseBlock)
    {
        void (^responseBlock)(NSHTTPURLResponse* _Nullable response) = _responseBlock;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if (responseBlock)
            {
                responseBlock(response);
            }
        }];
    }
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
{
    NSURLComponents *requestURLComponent = [[NSURLComponents alloc] initWithURL:task.originalRequest.URL resolvingAgainstBaseURL:NO];
    
    NSURLProtectionSpace *protectionSpace = [challenge protectionSpace];
    
    if ([[protectionSpace authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:protectionSpace.serverTrust];
        
        completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
    }
    else
    {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling,nil);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    [self sendUploadProgress:self.uploadProgress];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error
{
    [self sendCompletionData:_data error:error];
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    NSDictionary *headers = [response allHeaderFields];
    if (headers)
    {
        if (_data == nil)
        {
            _data = [[NSMutableData alloc] init];
        }
    }
    
    [self sendResponse:response];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [_data appendData:data];
    
    [self sendDownloadProgress:self.downloadProgress];
}

#pragma mark - Other methods

-(void)start
{
    _customError = nil;
    [self.task resume];
}

-(void)cancel
{
    _customError = [NSError errorWithDomain:NSStringFromClass([self class]) code:NSURLErrorCancelled userInfo:nil];
    
    [self sendCompletionData:_data error:_customError];
    
    [self.task cancel];
    
    _responseBlock = NULL;
    _uploadProgressBlock = NULL;
    _downloadProgressBlock = NULL;
    _dataCompletionBlock = NULL;
}

-(void)dealloc
{
    _data = nil;
    _uploadProgressBlock = NULL;
    _downloadProgressBlock = NULL;
    _responseBlock = NULL;
    _dataCompletionBlock = NULL;
}

@end
