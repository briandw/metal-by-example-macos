
#import "MBEMetalView.h"

@import Metal;
@import simd;

typedef struct
{
    vector_float4 position;
    vector_float4 color;
} MBEVertex;

@interface MBEMetalView ()
@property (nonatomic) NSTimer *refreshTimer;

@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipeline;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLBuffer> vertexBuffer;

@end

@implementation MBEMetalView

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

- (void)dealloc
{
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
}

- (void)commonInit
{
     _frameDuration = (1.0 / 60.0f);
    _clearColor = MTLClearColorMake(1, 1, 1, 1);
    [self makeBackingLayer];
    [self makeBuffers];
    [self makePipeline];
}

- (CAMetalLayer *)metalLayer
{
    return (CAMetalLayer *)self.layer;
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

        [self.refreshTimer invalidate];
        self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:self.frameDuration
                                                             target:self
                                                           selector:@selector(redraw)
                                                           userInfo:nil
                                                            repeats:YES];
}

- (void)stopDrawing
{
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
}

- (void)makePipeline
{
    id<MTLLibrary> library = [self.device newDefaultLibrary];
    
    id<MTLFunction> vertexFunc = [library newFunctionWithName:@"vertex_main"];
    id<MTLFunction> fragmentFunc = [library newFunctionWithName:@"fragment_main"];
    
    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineDescriptor.vertexFunction = vertexFunc;
    pipelineDescriptor.fragmentFunction = fragmentFunc;
    
    NSError *error = nil;
    _pipeline = [self.device newRenderPipelineStateWithDescriptor:pipelineDescriptor
                                                       error:&error];
    
    if (!_pipeline)
    {
        NSLog(@"Error occurred when creating render pipeline state: %@", error);
    }
    
    _commandQueue = [self.device newCommandQueue];
}

- (void)makeBuffers
{
    static const MBEVertex vertices[] =
    {
        { .position = {  0.0,  0.5, 0, 1 }, .color = { 1, 0, 0, 1 } },
        { .position = { -0.5, -0.5, 0, 1 }, .color = { 0, 1, 0, 1 } },
        { .position = {  0.5, -0.5, 0, 1 }, .color = { 0, 0, 1, 1 } }
    };
    
    _vertexBuffer = [self.device newBufferWithBytes:vertices
                                        length:sizeof(vertices)
                                       options:MTLResourceOptionCPUCacheModeDefault];
}

- (void)redraw
{
    id<CAMetalDrawable> drawable = [self.metalLayer nextDrawable];
    id<MTLTexture> framebufferTexture = drawable.texture;
    
    if (drawable)
    {
        MTLRenderPassDescriptor *passDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
        passDescriptor.colorAttachments[0].texture = framebufferTexture;
        passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.85, 0.85, 0.85, 1);
        passDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
        passDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
        
        id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
        
        id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];
        [commandEncoder setRenderPipelineState:self.pipeline];
        [commandEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
        [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
        [commandEncoder endEncoding];
        
        [commandBuffer presentDrawable:drawable];
        [commandBuffer commit];
    }
}

@end

