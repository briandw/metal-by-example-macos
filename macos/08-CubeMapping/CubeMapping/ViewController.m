//
//  ViewController.m
//  Lighting
//
//  Created by Brian Williams on 11/8/16.
//  Copyright © 2016 Rantlab. All rights reserved.
//

#import "ViewController.h"
#import "MBETextureLoader.h"
#import "MBERenderer.h"
#import "MBEMetalView.h"
#import "MBEMatrixUtilities.h"
@import Metal;
@import simd;

@interface ViewController ()
@property (nonatomic, strong) MBERenderer *renderer;
@property (nonatomic) NSTimer *refreshTimer;
@property (nonatomic, assign) float baseZoomFactor, pinchZoomFactor;

@end


@implementation ViewController

- (void)dealloc
{
    [_refreshTimer invalidate];
    _refreshTimer = nil;
}

- (MBEMetalView *)metalView {
    return (MBEMetalView *)self.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1/60.0f
                                                         target:self
                                                       selector:@selector(draw)
                                                       userInfo:nil
                                                        repeats:YES];
    
    self.renderer = [[MBERenderer alloc] initWithLayer:self.metalView.metalLayer];
    
//    NSGestureRecognizer *pinchGesture = [[NSMagnificationGestureRecognizer alloc] initWithTarget:self
//                                                                                  action:@selector(magGestureDidRecognize:)];
//    [self.view addGestureRecognizer:pinchGesture];
//    
//    NSGestureRecognizer *tapGesture = [[NSClickGestureRecognizer alloc] initWithTarget:self
//                                                                              action:@selector(clickGestureDidRecognize:)];
//    [self.view addGestureRecognizer:tapGesture];
}

/*
- (void)magGestureDidRecognize:(NSMagnificationGestureRecognizer *)gesture
{
    switch (gesture.state)
    {
        case NSGestureRecognizerStateChanged:
            self.pinchZoomFactor = 1 / gesture.magnification;
            break;
        case NSGestureRecognizerStateEnded:
            self.baseZoomFactor = self.baseZoomFactor * self.pinchZoomFactor;
            self.pinchZoomFactor = 1.0;
        default:
            break;
    }
    
    float constrainedZoom = fmax(1.0, fmin(100.0, self.baseZoomFactor * self.pinchZoomFactor));
    self.pinchZoomFactor = constrainedZoom / self.baseZoomFactor;
}

- (void)clickGestureDidRecognize:(NSClickGestureRecognizer *)gesture
{
    self.renderer.mipmappingMode = ((self.renderer.mipmappingMode + 1) % 4);
}*/

- (void)updateOrientation
{
    vector_float4 X = { 1.0,    0,      0,      0 };
    vector_float4 Y = { 0,      1.0,    0,      0 };
    vector_float4 Z = { 0,      0,      1.0,    0 };
    vector_float4 W = { 0,      0,      0,      1 };
    
    matrix_float4x4 orientation = { X, Y, Z, W };
    self.renderer.sceneOrientation = orientation;
}

- (void)draw
{
    [self updateOrientation];
    [self.renderer draw];
}

@end
