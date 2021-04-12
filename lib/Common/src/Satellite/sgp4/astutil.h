#ifndef _ASTUTIL_H_
#define _ASTUTIL_H_
/*     ----------------------------------------------------------------      

                               UNIT ASTUTIL;

    This file contains some utility routines for character operations.       
                                                                             
                            Companion code for                               
               Fundamentals of Astrodyanmics and Applications                
                                     2001                                    
                              by David Vallado                               
                                                                             
       (H)               email valladodl@worldnet.att.net                    
       (W) 303-344-6037, email davallado@west.raytheon.com                   
                                                                             
       *****************************************************************     
                                                                             
    Current :                                                                
              14 May 01  David Vallado                                       
                           2nd edition baseline                              
    Changes :                                                                
              23 Nov 87  David Vallado                                       
                           Original baseline                                 
                                                                             
       ----------------------------------------------------------------      

                                  INTERFACE

       ----------------------------------------------------------------*/
#include "astmath.h"

int GetPart(char *, int , int);
long    GetPartL(char *, int , int);
double    GetPartR(char *, int , int);
char   *RmSpcs(char *);
char   *RmSpcs(char *, int);
char   *UpCaseStr(char *);

#endif
