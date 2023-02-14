#Вспомогательный Makefile. Вызывает основной Makefile из родительской директории
# с теми же ключами
all:
	 $(MAKE) -C  ../ all START_D=src_rus
clean:
	 $(MAKE) -C ../ clean
test:
	 $(MAKE) -C ../ test START_D=src_rus
run:
	 $(MAKE) -C ../ run
reserve:
	 $(MAKE) -C ../ reserve
	
.PHONY: all clean run reserve



