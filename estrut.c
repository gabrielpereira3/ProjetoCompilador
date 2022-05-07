/*+-------------------------------------------------------------
  |           UNIFAL - Universidade Federal de Alfenas.
  |             BACHARELADO EM CIENCIA DA COMPUTACAO.
  | Trabalho..: Vetor e verificacao de tipos
  | Disciplina: Teoria de Linguagens e Compiladores
  | Professor.: Luiz Eduardo da Silva
  | Aluno.....: Gabriel Pereira Soares
  | Data......: 10/04/2022
  +-------------------------------------------------------------*/

#define TAM_TAB 100
#define TAM_PIL 100

// Pilha Semantica
int Pilha[TAM_PIL];
int topo = -1;

// Tabela de Simbolos
struct elem_tab_simbolos {
    char id[100];
    int endereco;
    char tipo;
    char categoria[4];
    int tamanho;
} TabSimb[TAM_TAB], elem_tab;

int pos_tab;

// Rotina da pilha semantica
void empilha(int valor) {
    if (topo == TAM_PIL)
        erro("Pilha cheia");
    Pilha[++topo] = valor;
} 

int desempilha () {
    if (topo == -1)
        erro("Pilha vazia");
    return Pilha[topo--];
}

// Rotinas da Tabela de Simbolos
// retorna -1 se não encontra o id
int busca_simbolo (char *id) {
    int i = pos_tab - 1;
    for (; strcmp(TabSimb[i].id, id) && i >= 0; i--);
    return i;
}

void insere_simbolo (struct elem_tab_simbolos elem) {
    int i;
    if (pos_tab == TAM_TAB)
        erro("Tabela de Simbolos cheia!");
    i = busca_simbolo(elem.id);
    if (i != -1)
        erro("Identificador duplicado");
    TabSimb[pos_tab++] = elem;
}

void mostra_tabela() {
    int i;
    char tipo[3];

    puts("\nTabela de Simbolos");
    printf("\n%3s | %s | %s | %s | %s | %s\n", "#", "ID", "END", "TIPO", "CAT", "TAM");

    for(i = 0; i < 50; i++)
        printf("-");
    for(i = 0; i < pos_tab; i++) {
        if(TabSimb[i].tipo == 'i'){
            tipo[0] = 'I';
            tipo[1] = 'N';
            tipo[2] = 'T';
        } else if(TabSimb[i].tipo == 'l') {
            tipo[0] = 'L';
            tipo[1] = 'O';
            tipo[2] = 'G';
        }
        printf("\n%3d |  %s |  %d  | %3s  | %3s | %2d", i, TabSimb[i].id, TabSimb[i].endereco, tipo, TabSimb[i].categoria, TabSimb[i].tamanho);
    }
    puts("\n");
}
