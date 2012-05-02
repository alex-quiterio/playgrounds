/* 
 * File:   CYK.c
 * Author: alexandre
 *
 */

#include <stdio.h>
#include <stdlib.h>


/*
 * DEFINE CONSTANTS
 */
#define MARKER '#'
#define NULL_SYMBOL '$'
#define BASE_RULE 'A'
#define INITIAL_RULE 'R'
#define ALPHABET 26
#define MAX_SYMBOLS_PER_RULE 3
#define MAX_BINARY_SEQUENCE 5000

/* ************   GRAMMAR STRUCTS *********************** */
/**
 * Struct Symbol has a character
 * and a position in array mode.
 * To find a symbol, we only need to
 * access the position in O(1)
 */
typedef struct Symbol {
    char symbol;
    int position;
} Symbol;

/**
 * Struct Rule has a head,
 * and a collection of terminal or non terminal symbols
 * If the Rule is a Terminal, it has the value
 * isTerminal marked with 1;
 */
typedef struct Rule {
    Symbol* head;
    Symbol* terminator[2];
    struct Rule *next;
} Rule;

/**
 * List of Rules used on Grammar to define
 * Terminal or Non Terminal Rules
 */
typedef struct RuleList {
    Rule* first;
    Rule* last;
} RuleList;

/**
 * Struct Grammar has two lists
 * of rules
 */
typedef struct Grammar {
    RuleList* NonTerminalRuleList;
    RuleList* TerminalRuleList;
} Grammar;

/* ************   SEQUENCE STRUCTS *********************** */
/**
 * Sequence has an array of characters
 * with MAX_BINARY_SEQUENCE size
 * and a pointer to the next element of the list
 */
typedef struct Sequence {
    char sequence[MAX_BINARY_SEQUENCE];
    struct Sequence* next;
} Sequence;
/**
 * Struct SequenceCollection is a list
 * of sequences computed in the future
 * with CYK algorithm
 */
typedef struct SequenceCollection {
    Sequence* first;
    Sequence* last;
} SequenceCollection;

/* ************   GRAMMAR CONSTRUCTORS *********************** */
/**
 * Symbol Constructor
 */
Symbol*
newSymbol(char symbol) {
    if(symbol == NULL_SYMBOL) {
        return NULL;
    }
    Symbol* grammarSymbol = (Symbol*) malloc(sizeof(Symbol));
    grammarSymbol->position = symbol - BASE_RULE;
    grammarSymbol->symbol = symbol;
    return grammarSymbol;
}
/**
 * Grammar Constructor
 */
Grammar*
newGrammar() {
    Grammar *grammar = (Grammar*) malloc(sizeof(Grammar));
    grammar->TerminalRuleList = (RuleList*) malloc(sizeof(RuleList));
    grammar->NonTerminalRuleList = (RuleList*) malloc(sizeof(RuleList));
    return grammar;
}

/**
 * Add Rule to List of rules
 */
void
addRuletoList(Rule* rule, RuleList* list) {
    if(list->first != NULL) {
        list->last->next = rule;
    }
    else {
        list->first = rule;
    }
    list->last = rule;
}
/**
 * Add rule to Grammar
 */
void
addRuleToGrammar(Grammar* grammar, Rule* rule) {
    if(rule->terminator[1] == NULL) {
        addRuletoList(rule, grammar->TerminalRuleList);
    } else  {
        addRuletoList(rule, grammar->NonTerminalRuleList);
    }
}
/**
 * Rule Constructor
 */
Rule*
newRule
(Symbol* head, Symbol* terminator1, Symbol* terminator2) {

    Rule *terminalRule = (Rule*) malloc(sizeof(Rule));
    terminalRule->head=head;
    terminalRule->terminator[0]=terminator1;
    terminalRule->terminator[1]=terminator2;
    terminalRule->next = NULL;

    return terminalRule;
}

/* ************   SEQUENCE CONSTRUCTORS *********************** */
/**
 * SequenceCollection Constructor
 */
SequenceCollection*
newSequenceCollection() {
    SequenceCollection *collection =
            (SequenceCollection*) malloc(sizeof(SequenceCollection));
    collection->first = NULL;
    collection->last = NULL;
    return collection;
}
/**
 * AddNewSequence Constructor
 */
void
addNewSequence(SequenceCollection* collection, Sequence* sequence) {
    if(collection->first != NULL) {
        collection->last->next = sequence;
    } else {
        collection->first = sequence;
    }
    collection->last = sequence;
}
/**
 * newSequence Constructor
 */
Sequence*
newSequence() {
    Sequence* newOne = (Sequence*) malloc(sizeof(Sequence));
    newOne->next = NULL;
    return newOne;
}

