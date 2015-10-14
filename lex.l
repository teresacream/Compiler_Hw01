%{
#define LIST               strcat(buf, yytext)
#define token(t)           {LIST; if (Opt_T) printf("<%s>\n", #t);}
#define tokenInteger(t, i) {LIST; if (Opt_T) printf("<%s: %s>\n", #t, i);}
#define tokenString(t, s)  {LIST; if (Opt_T) printf("<%s: %s>\n", #t, s);}
#define MAX_LINE_LENG      256
/*開始自己胡搞瞎搞*/
#define tokenFloat(t, f)   		 {LIST; if (Opt_T) printf("<%s: %s>\n", #t, f);}
#define tokenScientific(t, sc)   {LIST; if (Opt_T) printf("<%s: %s>\n", #t, sc);}
#define tokenSpec(t)		     {LIST; if (Opt_T) printf("<%c>\n", t);}
char Strbuf[MAX_LINE_LENG];	/*用來存字串內容的*//*你為什麼不吃我的string.h？？*/
/*開始自己胡搞瞎搞*/

int Opt_S = 1;
int Opt_T = 1;
int linenum = 1;
char buf[MAX_LINE_LENG];
%}

/*你為什麼不吃我的反斜線和雙引號？？*/
STRCNT	([^"\n)])*
WT		[\t	]+
/*你為什麼不吃我的反斜線和雙引號？？*/

%Start STR CMTA CMTB PSDCMT
%%
<STR>"\""   	{	/*String結束*/
					tokenString(string, Strbuf);
					Strbuf[0] = '\0';
					BEGIN INITIAL;
				}
<STR>"\"\""   	{	/*兩個雙引號*/
					LIST;
					strcat(Strbuf, "\"");
				}
<STR>{STRCNT}	{	/*String內容*/
					LIST;
					strcat(Strbuf, yytext);
				}
<INITIAL>"\""	{	/*String開始*/
					LIST;
					BEGIN STR;
				}				

				
<INITIAL>"//"	{	/*Comment_A(雙斜線Comment)開始*/
					LIST;
					BEGIN CMTA;
				}
<CMTA>"\n"		{	/*Comment_A結束*/
					LIST;
					if (Opt_S)
						printf("%d: %s", linenum, buf);
					linenum++;
					buf[0] = '\0';
					BEGIN INITIAL;
				}
<CMTA>[^\n]*	{	/*Comment_A內容*/
					LIST;
				}
				
				
^"/*"&"*/"		{	/*Comment_B(有星星的Comment)-一行*/
					LIST;
				}
^"/*"			{	/*Comment_B開始*/
					LIST;
					BEGIN CMTB;
				}
<CMTB>&"*/"		{	/*Comment_B結束*/
					LIST;
					BEGIN INITIAL;
				}
<CMTB>^"*/"		{	/*Comment_B結束*/
					LIST;
					BEGIN INITIAL;
				}
<CMTB>[^\n]		{	/*Comment_B內容*/
					LIST;
				}
<CMTB>"\n"		{	/*跟Initial狀態的換行一樣*/
					LIST;
					if (Opt_S)
						printf("%d: %s", linenum, buf);
					linenum++;
					buf[0] = '\0';
				}							
				
<INITIAL>","			{tokenSpec(',');}
<INITIAL>";"			{tokenSpec(';');}
<INITIAL>":"			{tokenSpec(':');}
<INITIAL>"("     	{tokenSpec('(');}
<INITIAL>")"			{tokenSpec(')');}
<INITIAL>"["			{tokenSpec('[');}
<INITIAL>"]"			{tokenSpec(']');}

<INITIAL>"+"			{tokenSpec('+');}
<INITIAL>"-"			{tokenSpec('-');}
<INITIAL>"*"			{tokenSpec('*');}
<INITIAL>"/"			{tokenSpec('/');}
<INITIAL>"mod"		{token(mod);}
<INITIAL>":="		{token(:=);}
<INITIAL>"<"			{tokenSpec('<');}
<INITIAL>">"			{tokenSpec('>');}
<INITIAL>"<="		{token(<=);}
<INITIAL>">="		{token(>=);}
<INITIAL>"="			{tokenSpec('=');}
<INITIAL>"and"		{token(and);}
<INITIAL>"or"		{token(or);}
<INITIAL>"not"		{token(not);}


<INITIAL>"array"	{token(KWarray);}
<INITIAL>"begin"	{token(KWbegin);}
<INITIAL>"boolean"	{token(KWboolean);}
<INITIAL>"def"		{token(KWdef);}
<INITIAL>"do"		{token(KWdo);}
<INITIAL>"else"		{token(KWelse);}
<INITIAL>"end"		{token(KWend);}
<INITIAL>"false"	{token(KWfalse);}
<INITIAL>"for"		{token(KWfor);}
<INITIAL>"integer"	{token(KWinteger);}
<INITIAL>"if"		{token(KWif);}
<INITIAL>"of"		{token(KWof);}
<INITIAL>"print"	{token(KWprint);}
<INITIAL>"read"		{token(KWread);}
<INITIAL>"real"		{token(KWreal);}
<INITIAL>"string"	{token(KWstring);}
<INITIAL>"then"		{token(KWthen);}
<INITIAL>"to"		{token(KWto);}
<INITIAL>"true"		{token(KWtrue);}
<INITIAL>"return"	{token(KWreturn);}
<INITIAL>"var"		{token(KWvar);}
<INITIAL>"while"	{token(KWwhile);}


<INITIAL>0[0-7]+				{tokenInteger(integer, yytext);}				
<INITIAL>0|([1-9][0-9]*)		{tokenInteger(integer, yytext);}


<INITIAL>[a-zA-Z_]([a-zA-Z_]|[0-9])*	{tokenString(id, yytext);}


<INITIAL>(0|([1-9][0-9]*))"."[0-9]+	{tokenFloat(float, yytext);}


<INITIAL>(((0|[1-9]+)"."[0-9]*)|(0|([1-9][0-9]*))|(0[0-7]+))[Ee][+-]((0|[1-9][0-9]*)|0[0-7]+)	{tokenScientific(scientific, yytext);}


<INITIAL>" "			{LIST;}
<INITIAL>"\t"			{LIST;}


"//&"						{	/*Pseudocomments開始*/
								LIST;
								BEGIN PSDCMT;
							}
<PSDCMT>"S+"[^\n]*			{
								LIST;
								Opt_S = 1;
								BEGIN INITIAL;
							}
<PSDCMT>"S-"[^\n]*			{
								LIST;
								Opt_S = 0;
								BEGIN INITIAL;
							}
<PSDCMT>"T+"[^\n]*			{
								LIST;
								Opt_T = 1;
								BEGIN INITIAL;
							}
<PSDCMT>"T-"[^\n]*			{
								LIST;
								Opt_T = 0;
								BEGIN INITIAL;
							}

							
<INITIAL>"\n"  	{
					LIST;
					if (Opt_S)
						printf("%d: %s", linenum, buf);
					linenum++;
					buf[0] = '\0';
				}
%%

int main( int argc, char **argv )
{
  if( argc != 2 ) {
    fprintf( stderr, "Usage: ./scanner input.txt\n" );
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
