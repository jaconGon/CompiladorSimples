// Estruturas Auxiliares

/*
* Tabela de Símbolos 
* -> uma estrura melhor seria a tabela hash
* -> é o gargalo do nosso compilador, as buscas nessa tabela ocorrerão várias vezes
*/

enum 
{
    INT,
    LOG,
    REG
};


#define TAM_TAB 100

struct elemTabSimbolos {
    char id[100]; // nome do indentificador
    int end;      // endereco 
    int tip;      // tipo
    int tam;      // tamanho
    int pos;      // talvez *?

} tabSim[TAM_TAB], elemTab;

int posTab; // inidica a próxima posicao livre para inserir

// Rotinas
int buscaSimbolo (char *s){
    int i;
    for (i = posTab -1; strcmp(tabSim[i].id, s) && i >= 0; i--) // posiciona no último elemento e vai decrementando
        ;
    if (i == -1){
        char msg[200];
        sprintf(msg, "Identificador [%s] não encontrado!", s); // sprintf gera e printa um string
        yyerror(msg); // aborta quando chamado (técnica do pânico), diferente de Java e C que tratam o erro
    }
    return i;
}

void insereSimbolo (struct elemTabSimbolos elem){
    int i;
    if (posTab ==  TAM_TAB) 
        yyerror("Tabela de Símbolos cheia!");
    for (i = posTab -1; strcmp(tabSim[i].id, elem.id) && i >= 0; i--)
        ; 
    if (i != -1){
        char msg[200];
        sprintf(msg, "Identificador [%s] duplicado!", elem.id);
        yyerror(msg); 
    }
    tabSim[posTab++] = elem; // insere e depois pula um no posTab
}

void mostraTabela(){
    puts("Tabela de simbolos");
    puts("------------------");
    printf("%30s | %s | %s | %s | %s | %s\n", "ID" , "END", "TIP", "TAM", "POS", "CAMPOS");
    for(int i = 0 ; i < 70 ; i++)
        printf("-");
    for(int i = 0; i < posTab ; i++) {
        char tipo[4];
        switch (tabSim[i].tip) {
            case INT :
                strcpy(tipo, "INT");
                break;
            case LOG :
                strcpy(tipo, "LOG");
                break;
            default :
                strcpy(tipo, "REG");
        }
        printf("\n%30s | %3d | %s | %3d | %3d | %s",
            tabSim[i].id,
            tabSim[i].end,
            tipo,
            tabSim[i].tam,
            tabSim[i].pos,
            ""
            );
    }
    puts("");
    // for(int i = 0 ; i < 70 ; i++)
    //     printf("-");
    // puts("");
}

// TODO: Retirar símbolos da tabela, descadastrar o nome da tabela
// TODO: Verificar símbolos da tabela

// Pilha Semântica
#define TAM_PIL 100
int pilha[TAM_PIL];
int topo = -1; // vai indicar exatamente onde ele vai inserir

void empilha (int valor){
    if(topo == TAM_PIL)
        yyerror("Pilha semântica cheia!");
    pilha[++topo] = valor;
}

int desempilha (void){
    if(topo == -1)
        yyerror("Pilha semântica vazia!");
    return pilha[topo--];
}

// tipo1 e tipo2 são os tipos esperados na expressão
// ret é o tipo que sera empilhado com resultado da expressão
// vai acontecer em cada expressão
void testaTipo(int tipo1, int tipo2, int ret){
    int t1 = desempilha();
    int t2 = desempilha();
    if(t1 != tipo1 || t2 != tipo2)
        yyerror("Incompatibilidade de tipo");
    empilha(ret);
}
