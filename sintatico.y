/* Arquivo da Gramática*/
/* Cabeçalhos*/
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lexico.c" /* Gerado a partir da ferramenta flex*/
/* int yylex(); Gerado a partir da compilação utilizando o flex, pode ser utilizado o programa lexico.c todo*/
/* int erro (char *s); Rotina de erro, mas ele retirou daqui*/
#include "utils.c"
int contaVar = 0;
int rotulo = 0;
int tipo;
%}

%start programa

/* Todos os símbolos retornados pelo léxico, terminais*/
%token T_PROGRAMA
%token T_INICIO
%token T_FIM
%token T_LEIA
%token T_ESCREVA
%token T_SE
%token T_ENTAO
%token T_SENAO
%token T_FIMSE
%token T_ENQTO
%token T_FACA
%token T_FIMENQTO
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
%token T_INTEIRO
%token T_LOGICO
%token T_V
%token T_F
%token T_IDENTIF
%token T_NUMERO
%token T_DEF
%token T_FIMDEF
%token T_REG

/* Definir precedência das operações*/
%left T_E T_OU
%left T_IGUAL
%left T_MAIOR T_MENOR
%left T_MAIS T_MENOS
%left T_VEZES T_DIV

%%

programa
    : cabecalho define_registro variaveis 
        { 
            mostraTabela();
            empilha (contaVar);
            if(contaVar)
                fprintf(yyout, "\tAMEM\t%d\n", contaVar); 
            
        }
     T_INICIO lista_comandos T_FIM
        { 
            int conta = desempilha();
            if(conta)
                fprintf(yyout, "\tDMEM\t%d\n", conta); 
        }
        { fprintf(yyout, "\tFIMP\n"); }
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

define_registro
    : 
    | T_DEF lista_campos T_FIMDEF T_IDENTIF define_registro
    ;

/* declaracao_campos
    : tipo lista_campos declaracao_campos
    | tipo lista_campos
    ; */

tipo
    : T_INTEIRO
        {tipo = INT;}
    | T_LOGICO
        {tipo = LOG;}
    | T_REG T_IDENTIF
        {tipo = REG;}
    ;

lista_variaveis
    :lista_variaveis 
     T_IDENTIF 
        {
            strcpy(elemTab.id, atomo);
            elemTab.end = contaVar;
            elemTab.tip = tipo;
            insereSimbolo (elemTab); 
            contaVar ++;
            
        }
    | T_IDENTIF
        {
            strcpy(elemTab.id, atomo);
            elemTab.end = contaVar;
            elemTab.tip = tipo;
            insereSimbolo (elemTab); 
            contaVar ++;
        }
    ;

lista_comandos
    : /* vazio*/
    | comando lista_comandos
    ;

lista_campos 
    : tipo T_IDENTIF
    | lista_campos tipo T_IDENTIF
    ;

comando
    : entrada_saida
    | repeticao
    | selecao
    | atribuicao
    ;

entrada_saida
    : entrada
    | saida
    ;

entrada
    : T_LEIA T_IDENTIF
        {   
            int pos = buscaSimbolo (atomo);
            fprintf(yyout, "\tLEIA\n"); 
            fprintf(yyout, "\tARZG\t%d\n", tabSim[pos].end); 
        }
    ;

saida
    : T_ESCREVA expr
        { desempilha(); fprintf(yyout, "\tESCR\n"); }
    ;

atribuicao
    : T_IDENTIF 
        {
            int pos = buscaSimbolo(atomo);
            empilha(pos);
        }
      T_ATRIB expr
        { 
            int tip = desempilha();
            int pos = desempilha();
            if (tabSim[pos].tip != tip)
                yyerror("Incompatibilidade de tipo");
            fprintf(yyout, "\tARZG\t%d\n", tabSim[pos].end);    
        }
    ;

selecao
    : T_SE expr T_ENTAO 
        {
            int t = desempilha();
            if (t != LOG)
                yyerror("Incompatibilidade de tipo");
            fprintf(yyout, "\tDSVF\tL%d\n", ++rotulo); 
            empilha(rotulo);
        }
      lista_comandos T_SENAO 
         {
            fprintf(yyout, "\tDSVS\tL%d\n", ++rotulo);
            int rot = desempilha(); 
            fprintf(yyout, "L%d\tNADA\n", rot); 
            empilha(rotulo);
         }
      lista_comandos T_FIMSE
        { 
            int rot = desempilha();
            fprintf(yyout, "L%d\tNADA\n", rot); 
        }

    ;

