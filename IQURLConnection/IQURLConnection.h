//
//  IQURLConnection.h
// https://github.com/hackiftekhar/IQURLConnection
// Copyright (c) 2013-16 Iftekhar Qurashi.
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

#import <Foundation/NSURLConnection.h>
#import <CoreGraphics/CGBase.h>

@interface IQURLConnection : NSURLConnection

+(NSString*)backgroundSessionFilesDirectory;

///--------------------------
/// @name Initialization
///--------------------------

/**
 Send an asynchronous request, you can optionally register for response, upload, download and completionHandlers. This method automatically triggers `start` method.
 */
+ (nonnull instancetype)sendAsynchronousRequest:(nonnull NSMutableURLRequest *)request
                                  responseBlock:(void (^ __nullable)(NSHTTPURLResponse* _Nullable response))responseBlock
                            uploadProgressBlock:(void (^ __nullable)(CGFloat progress))uploadProgress
                          downloadProgressBlock:(void (^ __nullable)(CGFloat progress))downloadProgress
                              completionHandler:(void (^ __nullable)(NSData* _Nullable result, NSError* _Nullable error))completion;

/**
 Initialize an asynchronous request, you can optionally register for response, upload, download and completionHandlers. This method doesn't automatically triggers `start` method, `start` method should be triggered manually according to need.
 */
- (instancetype _Nonnull )initWithRequest:(NSMutableURLRequest *_Nonnull)request
                         isBackgroundTask:(BOOL)isBackgroundTask
                               resumeData:(NSData*_Nullable)dataToResume
                            responseBlock:(void (^ __nullable)(NSHTTPURLResponse* _Nullable response))responseBlock
                      uploadProgressBlock:(void (^ __nullable)(CGFloat progress))uploadProgress
                    downloadProgressBlock:(void (^ __nullable)(CGFloat progress))downloadProgress
                          completionBlock:(void (^ __nullable)(NSData* _Nullable result, NSError* _Nullable error))completion;

////Functions of NSURLConnection start and cancel
- (void)start;
- (void)cancel;



@property(nonatomic, strong, nullable, class) void (^backgroundSessionCompletionHandler)(void);

@property(nonatomic, strong, readonly) NSURLRequest *originalRequest;
@property(nonatomic, strong, readonly) NSURLSessionTask *task;

@property(nonatomic, assign, readonly) BOOL isBackgroundTask;

@property(nonatomic, strong, readonly) NSDictionary *cachedDictionaryResponse;


///--------------------------
/// @name Request
///--------------------------

/**
 Upload progress of request.
 */
@property(nonatomic, assign, readonly) CGFloat uploadProgress;

/**
 Upload progress callback block.
 */
@property(nullable, nonatomic, strong) void (^uploadProgressBlock)(CGFloat progress);


///--------------------------
/// @name Response
///--------------------------

/**
 HTTP Response by the request. It will be nil before getting a response.
 */
@property(nullable, nonatomic, strong, readonly) NSHTTPURLResponse *response;

/**
 Response callback block.
 */
@property(nullable, nonatomic, strong) void (^responseBlock)(NSHTTPURLResponse* _Nullable response);

/**
 Download progress of request.
 */
@property(nonatomic, assign, readonly) CGFloat downloadProgress;

/**
 Download progress callback block.
 */
@property(nullable, nonatomic, strong) void (^downloadProgressBlock)(CGFloat progress);


///--------------------------
/// @name Response Completion
///--------------------------

/**
 Response data of request.
 */
@property(nullable, nonatomic, strong, readonly) NSData *responseData;

/**
 Error object of request.
 */
@property(nullable, nonatomic, strong, readonly) NSError *error;

/**
 Download progress callback block.
 */
@property(nullable, nonatomic, strong) void (^dataCompletionBlock)(NSData* _Nullable result, NSError* _Nullable error);


///--------------------------
/// @name Cache
///--------------------------

/**
 Previoiusly Cached response of the request.
 */
@property(nullable, nonatomic, strong, readonly) NSCachedURLResponse *cachedURLResponse;

@end
