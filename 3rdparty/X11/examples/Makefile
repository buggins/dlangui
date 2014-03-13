DC = dmd -c $(INCS)
DLINK = dmd $(LIBS)

INCS = -I..
LIBS = -L-lX11

RM = rm

%.o: %.d 
	 $(DC) $(<)

all: simple

simple: simple.o
	$(DLINK) $<

clean:
	$(RM) *.o simple

