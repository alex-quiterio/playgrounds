#include<stdio.h>
#include "List.h"


#define MAX_ELEMENTS 10

int 
main(int argc, char** argv) {
    
    List * list = createList();
    int index;
   
    printf("Insert Elements on a Double Linked List\n"); 
    
    for(index = 0; index < MAX_ELEMENTS; index++) {
        addElement(index, list);
    }
    
    printAllElements(list);
    printf("removing elements from list ehehhe 42\n\n\n");    
    removeElement(0, list);
    removeElement(4, list);
    printAllElements(list);
    printf("Done it :)\n");
    return 1;
}
