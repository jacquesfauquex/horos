#import "N2RedundantWebServiceClient.h"

@class N2WSDL;

@interface N2SOAPWebServiceClient : N2RedundantWebServiceClient {
	N2WSDL* _wsdl;
}

@property(readonly) N2WSDL* wsdl;

-(id)initWithWSDL:(N2WSDL*)wsdl;
-(id)execute:(NSString*)method;
-(id)execute:(NSString*)function params:(NSArray*)params;

@end
