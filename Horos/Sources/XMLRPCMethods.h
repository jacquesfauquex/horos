#import "N2XMLRPCConnection.h"

@class N2ConnectionListener;
@class HTTPServerRequest;

/** \brief XML-RPC for RIS integration */
@interface XMLRPCInterface : NSObject<N2XMLRPCConnectionDelegate> {
    N2ConnectionListener* _listener;
}

-(id)methodCall:(NSString*)methodName parameters:(NSDictionary*)parameters error:(NSError**)error;
-(void)processXMLRPCMessage:(NSString*)selName httpServerMessage:(NSMutableDictionary*)httpServerMessage HTTPServerRequest:(HTTPServerRequest*)mess version:(NSString*)vers paramDict:(NSDictionary*)paramDict encoding:(NSString*)encoding __deprecated;

@end
