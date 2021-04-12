#import "Context.h"




namespace Graphics
{

#if TARGET_OS_IPHONE

Context::Context()
	:
	mCoordinateScale(1.0)
{
	mCGContext = ::UIGraphicsGetCurrentContext();
}

#else

Context::Context()
	:
	mCoordinateScale(1.0)
{
	NSGraphicsContext* cocoaCTX = [NSGraphicsContext currentContext];
	mCGContext = (CGContextRef) cocoaCTX.graphicsPort;
}

#endif


};	//	namespace Graphics
