#import "MBEMetalView.h"

@interface MBEMetalView ()

@property (nonatomic) id <MTLDevice> device;

@end

@implementation MBEMetalView

+ (Class)layerClass
{
    return [CAMetalLayer class];
}

- (CAMetalLayer *)metalLayer
{
    return (CAMetalLayer *)self.layer;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        _device = MTLCreateSystemDefaultDevice();
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame device:(id<MTLDevice>)device
{
    if ((self = [super initWithFrame:frame]))
    {
        _device = device;
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
}

- (CALayer *)makeBackingLayer
{
    CAMetalLayer *layer = [[CAMetalLayer alloc] init];
    layer.bounds = self.bounds;
    layer.device = self.device;
    layer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    
    return layer;
}

- (void)layout
{
    [super layout];
    CGFloat scale = [NSScreen mainScreen].backingScaleFactor;
    
    // If we've moved to a window by the time our frame is being set, we can take its scale as our own
    if (self.window)
    {
        scale = self.window.screen.backingScaleFactor;
    }
    
    CGSize drawableSize = self.bounds.size;
    
    // Since drawable size is in pixels, we need to multiply by the scale to move from points to pixels
    drawableSize.width *= scale;
    drawableSize.height *= scale;
    
    self.metalLayer.drawableSize = drawableSize;
}

@end
