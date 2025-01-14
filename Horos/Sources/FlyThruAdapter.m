


#import "FlyThruAdapter.h"

// abstract class
@implementation FlyThruAdapter

- (id) initWithWindow3DController: (Window3DController*) aWindow3DController
{
	self = [super init];
	controller = aWindow3DController;
	return self;
}
-(void) dealloc
{
	[super dealloc];
}

- (Camera*) getCurrentCamera{return nil;}
- (void) setCurrentViewToCamera:(Camera*)aCamera{}
- (NSImage*) getCurrentCameraImage:(BOOL) highQuality {return nil;}
- (void) setCurrentViewToLowResolutionCamera:(Camera*)aCamera
{
	[self setCurrentViewToCamera: aCamera];
}
- (void) prepareMovieGenerating{}
- (void) endMovieGenerating{}
@end
