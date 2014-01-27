/* 
 * File:   CYK.c
 * Author: alexandre
 */
#include <stdio.h>

/*
 * DEFINE CONSTANTS
 */
#define MARKER '#'
#define ALPHABET 26

/*
 * DEFINE SYMBOL CONSTANTS
 */
#define NULL_SYMBOL '$'
#define BASE_RULE 'A'
#define INITIAL_RULE 'R'

/*
 * DEFINE RULE CONSTANTS
 */
#define MAX_RULES 1024
#define MAX_SYMBOLS_PER_RULE 3

/*
 * DEFINE SEQUENCES CONSTANTS
 */
#define MAX_SEQUENCES 128
#define MAX_BINARY_SEQUENCE 1024

/* ************   STACK INITIALIZATION *********************** */

char collection[MAX_SEQUENCES][MAX_BINARY_SEQUENCE];
char grammarNT[MAX_RULES][MAX_SYMBOLS_PER_RULE];
char grammarT[ALPHABET*2][MAX_SYMBOLS_PER_RULE - 1];
int nTerminals = 0;
int nnoTerminals = 0;
int Nsequences = 0;

/* ************   PARSING FUNCTIONS *********************** */
/**
 * strlen: String Length function Optimization
 * @param receives a char pointer
 * @return the length of the pointer with \0
 */
size_t
strlen(str) const char *str; 
{
  const char *s;
  for (s = str; *s; ++s);
  return(s - str);
}
/**
 * GetRule: Read one rule from input
 * @param line[] receives an array of chars
 * @return the same array formated is returned 
 * to be consumed by rule generator
 */
void
getRule(line) char line[]; 
{
    int length;
    char* check;
    check = fgets(line, sizeof(line)*MAX_SYMBOLS_PER_RULE, stdin);
    length = strlen(line) - 1;
    if(length == 2) {
        line[2] = NULL_SYMBOL;
    }
}

/**
 * ReadRules: Read all the rules used in Grammar
 * @param the empty dictionary of rules
 * @return the grammar completed with all the rules
 * read from stdin
 */
void
readRules() 
{
    char bucket[MAX_SYMBOLS_PER_RULE];
    getRule(bucket);
    while (bucket[0] != MARKER) 
    {
        if(bucket[2] == NULL_SYMBOL) 
        {
            grammarT[nTerminals][0] = bucket[0];
            grammarT[nTerminals][1] = bucket[1];
            nTerminals++;
        } 
        else 
        {
            grammarNT[nnoTerminals][0] = bucket[0];
            grammarNT[nnoTerminals][1] = bucket[1];
            grammarNT[nnoTerminals][2] = bucket[2];
            nnoTerminals++;
        }
        getRule(bucket);
    }
}

void 
getSequence(char line[])
{
    char* check;
    check = fgets(line, sizeof(line)*MAX_BINARY_SEQUENCE, stdin);
}

/**
 * ReadSequences: Read all the sequences used to 
 * compute and decide if sequence belongs to the grammar language or not
 * @param SequenceCollection  an empty dictionary with space to put their a 
 * maximum of sequences of 1024 numbers
 * @return the collection with all the sequences parsed from input
 */ 
void
readSequences() 
{
    getSequence(collection[Nsequences]);
    while(collection[Nsequences][0] != MARKER) 
    {
        Nsequences++;
        getSequence(collection[Nsequences]);
    }
}

/* ************   BIT SHIFTING FUNCTIONS *********************** */

/**
 * PutItOne: mark a position in bit array to one
 * @param position  the position which we want to mark 
 * @param number the old value 
 * @return the new value with position p marked
 */ 
inline void 
putItOne(int position, unsigned int* number)
{
    unsigned int buff = 1 << position;
    *number = (*number | buff);
}

/**
 * GetValue: if the value in position p is marked with one, then return 1
 * otherwise return 0
 * @param position  the position which we want to check
 * @param const value the value of the search
 * @return 1 if position p is marked with 1, otherwise return 0
 */ 
inline int 
getValue(int position, int const value) 
{
    unsigned int buff = 1 << position;
    return (value & buff);
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
cykAlgorithm(sequenceNumber) int sequenceNumber;
{

    int n = strlen(collection[sequenceNumber]), ix, jx, kx, dx;
    unsigned int matrix[n][n];

   for(ix = 1; ix < n; ix++) 
   {
        for(jx = 1; jx < n; jx++) 
        {
            matrix[ix][jx]= 0;
        }
    }

    // Frist Iteration Bottom-Up
    for(ix = 1; ix < n; ix++) 
    {
        for(jx = 0; jx < nTerminals; jx++) 
        {
            if(grammarT[jx][1] == collection[sequenceNumber][ix-1]) 
            {
                putItOne(grammarT[jx][0]- BASE_RULE, &matrix[ix][1]);
            }
        }
    }
    
    //Main Loop of Algorithm
    for(ix = 2; ix < n; ix++) 
    {
        for(jx = 1; jx < n - ix + 1; jx++) 
        {
            for(kx = 1; kx < ix; kx++) 
            {
                for(dx = 0; dx < nnoTerminals; dx++) 
                {
                    if(getValue(grammarNT[dx][1]- BASE_RULE, matrix[jx][kx]) 
                        && getValue(grammarNT[dx][2]- BASE_RULE, matrix[jx + kx][ix-kx])) 
                        {
                            putItOne(grammarNT[dx][0]- BASE_RULE, &matrix[jx][ix]);
                        }
                }
            }
        }
    }
    
    if(getValue(INITIAL_RULE-BASE_RULE, matrix[1][n-1])) 
    {
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
solveProblem() 
{

    int computedSequences = 0;
    if(nTerminals == 0 || Nsequences == 0) 
    {
        return;
    }

    while(computedSequences < Nsequences) 
    {
        cykAlgorithm(computedSequences);
        computedSequences++;
    }
}

/**
 * Main Function
 */
int main(void) 
{
    readRules();
    readSequences();
    solveProblem();
    return 0;
}
