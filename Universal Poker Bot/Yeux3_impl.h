#ifndef __YEUX3_IMPL_H__
#define __YEUX3_IMPL_H__

/* comment it if you want to use HWND instead of pic structure */
#define PIC_MOD

/* comment to avoir wasting cpu time writting useless image for debug purpose */
#define DEBUG_MOD

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

/* on non windows system, PIC_MOD is mandatory */
#ifndef WIN32
#ifndef PIC_MOD
#define PIC_MOD
#endif
#endif

#ifdef PIC_MOD
#include "pic.h"
#else
/* use hwnd */
#endif

#ifdef _MSC_VER
#include "stdafx.h"
#endif

#include <string>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#ifdef WIN32
#define YEUX_V2_API __declspec(dllexport)
#else
#define YEUX_V2_API extern "C"
#define BOOL int
#define BYTE uint8_t
#define TRUE 1
#define FALSE 0
#include <stdlib.h>
//#define CString std::string
#define COLORREF uint32_t
#define RGB(r, g ,b)  ((uint32_t) (((uint8_t)(r) | ((uint16_t)(g) << 8)) | (((uint32_t) (uint8_t) (b)) << 16))) 
#define GetRValue(rgb)   ((uint8_t) (rgb)) 
#define GetGValue(rgb)   ((uint8_t) (((uint16_t) (rgb)) >> 8)) 
#define GetBValue(rgb)   ((uint8_t) ((rgb) >> 16)) 
#endif

#include "structs_defines.h"

#endif /* __YEUX3_H__ */
