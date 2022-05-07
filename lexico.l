/*+-------------------------------------------------------------
  |           UNIFAL - Universidade Federal de Alfenas.
  |             BACHARELADO EM CIENCIA DA COMPUTACAO.
  | Trabalho..: Vetor e verificacao de tipos
  | Disciplina: Teoria de Linguagens e Compiladores
  | Professor.: Luiz Eduardo da Silva
  | Aluno.....: Gabriel Pereira Soares
  | Data......: 10/04/2022
  +-------------------------------------------------------------*/

%{
#include"sintatico.h"
void erro (char *);
int yyerror (char *);
char atomo[100];
int numLinha = 1;
%}

identificador [a-zA-Z][a-zA-Z0-9]*
numero [0-9]+
espaco [ \t]+
novalinha [\n]

%x coment
%option noyywrap

%%

programa        return T_PROGRAMA;
inicio          return T_INICIO;
fimprograma     return T_FIM;

leia            return T_LEIA;
escreva         return T_ESCREVA;

se              return T_SE;
entao           return T_ENTAO;
senao           return T_SENAO;
fimse           return T_FIMSE;

enquanto        return T_ENQUANTO;
faca            return T_FACA;
fimenquanto     return T_FIMENQUANTO;

repita          return T_REPITA;
ate             return T_ATE;
fimrepita       return T_FIMREPITA;

"+"             return T_MAIS;
"-"             return T_MENOS;
"*"             return T_VEZES;
div             return T_DIV;

">"             return T_MAIOR;
"<"             return T_MENOR;
"="             return T_IGUAL;

e               return T_E;
ou              return T_OU;
nao             return T_NAO;

"<-"            return T_ATRIB;
"("             return T_ABRE;
")"             return T_FECHA;
"["             return T_ABRECOL;
"]"             return T_FECHACOL;

inteiro         return T_INTEIRO;
logico          return T_LOGICO;

F               return T_F;
V               return T_V;

{identificador} { strcpy(atomo, yytext); return T_IDENTIF;}
{numero}        { strcpy(atomo, yytext); return T_NUMERO;}
{espaco}        /* nao faz nada*/
{novalinha}     { numLinha++; }
"//".*          ; /* nao faz nada*/
"/*"            BEGIN(coment);
<coment>"*/"    BEGIN(INITIAL);
<coment>.       ; /* nao faz nada */
<coment>\n      { numLinha++; }
.               erro("LEXICO");

%%
