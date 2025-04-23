%{

#include  "mikroC.h"

int yylex();
void yyerror(const char *);

extern Uzel *Koren;

bool Konst(const Uzel *);

bool Konst(const Uzel *,const Uzel *);

%}

%token  <c>  CISLO
%token  <r>  RETEZ PROMENNA
%token  IF ELSE FOR WHILE DO PRINT SCAN
%type   <u>  program prikaz prikazy vyraz vyrazf retez promenna

%right  '=' P_NASOB P_DELEN P_MODUL P_PRICT P_ODECT P_POSUNVLEVO P_POSUNVPRAVO P_AND P_XOR P_OR
%left   OR
%left   AND
%left   '|'
%left   '^'
%left   '&'
%left   ROVNO NENIROVNO
%left   '<' '>' MENSIROVNO VETSIROVNO
%left   POSUNVLEVO POSUNVPRAVO
%left   '+' '-'
%left   '*' '/' '%'
%right  INKREM DEKREM '!' '~' NOT MINUS PLUS

%start  program

%error_verbose

%%

program:   '{' prikazy '}'    { Koren=$2; return 0; };

prikazy:   prikaz prikazy     { $$= $2 ? GenUzel(0,$1,$2) : $1; }
         |                    { $$=NULL; };

prikaz:    '{' prikazy '}'    { $$=$2; }

         | vyraz ';'          { $$=$1; }

         | ';'                { $$=NULL; }

         | IF '(' vyraz ')' prikaz { $$=GenUzel(IF,$3,$5); }

         | IF '(' vyraz ')' prikaz ELSE prikaz { $$=GenUzel(IF,$3,$5,$7); }

         | FOR '(' vyrazf ';' vyraz ';' vyrazf ')' prikaz { $$=GenUzel(FOR,$3,$5,$7,$9); }

         | WHILE '(' vyraz ')' prikaz { $$=GenUzel(WHILE,$3,$5); }

         | DO prikaz WHILE '(' vyraz ')' ';' { $$=GenUzel(DO,$2,$5); }

         | '{' prikazy error '}' { $$=NULL; }

         | error ';'          { $$=NULL; };

vyrazf:    vyraz              { $$=$1; }
         |                    { $$=NULL; };

prikaz:    PRINT '(' vyraz ')' ';' { $$=GenUzel(PRINT,$3); }

         | PRINT '(' retez ')' ';' { $$=GenUzel(PRINT,$3); }

         | PRINT '(' retez ',' vyraz ')' ';' { $$=GenUzel(PRINT,$3,$5); }

         | SCAN '(' promenna ')' ';' { $$=GenUzel(SCAN,$3); };

retez:     RETEZ              { $$=GenRetez($1); };

