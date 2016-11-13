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
@end


@implementation ViewController

- (MBEMetalView *)metalView {
    return (MBEMetalView *)self.view;
}

- (void)viewDidLoad {
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
