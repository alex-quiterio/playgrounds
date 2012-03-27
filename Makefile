CC=gcc
CFLAGS=-c -Wall
LDFLAGS=
SOURCES=main.c List.c
OBJECTS=$(SOURCES:.c=.o)
EXECUTABLE=TestList

all: $(SOURCES) $(EXECUTABLE)
	
$(EXECUTABLE): $(OBJECTS) 
	$(CC) $(LDFLAGS) $(OBJECTS) -o $@

.cpp.o:
	$(CC) $(CFLAGS) $< -o $@
