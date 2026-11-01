#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "../List.h"

/* Walks the list in both directions and checks it matches `expected`. */
static void assertContents(List *list, const int *expected, int n) {
    assert(list->size == n);

    item *node = list->head;
    for (int i = 0; i < n; i++) {
        assert(node != NULL);
        assert(node->number == expected[i]);
        node = node->next;
    }
    assert(node == NULL);

    node = list->tail;
    for (int i = n - 1; i >= 0; i--) {
        assert(node != NULL);
        assert(node->number == expected[i]);
        node = node->previous;
    }
    assert(node == NULL);
}

static List *listOf(const int *values, int n) {
    List *list = createList();
    for (int i = 0; i < n; i++) {
        list->add(values[i], list);
    }
    return list;
}

/* Captures what list->print writes to stdout. */
static void assertPrints(List *list, const char *expected) {
    char buffer[256] = {0};
    fflush(stdout);
    int saved = dup(STDOUT_FILENO);
    FILE *tmp = tmpfile();
    dup2(fileno(tmp), STDOUT_FILENO);
    list->print(list);
    fflush(stdout);
    dup2(saved, STDOUT_FILENO);
    close(saved);
    rewind(tmp);
    size_t len = fread(buffer, 1, sizeof(buffer) - 1, tmp);
    buffer[len] = '\0';
    fclose(tmp);
    assert(strcmp(buffer, expected) == 0);
}

static void testNewListIsEmpty(void) {
    List *list = createList();
    assertContents(list, NULL, 0);
    assertPrints(list, "[]\n");
    removeList(list);
}

static void testAddAppendsAtTail(void) {
    int values[] = {1, 2, 3};
    List *list = listOf(values, 3);
    assertContents(list, values, 3);
    assertPrints(list, "[1, 2, 3]\n");
    removeList(list);
}

static void testGetIsOneBased(void) {
    int values[] = {10, 20, 30};
    List *list = listOf(values, 3);
    assert(list->get(1, list) == 10);
    assert(list->get(2, list) == 20);
    assert(list->get(3, list) == 30);
    removeList(list);
}

static void testRemoveHead(void) {
    int values[] = {1, 2, 3};
    List *list = listOf(values, 3);
    list->remove(1, list);
    int expected[] = {2, 3};
    assertContents(list, expected, 2);
    removeList(list);
}

static void testRemoveMiddle(void) {
    int values[] = {1, 2, 3};
    List *list = listOf(values, 3);
    list->remove(2, list);
    int expected[] = {1, 3};
    assertContents(list, expected, 2);
    removeList(list);
}

static void testRemoveTail(void) {
    int values[] = {1, 2, 3};
    List *list = listOf(values, 3);
    list->remove(3, list);
    int expected[] = {1, 2};
    assertContents(list, expected, 2);
    list->add(4, list);
    int afterAdd[] = {1, 2, 4};
    assertContents(list, afterAdd, 3);
    removeList(list);
}

static void testRemoveOnlyElement(void) {
    int values[] = {7};
    List *list = listOf(values, 1);
    list->remove(7, list);
    assertContents(list, NULL, 0);
    list->add(8, list);
    int expected[] = {8};
    assertContents(list, expected, 1);
    removeList(list);
}

static void testRemoveMissingValueIsNoop(void) {
    int values[] = {1, 2};
    List *list = listOf(values, 2);
    list->remove(99, list);
    assertContents(list, values, 2);
    removeList(list);
}

static void testRemoveFirstOccurrenceOnly(void) {
    int values[] = {5, 6, 5};
    List *list = listOf(values, 3);
    list->remove(5, list);
    int expected[] = {6, 5};
    assertContents(list, expected, 2);
    removeList(list);
}

static void testDemoScenario(void) {
    int values[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
    List *list = listOf(values, 10);
    list->remove(0, list);
    list->remove(4, list);
    assertPrints(list, "[1, 2, 3, 5, 6, 7, 8, 9]\n");
    removeList(list);
}

int main(void) {
    testNewListIsEmpty();
    testAddAppendsAtTail();
    testGetIsOneBased();
    testRemoveHead();
    testRemoveMiddle();
    testRemoveTail();
    testRemoveOnlyElement();
    testRemoveMissingValueIsNoop();
    testRemoveFirstOccurrenceOnly();
    testDemoScenario();
    printf("doubled-linked-lists: all tests passed\n");
    return 0;
}
