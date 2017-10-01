#ifndef __YEUX3_H__
#define __YEUX3_H__

extern "C" int OpenTablemap(const char* filename);
extern "C" void GetRegionPos(const char* name, int& posleft, int& postop, int& posright, int& posbottom);
extern "C" int ReadRegion(struct simg *img,const char* name, char *result, int offset);

#endif /* __YEUX3_H__ */
