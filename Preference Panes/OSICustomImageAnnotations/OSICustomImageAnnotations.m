#import "OSICustomImageAnnotations.h"
#import "PreferencesWindowController+DCMTK.h"
#import "NSPreferencePane+OsiriX.h"

NSComparisonResult  compareViewTags(id firstView, id secondView, void * context);
NSComparisonResult  compareViewTags(id firstView, id secondView, void * context)
{
   int firstTag;
   int secondTag;
   id v = context;
	
	if( [v boolValue])
	{
		secondTag = [firstView tag];
		firstTag = [secondView tag];
	}
	else
	{
		firstTag = [firstView tag];
		secondTag = [secondView tag];
	}

   if (firstTag == secondTag) {return NSOrderedSame;}
   else
   {
       if (firstTag < secondTag) {return NSOrderedAscending;}
       else {return NSOrderedDescending;}
   }
}

@implementation OSICustomImageAnnotations

- (id) initWithBundle:(NSBundle *)bundle
{
	if( self = [super init])
	{
		NSNib *nib = [[[NSNib alloc] initWithNibNamed: @"OSICustomImageAnnotations" bundle: nil] autorelease];
		[nib instantiateWithOwner:self topLevelObjects:&_tlos];
		
		[self setMainView: [mainWindow contentView]];
		[self mainViewDidLoad];
	}
	
	return self;
}

- (void)dealloc {
    [_tlos release]; _tlos = nil;
    
    [super dealloc];
}

- (void)mainViewDidLoad {
	//[gray setInterceptsMouse:YES];
}

- (void) enableControls:(BOOL)enable
{
	if(!enable) [layoutView setDisabledText:@""];
	else [layoutView setDefaultDisabledText];
	[[self mainView] sortSubviewsUsingFunction:(NSComparisonResult (*)(id, id, void *))compareViewTags context: [NSNumber numberWithBool:enable]];
}

#pragma mark -

- (NSArray*) prepareDICOMFieldsArrays
{
	return [[[[self mainView] window] windowController] prepareDICOMFieldsArrays];
}

- (IBAction) loadsave:(id) sender
{
	if( [sameAsDefaultButton state] == NSOnState) return;
	
	if( [sender selectedSegment] == 0)		// Save
	{
		[self switchModality: modalitiesPopUpButton save: YES];
		
		NSSavePanel *sPanel = [NSSavePanel savePanel];
		[sPanel setAllowedFileTypes:@[@"plist"]];
        sPanel.nameFieldStringValue = [NSString stringWithFormat:@"%@.plist", [[modalitiesPopUpButton selectedItem] title] ];
        
        [sPanel beginWithCompletionHandler:^(NSInteger result) {
            if (result != NSFileHandlingPanelOKButton)
                return;
            
            [[layoutController curDictionary] writeToURL:sPanel.URL atomically:YES];
        }];
	}
	else						// Load
	{
		NSOpenPanel *sPanel = [NSOpenPanel openPanel];
        [sPanel setAllowedFileTypes:@[@"plist"]];

        [sPanel beginWithCompletionHandler:^(NSInteger result) {
            if (result != NSFileHandlingPanelOKButton)
                return;
            
            NSDictionary *cur = [NSDictionary dictionaryWithContentsOfURL:sPanel.URL];
            if( cur)
            {
                if( NSRunInformationalAlertPanel( NSLocalizedString(@"Settings", nil), NSLocalizedString( @"Are you really sure you want to replace current settings? It will delete the current settings.", nil) , NSLocalizedString(@"OK", nil), NSLocalizedString(@"Cancel", nil), 0L) == NSAlertDefaultReturn)
                {
                    NSMutableDictionary *annotationsLayoutDictionary = [layoutController annotationsLayoutDictionary];
                    
                    [annotationsLayoutDictionary setObject: cur  forKey: [layoutController currentModality]];
                    
                    [self switchModality: modalitiesPopUpButton save: NO];
                }
            }
        }];
	}
}

