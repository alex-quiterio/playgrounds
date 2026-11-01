#include "List.h"

void addElement(int value, void *currentlist) {

    item *buffer;

    List *list = (List *)currentlist;

    list->size += 1;

    buffer = (item *)malloc(sizeof(item));
    buffer->number = value;
    buffer->next = NULL;

    if (list->head != NULL) {

        buffer->previous = list->tail;
        list->tail->next = buffer;
        list->tail = buffer;
    } else {
        buffer->previous = NULL;
        list->head = buffer;
        list->tail = buffer;
    }
}

void removeElement(int value, void *currentlist) {

    List *list = (List *)currentlist;
    item *node = list->head;

    while (node != NULL && node->number != value) {
        node = node->next;
    }
    if (node == NULL) {
        return; /* value not in the list */
    }

    if (node->previous != NULL) {
        node->previous->next = node->next;
    } else {
        list->head = node->next;
    }
    if (node->next != NULL) {
        node->next->previous = node->previous;
    } else {
        list->tail = node->previous;
    }

    list->size -= 1;
    free(node);
}

int getElement(int pos, void *currentlist) {

    List *list = (List *)currentlist;
    item *node = list->head;
    int position = 1;

    while (pos != position) {
        node = node->next;
        position++;
    }

    return (int)node->number;
}

void printElements(void *currentlist) {

    List *list = (List *)currentlist;
    item *currentPosition = list->head;

    printf("[");
    while (currentPosition != NULL) {
        printf("%d", currentPosition->number);
        if (currentPosition->next != NULL) {
            printf(", ");
        }
        currentPosition = currentPosition->next;
    }
    printf("]\n");
}

List *createList(void) {

    List *newList;

    newList = (List *)malloc(sizeof(List));
    newList->head = NULL;
    newList->tail = NULL;
    newList->size = 0;
    newList->add = &addElement;
    newList->remove = &removeElement;
    newList->print = &printElements;
    newList->get = &getElement;
    return newList;
}

void removeList(List *list) {

    item *currentPosition = list->head;
    item *freePosition = NULL;
    while (currentPosition != NULL) {
        freePosition = currentPosition;
        currentPosition = currentPosition->next;
        free(freePosition);
    }
    free(list);
}
