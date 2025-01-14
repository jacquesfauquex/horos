#import <PreferencePanes/PreferencePanes.h>

@interface PreferencesView : NSControl {
	NSMutableArray* groups;
	id buttonActionTarget;
	SEL buttonActionSelector;
}

@property(retain) id buttonActionTarget;
@property(assign) SEL buttonActionSelector;

-(void)addItemWithTitle:(NSString*)title image:(NSImage*)image toGroupWithName:(NSString*)groupName context:(id)context;
-(NSUInteger)itemsCount;
-(id)contextForItemAtIndex:(NSUInteger)index;
-(NSInteger)indexOfItemWithContext:(id)context;
-(void)removeItemWithBundle: (NSBundle*) bundle;

@end