- (IBAction) reset: (id) sender
{
	if( NSRunInformationalAlertPanel( NSLocalizedString(@"Settings", nil), NSLocalizedString( @"Are you really sure you want to reset the current default settings? It will delete the current settings.", nil) , NSLocalizedString(@"OK", nil), NSLocalizedString(@"Cancel", nil), 0L) == NSAlertDefaultReturn)
	{
		NSMutableDictionary *annotationsLayoutDictionary = [layoutController annotationsLayoutDictionary];
		
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"AnnotationsDefault.plist"]];
		
		[annotationsLayoutDictionary setObject: [dict objectForKey:@"Default"]  forKey: @"Default"];
		
		[self switchModality: modalitiesPopUpButton save: NO];
	}
}

- (id)init
{
	NSLog(@"OSICustomImageAnnotations init");
	
	self = [super init];
	if (self != nil)
	{
	}
	
	return self;
}

-(void) willUnselect
{
	[[[self mainView] window] makeFirstResponder: nil];
}

- (void)willSelect
{
	NSLog(@"OSICustomImageAnnotations willSelect");
	
	if( [modalitiesPopUpButton numberOfItems] < 5)
	{
		NSArray *modalities = [NSArray arrayWithObjects:NSLocalizedString(@"Default", nil), @"CR", @"CT", @"DX", @"ES", @"MG", @"MR", @"NM", @"OT",@"PT",@"RF",@"SC",@"US",@"XA", nil];
		
		[modalitiesPopUpButton removeAllItems];

		for (id item in modalities)
			[modalitiesPopUpButton addItemWithTitle: item];
	}
	
	if( layoutController == nil)
	{
		layoutController = [[CIALayoutController alloc] initWithWindow:window];
		[sameAsDefaultButton setHidden:YES];
		[resetDefaultButton setHidden:NO];
	}
}

- (void)didSelect
{
	[layoutController setLayoutView:layoutView];
	[layoutController setPrefPane:self];
	[layoutController awakeFromNib];
    
	[self enableControls:[self isUnlocked]];
}

- (NSPreferencePaneUnselectReply)shouldUnselect;
{
	NSWindow *win = [[self mainView] window];
	[win makeFirstResponder:contentTokenField];
	
	[layoutController validateTokenTextField:self];
	
	if(![layoutController checkAnnotations] || ![layoutController checkAnnotationsContent])
		return NSUnselectCancel;
	else
		return NSUnselectNow;
}

- (void)didUnselect
{
	if(layoutController)
	{
		[layoutController saveAnnotationLayout];
//		[layoutController release];
	}
//	layoutController = nil;

	[DICOMFieldsPopUpButton removeAllItems];
}

- (IBAction)addAnnotation:(id)sender;
{
	[layoutController addAnnotation:sender];
	
	[addCustomDICOMFieldButton setEnabled:YES];
	[addDICOMFieldButton setEnabled:YES];
	[addDatabaseFieldButton setEnabled:YES];
	[addSpecialFieldButton setEnabled:YES];
}

- (IBAction)removeAnnotation:(id)sender;
{
	[layoutController removeAnnotation:sender];
	[titleTextField setStringValue:@""];
	
	[addCustomDICOMFieldButton setEnabled:NO];
	[addDICOMFieldButton setEnabled:NO];
	[addDatabaseFieldButton setEnabled:NO];
	[addSpecialFieldButton setEnabled:NO];
}

- (IBAction)setTitle:(id)sender;
{
	[layoutController setTitle:sender];
}

- (IBAction)addFieldToken:(id)sender;
{
	if(sender==addCustomDICOMFieldButton || sender==addDICOMFieldButton || sender==addDatabaseFieldButton || sender==addSpecialFieldButton)
	{
		NSWindow *win = [[self mainView] window];
		[win makeFirstResponder:contentTokenField];
	}
	[layoutController addFieldToken:sender];
}

- (IBAction)validateTokenTextField:(id)sender;
{
	[layoutController validateTokenTextField:sender];
}

