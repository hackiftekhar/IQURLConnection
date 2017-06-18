//
//  AsyncImageViewCell.m
//  AsyncImageView
//
//  Created by Canopus 4 on 16/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "AsyncImageViewCell.h"

@implementation AsyncImageViewCell

-(void)prepareForReuse
{
    [super prepareForReuse];
    [self.asyncImageView removeCallbacks];
}

-(void)dealloc
{
    [self.asyncImageView removeCallbacks];
}

@end
