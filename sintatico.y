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
#include <stdio.h>
#include <string.h>
#include "lexico.c"
#include <stdlib.h>
#include "estrut.c"

int conta = 0;
int rotulo = 0;
char tipo;
int tamanho;
%}

%start programa

%token T_PROGRAMA
%token T_INICIO
%token T_FIM
%token T_LEIA
%token T_ESCREVA
%token T_SE
%token T_ENTAO
%token T_SENAO
%token T_FIMSE
%token T_ENQUANTO
%token T_FACA
%token T_FIMENQUANTO
%token T_REPITA
%token T_ATE
%token T_FIMREPITA
%token T_MAIS
%token T_MENOS
%token T_VEZES
%token T_DIV
%token T_MAIOR
%token T_MENOR
%token T_IGUAL
%token T_E
%token T_OU
%token T_NAO
%token T_ATRIB
%token T_ABRE
%token T_FECHA
%token T_ABRECOL
%token T_FECHACOL
%token T_INTEIRO
%token T_LOGICO
%token T_F
%token T_V
%token T_IDENTIF
%token T_NUMERO

%left T_E T_OU
%left T_IGUAL
%left T_MAIOR T_MENOR
%left T_MAIS T_MENOS
%left T_VEZES T_DIV

%%
programa
    : cabecalho variaveis
        { 
            mostra_tabela();
            fprintf(yyout, "\tAMEM\t%d\n", conta);
            empilha (conta);
        }
    T_INICIO lista_comandos T_FIM
        {
            fprintf(yyout, "\tDMEM\t%d\n", desempilha());
            fprintf(yyout, "\tFIMP\n");
        }
    ;

cabecalho
    : T_PROGRAMA T_IDENTIF
        { fprintf(yyout, "\tINPP\n"); }
    ;

variaveis
    :
    | declaracao_variaveis
    ;

declaracao_variaveis
    : tipo lista_variaveis declaracao_variaveis
    | tipo lista_variaveis
    ;

tipo
    : T_INTEIRO { tipo = 'i'; }
    | T_LOGICO  { tipo = 'l'; }
    ;

lista_variaveis
    : lista_variaveis variavel
    | variavel
    ;

variavel
    : T_IDENTIF
        { strcpy (elem_tab.id, atomo);}
        tamanho
    ;

tamanho
    :   
        { 
            elem_tab.endereco = conta++;
            elem_tab.tipo = tipo;
            strcpy (elem_tab.categoria, "VAR");
            elem_tab.tamanho = 1;
            insere_simbolo(elem_tab);
        }
    | T_ABRECOL T_NUMERO T_FECHACOL
        {
            tamanho = atoi(atomo);
            elem_tab.endereco = conta;
            elem_tab.tipo = tipo;
            strcpy (elem_tab.categoria, "VET");
            elem_tab.tamanho = tamanho;
            insere_simbolo(elem_tab);
            conta = conta + tamanho;
        }
    ;

lista_comandos
    :
    | comando lista_comandos
    ;

comando
    : leitura
    | escrita
    | repeticao
    | selecao
    | atribuicao
    ;

leitura
    : T_LEIA T_IDENTIF
        { 
            int pos = busca_simbolo(atomo);
            if (pos  == -1)
                erro ("Variável não declarada!");
            empilha(pos);
        }
      indiceLeitura
    ;

indiceLeitura
    :
        {
            int p = desempilha();
            printf("%d\n", p);
            fprintf(yyout, "\tLEIA\n");
            fprintf(yyout, "\tARZG\t%d\n", TabSimb[p].endereco);
        }
    | T_ABRECOL expr T_FECHACOL
        {
            char t = desempilha();
            int p = desempilha();
            if (t == 'l')
                erro("tipo do indice deve ser inteiro");
            if (strcmp(TabSimb[p].categoria, "VET") != 0)
                erro("Variável não é vetor.");
            printf("%d\n", p);
            fprintf(yyout, "\tLEIA\n");
            fprintf(yyout, "\tARZV\t%d\n", TabSimb[p].endereco);
        }
    ;

