#import "DCMTKFileFormat.h"

#include "osconfig.h"
#include "dcfilefo.h"
#include "dcdeftag.h"
#include "ofstd.h"

#include "dctk.h"
#include "dcdebug.h"
#include "cmdlnarg.h"
#include "ofconapp.h"
#include "dcuid.h"       /* for dcmtk version name */
#include "djdecode.h"    /* for dcmjpeg decoders */
#include "dipijpeg.h"    /* for dcmimage JPEG plugin */

@implementation DCMTKFileFormat

@synthesize dcmtkDcmFileFormat;

- (id) initWithFile: (NSString*) file
{
    self = [super init];
    
    DcmFileFormat *fileformat = new DcmFileFormat();
    
    fileformat->loadFile( file.UTF8String, EXS_Unknown, EGL_noChange, DCM_MaxReadLength, ERM_autoDetect);
    self.dcmtkDcmFileFormat = fileformat;
    
    return self;
}

- (void) dealloc
{
    if( self.dcmtkDcmFileFormat)
    {
        delete (DcmFileFormat*) self.dcmtkDcmFileFormat;
        self.dcmtkDcmFileFormat = nil;
    }
    
    [super dealloc];
}
@end
