#include"List.h"

List*
createList() {

    List * newList;
    
    newList = (List*) malloc(sizeof(List));
    newList->head = NULL;
    newList->tail = NULL;
    newList->size = 0;
    return newList;
}

void 
addElement(int value, List* list) {

    item* buffer;

    list->size +=1;

    buffer = (item*) malloc(sizeof(item));
    buffer->number = value;
    buffer->next  = NULL;
    
    if(list->head != NULL) {
    
        buffer->previous = list->tail;
        list->tail->next = buffer;
        list->tail = buffer;
   } 
   else {
        buffer->previous = NULL;
        list->head = buffer;
        list->tail = buffer;
     }
}

void removeElement(int value, List* list) {
    
    item* previous = list->head;
    item* after = list->head;
    list->size -=1;
    
    while(after->number != value) {
    previous = after;
    after = after->next;
    }
    
    previous->next = after->next;
    after->next->previous = previous;   
    
    if(after->number == list->head->number) {
        list->head = list->head->next;
    }
    free(after);
}

void
printFirst(List *list) {

    printf("This is the first value of my list: %d\n", list->head->number);
    return;
}


void
printAllElements(List *list) {
    
    item* currentPosition = list->head;
    int index = 0;
    
    while(currentPosition != NULL) {
    
        printf("[index]%d <--> [value]%d\n", index, currentPosition->number);
        currentPosition = currentPosition->next;
        index +=1;
    }
}
