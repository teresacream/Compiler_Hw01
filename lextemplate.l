%{
#include <string>	
#define LIST               strcat(buf, yytext)
#define token(t)           {LIST; if (Opt_T) printf("<%s>\n", #t);}
#define tokenInteger(t, i) {LIST; if (Opt_T) printf("<%s:%d>\n", #t, i);}
#define tokenString(t, s)  {LIST; if (Opt_T) printf("<%s:%s>\n", #t, s);}
#define MAX_LINE_LENG      256
/*開始自己胡搞瞎搞*/
#define tokenFloat(t, f)   		 {LIST; if (Opt_T) printf("<%s:%f>\n", #t, f);}
#define tokenScientific(t, sc)   {LIST; if (Opt_T) printf("<%s:%s>\n", #t, sc);}
string Strbuf;	/*用來存字串內容的*/
/*開始自己胡搞瞎搞*/

int Opt_S = 1;
int Opt_T = 1;
int linenum = 1;
char buf[MAX_LINE_LENG];
%}

%Start STR CMT_A CMT_B PSDCMT

%%
"("     {token('(');}
\n      {
          LIST;
          if (Opt_S)
			printf("%d:%s\n", linenum, buf);
          linenum++;
          buf[0] = '\0';
        }
/*開始自己胡搞瞎搞*/
/*Delimiters*/
	","			{token(',');}
	";"			{token(';');}
	":"			{token(':');}
	")"			{token(')');}
	"["			{token('[');}
	"]"			{token(']');}

/*Arithmetic, Relational, and Logical Operators*/
	"+"			{token('+');}
	"-"			{token('-');}
	"*"			{token('*');}
	"/"			{token('/');}
	"mod"		{token(mod);}
	":="		{token(:=);}
	"<"			{token('<');}
	">"			{token('>');}
	"<="		{token(<=);}
	">="		{token(>=);}
	"="			{token('=');}
	"and"		{token(and);}
	"or"		{token(or);}
	"not"		{token(not);}
	
/*Keywords*/
	"array"		{token(KWarray);}
	"begin"		{token(KWbegin);}
	"boolean"	{token(KWboolean);}
	"def"		{token(KWdef);}
	"do"		{token(KWdo);}
	"else"		{token(KWelse);}
	"end"		{token(KWend);}
	"false"		{token(KWfalse);}
	"for"		{token(KWfor);}
	"integer"	{token(KWinteger);}
	"if"		{token(KWif);}
	"of"		{token(KWof);}
	"print"		{token(KWprint);}
	"read"		{token(KWread);}
	"real"		{token(KWreal);}
	"string"	{token(KWstring);}
	"then"		{token(KWthen);}
	"to"		{token(KWto);}
	"true"		{token(KWtrue);}
	"return"	{token(KWreturn);}
	"var"		{token(KWvar);}
	"while"		{token(KWwhile);}

/*Identifiers*/
	[a-zA-Z_]([a-zA-Z_]|[0-9])*	{tokenString(identifier, yytext);}
	
/*Integer Constants*/	
	0[0-7]+				{tokenInteger(integer, yytext);}
	0|([1-9][0-9]*)		{tokenInteger(integer, yytext);}

/*Floating-Point Constants*/
	(0|[1-9]*).[0-9]*	{tokenFloat(float, yytext);}

/*Scientific Notations 1.23E4, 1.23E+4, 1.23E-4, 123E4*/
	(((0|[1-9]*).[0-9]*)|([1-9]*))[Ee][+-](0|[1-9][0-9]*)	{tokenScientific("scientific", yytext);}

/*String*/
	"\""			{	/*String開始*/
						LIST;
						BEGIN STR;
					}
	<STR>"\"\"" 	{	/*兩個引號*/
						LIST;
						Strbuf = Strbuf + "\"";
					}
	<STR> [^(\n")]*	{	/*String內容*/
						LIST;
						Strbuf = Strbuf + yytext;
					}
	<STR>"\""   	{	/*String結束*/
						LIST;
						tokenString(string, Strbuf);
						Strbuf.clear();
						BEGIN INITIAL;
					}
				
/*Comment*/
	"//"			{	/*Comment_A(雙斜線Comment)開始*/
						LIST;
						BEGIN CMT_A;
					}
	<CMT_A>[^(\n)]*	{	/*Comment_A內容*/
						LIST;
					}
	<CMT_A>\n		{	/*Comment_A結束*/
						LIST;
						if (Opt_S)
							printf("%d:%s\n", linenum, buf);
						linenum++;
						buf[0] = '\0';
						BEGIN INITIAL;
					}
					
	"/*"			{	/*Comment_B(有星星的Comment)開始*/
						LIST;
						BEGIN CMT_B;
					}
	<CMT_B>\n		{	/*跟Initial狀態的換行一樣*/
						LIST;
						if (Opt_S)
							printf("%d:%s\n", linenum, buf);
						linenum++;
						buf[0] = '\0';
					}
	<CMT_B>"*/"		{	/*Comment_B結束*/
						LIST;
						BEGIN INITIAL;
					}
/*Whitespace or Tab*/
	[\t	]+		{LIST;}
	
/*Pseudocomments*/
	"//&"						{	/*Pseudocomments開始*/
									LIST;
									BEGIN PSDCMT;
								}
	<PSDCMT>[(A-R)|(U-Z)][+-]	{
									LIST;
									BEGIN INITIAL;
								}
	<PSDCMT>"S+"				{
								LIST;
								Opt_S = 1;
								BEGIN INITIAL;
								}
	<PSDCMT>"S-"				{
								LIST;
								Opt_S = 0;
								BEGIN INITIAL;
								}
	<PSDCMT>"T+"				{
								LIST;
								Opt_T = 1;
								BEGIN INITIAL;
								}
	<PSDCMT>"T-"				{
								LIST;
								Opt_T = 0;
								BEGIN INITIAL;
								}

/*開始自己胡搞瞎搞*/		
%%
int main( int argc, char **argv )
{
  if( argc != 2 ) {
    fprintf( stderr, "Usage: ./scanner [filename]\n" );
    exit(0);
  }
	
  FILE *fp = fopen( argv[1], "r" );
  if( fp == NULL ) {
    fprintf( stderr, "Open file error\n" );
    exit(-1);
  }
	
  yyin = fp;

  yylex();

  exit(0);
}

/*
           霸葛～吃光光
  ▕ ⊙  ⊙ ▏/
  ▕ ▼▼▼▼▼▼ ▏
  ▕ ▲▲▲▲▲▲ ▏
       <██>
        ||
						然而並沒有卵用。
*/