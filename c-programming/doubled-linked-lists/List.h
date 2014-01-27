#ifndef LIST___H
#define LIST___H

#include<stdio.h>
#include <stdlib.h>

struct node {

    int   number;
    struct node* previous;
    struct node    * next;
};

typedef struct List {

    int size;
    struct node* head;
    struct node* tail;
    void (*add)(int a, void* list);
    void (*remove)(int a, void* list);
    void (*print)(void* list);
    int (*get)(int value, void* list);
} List;

typedef struct node item;

/* Functions */
List * createList();
void removeList(List* list);
#endif
