//
//  MBEVIewController.m
//  MetalTest
//
//  Created by brian on 11/6/16.
//  Copyright © 2016 Rantlab. All rights reserved.
//

#import "MBEVIewController.h"
#import "MBEMetalView.h"


@interface MBEVIewController ()
@end

@implementation MBEVIewController

- (MBEMetalView *)metalView
{
    return (MBEMetalView *)self.view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    [self.metalView startDrawing];
}

@end
