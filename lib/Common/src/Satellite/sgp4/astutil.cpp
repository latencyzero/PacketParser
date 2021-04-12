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

                                  IMPLEMENTATION

       ----------------------------------------------------------------*/
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#include "astutil.h"

/*------------------------------------------------------------------------------
|
|                           FUNCTION GETPART
|
|  These functions parse a section of a string and return various types of
|    values - Real, INTEGER, Byte, etc., depending on the last letter in the
|    name.
|
|  Author        : David Vallado                  303-344-6037    1 Mar 2001
|
|  Inputs          Description                    Range / Units
|    InStr       - Input String
|    LocStart    - Location to start parsing
|    Leng        - Length of dersired variable
|
|  Outputs       :
|    FUNCTION    - variable of correct type
|
|  Locals        :
|    TempStr     - Temporary string
|    Temp        - Temporary variable
|    Code        - Error variable
|
|  Coupling      :
|    None.
|
 -----------------------------------------------------------------------------*/
int GetPart(char *InStr, int LocStart, int Leng)
{
  char TempStr[80];

  strncpy(TempStr, InStr + LocStart - 1, Leng);
  TempStr[Leng] = '\0';
  return atoi(TempStr);
}

long GetPartL(char *InStr, int LocStart, int Leng)
{
  char TempStr[80];

  strncpy(TempStr, InStr + LocStart - 1, Leng);
  TempStr[Leng] = '\0';
  return atol(TempStr);
}

double GetPartR(char *InStr, int LocStart, int Leng)
{
  char TempStr[80];

  strncpy(TempStr, InStr + LocStart - 1, Leng);
  TempStr[Leng] = '\0';
  return atof(TempStr);
}

/* -----------------------------------------------------------------------------
|
|                           FUNCTION RMSPCS
|
|  This Function removes leading and trailing spaces from a string.
|
|  Author        : David Vallado                  303-344-6037    1 Mar 2001
|
|  Inputs        :
|    S           - String
|
|  Outputs       :
|    RmSPcs      - Result
|
|  Locals        :
|    None.
|
|  Constants     :
|    None.
|
|  Coupling      :
|    None.
|
 ----------------------------------------------------------------------------*/
char *RmSpcs(char *s)
{
  char *t;

  t = s;
  while((*t == ' ') && (strlen(t) > 0))
    t++;
  while ((*(t+strlen(t)) == ' ') && (strlen(t) > 0))
    *(t+strlen(t)) = '\0';
  return t;
}

char *RmSpcs(char *s, int l)
{
  char *t;

  t = s;
  while((*t == ' ') && (t < s + l))
    t++;
  while ((*(t+strlen(t)) == ' ') && (strlen(t) > 0))
    *(t+strlen(t)) = '\0';
  return t;
}

/* -----------------------------------------------------------------------------
|
|                           FUNCTION UPCASESTR
|
|  This Function converts a string to all UPPERCASE.
|
|  Author        : David Vallado                  303-344-6037    1 Mar 2001
|
|  Inputs        :
|    S           - String
|
|  Outputs       :
|    UpCaseStr   - Result
|
|  Locals        :
|    i           - Index
|
|  Constants     :
|    None.
|
|  Coupling      :
|    None.
|
 ----------------------------------------------------------------------------*/
char *UpCaseStr(char *s)
{
  char *t;

  t = s;
  for (unsigned int i = 0; i < strlen(s); i++)
    *(t+i) = toupper(*(t+i));
  return t;
}

