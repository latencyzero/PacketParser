/**
*/


#ifndef	__DebugMacros_h__
#define __DebugMacros_h__


#ifndef	kDebugLevel
#define kDebugLevel			0
#endif

#if	kDebugLevel > 0

void    DebugLog(const char* inFileName, uint32_t inLineNumber, NSString* inFormat, ...);

#define DebugLog_(...)									\
    do													\
	{													\
        ::DebugLog( __FILE__, __LINE__, __VA_ARGS__ );	\
    } while (false);



#else	//	kDebugLevel > 0

#define DebugLog_(...)




#endif	//	kDebugLevel > 0




#define	kDebugAssert				1



#if	kDebugAssert


#define	DebugAssert_(x)																					\
	do {																								\
		if (!(x)) {																				\
			std::fprintf(stderr, "File: %s, Line: %lu, " #x " is NULL\n", __FILE__, __LINE__);			\
		}																								\
	} while (false)





#define	aDebugLog_(x)																					\
	do {																								\
		std::fprintf(stderr, "Log File: %s, Line: %lu: %s\n", __FILE__, __LINE__, x);					\
	} while (false)

#define	aDebugLogFormat_(inFmt, ...)																		\
	do {																								\
		std::fprintf(stderr, "Log File: %s, Line: %lu: " inFmt "\n", __FILE__, __LINE__, ##__VA_ARGS__);		\
	} while (false)


#else	//	kDebugAssert

//	••• Do we really need something here for the extra ';'?

#define	aDebugLog_(x)							do {} while (false)
#define	aDebugLogFormat_(inFmt, ...)				do {} while (false)

#endif	//	kDebugAssert









#endif	//	__DebugMacros_h__

