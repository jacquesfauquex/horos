#import <Foundation/Foundation.h>



@interface DCMTransferSyntax : NSObject {

NSString	*transferSyntax;
BOOL		isEncapsulated;
BOOL		isLittleEndian;
BOOL		isExplicit;
NSString	*name;
NSMutableDictionary *transferSyntaxDict;

}
@property(readonly) NSString *transferSyntax;
@property(readonly) NSString *name;
@property(readonly )BOOL isEncapsulated;
@property(readonly) BOOL isLittleEndian;
@property(readonly) BOOL isExplicit;

+(id)ExplicitVRLittleEndianTransferSyntax;
+(id)ImplicitVRLittleEndianTransferSyntax;
+(id)ExplicitVRBigEndianTransferSyntax;

+(id)JPEG2000LosslessTransferSyntax;
+(id)JPEG2000LossyTransferSyntax;
+(id)JPEGBaselineTransferSyntax;
+(id)JPEGExtendedTransferSyntax;
+(id)JPEGLosslessTransferSyntax;
+(id)JPEGLossless14TransferSyntax;
+(id)JPEGLSLosslessTransferSyntax;
+(id)JPEGLSLossyTransferSyntax;
+(id)RLELosslessTransferSyntax;

- (id)initWithTS:(NSString *)ts;
- (id)initWithTS:(NSString *)ts isEncapsulated:(BOOL)encapsulated  isLittleEndian:(BOOL)endian  isExplicit:(BOOL)explicitValue name:(NSString *)aName;
- (id)initWithTransferSyntax:(DCMTransferSyntax *)ts;


- (BOOL)isEqualToTransferSyntax:(DCMTransferSyntax *)ts;

@end
