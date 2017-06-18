//
// IQDataCache.m
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

#import "IQDataCache.h"

@implementation IQDataCache
{
    NSCache *_cache;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _cache = [[NSCache alloc] init];
        [_cache setName:@"Selfie Cache"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

+(IQDataCache*)sharedCache
{
    static IQDataCache *dataCache;
    
    if (dataCache == nil)
    {
        dataCache = [[self alloc] init];
    }
    
    return dataCache;
}

-(void)storeData:(NSData*)data forURL:(NSString*)url
{
    if (data != nil && url != nil)
    {
        [_cache setObject:data forKey:url];
    }
}

-(NSData*)dataForURL:(NSString*)url
{
    if (url != nil)
    {
        return [_cache objectForKey:url];
    }
    else
    {
        return nil;
    }
}

-(void)removeCacheDataForURL:(NSString*)urlString
{
    [_cache removeObjectForKey:urlString];
}

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
    [_cache removeAllObjects];
}

@end
