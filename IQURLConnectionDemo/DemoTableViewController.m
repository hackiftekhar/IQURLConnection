//
//  DemoTableViewController.m
//  AsyncImageView
//
//  Created by Canopus 4 on 16/09/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "DemoTableViewController.h"
#import "DemoCollectionViewController.h"

@interface DemoTableViewController ()

@end

@implementation DemoTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DifferentURL"])
    {
        DemoCollectionViewController *controller = segue.destinationViewController;
        controller.urls = @[    //Medium Images
                            @"http://res.cloudinary.com/demo/image/upload/sample.jpg",
                            @"http://upload.wikimedia.org/wikipedia/commons/1/16/HDRI_Sample_Scene_Balls_(JPEG-HDR).jpg",
                            @"http://imgsv.imaging.nikon.com/lineup/lens/zoom/normalzoom/af-s_24-85mmf_35-45g_ed_vr/img/sample/sample2_l.jpg",
                            @"http://nikonrumors.com/wp-content/uploads/2014/03/Nikon-1-V3-sample-photo.jpg",
                            @"http://imgsv.imaging.nikon.com/lineup/lens/zoom/normalzoom/af-s_dx_18-300mmf_35-56g_ed_vr/img/sample/sample4_l.jpg",
                            @"http://www.cameraegg.org/wp-content/uploads/2013/08/AF-S-DX-NIKKOR-18-140mm-f-3.5-5.6G-ED-VR-sample-images-1.jpg",
                            @"http://dcuser.net/images/nikon/d700/nikon-d700-sample-photo-17.jpg",
                            @"http://upload.wikimedia.org/wikipedia/en/9/9e/Lensbaby-sample.JPG",
                            @"http://indianapublicmedia.org/arts/files/2012/04/sample-gates-9-940x626.jpg",
                            @"http://cdn.gottabemobile.com/wp-content/uploads/2012/02/nikon-d800-sample-image-cat-head-620x507.png",
                            @"http://www.sonolta.com/sony-photos/d/1964-3/dSLR+Sample+Images",
                            @"http://cdn-4.nikon-cdn.com/en_INC/o/oLrTCTTuzYdOceunJwHWLeCyRmU/Photography/S3500_sample-photo_03.jpg",
                            @"http://cdn-4.nikon-cdn.com/en_INC/o/hf5PVfvLIjkWyg0rzAM27OIAroI/Photography/S01_sample-photo_04.jpg",
                            @"http://www.cameraegg.org/wp-content/uploads/2013/02/Nikon-D7100-Sample-Image-5.jpg",
                            @"http://4.bp.blogspot.com/-nTwks1VdWu4/UGAroalldrI/AAAAAAAALOo/SdPxvADI1vk/s1600/sample-pic-sony-w570-6.jpg"
                            ];
    }
    
    else if ([segue.identifier isEqualToString:@"SameURL"])
    {
        DemoCollectionViewController *controller = segue.destinationViewController;
        controller.urls = @[@"http://www.screensavergift.com/wp-content/uploads/BeautifulNature3-610x320.jpg",
                            @"http://3.bp.blogspot.com/-wsg2e3JHlmM/Tph8wx7ISdI/AAAAAAAABCk/9jhaYGA5-wk/s640/Beautiful+Peacock+hd+wallpapers+free+download+-5.jpg",
                            @"http://media-cdn.tripadvisor.com/media/photo-s/02/67/a1/0f/beautiful-turtles.jpg",
                            @"http://1.bp.blogspot.com/-PUanEkDK4Bo/T3APVapVF2I/AAAAAAAACrU/SGbXGdbeLFw/s640/beautiful-birds-2.jpg",
                            @"http://www.screensavergift.com/wp-content/uploads/BeautifulNature3-610x320.jpg",
                            @"http://3.bp.blogspot.com/-wsg2e3JHlmM/Tph8wx7ISdI/AAAAAAAABCk/9jhaYGA5-wk/s640/Beautiful+Peacock+hd+wallpapers+free+download+-5.jpg",
                            @"http://media-cdn.tripadvisor.com/media/photo-s/02/67/a1/0f/beautiful-turtles.jpg",
                            @"http://1.bp.blogspot.com/-PUanEkDK4Bo/T3APVapVF2I/AAAAAAAACrU/SGbXGdbeLFw/s640/beautiful-birds-2.jpg",
                            @"http://www.screensavergift.com/wp-content/uploads/BeautifulNature3-610x320.jpg",
                            @"http://3.bp.blogspot.com/-wsg2e3JHlmM/Tph8wx7ISdI/AAAAAAAABCk/9jhaYGA5-wk/s640/Beautiful+Peacock+hd+wallpapers+free+download+-5.jpg",
                            @"http://media-cdn.tripadvisor.com/media/photo-s/02/67/a1/0f/beautiful-turtles.jpg",
                            @"http://1.bp.blogspot.com/-PUanEkDK4Bo/T3APVapVF2I/AAAAAAAACrU/SGbXGdbeLFw/s640/beautiful-birds-2.jpg",
                            @"http://www.screensavergift.com/wp-content/uploads/BeautifulNature3-610x320.jpg",
                            @"http://3.bp.blogspot.com/-wsg2e3JHlmM/Tph8wx7ISdI/AAAAAAAABCk/9jhaYGA5-wk/s640/Beautiful+Peacock+hd+wallpapers+free+download+-5.jpg",
                            @"http://media-cdn.tripadvisor.com/media/photo-s/02/67/a1/0f/beautiful-turtles.jpg",
                            @"http://1.bp.blogspot.com/-PUanEkDK4Bo/T3APVapVF2I/AAAAAAAACrU/SGbXGdbeLFw/s640/beautiful-birds-2.jpg",
                            @"http://www.screensavergift.com/wp-content/uploads/BeautifulNature3-610x320.jpg",
                            @"http://3.bp.blogspot.com/-wsg2e3JHlmM/Tph8wx7ISdI/AAAAAAAABCk/9jhaYGA5-wk/s640/Beautiful+Peacock+hd+wallpapers+free+download+-5.jpg",
                            @"http://media-cdn.tripadvisor.com/media/photo-s/02/67/a1/0f/beautiful-turtles.jpg",
                            @"http://1.bp.blogspot.com/-PUanEkDK4Bo/T3APVapVF2I/AAAAAAAACrU/SGbXGdbeLFw/s640/beautiful-birds-2.jpg",
                            ];
    }
}

@end
