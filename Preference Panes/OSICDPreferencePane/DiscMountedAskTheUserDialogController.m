#import "DiscMountedAskTheUserDialogController.h"

@interface DiscMountedAskTheUserDialogController ()

@end

@implementation DiscMountedAskTheUserDialogController

@synthesize label = _label;
@synthesize choice = _choice;

- (id)initWithMountedPath:(NSString*)path dicomFilesCount:(NSInteger)count {
    if ((self = [super initWithWindowNibName:@"DiscMountedAskTheUserDialog"])) {
        _mountedPath = [path retain];
        _filesCount = count;
    }
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [_label setStringValue:[NSString stringWithFormat:NSLocalizedString(@"A disc named %@, containing %d DICOM files, was mounted. What do you want to do with these files?", nil), [_mountedPath lastPathComponent], (int)_filesCount]];
}

-(void)dealloc {
    [_mountedPath release];
    [super dealloc];
}

-(IBAction)buttonAction:(NSButton*)sender {
    _choice = [sender tag];
    [NSApp stopModal];
    [[self window] orderOut:self];
}

@end
