//
//  MBEVIewController.m
//  MetalTest
//
//  Created by brian on 11/6/16.
//  Copyright © 2016 Rantlab. All rights reserved.
//

#import "MBEVIewController.h"
#import "MBEMetalView.h"
#import "MBERenderer.h"

@interface MBEVIewController ()
@property (nonatomic, strong) MBERenderer *renderer;
@end

@implementation MBEVIewController

- (MBEMetalView *)metalView
{
    return (MBEMetalView *)self.view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.renderer = [MBERenderer new];
    self.metalView.delegate = self.renderer;
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    [self.metalView startDrawing];
}

@end
