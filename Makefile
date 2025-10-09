numconv: numconv.o
	ld -o numconv numconv.o

numconv.o: numconv.s
	gcc -ggdb -c numconv.s

.PHONY: clean
clean:
	rm -vf numconv.o numconv
