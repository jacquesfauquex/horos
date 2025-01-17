
#import "NSUserDefaultsController+N2.h"
#import "N2Debug.h"

@implementation NSUserDefaultsController (N2)

-(NSString*)stringForKey:(NSString*)key {
	id obj = [self.values valueForKey:key];
	if (![obj isKindOfClass:[NSString class]]) return NULL;
	return obj;
}

-(NSArray*)arrayForKey:(NSString*)key {
	id obj = [self.values valueForKey:key];
	if (![obj isKindOfClass:[NSArray class]]) return NULL;
	return obj;
}

-(NSDictionary*)dictionaryForKey:(NSString*)key {
	id obj = [self.values valueForKey:key];
	if (![obj isKindOfClass:[NSDictionary class]]) return NULL;
	return obj;
}

-(NSData*)dataForKey:(NSString*)key {
	id obj = [self.values valueForKey:key];
	if (![obj isKindOfClass:[NSData class]]) return NULL;
	return obj;
}

-(NSInteger)integerForKey:(NSString*)key {
	NSNumber* obj = [self.values valueForKey:key];
	if (![obj respondsToSelector:@selector(integerValue)]) return 0;
	return [obj integerValue];
}

-(float)floatForKey:(NSString*)key {
	NSNumber* obj = [self.values valueForKey:key];
	if (![obj respondsToSelector:@selector(floatValue)]) return 0;
	return [obj floatValue];
}

-(double)doubleForKey:(NSString*)key {
	NSNumber* obj = [self.values valueForKey:key];
	if (![obj respondsToSelector:@selector(doubleValue)]) return 0;
	return [obj doubleValue];
}

-(BOOL)boolForKey:(NSString*)key {
	NSNumber* obj = [self.values valueForKey:key];
	if (![obj respondsToSelector:@selector(boolValue)]) return NO;
	return [obj boolValue];
}

-(void)setString:(NSString*)value forKey:(NSString*)defaultName {
	if (![value isKindOfClass:[NSString class]])
		[NSException raise:NSInvalidArgumentException format:@"Value must be of class NSString"];
	[self.values setValue:value forKey:defaultName];
}

-(void)setArray:(NSArray*)value forKey:(NSString*)defaultName {
	if (![value isKindOfClass:[NSArray class]])
		[NSException raise:NSInvalidArgumentException format:@"Value must be of class NSArray"];
	[self.values setValue:value forKey:defaultName];
}

-(void)setDictionary:(NSDictionary*)value forKey:(NSString*)defaultName {
	if (![value isKindOfClass:[NSDictionary class]])
		[NSException raise:NSInvalidArgumentException format:@"Value must be of class NSDictionary"];
	[self.values setValue:value forKey:defaultName];
}

-(void)setData:(NSData*)value forKey:(NSString*)defaultName {
	if (![value isKindOfClass:[NSData class]])
		[NSException raise:NSInvalidArgumentException format:@"Value must be of class NSData"];
	[self.values setValue:value forKey:defaultName];
}

//-(void)setStringArray:(NSArray*)value forKey(NSString*)defaultName 

-(void)setInteger:(NSInteger)value forKey:(NSString*)defaultName {
	[self.values setValue:[NSNumber numberWithInteger:value] forKey:defaultName];
}

-(void)setFloat:(float)value forKey:(NSString*)defaultName {
	[self.values setValue:[NSNumber numberWithFloat:value] forKey:defaultName];
}

-(void)setDouble:(double)value forKey:(NSString*)defaultName {
	[self.values setValue:[NSNumber numberWithDouble:value] forKey:defaultName];
}

-(void)setBool:(BOOL)value forKey:(NSString*)defaultName {
	[self.values setValue:[NSNumber numberWithBool:value] forKey:defaultName];
}

@end

CF_EXTERN_C_BEGIN

NSString* valuesKeyPath(NSString* key) {
	return [@"values." stringByAppendingString:key];
}

CF_EXTERN_C_END

@implementation NSObject (N2ValuesBinding)

-(id)valueForValuesKey:(NSString*)keyPath {
	return [self valueForKeyPath:valuesKeyPath(keyPath)];
}

-(void)setValue:(id)value forValuesKey:(NSString*)keyPath {
	[self setValue:value forKeyPath:valuesKeyPath(keyPath)];
}

-(void)bind:(NSString*)binding toObject:(id)observable withValuesKey:(NSString*)key options:(NSDictionary*)options {
	[self bind:binding toObject:observable withKeyPath:valuesKeyPath(key) options:options];
}

-(void)addObserver:(NSObject*)observer forValuesKey:(NSString*)key options:(NSKeyValueObservingOptions)options context:(void*)context {
	[self addObserver:observer forKeyPath:valuesKeyPath(key) options:options context:context];
}

-(void)removeObserver:(NSObject*)observer forValuesKey:(NSString*)key {
    
    @try {
        [self removeObserver:observer forKeyPath:valuesKeyPath(key)];
    }
    @catch (NSException *exception) {
        N2LogException( exception);
    }
}

@end

