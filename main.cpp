#include <iostream>
#include <map>
#include <cstring>
#include "mikroC.h"
#include "mikroC.tab.hpp"

extern FILE* yyin;
extern unsigned Radek, Sloupec;
bool Chyby = false;
Uzel* Koren = 0;
std::map<std::string, int*> tableVariables;
std::map<std::string, const char*> tableStrings;

int yyparse();
int Interpr(const Uzel *u);

int main(int argc, char* argv[]) {
    if (argc < 2) {
        printf("Zadejte jmeno souboru s programem.\n");
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (yyin == nullptr) {
        printf("Soubor '%s' se nepodarilo otevrit.\n", argv[1]);
        return 1;
    }

    Flush();
    LexInit();

    int parse = yyparse();

    fclose(yyin);

    if (!Chyby || parse) {
        Interpr(Koren);
    } else {
        fprintf(stderr, "\nChyba pri parsovani.\n");
    }

    return 0;
}

Uzel* GenUzel(int typ, Uzel* prvni, Uzel* druhy, Uzel* treti, Uzel* ctvrty) {
    Uzel* u = new Uzel;

    u->Typ = typ;
    u->z.z.prvni = prvni;
    u->z.z.druhy = druhy;
    u->z.z.treti = treti;
    u->z.z.ctvrty = ctvrty;
    return u;
}

Uzel* GenCislo(int cislo){
    Uzel* u = new Uzel{};

    u->Typ = CISLO;
    u->z.Cislo = cislo;
    return u;
}

Uzel* GenRetez(const char* retez){
    Uzel* u = new Uzel{};
    u->Typ = RETEZ;

    auto key = std::string(retez);
    if (tableStrings.find(key) != tableStrings.end()) {
        u-> z.Retez = tableStrings[key];
    } else {
        auto adresa = new char[std::strlen(retez)+1];
        tableStrings[key] = adresa;
        std::strcpy(adresa, retez);
        u->z.Retez = tableStrings[key];
    }
    return u;
}

Uzel* GenPromen(const char* jmeno){
    Uzel* u = new Uzel{};
    u->Typ = PROMENNA;

    auto key = std::string(jmeno);
    if (!tableVariables.contains(key)) {
        int* adresa = new int;
        tableVariables[jmeno] = adresa;
        u->z.Adresa = tableVariables[jmeno];
    } else {
        u->z.Adresa = tableVariables[key];
    }

    return u;
}

void Chyba(const char* S, Pozice P){
    Chyby = true;

    switch (P){
        case SLOUPEC:
            printf("%u.%u %s\n", Radek, Sloupec, S);
            break;
        case RADEK:
            printf("%u %s\n", Radek, S);
            break;
        case BEZPOZICE:
        default:
            printf("%s\n", S);
            break;
    }
    //abort();
}

void yyerror(const char *S)
{
    Chyba(S);
}

void Abort() {
    system("pause"); abort();
}

int Interpr(const Uzel *u) {
    if (u == nullptr) return 0;

#define prvni u->z.z.prvni
#define druhy u->z.z.druhy
#define treti u->z.z.treti
#define ctvrty u->z.z.ctvrty

    switch (u->Typ) {
        case 0:
            Interpr(prvni);
            Interpr(druhy);
            return 0;
        case INKREM:
            if (prvni) {
                if (prvni->Typ == CISLO) {
                    return ++(prvni->z.Cislo);
                } else {
                    return ++(*prvni->z.Adresa);
                }
            } else {
                if (druhy->Typ == CISLO) {
                    return (druhy->z.Cislo)++;
                } else {
                    return (*druhy->z.Adresa)++;
                }
            }
        case DEKREM:
            if (prvni) {
                return --*prvni->z.Adresa;
            }
            return (*druhy->z.Adresa)--;
        case '-':
            if (druhy) {
                return Interpr(prvni) - Interpr(druhy);
            }
            return -Interpr(prvni);
        case '+':
            if (druhy) {
                return Interpr(prvni) + Interpr(druhy);
            }
            return Interpr(prvni);
        case '~':
            return ~Interpr(prvni);
        case '!':
        case NOT:
            return !Interpr(prvni);
        case '*':
            return Interpr(prvni) * Interpr(druhy);
        case '/':{
            int d = Interpr(druhy);
            if (d == 0){
                printf("\nDeleni nulou\n"); Abort();
            }
            return Interpr(prvni) / d;
        }
        case '%':{
            int m = Interpr(druhy);
            if (m == 0){
                printf("\nDeleni nulou\n"); Abort();
            }
            return Interpr(prvni) % m;
        }
        case POSUNVLEVO:
            return Interpr(prvni) << Interpr(druhy);
        case POSUNVPRAVO:
            return Interpr(prvni) >> Interpr(druhy);
        case ROVNO:
            return Interpr(prvni) == Interpr(druhy);
        case NENIROVNO:
            return Interpr(prvni) != Interpr(druhy);
        case '<':
            return Interpr(prvni) < Interpr(druhy);
        case '>':
            return Interpr(prvni) > Interpr(druhy);
        case MENSIROVNO:
            return Interpr(prvni) <= Interpr(druhy);
        case VETSIROVNO:
            return Interpr(prvni) >= Interpr(druhy);
        case '&':
            return Interpr(prvni) & Interpr(druhy);
        case '^':
            return Interpr(prvni) ^ Interpr(druhy);
        case '|':
            return Interpr(prvni) | Interpr(druhy);
        case AND:
            return Interpr(prvni) && Interpr(druhy);
        case OR:
            return Interpr(prvni) || Interpr(druhy);
        case '=':
            return *prvni->z.Adresa = Interpr(druhy);
        case P_NASOB:
            return *prvni->z.Adresa *= Interpr(druhy);
        case P_DELEN:
            return *prvni->z.Adresa /= Interpr(druhy);
        case P_MODUL:
            return *prvni->z.Adresa %= Interpr(druhy);
        case P_PRICT:
            return *prvni->z.Adresa += Interpr(druhy);
        case P_ODECT:
            return *prvni->z.Adresa -= Interpr(druhy);
        case P_POSUNVLEVO:
            return *prvni->z.Adresa <<= Interpr(druhy);
        case P_POSUNVPRAVO:
            return *prvni->z.Adresa >>= Interpr(druhy);
        case P_AND:
            return *prvni->z.Adresa &= Interpr(druhy);
        case P_XOR:
            return *prvni->z.Adresa ^= Interpr(druhy);
        case P_OR:
            return *prvni->z.Adresa |= Interpr(druhy);
        case IF:
            if (Interpr(prvni)) {       // condition
                Interpr(druhy);         // then
            } else {                    // else
                Interpr(treti);
            }
            return 0;
        case ELSE:
            return Interpr(prvni);
        case FOR:
            Interpr(prvni);
            while (Interpr(druhy)) {
                Interpr(ctvrty);
                Interpr(treti);
            }
            return 0;
        case WHILE:
            while (Interpr(prvni)) {    // loop condition
                Interpr(druhy);         // loop body
            }
            return 0;
        case DO:
            do{
                Interpr(prvni);         // loop body
            } while (Interpr(druhy));   // loop condition
            return 0;
        case PRINT:
            if (prvni->Typ != RETEZ) {
                printf("%i",Interpr(prvni));
                return 0;
            }
            if (druhy) {
                printf(prvni->z.Retez, Interpr(druhy));

                return 0;
            }
            printf(prvni->z.Retez);
            return 0;
        case SCAN:
            scanf("%d", prvni->z.Adresa);
            return 0;
        case CISLO:
            return u->z.Cislo;
        case RETEZ:
            return *u->z.Retez;
        case PROMENNA:
            return *u->z.Adresa;
        default:
            printf(u->Typ<256 ? "\nNeznamy symbol: '%c'" : "\nNeznamy symbol: %i", u->Typ);
            Abort();
    }
    return 1;
}
