BIN = bin
OBJ = obj
GEN = gen

HDRS = injector.h
SRCS = injector.c

TEST = $(SRCS) test.c

CC=clang

LDFLAGS := -g -mmacosx-version-min=10.12
CFLAGS := -g -mmacosx-version-min=10.12 -I. 

SHELLCODE_SRCS = shellcode.c
SHELLCODE_CFLAGS = \
	-Wno-implicit-function-declaration \
	-fno-stack-protector \
	-fPIC

test: sc $(HDRS) $(SRCS) 
	$(CC) $(CFLAGS) $(LDFLAGS) $(TEST) \
		-o $(BIN)/inj

prepare:
	@mkdir -p $(BIN) $(GEN) $(OBJ)

sc: prepare $(SHELLCODE_SRCS)
	$(CC) -c $(SHELLCODE_CFLAGS) $(SHELLCODE_SRCS) -o $(OBJ)/$@.o
	gobjcopy -Obinary $(OBJ)/$@.o -j .text $(BIN)/$@
	@mkdir -p $(GEN)

	cd $(BIN) && xxd -i sc > ../$(GEN)/$@.h
	nm $(OBJ)/$@.o | python offsets.py > $(GEN)/offsets.h

clean:
	rm -rf $(BIN)/* $(GEN)/* $(OBJ)/*

format:
	clang-format -i $(TEST) $(HDRS) $(SHELLCODE_SRCS)