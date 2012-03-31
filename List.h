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
    void (*addItem)(int a, void* b);
} List;

typedef struct node item;

/* Functions */

List * createList();
void removeElement(int i, List* list);
void printFirst(List* list);
void printAllElements(List *list);
#endif
