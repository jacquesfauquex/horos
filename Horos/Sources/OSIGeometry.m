#import "OSIGeometry.h"


OSISlab OSISlabMake(N3Plane plane, CGFloat thickness)
{
    OSISlab slab;
    slab.plane = plane;
    slab.thickness = thickness;
    return slab;
}

bool OSISlabEqualTo(OSISlab slab1, OSISlab slab2)
{
    return N3PlaneEqualToPlane(slab1.plane, slab2.plane) && slab1.thickness == slab2.thickness; 
}

bool OSISlabIsCoincidentToSlab(OSISlab slab1, OSISlab slab2)
{
    return N3PlaneIsCoincidentToPlane(slab1.plane, slab2.plane) && slab1.thickness == slab2.thickness; 
}

bool OSISlabContainsVector(OSISlab slab, N3Vector vector)
{
    return N3VectorDistanceToPlane(vector, slab.plane) - slab.thickness/2.0 <= (CGFLOAT_MIN * 1E5);
}

bool OSISlabContainsPlane(OSISlab slab, N3Plane plane)
{
    return N3PlaneIsParallelToPlane(slab.plane, plane) && OSISlabContainsVector(slab, plane.point);
}

OSISlab OSISlabApplyTransform(OSISlab slab, N3AffineTransform transform)
{
    OSISlab transformedSlab;
    N3Vector topPoint;
    N3Vector transformedTopPoint;
    
    topPoint = N3VectorAdd(slab.plane.point, N3VectorScalarMultiply(N3VectorNormalize(slab.plane.normal), slab.thickness));
    transformedTopPoint = N3VectorApplyTransform(topPoint, transform);
    
    transformedSlab.plane = N3PlaneApplyTransform(slab.plane, transform);
    transformedSlab.thickness = N3VectorDistance(transformedSlab.plane.point, transformedTopPoint);

    return transformedSlab;
}

NSString *NSStringFromOSISlab(OSISlab slab)
{
    return [NSString stringWithFormat:@"{%@, %f}", NSStringFromN3Plane(slab.plane), slab.thickness];
}

CFDictionaryRef OSISlabCreateDictionaryRepresentation(OSISlab slab)
{
	CFDictionaryRef planeDict;
    NSNumber *thicknessNumber;
	CFDictionaryRef slabDict;
	
	planeDict = N3PlaneCreateDictionaryRepresentation(slab.plane);
	thicknessNumber = [NSNumber numberWithDouble:slab.thickness];
	slabDict = (CFDictionaryRef)[[NSDictionary alloc] initWithObjectsAndKeys:(id)planeDict, @"plane", thicknessNumber, @"thickness", nil];
	CFRelease(planeDict);
	return slabDict;
}

bool OSISlabMakeWithDictionaryRepresentation(CFDictionaryRef dict, OSISlab *slab)
{
	OSISlab tempSlab;
	CFDictionaryRef planeDict;
	CFNumberRef thicknessNumber;
	
	if (dict == NULL) {
		return false;
	}
	
	planeDict = CFDictionaryGetValue(dict, @"plane");
	thicknessNumber = CFDictionaryGetValue(dict, @"thickness");
	
	if (planeDict == NULL || CFGetTypeID(planeDict) != CFDictionaryGetTypeID() ||
		thicknessNumber == NULL || CFGetTypeID(thicknessNumber) != CFNumberGetTypeID()) {
		return false;
	}
	
	if (N3PlaneMakeWithDictionaryRepresentation(planeDict, &(tempSlab.plane)) == false) {
		return false;
	}
    
    CFNumberGetValue(thicknessNumber, kCFNumberCGFloatType, &(tempSlab.thickness));
//	if (CFNumberGetValue(thicknessNumber, kCFNumberCGFloatType, &(tempSlab.thickness)) == false) {
//		return false;
//	}
    
	if (slab) {
		*slab = tempSlab;
	}
	return true;
}

@implementation NSValue (OSIGeometryAdditions)

+ (NSValue *)valueWithOSISlab:(OSISlab)slab
{
    return [NSValue valueWithBytes:&slab objCType:@encode(OSISlab)];
}

- (OSISlab)OSISlabValue
{
    OSISlab slab;
    assert(strcmp([self objCType], @encode(OSISlab)) == 0);
    [self getValue:&slab];
    return slab;
}

@end



