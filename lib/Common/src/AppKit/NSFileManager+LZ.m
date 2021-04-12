/**
	NSFileManager+LZ.m
	Schematic

	Created by Roderick Mann on 5/19/11.
	Copyright 2011 Latency: Zero. All rights reserved.
*/

#import "NSFileManager+LZ.h"


@implementation NSFileManager(LZ)


- (BOOL)
createFileAtURL: (NSURL*) inURL
	contents: (NSData*) inData
	attributes: (NSDictionary*) inAttrs
{
	NSString* path = inURL.path;
	return [self createFileAtPath: path contents: inData attributes: inAttrs];
}


@end