escrita
    : T_ESCREVA expr
        {
            desempilha();
            fprintf(yyout, "\tESCR\n");
        }
    ;

repeticao
    : T_ENQUANTO
        {
            rotulo++;
            fprintf(yyout, "L%d\tNADA\n", rotulo);
            empilha(rotulo);
        }
    expr T_FACA
        {
            char t = desempilha();
            if (t != 'l')
                erro ("Incompatibilidade de tipos!");
            rotulo++;
            fprintf(yyout, "\tDSVF\tL%d\n", rotulo);
            empilha(rotulo);
        }
    lista_comandos T_FIMENQUANTO
        { 
            int r1 = desempilha();
            int r2 = desempilha();
            fprintf(yyout, "\tDSVS\tL%d\n", r2);
            fprintf(yyout, "L%d\tNADA\n", r1);
        }
    | T_REPITA 
        {
            rotulo++;
            fprintf (yyout, "L%d\tNADA\n", rotulo);
        }
    lista_comandos T_ATE expr T_FIMREPITA
        { 
            char t = desempilha();
            if (t != 'l')
                erro ("Incompatibilidade de tipos!");
            fprintf (yyout, "\tDSVF\tL%d\n", rotulo);
        }
    ;

selecao
    : T_SE expr T_ENTAO
        {   
            char t = desempilha();
            if (t != 'l')
                erro ("Incompatibilidade de tipos!");            
            rotulo++;
            fprintf(yyout, "\tDSVF\tL%d\n", rotulo);
            empilha(rotulo);
        }
    lista_comandos T_SENAO
        {
            int r = desempilha();
            rotulo++;
            fprintf(yyout, "\tDSVS\tL%d\n", rotulo);
            empilha(rotulo);
            fprintf(yyout, "L%d\tNADA\n", r);
        }
    lista_comandos T_FIMSE
        { 
            int r = desempilha();
            fprintf(yyout, "L%d\tNADA\n", r);
        }
    ;

atribuicao
    : T_IDENTIF
        {
            int pos = busca_simbolo(atomo);
            if (pos == -1)
                erro ("Variável não declarada!");
            empilha(pos);  
        }
      posicao T_ATRIB expr
        {
            int tipo = desempilha();
            int pos = desempilha();
            if (tipo != TabSimb[pos].tipo)
                erro ("Incompatibilidade de tipos!");
            if (strcmp(TabSimb[pos].categoria, "VAR") == 0)
                fprintf(yyout, "\tARZG\t%d\n", TabSimb[pos].endereco);
            else
                fprintf(yyout, "\tARZV\t%d\n", TabSimb[pos].endereco);
        }
    ;

posicao
    :
    | T_ABRECOL expr
        {
            int t = desempilha();
            int p = desempilha();
            if (t == 'l')
                erro("tipo do indice deve ser inteiro");
            if (strcmp(TabSimb[p].categoria, "VET") != 0)
                erro("Variável não é vetor.");
            empilha(p);
        }
    T_FECHACOL
    ;

