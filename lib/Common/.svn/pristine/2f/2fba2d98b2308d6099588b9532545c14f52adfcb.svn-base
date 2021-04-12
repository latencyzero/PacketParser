/*
 *  Image.h
 *  Graphics Library
 *
 *  Created by Roderick Mann on 1/17/08.
 *  Copyright 2008 Latency: Zero. All rights reserved.
 *
 */

#ifndef	__Image_h__
#define	__Image_h__



//
//	Forward Declarations
//

typedef struct CGImage*		CGImageRef;
class CString;


namespace
Graphics
{

class
Image
{
public:
				Image();
				
				/**
					Load the named image found in the app main bundle.
				*/
				
				Image(const CString& inImageName,
						const CString& inImageType);
										
	CGImageRef	getImageRef() const					{ return mImageRef; }
	
	
	void		set(const CString& inImageName,
					const CString& inImageType);
								
private:
	CGImageRef					mImageRef;
};





};




#endif	//	__Image_h__