vyraz:     INKREM promenna    { $$=GenUzel(INKREM,$2); }

         | DEKREM promenna    { $$=GenUzel(DEKREM,$2); }

         | promenna INKREM    { $$=GenUzel(INKREM,NULL,$1); }

         | promenna DEKREM    { $$=GenUzel(DEKREM,NULL,$1); }

         | '!' vyraz          { if (Konst($2)) { $2->z.Cislo=!$2->z.Cislo; $$=$2; }
                                else $$=GenUzel('!',$2); }

         | NOT vyraz          { if (Konst($2)) { $2->z.Cislo=!$2->z.Cislo; $$=$2; }
                                else $$=GenUzel('!',$2); }

         | '~' vyraz          { if (Konst($2)) { $2->z.Cislo=~$2->z.Cislo; $$=$2; }
                                else $$=GenUzel('~',$2); }

         | vyraz '*' vyraz    { if (Konst($1,$3)) { $1->z.Cislo*=$3->z.Cislo; $$=$1; }
                                else $$=GenUzel('*',$1,$3); }

         | vyraz '/' vyraz    { if (Konst($1,$3)) { if ($3->z.Cislo!=0) $1->z.Cislo/=$3->z.Cislo;
                                                    else Chyba("Deleni nulou");
                                                    $$=$1; }
                                else $$=GenUzel('/',$1,$3); }

         | vyraz '%' vyraz    { if (Konst($1,$3)) { if ($3->z.Cislo!=0) $1->z.Cislo%=$3->z.Cislo;
                                                    else Chyba("Deleni nulou");
                                                    $$=$1; }
                                else $$=GenUzel('%',$1,$3); }

         | vyraz '+' vyraz    { if (Konst($1,$3)) { $1->z.Cislo+=$3->z.Cislo; $$=$1; }
                                else $$=GenUzel('+',$1,$3); }

         | vyraz '-' vyraz    { if (Konst($1,$3)) { $1->z.Cislo-=$3->z.Cislo; $$=$1; }
                                else $$=GenUzel('-',$1,$3); }

         | vyraz POSUNVLEVO vyraz  { if (Konst($1,$3)) { $1->z.Cislo<<=$3->z.Cislo; $$=$1; }
                                     else $$=GenUzel(POSUNVLEVO,$1,$3); }

         | vyraz POSUNVPRAVO vyraz { if (Konst($1,$3)) { $1->z.Cislo>>=$3->z.Cislo; $$=$1; }
                                     else $$=GenUzel(POSUNVPRAVO,$1,$3); }

         | vyraz '<' vyraz    { if (Konst($1,$3)) { $1->z.Cislo= $1->z.Cislo<$3->z.Cislo; $$=$1; }
                                else $$=GenUzel('<',$1,$3); }

         | vyraz '>' vyraz    { if (Konst($1,$3)) { $1->z.Cislo= $1->z.Cislo>$3->z.Cislo; $$=$1; }
                                else $$=GenUzel('>',$1,$3); }

         | vyraz MENSIROVNO vyraz { if (Konst($1,$3)) { $1->z.Cislo= $1->z.Cislo<=$3->z.Cislo; $$=$1; }
                                    else $$=GenUzel(MENSIROVNO,$1,$3); }

         | vyraz VETSIROVNO vyraz { if (Konst($1,$3)) { $1->z.Cislo= $1->z.Cislo>=$3->z.Cislo; $$=$1; }
                                    else $$=GenUzel(VETSIROVNO,$1,$3); }

         | vyraz ROVNO vyraz  { if (Konst($1,$3)) { $1->z.Cislo= $1->z.Cislo==$3->z.Cislo; $$=$1; }
                                else $$=GenUzel(ROVNO,$1,$3); }

         | vyraz NENIROVNO vyraz { if (Konst($1,$3)) { $1->z.Cislo= $1->z.Cislo!=$3->z.Cislo; $$=$1; }
                                   else $$=GenUzel(NENIROVNO,$1,$3); }

         | vyraz '&' vyraz    { if (Konst($1,$3)) { $1->z.Cislo&=$3->z.Cislo; $$=$1; }
                                else $$=GenUzel('&',$1,$3); }

         | vyraz '^' vyraz    { if (Konst($1,$3)) { $1->z.Cislo^=$3->z.Cislo; $$=$1; }
                                else $$=GenUzel('^',$1,$3); }

         | vyraz '|' vyraz    { if (Konst($1,$3)) { $1->z.Cislo|=$3->z.Cislo; $$=$1; }
                                else $$=GenUzel('|',$1,$3); }

         | vyraz AND vyraz    { if (Konst($1,$3)) { $1->z.Cislo= $1->z.Cislo && $3->z.Cislo; $$=$1; }
                                else $$=GenUzel(AND,$1,$3); }

         | vyraz OR vyraz     { if (Konst($1,$3)) { $1->z.Cislo= $1->z.Cislo || $3->z.Cislo; $$=$1; }
                                else $$=GenUzel(OR,$1,$3); }

         | promenna '=' vyraz { $$=GenUzel('=',$1,$3); }

         | promenna P_NASOB vyraz { $$=GenUzel(P_NASOB,$1,$3); }

         | promenna P_DELEN vyraz { $$=GenUzel(P_DELEN,$1,$3); }

         | promenna P_MODUL vyraz { $$=GenUzel(P_MODUL,$1,$3); }

         | promenna P_PRICT vyraz { $$=GenUzel(P_PRICT,$1,$3); }

         | promenna P_ODECT vyraz { $$=GenUzel(P_ODECT,$1,$3); }

         | promenna P_POSUNVLEVO vyraz  { $$=GenUzel(P_POSUNVLEVO,$1,$3); }

         | promenna P_POSUNVPRAVO vyraz { $$=GenUzel(P_POSUNVPRAVO,$1,$3); }

         | promenna P_AND vyraz { $$=GenUzel(P_AND,$1,$3); }

         | promenna P_XOR vyraz { $$=GenUzel(P_XOR,$1,$3); }

         | promenna P_OR vyraz  { $$=GenUzel(P_OR,$1,$3); }

         | '-' vyraz %prec MINUS { if (Konst($2)) { $2->z.Cislo=-$2->z.Cislo; $$=$2; }
                                   else $$=GenUzel('-',$2); }

         | '+' vyraz %prec PLUS { $$=$2; }

         | '(' vyraz ')'      { $$=$2; }

         | promenna           { $$=$1; }

         | CISLO              { $$=GenCislo($1); }

         | '(' error ')'      { $$=NULL; };

promenna:  PROMENNA           { $$=GenPromen($1); };

%%

static bool Konst(const Uzel *u)
{ return u && u->Typ==CISLO; }

static bool Konst(const Uzel *u1,const Uzel *u2)
{ return u1 && u1->Typ==CISLO && u2 && u2->Typ==CISLO; }

