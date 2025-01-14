
#import "OSIGeneralPreferencePanePref.h"
#import "NSPreferencePane+OsiriX.h"
#import "AppController.h"
#import "DefaultsOsiriX.h"
#import "N2Debug.h"

static NSArray *languagesToMoveWhenQuitting = nil;

@interface IsQualityEnabled: NSValueTransformer {}
@end
@implementation IsQualityEnabled
+ (Class)transformedValueClass { return [NSNumber class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)item {
   if( [item intValue] == 3 || [item intValue] == 4)
		return [NSNumber numberWithBool: YES];
	else
		return [NSNumber numberWithBool: NO];
}
@end

@implementation OSIGeneralPreferencePanePref

@synthesize languages;

- (id) initWithBundle:(NSBundle *)bundle
{
	if( self = [super init])
	{
        // Scan for available languages
        self.languages = [NSMutableArray array];
        for( NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath: [[NSBundle mainBundle] resourcePath] error: nil])
        {
            if( [[file pathExtension] isEqualToString: @"lproj"])
            {
                NSString *name = [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value: [file stringByDeletingPathExtension]];
                
                if( name.length == 0)
                    name = [file stringByDeletingPathExtension];
                
                [languages addObject: [NSMutableDictionary dictionaryWithObjectsAndKeys: [file stringByDeletingPathExtension], @"foldername", name, @"language", [NSNumber numberWithBool: YES], @"active", nil]];
            }
        }
        
        for( NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath: [[[[NSBundle mainBundle] resourcePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent: @"Resources Disabled"] error: nil])
        {
            if( [[file pathExtension] isEqualToString: @"lproj"])
            {
                NSString *name = [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value: [file stringByDeletingPathExtension]];
                
                if( name.length == 0)
                    name = [file stringByDeletingPathExtension];
                
                [languages addObject: [NSMutableDictionary dictionaryWithObjectsAndKeys: [file stringByDeletingPathExtension], @"foldername", name, @"language", [NSNumber numberWithBool: NO], @"active", nil]];
            }
        }
        
		NSNib *nib = [[[NSNib alloc] initWithNibNamed: @"OSIGeneralPreferencePanePref" bundle: nil] autorelease];
		[nib instantiateWithOwner:self topLevelObjects:&_tlos];
        
        [compressionSettingsWindow retain];
		
		[self setMainView: [mainWindow contentView]];
		[self mainViewDidLoad];
	}
	
	return self;
}

- (NSUInteger) JP2KWriter
{
	return [[NSUserDefaults standardUserDefaults] boolForKey: @"useDCMTKForJP2K"];
}




- (IBAction) resetPreferences: (id) sender
{
	NSInteger result = NSRunInformationalAlertPanel( NSLocalizedString(@"Reset Preferences", nil), NSLocalizedString(@"Are you sure you want to reset ALL preferences of Horos? All the preferences will be reseted to their default values.", nil), NSLocalizedString(@"Cancel",nil), NSLocalizedString(@"OK",nil),  nil);
	
	if( result == NSAlertAlternateReturn)
	{
		for( NSString *k in [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys])
			[[NSUserDefaults standardUserDefaults] removeObjectForKey: k];
		
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (IBAction) savePreferences: (id) sender
{
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    NSSavePanel *save = [NSSavePanel savePanel];
    
    [save setAllowedFileTypes: [NSArray arrayWithObject: @"plist"]];
    [save setNameFieldStringValue: @"Horos-Preferences.plist"];
    
    if( [save runModal] == NSFileHandlingPanelOKButton)
	{
        NSDictionary *defaultsPreferences = [DefaultsOsiriX getDefaults];
        NSMutableDictionary *customizedPreferences = [NSMutableDictionary dictionary];
        
        for( NSString *k in [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys])
        {
            if( [defaultsPreferences objectForKey: k] == nil || [[[NSUserDefaults standardUserDefaults] objectForKey: k] isEqual: [defaultsPreferences objectForKey: k]] == NO)
                [customizedPreferences setObject: [[NSUserDefaults standardUserDefaults] objectForKey: k] forKey: k];
        }
        
		[customizedPreferences writeToURL: save.URL atomically: YES];
	}
}

+ (void) errorMessage:(NSURL*) url
{
    NSRunAlertPanel( NSLocalizedString( @"Preferences", nil), NSLocalizedString( @"Failed to download and synchronize preferences from this URL: %@", nil), NSLocalizedString( @"OK", nil), nil, nil, url.absoluteString);
}

+ (void) addPreferencesFromURL: (NSURL*) url
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    BOOL succeed = NO;
    
    if( url)
    {
        NSLog( @"--- loading preferences from URL: %@", url);
        
        @try {
            BOOL activated = NO;
            if( [NSThread isMainThread] == NO)
                activated = [[NSUserDefaults standardUserDefaults] boolForKey: @"SyncPreferencesFromURL"];
            
            NSDictionary *customizedPreferences = [NSDictionary dictionaryWithContentsOfURL: url];
            
            if( customizedPreferences)
            {
                for( NSString *key in customizedPreferences)
                    [[NSUserDefaults standardUserDefaults] setObject: [customizedPreferences objectForKey: key] forKey: key];
                
                succeed = YES;
                
                if( [NSThread isMainThread] == NO)
                {
                    [[NSUserDefaults standardUserDefaults] setObject: url.absoluteString forKey: @"SyncPreferencesURL"];
                    [[NSUserDefaults standardUserDefaults] setBool: activated forKey: @"SyncPreferencesFromURL"];
                }
            }
        }
        @catch (NSException *exception) {
            N2LogException( exception);
        }
        NSLog( @"--- loading preferences from URL: %@ - DONE", url);
    }
    
    if( succeed == NO)
        [[OSIGeneralPreferencePanePref class] performSelectorOnMainThread: @selector( errorMessage:) withObject: url waitUntilDone: NO];
    
    [pool release];
}

- (IBAction) refreshPreferencesURLSync:(id)sender
{
    [[[self mainView] window] makeFirstResponder: nil];
    
    if( [NSURL URLWithString: [[NSUserDefaults standardUserDefaults] stringForKey: @"SyncPreferencesURL"]] == nil)
        NSRunInformationalAlertPanel( NSLocalizedString(@"Sync Preferences", nil), NSLocalizedString(@"The provided URL doesn't seem correct. Check it's validity.", nil), NSLocalizedString(@"OK",nil), nil,  nil);
    else
    {
        NSInteger result = NSRunInformationalAlertPanel( NSLocalizedString(@"Sync Preferences", nil), NSLocalizedString(@"Are you sure you want to replace  current preferences with the preferences stored at this URL? You cannot undo this operation.", nil), NSLocalizedString(@"Cancel",nil), NSLocalizedString(@"OK",nil),  nil);
        
        if( result == NSAlertAlternateReturn)
            [NSThread detachNewThreadSelector: @selector( addPreferencesFromURL:) toTarget: [OSIGeneralPreferencePanePref class] withObject: [NSURL URLWithString: [[NSUserDefaults standardUserDefaults] stringForKey: @"SyncPreferencesURL"]]];
    }
}

- (IBAction) loadPreferences: (id) sender
{
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    NSOpenPanel *open = [NSOpenPanel openPanel];
    
    open.canChooseFiles = YES;
	open.canChooseDirectories = NO;
	open.canCreateDirectories = NO;
	open.allowsMultipleSelection = NO;
	open.message = NSLocalizedString(@"Select the preferences file (plist) to load:", nil);
	
    if( [open runModal] == NSFileHandlingPanelOKButton)
    {
        NSInteger result = NSRunInformationalAlertPanel( NSLocalizedString(@"Load Preferences", nil), NSLocalizedString(@"Are you sure you want to replace  current preferences with the preferences stored in this file? You cannot undo this operation.", nil), NSLocalizedString(@"Cancel",nil), NSLocalizedString(@"OK",nil),  nil);
        
        if( result == NSAlertAlternateReturn)
            [OSIGeneralPreferencePanePref addPreferencesFromURL: open.URL];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)initialize
{
	IsQualityEnabled *a = [[[IsQualityEnabled alloc] init] autorelease];
	
	[NSValueTransformer setValueTransformer:a forName:@"IsQualityEnabled"];
}

- (void) dealloc
{
	NSLog(@"dealloc OSIGeneralPreferencePanePref");
	
    [languages release];
    
    [compressionSettingsWindow release];
    
    [_tlos release]; _tlos = nil;
    
	[super dealloc];
}

-(void) willUnselect
{
	[[[self mainView] window] makeFirstResponder: nil];
    
    BOOL enabled = NO;
    
    for( NSDictionary *d in languages)
    {
        if( [[d valueForKey: @"active"] boolValue])
            enabled = YES;
    }
    
    // At least one language must be active !
    if( enabled == NO)
        [[languages objectAtIndex: 0] setValue: [NSNumber numberWithBool: YES] forKey: @"active"];
    
    [languagesToMoveWhenQuitting release];
    languagesToMoveWhenQuitting = [languages copy];
}

+ (void) applyLanguagesIfNeeded
{
    NSString *activePath = [[NSBundle mainBundle] resourcePath];
    NSString *inactivePath = [[activePath stringByDeletingLastPathComponent] stringByAppendingPathComponent: @"Resources Disabled"];
    
    if( [[NSFileManager defaultManager] fileExistsAtPath: inactivePath] == NO)
        [[NSFileManager defaultManager] createDirectoryAtPath: inactivePath withIntermediateDirectories: NO attributes: nil error: nil];
    
    for( NSDictionary *d in languagesToMoveWhenQuitting)
    {
        NSString *language = [[d valueForKey: @"foldername"] stringByAppendingPathExtension: @"lproj"];
        
        if( [[d valueForKey: @"active"] boolValue])
        {
            if( [[NSFileManager defaultManager] fileExistsAtPath: [inactivePath stringByAppendingPathComponent: language]])
            {
                NSError *error = nil;
                [[NSFileManager defaultManager] removeItemAtPath: [activePath stringByAppendingPathComponent: language] error: nil];
                if( [[NSFileManager defaultManager] moveItemAtPath: [inactivePath stringByAppendingPathComponent: language] toPath: [activePath stringByAppendingPathComponent: language] error: &error] == NO)
                    NSLog( @"*********** applyLanguagesIfNeeded failed: %@ %@", language, error);
            }
        }
        else
        {
            if( [[NSFileManager defaultManager] fileExistsAtPath: [activePath stringByAppendingPathComponent: language]])
            {
                NSError *error = nil;
                [[NSFileManager defaultManager] removeItemAtPath: [inactivePath stringByAppendingPathComponent: language] error: nil];
                if( [[NSFileManager defaultManager] moveItemAtPath: [activePath stringByAppendingPathComponent: language] toPath: [inactivePath stringByAppendingPathComponent: language] error: &error] == NO)
                    NSLog( @"*********** applyLanguagesIfNeeded failed: %@ %@", language, error);
            }
        }
    }
    
    [languagesToMoveWhenQuitting release];
    languagesToMoveWhenQuitting = nil;
}

- (IBAction) endEditCompressionSettings:(id) sender
{
	[compressionSettingsWindow orderOut:sender];
	[NSApp endSheet: compressionSettingsWindow returnCode:[sender tag]];
	
	if( [sender tag] == 1)
	{
	}
	else
	{
		[[NSUserDefaults standardUserDefaults] setObject: compressionSettingsCopy forKey: @"CompressionSettings"];
		[[NSUserDefaults standardUserDefaults] setObject: compressionSettingsLowResCopy forKey: @"CompressionSettingsLowRes"];
	}
	
	[compressionSettingsCopy autorelease];
	[compressionSettingsLowResCopy autorelease];
}

- (IBAction) editCompressionSettings:(id) sender
{
    if( [[[NSUserDefaults standardUserDefaults] arrayForKey: @"CompressionSettings"] count] < 14)
    {
        NSLog( @"*** reset compression settings");
        [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"CompressionSettings"];
    }
    
    if( [[[NSUserDefaults standardUserDefaults] arrayForKey: @"CompressionSettingsLowRes"] count] < 14)
    {
        NSLog( @"*** reset compression settings");
        [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"CompressionSettingsLowRes"];
    }
    
    compressionSettingsCopy = [[[NSUserDefaults standardUserDefaults] arrayForKey: @"CompressionSettings"] copy];
    compressionSettingsLowResCopy = [[[NSUserDefaults standardUserDefaults] arrayForKey: @"CompressionSettingsLowRes"] copy];
    
    [NSApp beginSheet: compressionSettingsWindow modalForWindow: [[self mainView] window] modalDelegate:self didEndSelector:nil contextInfo:nil];
}

@end
