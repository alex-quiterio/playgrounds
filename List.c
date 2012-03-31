#include"List.h"

// Global variable

void 
addElement(int value, void* currentlist) {

    item* buffer;
    
    List* list = (List*) currentlist;
    
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

void 
removeElement(int value, void* currentlist) {

    List *list = (List*) currentlist;   
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
printElements(void *currentlist) {

    List *list = (List*) currentlist;
    
    item* currentPosition = list->head;
    int index = 0;
    
    printf("[");
    while(currentPosition->next != NULL) {
    
        printf("%d, ", currentPosition->number);
        currentPosition = currentPosition->next;
        index +=1;
    }
    
    printf("%d]\n", currentPosition->number);
}

List*
createList() {

    List * newList;
    
    newList = (List*) malloc(sizeof(List));
    newList->head = NULL;
    newList->tail = NULL;
    newList->size = 0;
    newList->addItem = &addElement;
    newList->removeItem =&removeElement;
    newList->printList = &printElements;
    return newList;
}

