#import "ThreadsManager.h"
#import "ThreadModalForWindowController.h"
#import "NSThread+N2.h"

@interface ThreadsManager ()

-(void)subRemoveThread:(NSThread*)thread;

@end

@implementation ThreadsManager

@synthesize threadsController = _threadsController;

+(ThreadsManager*)defaultManager {
	static ThreadsManager* threadsManager = [[self alloc] init];
	return threadsManager;
}

-(id)init {
	self = [super init];
	
	//_threads = [[NSMutableArray alloc] init];
	
	_threadsController = [[NSArrayController alloc] init];
	[_threadsController setSelectsInsertedObjects:NO];
	[_threadsController setAvoidsEmptySelection:NO];
	[_threadsController setObjectClass:[NSThread class]];
    
    // cleanup timer
	_timer = [[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(cleanupFinishedThreads:) userInfo:nil repeats:YES] retain];
    
	return self;
}

-(void)dealloc {
    [_timer invalidate];
    [_timer release];
	[_threadsController release];
	[super dealloc];
}

-(void)cleanupFinishedThreads:(NSTimer*)timer {
    @synchronized (_threadsController) {
        for (NSThread* thread in [[_threadsController.content copy] autorelease])
        {
            if (thread.isFinished)
                [self subRemoveThread:thread];
        }
    }
}

#pragma mark Interface

-(NSArray*)threads {
	@synchronized (_threadsController) {
		return _threadsController.arrangedObjects;
	} return nil;
}

-(NSUInteger)threadsCount {
	@synchronized (_threadsController) {
		return [_threadsController.arrangedObjects count];
	} return 0;
}

-(NSThread*)threadAtIndex:(NSUInteger)index {
	@synchronized (_threadsController) {
		return [_threadsController.arrangedObjects objectAtIndex:index];
	} return nil;
}

-(void)subAddThread:(NSThread*)thread
{
	@synchronized (_threadsController)
    {
	@synchronized (thread)
	{
		if (![NSThread isMainThread])
			NSLog( @"***** NSThread we should NOT be here");
        
		if ([_threadsController.arrangedObjects containsObject:thread] || [thread isFinished])
		{
            // Do nothing
        }
		else
        {
            if (![thread isMainThread]/* && ![thread isExecuting]*/)
            {
                BOOL isExe = [thread isExecuting], isDone = [thread isFinished];
                
                @try
                {

                    if (!isDone) {
                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(threadWillExit:) name:NSThreadWillExitNotification object:thread];
                        [_threadsController addObject:thread];
                    }
                    if (!isExe && !isDone) { // not executing, not done executing... execute now
                        [thread start];
                    }
                    
                    if ([thread isFinished]) // already done?? wtf..
                    {
                        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSThreadWillExitNotification object:thread];
                        [_threadsController removeObject:thread];
                    }
                }
                @catch (NSException* e)
                {
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSThreadWillExitNotification object:thread];
                    [_threadsController removeObject:thread];
                }
            }
        }
	}
    }
}

-(void)addThreadAndStart:(NSThread*)thread
{
    if (![NSThread isMainThread])
    {
        if( [thread isExecuting] == NO && [thread isFinished] == NO)
            [thread start]; // We want to start it immediately: subAddThread must add it on main thread: the main thread is maybe locked.
        [self performSelectorOnMainThread:@selector(subAddThread:) withObject:thread waitUntilDone: NO];
    }
    else [self subAddThread:thread];
}

-(void) subRemoveThread:(NSThread*)thread
{
	@synchronized (_threadsController) {
	@synchronized (thread)
	{
		if (![NSThread isMainThread])
			NSLog( @"***** NSThread we should NOT be here");
        
        if ([_threadsController.content containsObject:thread]) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSThreadWillExitNotification object:thread];
            [_threadsController removeObject:thread];
        }
	}
	}
}

-(void)removeThread:(NSThread*)thread
{
    if (![NSThread isMainThread])
        [self performSelectorOnMainThread:@selector(subRemoveThread:) withObject:thread waitUntilDone:NO];
    else [self subRemoveThread:thread];
}

-(void)threadWillExit:(NSNotification*)notification {
	[self removeThread:notification.object];
}

@end
