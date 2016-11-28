//
//  ViewController.m
//  Lighting
//
//  Created by Brian Williams on 11/8/16.
//  Copyright © 2016 Rantlab. All rights reserved.
//

#import "ViewController.h"
#import "MBEMetalView.h"
#import "MBERenderer.h"

@import AudioToolbox;

@interface ViewController ()
@property (nonatomic, strong) MBERenderer *renderer;
@property (nonatomic, assign) CGPoint angularVelocity;
@property (nonatomic) NSTimer *refreshTimer;
@end


@implementation ViewController


- (MBEMetalView *)metalView {
    return (MBEMetalView *)self.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSPanGestureRecognizer *panGesture = [[NSPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(gestureDidRecognize:)];
    [self.view addGestureRecognizer:panGesture];

    self.renderer = [[MBERenderer alloc] initWithLayer:self.metalView.metalLayer];
    
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    
    [self.refreshTimer invalidate];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1/60.0
                                                         target:self
                                                       selector:@selector(redraw)
                                                       userInfo:nil
                                                        repeats:YES];

}

- (void)gestureDidRecognize:(NSGestureRecognizer *)gestureRecognizer
{
    NSPanGestureRecognizer *panGestureRecognizer = (NSPanGestureRecognizer *)gestureRecognizer;
    self.angularVelocity = [panGestureRecognizer velocityInView:self.view];
}

- (void)redraw
{
    [self.renderer draw];
}


@end
