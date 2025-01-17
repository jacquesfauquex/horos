#import "N2MutableUInteger.h"


@implementation N2MutableUInteger

@synthesize unsignedIntegerValue = _value;

+(id)mutableUIntegerWithUInteger:(NSUInteger)value {
	return [[[[self class] alloc] initWithUInteger:value] autorelease];
}

-(id)initWithUInteger:(NSUInteger)value {
	if ((self = [super init])) {
		_value = value;
	}
	
	return self;
}

-(void)increment {
	++_value;
}

-(void)decrement {
	if (_value) --_value;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"<N2MutableUInteger: %llu>", (long long)_value];
}

@end
