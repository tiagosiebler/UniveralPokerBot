#ifndef __PIC_H__
#define __PIC_H__

/* pic.h:
 * image structure
 *
 * (C) Copyright 2013 Ramone de Castillon 
 * ramone.castillon@gmail.com
 * http://poker-botting.blogspot.fr/.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the GNU Lesser General Public License
 * (LGPL) version 2.1 which accompanies this distribution, and is available at
 * http://www.gnu.org/licenses/lgpl-2.1.html
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

static const char ppm_header[]="P6\n%d %d\n255\n";

struct simg{
	uint32_t w;
	uint32_t h;
	int8_t b;
#define FMT_RGB 1	/* standard */
#define FMT_BGR 2
	int8_t format;
	uint32_t id;
	uint32_t ppm_size;
	uint8_t *pixels;
	uint8_t *ppm;
};

static inline void ppm_save(struct simg *img, char *filename)
{
	/* FIXME: debug*/ 
	FILE *f = fopen(filename, "wb");
	if (f) {
	    fwrite(img->ppm, img->ppm_size, 1, f);
	    fclose(f);
	}

}

static inline int ppm_load(struct simg *img, char *filename)
{
	size_t ret;
	size_t hdr_size;
	size_t ppm_size;
	FILE *f=fopen(filename, "rb");
	if (!f) {
		fprintf(stderr, "file %s not found\n", filename);
		goto err;
	}

	img->b = 3;
	img->id = 0;
	img->format = FMT_BGR;
	fscanf(f, ppm_header, &img->w, &img->h);
	if (img->w == 0 || img->h == 0) {
		printf("%u %u\n", img->w, img->h);
		goto err;
	}
	hdr_size=ftell(f);
	ppm_size = 3*img->w*img->h + hdr_size;
	if (ppm_size>img->ppm_size){
		img->ppm=(uint8_t*)realloc(img->ppm, ppm_size);
		img->ppm_size = ppm_size;
	}
	
	rewind(f);
	ret = fread(img->ppm, 1, ppm_size+10, f);
	if (ret != ppm_size)
		goto err;

	img->pixels = (uint8_t*)(((uint8_t*)img->ppm) + hdr_size);


	return 0;
err:
	if (f) fclose(f);
	return -1;
}

#endif /* __PIC_H__ */