repeticao
    : T_ENQTO 
        { 
            fprintf(yyout, "L%d\tNADA\n", ++rotulo);
            empilha(rotulo); 
        }
     expr T_FACA 
        { 
            int t = desempilha();
            if (t != LOG)
                yyerror("Incompatibilidade de tipo");
            fprintf(yyout, "\tDSVF\tL%d\n", ++rotulo);
            empilha(rotulo); 
        }
     lista_comandos T_FIMENQTO
        {
            int rot1 = desempilha();
            int rot2 = desempilha();
            fprintf(yyout, "\tDSVS\tL%d\n", rot2); 
            fprintf(yyout, "L%d\tNADA\n", rot1); 
        }
    ;

expr
    : expr T_VEZES expr
        { 
            testaTipo(INT,INT,INT); 
            fprintf(yyout, "\tMULT\n"); 
        }
    | expr T_DIV expr
        { 
            testaTipo(INT,INT,INT); 
            fprintf(yyout, "\tDIV\n"); 
        }
    | expr T_MAIS expr
        { 
            testaTipo(INT,INT,INT); 
            fprintf(yyout, "\tSOMA\n"); 
        }
    | expr T_MENOS expr
        { 
            testaTipo(INT,INT,INT); 
            fprintf(yyout, "\tSUBT\n"); 
        }
    | expr T_MAIOR expr
        { 
            testaTipo(INT,INT,LOG); 
            fprintf(yyout, "\tCMMA\n"); 
        }
    | expr T_MENOR expr
        { 
            testaTipo(INT,INT,LOG); 
            fprintf(yyout, "\tCMME\n"); 
        }
    | expr T_IGUAL expr
        { 
            testaTipo(INT,INT,LOG); 
            fprintf(yyout, "\tCMIG\n"); 
        }
    | expr T_E expr
        { 
            testaTipo(LOG,LOG,LOG); 
            fprintf(yyout, "\tCONJ\n"); 
        }
    | expr T_OU expr
        { 
            testaTipo(LOG,LOG,LOG); 
            fprintf(yyout, "\tDISJ\n"); 
        }
    | termo
    ;

termo
    : T_IDENTIF
        {
            int pos = buscaSimbolo(atomo); 
            fprintf(yyout, "\tCRVG\t%d\n", tabSim[pos].end);
            empilha(tabSim[pos].tip); 
        }
    | T_NUMERO
        { 
            fprintf(yyout, "\tCRCT\t%s\n", atomo);
            empilha(INT); 
        }
    | T_V
        { 
            fprintf(yyout, "\tCRCT\t1\n"); 
            empilha(LOG); 
        }
    | T_F
        { 
            fprintf(yyout, "\tCRCT\t0\n"); 
            empilha(LOG); 
            
        }
    | T_NAO termo
        { 
            int t = desempilha();
            if ( t != LOG)
                yyerror("Incompatibilidade de tipo");
            fprintf(yyout, "\tNEGA\n"); 
            empilha(LOG);             
        }
    | T_ABRE expr T_FECHA
    ;

%%
/* Implementação das funções*/
/* Função que o sintático gera*/
int main (int argc, char *argv[]) { 
    char *p, nameIn[100], nameOut[100];
    argv++; // pular para o proximo nome, pq o primeiro nome eh o do executavel, dpois eh os param
    if(argc < 2){ // se só tiver o nome do executavel, sem os parametros
        puts("\nCompilador da linguagem SIMPLES");
        puts("\n\tUSO: ./simples <NOME>[.simples]\n\n");
        exit(1);
    }
    p = strstr(argv[0], ".simples");// procurar se tem a ext simples
    if (p) *p = 0; // se tem a extensão ele vai apagar
    strcpy(nameIn, argv[0]);
    strcat(nameIn, ".simples");
    strcpy(nameOut, argv[0]);
    strcat(nameOut, ".mvs");
    yyin = fopen(nameIn, "rt");
    if(!yyin){
        puts("Programa fonte não encontrado!");
        exit(2);
    }
    yyout = fopen(nameOut, "wt");
    yyparse();
    printf("Programa ok!\n\n");
    return 0;
}