/* ************   PARSING FUNCTIONS *********************** */
/**
 * strlen: String Length function Optimization
 * @param receives a char pointer
 * @return the length of the pointer minus one (\0)
 */
size_t
strlen(str) const char *str; {
  const char *s;
  for (s = str; *s; ++s);
  return(s - str-1);
}
/**
 * GetRule: Read one rule of input
 * @param line[] receives an array of chars
 * @return the same array formated to be consumed
 * by rule generator
 */
void
getRule(char line[]) {
    int length;
    fgets(line, sizeof(line), stdin);
    length = strlen(line);
    if(length == 2) {
        line[2] = NULL_SYMBOL;
    }
}
/**
 * ReadRules: Read all the rules used in Grammar to parse
 * analyses the sequences in the future
 * @param grammar the grammar used to construct
 * the Rule Domain
 * @return void
 */
void
readRules(Grammar* grammar) {
    Rule* rule = NULL;
    char bucket[MAX_SYMBOLS_PER_RULE];

    getRule(bucket);
    while (bucket[0] != MARKER) {
        rule = newRule( newSymbol(bucket[0]),
                        newSymbol(bucket[1]),
                        newSymbol(bucket[2]));
        addRuleToGrammar(grammar, rule);
        getRule(bucket);
    }
}

/**
 * Read all the sequences used to print the problem final
 * solution
 * @param SequenceCollection    a struct with all the sequences
 * @return void
 */
void
readSequences (SequenceCollection* collection) {
    Sequence* newSeq = newSequence();
    fgets(newSeq->sequence, sizeof(newSeq->sequence), stdin);

    while(newSeq->sequence[0] != MARKER) {
        addNewSequence(collection, newSeq);
        newSeq = newSequence();
        fgets(newSeq->sequence, sizeof(newSeq->sequence), stdin);
    }
    
}

/* ************   CYK Algorithm *********************** */

/**
 * NOTE: Reference at http//:en.wikipedia.org/wiki/CYK_algorithm
 * if string S is member of the language it print yes, otherwise print no
 * @param   the grammar contain r nonterminal symbols R1 ... Rr
 * @param   the input be a string S consisting of n characters: a1 ... an
 * @return  void
 */
void
cykAlgorithm(Grammar* grammar, Sequence* sequence) {

    int n = strlen(sequence->sequence)+1, ix, jx, kx;
    Rule* rule = NULL;
    int matrix[n][n][ALPHABET];
    
        
    for(ix = 0; ix < n; ix++) {
        for(jx = 0; jx < n; jx++) {
                for(kx = 0; kx < ALPHABET; kx++) {
                    matrix[ix][jx][kx] = 0;
                }
        }
    }
    // Frist Iteration Bottom-Up
    for(ix = 1; ix < n; ix++) {
        rule = grammar->TerminalRuleList->first;
        for(; rule != NULL;) {
            if(rule->terminator[0]->symbol == sequence->sequence[ix-1]) {
                matrix[ix][1][rule->head->position] = 1;
            }
            rule = rule->next;
        }
    }
    //Main Loop of Algorithm
    for(ix = 2; ix < n; ix++) {
        for(jx = 1; jx < n - ix + 1; jx++) {
            for(kx = 1; kx < ix; kx++) {
                rule = grammar->NonTerminalRuleList->first;
                for(; rule != NULL;) {
                    if((matrix[jx][kx][rule->terminator[0]->position] == 1)
                    && (matrix[jx + kx][ix-kx][rule->terminator[1]->position] == 1)) {
                        matrix[jx][ix][rule->head->position] = 1;
                    }
                    rule = rule->next;
                }
            }
        }
    }
    
    if(matrix[1][n-1][INITIAL_RULE-BASE_RULE] == 1) {
        printf("yes\n");
        return;
    }
    printf("no\n");
}

/**
 * Analyses all the sequences with CYK algorithm
 * and print yes if the sequence is valid to the grammar
 * no otherwise
 * @param Grammar   the grammar which we need to compute
 *                  each sequence
 * @param SequenceCollection    a collection of sequences
 *                              to compute CYK
 * @return void
 */
void
solveProblem(Grammar* grammar, SequenceCollection* collection) {
    Sequence* sequence = collection->first;
    if(sequence == NULL) {
        return;
    }
    while(sequence != NULL) {
        cykAlgorithm(grammar,sequence);
        sequence = sequence->next;
    }
}

/**
 * Main Function
 */
int main(void) {

    Grammar * grammar = newGrammar();
    SequenceCollection *collection = newSequenceCollection();

    readRules(grammar);
    readSequences(collection);
    solveProblem(grammar, collection);

     return 0;
}