- (IBAction)saveAnnotationLayout:(id)sender;
{
	[layoutController saveAnnotationLayoutForModality:[[modalitiesPopUpButton selectedItem] title]];
}

- (IBAction)switchModality:(id)sender
{
	return [self switchModality: sender save: YES];
}

- (IBAction)switchModality:(id)sender save:(BOOL) save;
{
	[layoutController switchModality:sender save: save];
	[addAnnotationButton setEnabled:[sameAsDefaultButton state]==NSOffState];
	[removeAnnotationButton setEnabled:[sameAsDefaultButton state]==NSOffState];
	[loadsaveButton setEnabled:[sameAsDefaultButton state]==NSOffState];
	
	[addCustomDICOMFieldButton setEnabled:NO];
	[addDICOMFieldButton setEnabled:NO];
	[addDatabaseFieldButton setEnabled:NO];
	[addSpecialFieldButton setEnabled:NO];
}

- (CIALayoutController*)layoutController; {return layoutController;}

- (NSTextField*)titleTextField; {return titleTextField;}
- (NSTokenField*)contentTokenField; {return contentTokenField;}
- (NSTextField*)dicomNameTokenField; {return dicomNameTokenField;}
- (NSTextField*)dicomGroupTextField {return dicomGroupTextField;}
- (NSTextField*)dicomElementTextField; {return dicomElementTextField;}
- (NSTextField*)groupLabel; {return groupLabel;}
- (NSTextField*)elementLabel; {return elementLabel;}
- (NSTextField*)nameLabel; {return nameLabel;}
- (NSButton*)addCustomDICOMFieldButton; {return addCustomDICOMFieldButton;}
- (NSButton*)addDICOMFieldButton; {return addDICOMFieldButton;}
- (NSButton*)addDatabaseFieldButton; {return addDatabaseFieldButton;}
- (NSButton*)addSpecialFieldButton; {return addSpecialFieldButton;}
- (NSPopUpButton*)DICOMFieldsPopUpButton; {return DICOMFieldsPopUpButton;}
- (NSPopUpButton*)databaseFieldsPopUpButton; {return databaseFieldsPopUpButton;}
- (NSPopUpButton*)specialFieldsPopUpButton; {return specialFieldsPopUpButton;}
- (NSBox*)contentBox; {return contentBox;}
- (NSButton*)sameAsDefaultButton; {return sameAsDefaultButton;}
- (NSButton*)resetDefaultButton; {return resetDefaultButton;}
- (NSPopUpButton*)modalitiesPopUpButton; {return modalitiesPopUpButton;}

- (IBAction)setSameAsDefault:(id)sender;
{
	BOOL state = [sameAsDefaultButton state]==NSOnState;

	if(state)
	{
		if( NSRunInformationalAlertPanel( NSLocalizedString(@"Default", nil), NSLocalizedString( @"Are you really sure you want to replace current settings with the default settings? It will delete the current settings.", nil) , NSLocalizedString(@"OK", nil), NSLocalizedString(@"Cancel", nil), 0L) == NSAlertDefaultReturn) 
			[layoutController loadAnnotationLayoutForModality:@"Default"];
		else
		{
			[sameAsDefaultButton setState: NSOffState];
			return;
		}
	}
	else
	{
		[layoutController loadAnnotationLayoutForModality:[[modalitiesPopUpButton selectedItem] title]];
	}
	[layoutView setEnabled:!state];
	[sameAsDefaultButton setState:state];
	[layoutView setNeedsDisplay:YES];
	
	[addAnnotationButton setEnabled:!state];
	[removeAnnotationButton setEnabled:!state];
	[loadsaveButton setEnabled:!state];
	
	[orientationWidgetButton setEnabled:!state];
}

- (NSButton*)orientationWidgetButton; {return orientationWidgetButton;}

- (IBAction)toggleOrientationWidget:(id)sender;
{
	BOOL state = [orientationWidgetButton state]==NSOnState;

	[layoutController setOrientationWidgetEnabled:state];
}

@end
