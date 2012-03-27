#ifndef LIST___H
#define LIST___H

#include<stdio.h>
#include <stdlib.h>

struct node {

    int   number;
    struct node* previous;
    struct node    * next;
};

struct list {

    struct node* head;
    struct node* tail;
    int size;
};

typedef struct node item;
typedef struct list List;

/* Functions */

List * createList();
void addElement(int i, List* list);
void removeElement(int i, List* list);
void printFirst(List* list);
void printAllElements(List *list);
#endif
