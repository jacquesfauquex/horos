

#import "DCMObjectDBImport.h"
#import "DCM.h"


@implementation DCMObjectDBImport

+ (id)objectWithContentsOfFile:(NSString *)file decodingPixelData:(BOOL)decodePixelData	{
	return [[[DCMObjectDBImport alloc] initWithContentsOfFile:file decodingPixelData:decodePixelData] autorelease];
}


- (BOOL)isNeededAttribute:(char *)tagString{
	if (strcmp(tagString, "0008,0008") == 0 ||	//ImageType
		strcmp(tagString, "0008,0018") == 0 ||	// SOPInstanceUID
		strcmp(tagString, "0008,1030") == 0 ||	//StudyDescription
		strcmp(tagString, "0008,0060") == 0 ||	//Modality
		strcmp(tagString, "0008,0020") == 0 ||	//StudyDate
		strcmp(tagString, "0008,0030") == 0 ||	//StudyTime
		strcmp(tagString, "0008,0021") == 0 ||	//SeriesDate
		strcmp(tagString, "0008,0031") == 0 ||	//SeriesTime
		strcmp(tagString, "0008,0022") == 0 ||	//AcquistionDate
		strcmp(tagString, "0008,0032") == 0 ||	//AcquistionTime
		strcmp(tagString, "0008,103E") == 0 ||	//SeriesDescription
		
		strcmp(tagString, "0008,0080") == 0 ||	//InstitutionName 
		strcmp(tagString, "0008,0090") == 0 ||	//ReferringPhysiciansName
		strcmp(tagString, "0008,1050") == 0 ||	//PerformingPhysiciansName
		strcmp(tagString, "0008,0050") == 0 ||	//AccessionNumber
		strcmp(tagString, "0010,0010") == 0 ||	//PatientsName
		strcmp(tagString, "0010,0020") == 0 ||	//PatientID
		strcmp(tagString, "0010,0030") == 0 ||	//PatientsBD
		strcmp(tagString, "0010,1010") == 0 ||	//PatientsAge
		strcmp(tagString, "0010,0040") == 0 ||	//PatientsSex
		strcmp(tagString, "0018,0022") == 0 ||	//ScanOptions
		strcmp(tagString, "0018,0081") == 0 ||	//EchoTime
		
		strcmp(tagString, "0018,1030") == 0 ||	//ProtocolName 
		strcmp(tagString, "0020,0013") == 0 ||	//InstanceNumber
		strcmp(tagString, "0020,0011") == 0 ||	//SeriesNumber
		strcmp(tagString, "0020,000E") == 0 ||	//SeriesInstanceUID
		strcmp(tagString, "0020,000D") == 0 ||	//StudyInstanceUID
		strcmp(tagString, "0020,0010") == 0 ||	//StudyID
		strcmp(tagString, "0020,0032") == 0 ||	//Image Position
		strcmp(tagString, "0020,0037") == 0 ||	//Image Orientation
		strcmp(tagString, "0028,0008") == 0 ||	//Number of Frames
		strcmp(tagString, "0028,0010") == 0 ||	//Rows
		strcmp(tagString, "0028,0011") == 0 ||	//Columns
		strcmp(tagString, "0008,0016") == 0 ||	//SOPClassUID
		strcmp(tagString, "0008,0005") == 0	||	//SpecificCharacterSet
		strcmp(tagString, "0002,0010") == 0 ||	//Transfer Syntax UID
		strcmp(tagString, "0042,0011") == 0	||	//EncapsulatedDocument
		strcmp(tagString, "2001,100A") == 0	||	//CardiacMR
		strcmp(tagString, "2001,1008") == 0	||	//CardiacMR
		strcmp(tagString, "0032,4000") == 0	||	//StudyComments
		strcmp(tagString, "0020,4000") == 0	||	//ImageComments
		strcmp(tagString, "4008,0212") == 0	||	//InterpretationStatusID
	
		strcmp(tagString, "0002,0000") == 0
	)
	return YES;
	
	return NO;
}

@end
