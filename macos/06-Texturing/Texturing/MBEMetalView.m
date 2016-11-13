#import "MBEMetalView.h"

@interface MBEMetalView ()
@property (strong) id<CAMetalDrawable> currentDrawable;
@property (assign) NSTimeInterval frameDuration;
@property (strong) id<MTLTexture> depthTexture;

@property (nonatomic) id <MTLDevice> device;
@property (nonatomic) NSTimer *refreshTimer;

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
    _frameDuration = (1.0 / 60.0f);
    _clearColor = MTLClearColorMake(1, 1, 1, 1);
    
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
    
    [self makeDepthTextureForLayer:self.metalLayer];
}

- (void)setColorPixelFormat:(MTLPixelFormat)colorPixelFormat
{
    self.metalLayer.pixelFormat = colorPixelFormat;
}

- (MTLPixelFormat)colorPixelFormat
{
    return self.metalLayer.pixelFormat;
}

- (void)startDrawing
{
    if (self.window)
    {
        [self.refreshTimer invalidate];
        self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:self.frameDuration
                                                             target:self
                                                           selector:@selector(redraw)
                                                           userInfo:nil
                                                            repeats:YES];
    }
}

- (void)stopDrawing
{
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
}

- (void)redraw
{
    self.currentDrawable = [self.metalLayer nextDrawable];
    
    if ([self.delegate respondsToSelector:@selector(drawInView:)])
    {
        [self.delegate drawInView:self];
    }
}

- (void)makeDepthTextureForLayer:(CAMetalLayer *)metalLayer
{
    CGSize drawableSize = metalLayer.drawableSize;

    if ([self.depthTexture width] != drawableSize.width ||
        [self.depthTexture height] != drawableSize.height)
    {
        MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float
                                                                                        width:drawableSize.width
                                                                                       height:drawableSize.height
                                                                                    mipmapped:NO];

        desc.resourceOptions = MTLResourceStorageModePrivate;
        desc.usage = MTLTextureUsageRenderTarget;
        
        self.depthTexture = [metalLayer.device newTextureWithDescriptor:desc];
    }
    
    NSAssert(self.depthTexture, @"missing texture");
}

- (MTLRenderPassDescriptor *)currentRenderPassDescriptor
{
    MTLRenderPassDescriptor *passDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];

    passDescriptor.colorAttachments[0].texture = [self.currentDrawable texture];
    passDescriptor.colorAttachments[0].clearColor = self.clearColor;
    passDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    passDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;

    passDescriptor.depthAttachment.texture = self.depthTexture;
    passDescriptor.depthAttachment.clearDepth = 1.0;
    passDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
    passDescriptor.depthAttachment.storeAction = MTLStoreActionDontCare;

    return passDescriptor;
}

@end
