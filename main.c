#include<stdio.h>
#include "List.h"


#define MAX_ELEMENTS 10

int 
main(int argc, char** argv) {
    
    List * list = createList();
    int index;
   
    printf("Insert Elements on a Double Linked List\n"); 
    
    for(index = 0; index < MAX_ELEMENTS; index++) {
        list->add(index, list);
    }
    
    list->print(list); 
    list->remove(0,list);
    list->remove(4,list);
    list->print(list);
    printf("Done it :)\n");
    return 1;
}
