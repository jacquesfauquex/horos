
#import "NSView+N2.h"
#import "N2Operators.h"


@implementation NSView (N2)

- (void)setRecursiveEnabled:(BOOL)enabled
{
	if( [self respondsToSelector:@selector(setEnabled:)])
		[(NSControl *)self setEnabled:enabled];
		
	for( NSView *subview in [self subviews])
		[subview setRecursiveEnabled:enabled];
}

-(id)initWithSize:(NSSize)size {
	return [self initWithFrame:NSMakeRect(NSZeroPoint, size)];
}

-(NSRect)sizeAdjust {
	return NSZeroRect;
}

- (NSImage *) screenshotByCreatingPDF {
	NSData *imageData = [self dataWithPDFInsideRect: [self bounds]];
	return [[[NSImage alloc] initWithData: imageData] autorelease];
}
@end
