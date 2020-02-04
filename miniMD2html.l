%{
#define YYSTYPE char *
#include <string.h>
#include "miniMD2html.tab.h"
extern YYSTYPE yylval;
%}
%option yylineno

/* Flex definitions */
whitespace [ \t]+
newline [\n]+|{whitespace}[\n]+
/************* Start: add your definitions here */
textword [a-zA-Z:\.\-,'/]+
headermark ######|#####|####|###|##|#
digit [0-9]+
/* End: add your definitions here */
%%
 /************* Start: add your rules here. */
 /* Start in the first column, no leading spaces.*/
{textword} { yylval=strdup(yytext); return T_TEXTWORD; }
{digit} { yylval=strdup(yytext); return T_INT; } 
{headermark} { yylval=strdup(yytext); return T_HEADERMARK; } 
[_] return T_ITALIC;
[*]{2} return T_BOLD;
!\[ return T_IMG1;
\]\( return T_IMG2;
= return T_IMG3;
@ return T_IMG4;
\) return  T_IMG5;
 /* End: add your rules here */
{whitespace} { return T_BLANK; }
{newline} {return T_NEWLINE;}
%%
