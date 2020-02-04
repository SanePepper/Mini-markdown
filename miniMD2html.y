%{
#include "global.h"
#include "stdlib.h"
#include "stdio.h"
#define YYSTYPE char *
extern int yylex();
int yywrap();
int yyerror(const char*);
int yyparse();
extern FILE *yyin;
Html_Doc *html_doc;
%}

/* Define tokens here */
%token T_BLANK T_NEWLINE
 /************* Start: add your tokens here */
%token T_TEXTWORD T_INT T_HEADERMARK T_BOLD T_ITALIC
%token T_IMG1 T_IMG2 T_IMG3 T_IMG4 T_IMG5 
/* End: add your tokens here */

%% /* Grammer rules and actions follow */
s: mddoc;
mddoc: /*empty*/ | mddoc paragraph;
paragraph:
T_NEWLINE                 {add_linebreak(html_doc);} 
| pcontent T_NEWLINE   {add_element(html_doc, $1); free($1);}
;
 /************* Start: add your grammar rules here */


pcontent: header 
| rftext { $$=generate_paragraph($1);} ;

header: T_HEADERMARK T_BLANK rftext { $$=generate_header(strlen($1), $3); };

rftext: rftext T_BLANK rftextword { $$=(char *)malloc(2+strlen($1)+strlen($3)); strcpy($$,$1); char sp[2] = " "; strcat($$,sp); strcat($$, $3); }
| rftext rftextword { $$=(char *)malloc(1+strlen($1)+strlen($2)); strcpy($$,$1); strcat($$, $2); }
| rftextword { $$=$1; };

rftextword: format | image | textnum ;

image: T_IMG1 text T_IMG2 text T_IMG3 T_INT T_IMG4 T_INT T_IMG5 { $$=generate_image($2, $4, atoi($6),atoi($8));};

format: T_BOLD format T_BOLD { $$=generate_bold($2); }
| T_BOLD text T_BOLD { $$=generate_bold($2); }
| T_ITALIC format T_ITALIC { $$=generate_italic($2); }
| T_ITALIC text T_ITALIC { $$=generate_italic($2); }; 

text: text T_BLANK textnum  { $$=(char *)malloc(2+strlen($1)+strlen($3)); strcpy($$,$1); char sp[2] = " "; strcat($$,sp); strcat($$, $3); }
| text textnum { $$=(char *)malloc(1+strlen($1)+strlen($2)); strcpy($$,$1); strcat($$, $2); }
| textnum { $$=$1; };

textnum: T_TEXTWORD | T_INT ;
/* End: add your grammar rules here */
%%

int main(int argc, char *argv[]) {
  // yydebug = 1;

  FILE *fconfig = fopen(argv[1], "r");
  // make sure it is valid
  if (!fconfig) {
    printf("Error reading file!\n");
    return -1;
  }
  html_doc = new_html_doc();
  // set lex to read from file
  yyin = fconfig;
  int ret = yyparse();
  output_result(html_doc);
  del_html_doc(html_doc);
  return ret;
}


int yywrap(){
    return 1;
}

int yyerror(const char* s){
    extern int yylineno;
    extern char *yytext;
    printf("error while parsing line %d: %s at '%s', ASCII code: %d\n", yylineno, s, yytext, (int)(*yytext));
    return 1;
}
