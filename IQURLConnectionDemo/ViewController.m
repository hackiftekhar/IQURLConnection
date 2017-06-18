//
//  ViewController.m
//  IQURLConnectionDemo
//
//  Created by Iftekhar 4 on 03/02/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "ViewController.h"
#import "DAProgressOverlayView.h"
#import "IQURLConnection.h"

@interface ViewController ()
{
    __weak IBOutlet UIImageView *imageViewProgress;
    DAProgressOverlayView *progressOverlayView;
    __weak IBOutlet UILabel *labelProgress;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    progressOverlayView = [[DAProgressOverlayView alloc] init];
    imageViewProgress.layer.masksToBounds = YES;
    imageViewProgress.layer.cornerRadius = 35.;

	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)downloadButtonClicked:(UIButton *)sender
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/IQPhotoEditor/IQPhotoEditor/master/IQPhotoEditor%20Demo/Screenshot/IQPhotoEditorScreenshot1.png"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:300];
    
    imageViewProgress.image = nil;
    labelProgress.text = [NSString stringWithFormat:@"Progress:0%%"];
    [imageViewProgress addSubview:progressOverlayView];
    [progressOverlayView displayOperationWillTriggerAnimation];
    
    [IQURLConnection sendAsynchronousRequest:request responseBlock:^(NSHTTPURLResponse *response) {
    } uploadProgressBlock:^(CGFloat progress) {
    } downloadProgressBlock:^(CGFloat progress) {
        progressOverlayView.progress = progress;
        labelProgress.text = [NSString stringWithFormat:@"Progress:%d%%",(int)(progress*100)];
    } completionHandler:^(NSData *result, NSError *error) {
        
        UIImage *image = [UIImage imageWithData:result];
        imageViewProgress.image = image;
        
        [progressOverlayView displayOperationDidFinishAnimation];
        progressOverlayView.progress = 0;
        labelProgress.text = [NSString stringWithFormat:@"Progress:100%%"];
        
        [progressOverlayView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:progressOverlayView.stateChangeAnimationDuration];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
