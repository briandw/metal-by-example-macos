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

@interface ViewController ()
@property (nonatomic, strong) MBERenderer *renderer;
@property (nonatomic) NSTimer *refreshTimer;
@property (nonatomic, assign) float baseZoomFactor, pinchZoomFactor;

@end


@implementation ViewController

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
    
    self.baseZoomFactor = 2;
    self.pinchZoomFactor = 1;
    
    self.renderer = [[MBERenderer alloc] initWithLayer:self.metalView.metalLayer];
    
    NSGestureRecognizer *pinchGesture = [[NSMagnificationGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(magGestureDidRecognize:)];
    [self.view addGestureRecognizer:pinchGesture];
    
    NSGestureRecognizer *tapGesture = [[NSClickGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(clickGestureDidRecognize:)];
    [self.view addGestureRecognizer:tapGesture];
}


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
}

- (void)draw
{
    self.renderer.cameraDistance = self.baseZoomFactor * self.pinchZoomFactor;
    [self.renderer draw];
}

@end
