// Yeux3.cpp : Defines the entry point for the DLL application.
//

#include "Yeux3_impl.h"
#include "CTablemap.h"
#include "CTransform/CTransform.h"
/*
extern "C"
{
YEUX_V2_API int OpenTablemap(const char* filename);
YEUX_V2_API void GetRegionPos(const char* name, int& posleft, int& postop, int& posright, int& posbottom);
YEUX_V2_API int ReadRegion(struct simg *img,const char *name, char* result, int offset);
}*/

class CLobbyScraper
{
public: 
	char* ScrapeResult;
public:
	CLobbyScraper();
	~CLobbyScraper();
	bool Load(CString filename);
	bool GetSymbol(const CString name, CString& text) ;
	bool ProcessRegion(RMapCI r_iter);
	void GetRegionPos(const CString name, int& posl, int& post, int& posr, int& posb) ;
	bool ReadRegion(struct simg *img, const CString name, char *result, int ofsx=0, int ofsy=0) ;
};


CLobbyScraper::CLobbyScraper()
{

}

CLobbyScraper::~CLobbyScraper()
{

}
bool CLobbyScraper::Load(CString filename)
{

	p_tablemap = new CTablemap();
	int line = 0;
	int ret = p_tablemap->LoadTablemap(filename, VER_OPENSCRAPE_2, false, &line, false);
	
	if (ret != SUCCESS) {
		fprintf(stderr, "BUG: Hopper C++ : ERROR Loading tablemap\n");
	}

	return ret;
}

void CLobbyScraper::GetRegionPos(const CString name, int& posl, int& post, int& posr, int& posb) 
{																		
	posl = post = posr = posb= -1;
	RMapCI r_it = p_tablemap->r$()->find(name);
	if (r_it == p_tablemap->r$()->end())
		return;
	posl = r_it->second.left;
	post = r_it->second.top;
	posr = r_it->second.right;
	posb = r_it->second.bottom;

}


bool CLobbyScraper::GetSymbol(const CString name, CString& text) 
{
	SMapCI it = p_tablemap->s$()->find(name);
	if (it == p_tablemap->s$()->end())
		return false;
	text = it->second.text;
	return true;
}

bool CLobbyScraper::ReadRegion(struct simg *img, const CString name, char *result, int ofsx, int ofsy) 
{
	RMapCI r_it = p_tablemap->r$()->find(name.GetString());
	
	if (r_it == p_tablemap->r$()->end())
		return false;
	
	STablemapRegion region = r_it->second;
	
 	CTransform trans;
	CString text;
	CString separation;
	COLORREF cr_avg;

	/* FIXME: very ugly. There is something to fix here */
	int ret = trans.DoTransform(r_it, img, &text, &separation, &cr_avg);
	/* FIXME: hard coded 40 ... is so ugly :) */
	strncpy(result,text, 40);

	/* FIXME ... */
	return ret!=-4;
}

//////////// Les appels possible de l'extérieur : 
CLobbyScraper	scraper;

YEUX_V2_API int OpenTablemap(const char* filename)
{
	return scraper.Load((CString)filename);
}

YEUX_V2_API int ReadRegion(struct simg *img, const char *name, char *result, int offset)
{
	if (!scraper.ReadRegion(img, (CString)name, result, 0, offset))
		return 0;
	return 1;
}

YEUX_V2_API void GetRegionPos(const char* name, int& posleft, int& postop, int& posright, int& posbottom)
{
	scraper.GetRegionPos(name, posleft, postop, posright, posbottom);
}

