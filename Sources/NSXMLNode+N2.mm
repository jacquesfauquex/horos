#import "NSXMLNode+N2.h"


@implementation NSXMLNode (N2)

+(id)elementWithName:(NSString*)name text:(NSString*)text {
	return [self elementWithName:name children:[NSArray arrayWithObject:[NSXMLNode textWithStringValue:text]] attributes:NULL];
}

+(id)elementWithName:(NSString*)name unsignedInt:(NSUInteger)value {
	return [self elementWithName:name text:[NSString stringWithFormat:@"%u", (int) value]];
}

+(id)elementWithName:(NSString*)name bool:(BOOL)value {
	return [self elementWithName:name text: value? @"True" : @"False" ];	
}

-(NSXMLNode*)childNamed:(NSString*)childName {
	for (NSXMLNode* child in [self children]) 
		if ([[child name] isEqualToString:childName])
			return child;
	return NULL;
}

@end
