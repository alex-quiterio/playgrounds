CC=gcc
CFLAGS=-c -Wall
LDFLAGS=
SOURCES=main.c List.c
OBJECTS=$(SOURCES:.c=.o)
EXECUTABLE=TestList

all: $(SOURCES) $(EXECUTABLE)
	
$(EXECUTABLE): $(OBJECTS) 
	$(CC) $(LDFLAGS) $(OBJECTS) -o $@

.c.o:
	$(CC) $(CFLAGS) $< -o $@
	
clean:			
	rm -f *.o *~ $(EXECUTABLE)
