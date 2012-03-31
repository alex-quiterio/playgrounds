#include<stdio.h>
#include "List.h"


#define MAX_ELEMENTS 10

int 
main(int argc, char** argv) {
    
    List * list = createList();
    int index;
   
    printf("Insert Elements on a Double Linked List\n"); 
    
    for(index = 0; index < MAX_ELEMENTS; index++) {
        list->addItem(index, list);
    }
    
    list->printList(list); 
    list->removeItem(0,list);
    list->removeItem(4,list);
    list->printList(list);
    printf("Done it :)\n");
    return 1;
}
