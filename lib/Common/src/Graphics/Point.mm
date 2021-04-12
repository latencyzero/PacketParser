#import "Point.h"


namespace Graphics
{

NSString*
Point::toString() const
{
	NSString* s = [NSString stringWithFormat: @"%.2f, %.2f", x, y];
	return s;
}



}

