%{

#include <stdlib.h>
#include <string.h>
#include "mikroC.h"

extern YYSTYPE yylval;

#define  YY_SKIP_YYWRAP

int yywrap() { return 1; }

int isatty() { return yyin==stdin; }

unsigned Radek=1,Sloupec=1,Delka=0;

#define  NovyRadek  ++Radek,Sloupec=1,Delka=0;

void Delk(unsigned l=yyleng) { Sloupec+=Delka; Delka=l; }

#define  MAXRETEZ  256

static char Ret[MAXRETEZ+1];

%}

cislice   [0-9]
dekadic   {cislice}+
hexadecim 0[xX][0-9a-fA-F]+
binarni   0[bB][01]+
pismeno_  [a-zA-Z_]
jmeno     {pismeno_}({pismeno_}|{cislice})*

%%

" "       Delk(1);

\t        Delk(TABSIZE);

\n        NovyRadek

{dekadic} { sscanf(yytext,"%u",&yylval.c);
            Delk();
            return CISLO; }

{hexadecim} { sscanf(yytext,"%x",&yylval.c);
              Delk();
              return CISLO; }

{binarni} { yylval.c=0;
            for (char *p=yytext+2;*p;++p) { yylval.c<<=1; yylval.c|= *p-'0'; }
            Delk();
            return CISLO; }

false     { yylval.c=0;
            Delk();
            return CISLO; }

true      { yylval.c=1;
            Delk();
            return CISLO; }

"\""  { unsigned delka=0; char cc=0; bool chyba=false;
        Delk(1);
        yylval.r=Ret;
        for (;;) { char c=
#ifdef __cplusplus
          yyinput();
#else
          input();
#endif
          if (c==EOF) { Chyba("Neukonceny retezec",RADEK);
                        return 0; }
          if (c=='\n')
          { Chyba("Chybi znak '\"' na konci retezce",RADEK);
            NovyRadek
            Ret[delka]=0; return RETEZ; }

          if (c=='\t') { Delk(TABSIZE);
                         unsigned d=delka+TABSIZE;
                         while (delka<d) { if (delka<MAXRETEZ) Ret[delka]=' '; ++delka; } cc=0; }
          else { Delk(1);
            if (!cc) { if (c=='\\') { cc=c; continue; }
              if (c=='"') { Ret[delka<=MAXRETEZ?delka:MAXRETEZ]=0; return RETEZ; }
              if (delka<MAXRETEZ) Ret[delka]=c; ++delka; }
            else { switch (c)
                   { case 'a': c='\a'; break;
                     case 'b': c='\b'; break;
                     case 'f': c='\f'; break;
                     case 'n': c='\n'; break;
                     case 'r': c='\r'; break;
                     case 't': c='\t'; break;
                     case 'v': c='\v'; break;
                     case '\'': c='\''; break;
                     case '"': c='"'; break;
                     case '\\': c='\\'; break;
                     case '?': c='\?'; break; }
              if (delka<MAXRETEZ) Ret[delka]=c; ++delka; }
              cc=0; } }
          if (delka>MAXRETEZ)
          { if (!chyba) { Chyba("Dlouhy retezec"); chyba=true; } } }

'[^']'  yylval.c=yytext[1]; Delk(); return CISLO;

"'\\''" yylval.c='\''; Delk(); return CISLO;

"{"     Delk(); return '{';
"}"     Delk(); return '}';

"("     Delk(); return '(';
")"     Delk(); return ')';

"++"    Delk(); return INKREM;
"--"    Delk(); return DEKREM;
"!"     Delk(); return '!';
not     Delk(); return NOT;
"~"     Delk(); return '~';

"*"     Delk(); return '*';
"/"     Delk(); return '/';
"%"     Delk(); return '%';

"+"     Delk(); return '+';
"-"     Delk(); return '-';

"<<"    Delk(); return POSUNVLEVO;
">>"    Delk(); return POSUNVPRAVO;

"<"     Delk(); return '<';
">"     Delk(); return '>';
"<="    Delk(); return MENSIROVNO;
">="    Delk(); return VETSIROVNO;

"=="    Delk(); return ROVNO;
"!="    Delk(); return NENIROVNO;

"&"     Delk(); return '&';
"^"     Delk(); return '^';
"|"     Delk(); return '|';
"&&"    Delk(); return AND;
and     Delk(); return AND;
"||"    Delk(); return OR;
or      Delk(); return OR;

"="     Delk(); return '=';
"*="    Delk(); return P_NASOB;
"/="    Delk(); return P_DELEN;
"%="    Delk(); return P_MODUL;
"+="    Delk(); return P_PRICT;
"-="    Delk(); return P_ODECT;
"<<="   Delk(); return P_POSUNVLEVO;
">>="   Delk(); return P_POSUNVPRAVO;
"&="    Delk(); return P_AND;
"^="    Delk(); return P_XOR;
"|="    Delk(); return P_OR;

if      Delk(); return IF;
else    Delk(); return ELSE;

for     Delk(); return FOR;
while   Delk(); return WHILE;
do      Delk(); return DO;

print   Delk(); return PRINT;
scan    Delk(); return SCAN;

{jmeno} { unsigned l= yyleng<=MAXRETEZ ? yyleng : MAXRETEZ;
          memcpy(Ret,yytext,l); Ret[l]=0;
          yylval.r=Ret;
          Delk();
          return PROMENNA; }

,         Delk(); return ',';
;         Delk(); return ';';

"/*"  { char zz=0;
        Delk();
        for (;;) { char z=
#ifdef __cplusplus
          yyinput();
#else
          input();
#endif
          if (z!='\t') Delk(1); else Delk(TABSIZE);
          if (z==EOF) { Chyba("Neukonceny komentar",RADEK); return 0; }
          if (zz=='*' && z=='/') break;
          zz=z;
          if (z=='\n') NovyRadek } }

"//"  { for (;;) { char z=
#ifdef __cplusplus
          yyinput();
#else
          input();
#endif
          if (z==EOF) return 0;
          if (z=='\n') { NovyRadek break; } } }

.  { Delk();
     Chyba("Neznamy znak"); }

%%

void Flush() { YY_FLUSH_BUFFER; }

void LexInit() { Radek=1,Sloupec=1,Delka=0; }

