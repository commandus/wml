/*
   wml-tools 

   Copyright (C) 1999 Thomas Neill (tneill@pwot.co.uk)

   This file is part of the wml-tools package and it's usage is subject
   to the terms and conditions as given in the license. See the file
   LICENSE in the root directory of the distribution for details.
*/
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
	FILE *in, *out;
	int c, i, j, width, height, line, block, offset;
	char of[256], *p;

	if(argc != 2) {
		fprintf(stderr, "Usage: %s <file.wbmp>\n", argv[0]);
		exit(1);
	}

	if(!(in = fopen(argv[1], "r"))) {
		fprintf(stderr, "Can't open %s for reading\n", argv[1]);
		exit(1);
	}

	strcpy(of, argv[1]);
	if((p = strrchr(of, '.'))) {
		p++;
		*(p++) = 'x';
		*(p++) = 'p';
		*(p++) = 'm';
		*p = '\0';
	} else
		strcat(of, ".xpm");

	if(!(out = fopen(of, "w"))) {
		fprintf(stderr, "Can't open %s for writing\n", of);
		exit(1);
	}

	i = getc(in);
	j = getc(in);
	width = getc(in);
	height = getc(in);

	fprintf(out, "/* XPM */\nstatic char *xpm[] = {\n");
	fprintf(out, "\"%d %d 2 1\",\n", width, height);
	fprintf(out, "\"a c #000000\",\n");
	fprintf(out, "\"b c #ffffff\",\n");

	for(line = 0; line < height; line++) {
		fputc('"', out);
		for(block = 0; block < width; block += 8) {
			c = getc(in);
			for(offset = 0; (offset<8)&&((offset+block)<width); offset++) {
				if((c & (1 << (7 - offset))))
					fputc('b', out);
				else
					fputc('a', out);
			}
		}
		fputc('"', out);
		if(line != (height - 1))
			fputc(',', out);
		fputc('\n', out);
	}

	fprintf(out, "};\n");

	fclose(out);
	fclose(in);

	return 0;
}
