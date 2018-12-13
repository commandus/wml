/*
   wml-tools 

   Copyright (C) 1999 Thomas Neill (tneill@pwot.co.uk)

   This file is part of the wml-tools package and it's usage is subject
   to the terms and conditions as given in the license. See the file
   LICENSE in the root directory of the distribution for details.
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tree.h>
#include <parser.h>

FILE *out;

int debug = 0;

int dumpNodeIndent = 0;
int htmlIndent = 0;

void dumpNode(xmlNodePtr node)
{
        while(node) {
                fprintf(stderr, "%*s == %s\n", dumpNodeIndent, "", node->name);
                if(node->childs) {
                        dumpNodeIndent += 2;
                        dumpNode(node->childs);
                        dumpNodeIndent -= 2;
                }
                node = node->next;
        }
}

void showHtml(xmlNodePtr node)
{
	xmlNodePtr val;
	xmlAttrPtr attr;

	while(node) {
		if(strcmp("text", node->name) == 0) {
			fprintf(out, "%*s%s\n", htmlIndent, "", node->content);
		} else if(strcmp("wml", node->name) == 0) {
			fprintf(out, "<html>\n");
			fprintf(out, "<body>\n");
		} else if(strcmp("card", node->name) == 0) {
			fprintf(out, "%*s<table border=\"1\" width=\"100%%\">\n", htmlIndent, "");
			fprintf(out, "%*s<tr><td><b><a name=\"%s\">%s</a></b></td></tr>\n",
				(htmlIndent + 2), "", xmlGetProp(node, "id"), xmlGetProp(node, "title"));
			fprintf(out, "%*s</table>\n", htmlIndent, "");
		} else if(strcmp("table", node->name) == 0) {
			fprintf(out, "%*s<table border=\"1\" cellpadding=\"2\" cellspacing=\"2\">\n",
				htmlIndent, "");
		} else {
			fprintf(out, "%*s<%s", htmlIndent, "", node->name);
			attr = node->properties;
			while(attr) {
				val = attr->val;
				if(strcmp(val->name, "text") != 0)
					continue;
				else
					fprintf(out, " %s=\"%s\"", attr->name, val->content);
				attr = attr->next;
			}
			fprintf(out, ">\n");
		}

		if(node->childs) {
			htmlIndent += 2;
			showHtml(node->childs);
			htmlIndent -= 2;
		}

		if(strcmp("wml", node->name) == 0) {
			fprintf(out, "</body>\n");
			fprintf(out, "</html>\n");
		} else if(strcmp("card", node->name) == 0) {
			fprintf(out, "%*s<hr>\n", htmlIndent, "");
		} else if(strcmp("text", node->name) != 0)
			fprintf(out, "%*s</%s>\n", htmlIndent, "", node->name);

		node = node->next;
	}
}

int main(int argc, char **argv)
{
	char *inf, *outf;
	xmlDocPtr doc;

	if(argc == 2) {
		inf = argv[1];
		out = stdout;
	} else {
		fprintf(stderr, "Usage: %s file.wml [output.html]\n", argv[0]);
		exit(1);
	}

	doc = xmlParseFile(inf);
	if(!doc) {
		fprintf(stderr, "Couldn't parse %s as a valid XML document\n", inf);
		exit(1);
	}

	if(debug)
		dumpNode(doc->root);

	showHtml(doc->root);

	return 0;
}
