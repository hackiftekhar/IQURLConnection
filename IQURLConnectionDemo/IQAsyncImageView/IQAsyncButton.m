//
// IQAsyncButton.m
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

#import "IQAsyncButton.h"
#import "IQDataCache.h"
#import "IQURLConnection.h"
#import "UAProgressView.h"
#import "IQURLConnectionTaskQueue.h"

@interface IQAsyncButton ()

@property(nonatomic, strong) UAProgressView *progressView;
@property(nonatomic, strong) IQAsyncButtonImageCompletionBlock completion;

@end

@implementation IQAsyncButton
{
    IQURLConnectionTask *downloadTask;
}

-(void)loadImage:(NSString *)urlString
{
    [self loadImage:urlString completionHandler:NULL];
}

-(void)loadImage:(NSString *)urlString completionHandler:(IQAsyncButtonImageCompletionBlock)completion
{
    _completion = completion;
    [self setImage:nil forState:UIControlStateNormal];
    
    if (urlString == nil || [urlString isKindOfClass:[NSNull class]] || [NSURL URLWithString:urlString] == nil)
    {
        [self progress:1.0];
        [self downloadingFinishWithData:nil error:[NSError errorWithDomain:NSStringFromClass([self class]) code:NSURLErrorBadURL userInfo:nil]];
    }
    else
    {
        NSData *data = [[IQDataCache sharedCache] dataForURL:urlString];
        
        if (data)
        {
            [self progress:1.0];
            [self downloadingFinishWithData:data error:nil];
        }
        else
        {
            [self setImage:nil forState:UIControlStateNormal];
            self.progressView.hidden = NO;
            
            //Removing old callbacks
            [self removeCallbacks];
            
            downloadTask = [[IQURLConnectionTaskQueue sharedQueue] taskForURL:[NSURL URLWithString:urlString]];
            [self.progressView setProgress:downloadTask.downloadProgress animated:NO];
            
            [downloadTask addTarget:self action:@selector(progress:) forTaskEvents:IQTaskEventDownloadProgress];
            [downloadTask addTarget:self action:@selector(downloadingFinishWithData:error:) forTaskEvents:IQTaskEventFinish];
        }
    }
}

-(void)progress:(CGFloat)progress
{
    _progress = progress;
    [self.progressView setProgress:progress animated:YES];
}

-(void)downloadingFinishWithData:(NSData*)result error:(NSError*)error
{
    UIImage *image = [[UIImage alloc] initWithData:result];
    
    [self setImage:image forState:UIControlStateNormal];
    self.progressView.hidden = YES;
    
    //Animation
    if (image)
    {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.1f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        transition.removedOnCompletion = YES;
        
        [self.layer addAnimation:transition forKey:nil];
    }
    
    if (self.completion)
    {
        self.completion(image, error);
    }
}

-(UAProgressView *)progressView
{
    if (_progressView == nil)
    {
        _progressView = [[UAProgressView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _progressView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [self addSubview:_progressView];
    }
    
    return _progressView;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _progressView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

-(void)setImage:(UIImage *)image forState:(UIControlState)state
{
    [super setImage:image forState:state];
    
    if (image)
    {
        self.progressView.hidden = YES;
    }
}

-(void)removeCallbacks
{
    self.completion = NULL;

    [downloadTask removeTarget:self action:@selector(progress:) forTaskEvents:IQTaskEventDownloadProgress];
    [downloadTask removeTarget:self action:@selector(downloadingFinishWithData:error:) forTaskEvents:IQTaskEventFinish];
}

-(void)dealloc
{
    [self removeCallbacks];
}

@end

