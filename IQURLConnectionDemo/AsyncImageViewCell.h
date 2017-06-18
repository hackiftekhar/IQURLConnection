//
//  AsyncImageViewCell.h
//  AsyncImageView
//
//  Created by Canopus 4 on 16/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQAsyncImageView.h"

@interface AsyncImageViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet IQAsyncImageView *asyncImageView;

@end
