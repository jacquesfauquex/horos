#import "Wait.h"
#import "WaitRendering.h"
#import "NSWindow+N2.h"

@implementation WaitRendering

- (void) showWindow: (id) sender
{
	NSMutableArray *winList = [NSMutableArray array];
	
	for( NSWindow *w in [NSApp windows])
	{
		if( [w isVisible] && ([[w windowController] isKindOfClass: [WaitRendering class]] || [[w windowController] isKindOfClass: [Wait class]]))
			[winList addObject: [w windowController]];
	}
	
	if( [[self window] isVisible] == NO)
	{
		[[self window] center];
		[[self window] setFrame: NSMakeRect( [[self window] frame].origin.x, [[self window] frame].origin.y - [winList count] * (5 + [[self window] frame].size.height), [[self window] frame].size.width, [[self window] frame].size.height) display: NO];
	}
	[super showWindow: sender];
	[[self window] makeKeyAndOrderFront: sender];
	
	[self run];
	
	[[self window] display];
	[[self window] flushWindow];
	[[self window] makeKeyAndOrderFront: sender];
	
	displayedTime = [NSDate timeIntervalSinceReferenceDate];
}

- (void) setCancel:(BOOL) c
{
	supportCancel = c;
	
	[abort setHidden: !c];					[abort display];
	[currentTimeText setHidden: !c];		[currentTimeText display];
	[lastTimeText setHidden: !c];			[lastTimeText display];
}

- (void) thread:(id) sender
{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
	
	while( stop == NO)
	{
//		[current lockFocus];
//		[current setStringValue:[NSString stringWithFormat:@"%0.0f", (float) ([NSDate timeIntervalSinceReferenceDate] - starttime)]];
//		[current display];
//		[current unlockFocus];
//		NSLog(@"go %0.0f s", (float) ([NSDate timeIntervalSinceReferenceDate] - starttime));
//		[NSThread sleepForTimeInterval:0.2];

	//	[NSApp runModalSession:session];
	}
//	lasttime = [NSDate timeIntervalSinceReferenceDate] - starttime;
//	[NSApp abortModal];
//	[NSApp endModalSession:session];
	
    [pool release];
}

- (void) close
{
	while( [NSDate timeIntervalSinceReferenceDate] - displayedTime < 0.1)
		[NSThread sleepForTimeInterval: 0.05];
	
    [[self window] orderOut:self];
    
    if( session != nil)
	{
		[NSApp endModalSession:session];
		session = nil;
	}
}

-(void) end
{
	if( startTime == nil) return;	// NOT STARTED
	
	[self close];
	
	if( aborted == NO && supportCancel == YES)
	{
		lastDuration = -[startTime timeIntervalSinceNow];
	}
	
	[startTime release];
	startTime = nil;
	
	stop = YES;
}

-(void) resetLastDuration
{
	lastDuration = 0;
}

-(void) start
{
	if( startTime == nil)
	{
		aborted = NO;
		stop = NO;
		
		lastTimeFrame = 0;
		startTime = [[NSDate date] retain];
		
		if( lastDuration != 0)
		{
			long hours, minutes, seconds;
			
			hours = lastDuration;
			hours /= (60*60);
			minutes = lastDuration;
			minutes -= hours*60*60;
			minutes /= 60;
			seconds = lastDuration;
			seconds -= hours*60*60 + minutes*60;
			
			[lastTimeText setStringValue:[NSString stringWithFormat: NSLocalizedString( @"Last Duration:\r%2.2d:%2.2d:%2.2d", nil), hours, minutes, seconds]];
		}
		else [lastTimeText setStringValue:@""];
		
		[self showWindow: self];
	}
}

-(BOOL) aborted
{
	return aborted;
}

-(BOOL) run
{
	if( stop) return NO;
	if( startTime == nil) return YES;
	
	if( supportCancel)
	{
		NSTimeInterval  thisTime = [NSDate timeIntervalSinceReferenceDate];
		
		if( session == nil) 
            session = [NSApp beginModalSessionForWindow:[self window]];
		
        [NSApp runModalSession:session];
		
		if( thisTime - lastTimeFrame > 1.0)
		{
			NSTimeInterval  elapsedTime;
			long hours, minutes, seconds;
			
			lastTimeFrame = thisTime;
			
			elapsedTime = -[startTime timeIntervalSinceNow];
			
			hours = elapsedTime;
			hours /= (60*60);
			minutes = elapsedTime;
			minutes -= hours*60*60;
			minutes /= 60;
			seconds = elapsedTime;
			seconds -= hours*60*60 + minutes*60;
			
			[currentTimeText setStringValue:[NSString stringWithFormat: NSLocalizedString( @"Elapsed Time:\r%2.2d:%2.2d:%2.2d", nil), hours, minutes, seconds]];
			
			#if __LP64__
			#else
			UpdateSystemActivity(UsrActivity);	// avoid sleep or screen saver mode
			#endif
		}
	}
	
	return YES;
}

- (void) dealloc
{
    [self close];
    
	[string release];
    string = nil;
    
    [startTime release];
	startTime = nil;
    
	[super dealloc];
}

- (void) setString:(NSString*) str
{
    if( string != str)
    {
        [string release];
        string = [str retain];
	}
    
	[message setStringValue:string];
	[message display];
}

-(void) windowDidLoad
{
    [super windowDidLoad];
    
	[[self window] center];
	
	[message setStringValue: string];
	[progress setUsesThreadedAnimation: YES];
	[progress setIndeterminate: YES];
	[progress startAnimation: self];
	[lastTimeText setStringValue: @""];
}

-(id) init:(NSString*) str
{
	self = [super initWithWindowNibName:@"WaitRendering"];
	string = [str retain];
	session = nil;
	supportCancel = NO;
	lastDuration = 0;
	startTime = nil;
	displayedTime = [NSDate timeIntervalSinceReferenceDate];
	
    [[self window] setAnimationBehavior: NSWindowAnimationBehaviorNone];
    
	[[self window] setLevel: NSModalPanelWindowLevel];
	
	return self;
}

- (void) setCancelDelegate:(id) object
{
	cancelDelegate = object;
}

- (IBAction) abort:(id) sender
{
	stop = YES;
	aborted = YES;
	
	[cancelDelegate abort: self];
}

//- (NSProgressIndicator*) progress { return progress;}

@end
