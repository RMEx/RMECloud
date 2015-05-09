# Directories
BIN = beam
SRC = src
INC = include
OTH = asset
LOG = log

.PHONY: all clean

# Alias
all: run

# Module to compile
DEP_A = uri.beam util.beam template.beam layout.beam app.beam
DEP_B = crypter.beam initialize.beam
DEPENDANCIES = $(DEP_A) $(DEP_B)

# Compilers
%.beam : src/%.erl
	erlc -o $(BIN) -I $(INC) $(<) 

# Yaws runner
run: compile
	yaws --conf yaws.conf

# Precise compilation
compile: $(DEPENDANCIES)

# Clean routines
clean: clean-temp clean-binaries clean-log

clean-temp:
	rm -rf *~
	rm -rf */*~
	rm -rf */*/*~
	rm -rf \#*
	rm -rf */\#*
	rm -rf */*/\#*

clean-binaries:
	rm -rf $(BIN)/*beam

clean-log:
	rm -rf $(LOG)/*
