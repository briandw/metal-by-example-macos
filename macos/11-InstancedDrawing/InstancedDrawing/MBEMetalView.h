@import AppKit;
@import Metal;
@import QuartzCore.CAMetalLayer;

@protocol MBEMetalViewDelegate;

@interface MBEMetalView : NSView


/// The Metal layer that backs this view
@property (nonatomic, readonly) CAMetalLayer *metalLayer;

@end

