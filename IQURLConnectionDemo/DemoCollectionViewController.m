//
//  DemoCollectionViewController.m
//  AsyncImageView
//
//  Created by Canopus 4 on 16/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "DemoCollectionViewController.h"
#import "IQAsyncImageView.h"
#import "AsyncImageViewCell.h"

@interface DemoCollectionViewController ()

@end

@implementation DemoCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.urls.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AsyncImageViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([AsyncImageViewCell class]) forIndexPath:indexPath];
    
    [cell.asyncImageView loadImage:(self.urls)[indexPath.row]];
    
//    cell.task = [[[SSFileUploadManager sharedManager] tasks] objectAtIndex:indexPath.row];
    
    return cell;
    
}

@end