expr
    : expr T_VEZES expr
        {
            char t1 = desempilha();
            char t2 = desempilha();
            if (t1 != 'i' || t2 != 'i')
                erro ("Incompatibilidade de tipos!");
            empilha('i');
            fprintf(yyout, "\tMULT\n");
        }
    | expr T_DIV expr
        {
            char t1 = desempilha();
            char t2 = desempilha();
            if (t1 != 'i' || t2 != 'i')
                erro ("Incompatibilidade de tipos");
            empilha('i');
            fprintf(yyout, "\tDIVI\n");
        }
    | expr T_MAIS expr
        {
            char t1 = desempilha();
            char t2 = desempilha();
            if (t1 != 'i' || t2 != 'i')
                erro ("Incompatibilidade de tipos");
            empilha('i');
            fprintf(yyout, "\tSOMA\n");
        }
    | expr T_MENOS expr
        {
            char t1 = desempilha();
            char t2 = desempilha();
            if (t1 != 'i' || t2 != 'i')
                erro ("Incompatibilidade de tipos");
            empilha('i');
            fprintf(yyout, "\tSUBT\n");
        }

    | expr T_MAIOR expr
        {
            char t1 = desempilha();
            char t2 = desempilha();
            if (t1 != 'i' || t2 != 'i')
                erro ("Incompatibilidade de tipos");
            empilha('l');
            fprintf(yyout, "\tCMMA\n");
        }
    | expr T_MENOR expr
        {
            char t1 = desempilha();
            char t2 = desempilha();
            if (t1 != 'i' || t2 != 'i')
                erro ("Incompatibilidade de tipos");
            empilha('l');
            fprintf(yyout, "\tCMME\n");
        }
    | expr T_IGUAL expr
        {
            char t1 = desempilha();
            char t2 = desempilha();
            if (t1 != 'i' || t2 != 'i')
                erro ("Incompatibilidade de tipos");
            empilha('l');
            fprintf(yyout, "\tCMIG\n");
        }

    | expr T_E expr
        {
            char t1 = desempilha();
            char t2 = desempilha();
            if (t1 != 'l' || t2 != 'l')
                erro ("Incompatibilidade de tipos");
            empilha('l');
            fprintf(yyout, "\tCONJ\n");
        }
    | expr T_OU expr
        {
            char t1 = desempilha();
            char t2 = desempilha();
            if (t1 != 'l' || t2 != 'l')
                erro ("Incompatibilidade de tipos");
            empilha('l');
            fprintf(yyout, "\tDISJ\n");
        }

    | termo             
    ;

termo
    : T_IDENTIF
        {
            int pos = busca_simbolo(atomo);
            if (pos == -1)
                erro ("Variável não declarada!");
            empilha(TabSimb[pos].tipo);
            if (strcmp(TabSimb[pos].categoria, "VAR") == 0)
                fprintf(yyout, "\tCRVG\t%d\n", TabSimb[pos].endereco);
            if (strcmp(TabSimb[pos].categoria, "VET") == 0)
                empilha(pos);
        }
     indice
    | T_NUMERO
        {
            fprintf(yyout, "\tCRCT\t%s\n", atomo);
            empilha('i');
        }
    | T_V
        {
            fprintf(yyout, "\tCRCT\t1\n");
            empilha('l');
        }
    | T_F
        {
            fprintf(yyout, "\tCRCT\t0\n");
            empilha('l');
        }
    | T_NAO termo
        {
            char t = desempilha();
            if (t != 'l')
                erro ("Incompatibilidade de tipos!");
            fprintf(yyout, "\tNEGA\n");
            empilha('l');
        }
    | T_ABRE expr T_FECHA
    ;

indice
    : /*vazia*/
    | T_ABRECOL expr
        {
            char t = desempilha();
            if (t == 'l')
                erro("tipo do indice deve ser inteiro");
        }
     T_FECHACOL
        {
            int pos = desempilha();
            fprintf(yyout, "\tCRVV\t%d\n", TabSimb[pos].endereco);
        }
    ;

%%

void erro (char *s) {
    printf("ERRO NA LINHA %d: %s\n", numLinha, s);
    exit(10);
}

int yyerror (char *s){
    erro ("Erro sintático");
}

int main (int argc, char **argv) {

    char *p, nameIn[100], nameOut[100];

    argv++;

    if(argc < 2){

        puts("\nCompilador Simples:");
        puts("     USO: ./simples <nomefonte>[.simples]\n\n");
        exit(10);

    }

    p = strstr(argv[0], ".simples");

    if (p) *p = 0;

    strcpy(nameIn, argv[0]);
    strcat(nameIn, ".simples");
    strcpy(nameOut, argv[0]);
    strcat(nameOut, ".mvs");

    yyin = fopen (nameIn, "rt");

    if(!yyin) {

        puts("Programa fonte não encontrado!");
        exit(10);

    }

    yyout = fopen (nameOut, "wt");

    if(!yyparse())
        puts ("Programa ok!");
}