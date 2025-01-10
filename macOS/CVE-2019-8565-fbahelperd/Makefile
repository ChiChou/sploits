SRC = exploit.m
OUTPUT = bin/exploit

.PHONY: exec

exec: $(SRC)
	@mkdir -p bin
	clang $(SRC) -framework Foundation -o $(OUTPUT)

run: exec
	$(OUTPUT)

format:
	clang-format -i $(SRC)
