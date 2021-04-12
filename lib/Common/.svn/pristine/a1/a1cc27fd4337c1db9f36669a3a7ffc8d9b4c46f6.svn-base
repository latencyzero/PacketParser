/**
	NSMutableURLRequest+LZ.m
	Common
	
	Created by Roderick Mann on 3/22/11.
*/


#import "NSMutableURLRequest+LZ.h"

//
//	Library Imports
//

#import "NSString+LZ.h"



@implementation NSMutableURLRequest (LZ)

- (void)
setRequestParameters: (NSDictionary*) inParams
{
	//	Build the parameter list…
	
	NSMutableString* params = [NSMutableString string];
	bool first = true;
	for (NSString* key in inParams.allKeys)
	{
		if (!first)
		{
			[params appendString: @"&"];
		}
		
		[params appendString: key];
		NSString* val = [inParams valueForKey: key];
		val = val.stringByURLEncoding;
		[params appendFormat: @"=%@", val];
		
		first = false;
	}
	
	if ([self.HTTPMethod isEqualToString: @"POST"]
		|| [self.HTTPMethod isEqualToString: @"PUT"])
	{
		[self setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
		self.HTTPBody = [params dataUsingEncoding: NSUTF8StringEncoding];
	}
	else
	{
		NSString* s = [self.URL.absoluteString stringByAppendingFormat: @"?%@", params];
		NSURL* url = [NSURL URLWithString: s];
		self.URL = url;
	}
}

@end
