#import <PreferencePanes/PreferencePanes.h>
#import <SecurityInterface/SFChooseIdentityPanel.h>
#import <SecurityInterface/SFCertificateView.h>
#import "DNDArrayController.h"
#import <WebKit/WebKit.h>

#import "DICOMTLS.h"

@interface OSILocationsPreferencePanePref : NSPreferencePane 
{
	IBOutlet NSPopUpButton			*characterSetPopup;
	IBOutlet NSButton				*addServerDICOM, *addServerSharing,  *verifyPing, *addLocalPath, *loadNodes;
	NSString						*stringEncoding;
	
	IBOutlet DNDArrayController		*localPaths, *osiriXServers, *dicomNodes;
	
	// WADO
	IBOutlet NSWindow				*WADOSettings;
	int								WADOPort, WADOTransferSyntax, WADOhttps;
	NSString						*WADOUrl;
	NSString						*WADOUsername;
	NSString						*WADOPassword;
	
	// TLS
	IBOutlet NSWindow				*TLSSettings;
	BOOL							TLSEnabled;
	BOOL							TLSAuthenticated;
	NSString						*TLSAuthenticationCertificate;
	IBOutlet NSButton				*TLSChooseCertificateButton, *TLSCertificateButton;
	IBOutlet DNDArrayController		*TLSCipherSuitesArrayController;
	NSArray							*TLSSupportedCipherSuite;
	BOOL							TLSUseDHParameterFileURL;
	NSURL							*TLSDHParameterFileURL;
	TLSCertificateVerificationType	TLSCertificateVerification;
	
	IBOutlet NSWindow						*mainWindow;
    BOOL                            testingNodes;
    
    id _tlos;
}

@property int WADOhttps, WADOPort, WADOTransferSyntax;
@property (retain) NSString *WADOUrl;
@property (retain) NSString *WADOUsername;
@property (retain) NSString *WADOPassword;

@property BOOL TLSEnabled, TLSAuthenticated, TLSUseDHParameterFileURL, testingNodes;
@property (retain) NSURL *TLSDHParameterFileURL;
@property (retain) NSArray *TLSSupportedCipherSuite;
@property TLSCertificateVerificationType TLSCertificateVerification;

@property (retain) NSString *TLSAuthenticationCertificate;


+ (BOOL)echoServer:(NSDictionary*)serverParameters;

- (IBAction) testWADOUrl: (id) sender;
- (IBAction)refreshNodesListURL:(id)sender;
- (void)mainViewDidLoad;
- (IBAction)newServer:(id)sender;
- (IBAction)osirixNewServer:(id)sender;
- (IBAction)setStringEncoding:(id)sender;
- (IBAction)test:(id)sender;
- (void)resetTest;
- (IBAction)saveAs:(id)sender;
- (IBAction)loadFrom:(id)sender;
- (IBAction)addPath:(id)sender;
- (IBAction)OsiriXDBsaveAs:(id)sender;
- (IBAction)refreshNodesOsiriXDB:(id)sender;
- (IBAction)OsiriXDBloadFrom:(id)sender;

- (IBAction)cancel:(id)sender;
- (IBAction)ok:(id)sender;
- (IBAction)editWADO:(id)sender;

- (IBAction)editTLS:(id)sender;
- (IBAction)chooseTLSCertificate:(id)sender;
- (IBAction)viewTLSCertificate:(id)sender;
- (void)getTLSCertificate;
- (NSString*)DICOMTLSUniqueLabelForSelectedServer;
- (IBAction)selectAllSuites:(id)sender;
- (IBAction)deselectAllSuites:(id)sender;
@end


@interface NotWADOValueTransformer: NSValueTransformer
{}
@end
