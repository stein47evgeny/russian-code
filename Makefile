


# Название выходной программы без  .exe
TARGET = proba

# Имена файлов-исходников С/С++ !пока не реализовано
SRC_C_DIR = src_c/
# Папка файлов-исходников R++
SRC_RUS_DIR = src_rus/

# Папка сборки. Внимание все файлы внутри автоматически удаляются!
BIN_DIR = bin/
# Папка для .o файлов
OBJDIR = $(BIN_DIR)obj/
# Папка для временных си-файлов, которые будут компилироваться
SRCDIR = .src/

#NAME_LIST = $(RPP_DIR)list

VPATH := $(SRC_C_DIR) $(SRCDIR)

# Название выходного файла Windows
#OUT = $(TARGET).exe
# Название выходного файла
OUT = $(TARGET)
#Путь для sed, с символом экранирования слэша
START_DIR = src_rus\/
#	ifeq ($(START_D), src_rus)
#		START_DIR =
#	else
#		START_DIR = src_rus\/
#	endif
# Перечень файлов-исходников R++ с путем
# заполняется автоматически (в папке не должно быть "лишних" файлов)
#SOURCES_C :=$(wildcard $(SOURCES_C_DIR)*.c)
SOURCES_RUS := $(wildcard   $(SRC_RUS_DIR)*.r) $(wildcard   $(SRC_RUS_DIR)*.rpp)
HEADER_RUS :=  $(wildcard   $(SRC_RUS_DIR)*.rh)
# Перечень файлов-исходников C/C++ с путем
# заполняется автоматически (в папке не должно быть "лишних" файлов)
SOURCES_C :=   $(wildcard   $(SRC_C_DIR)*.c) $(wildcard $(SRC_C_DIR)*.cpp) 
HEADER_C := $(wildcard $(SRC_C_DIR)*.h) $(wildcard $(SRC_C_DIR)*.hpp)
# Имена исходников без путей
HEADER := $(patsubst   %.rh,%.h, $(notdir $(HEADER_RUS)))
#SOURCES := $(patsubst   %.r,%.c, $(R) ) $(patsubst   %.rpp,%.cpp, $(RPP) )
SOURCES := $(notdir $(SOURCES_RUS)) 
SOURCES := $(SOURCES:.rpp=.cpp)
SOURCES := $(SOURCES:.r=.c)

#SOURCES += $(SOURCES_RUS:%.r=$(SRCDIR)%.c)

# Выходной формат. (can be srec, ihex, binary)
FORMAT = ihex

# Перечень объектных файлов без пути
OBJECTS :=   $(SOURCES) $(notdir $(SOURCES_C)) 
OBJECTS := $(OBJECTS:.cpp=.o)
OBJECTS := $(OBJECTS:.c=.o)
# Перечень временных си-файлов, заголовочных файлов которые будут компилироваться
TEMP_SRC = $(SOURCES:%=$(SRCDIR)%)
TEMP_HDR = $(HEADER:%.h=$(SRCDIR)%.h)
#SOURCES +=  $(notdir $(SOURCES_C))

# Перечень объектных файлов с путем
#TEMP_OBJ = $(OBJECTS:%.o=$(OBJDIR)%.o)  
test:
	@echo $(SOURCES)
	@echo $(OBJECTS)
	@echo $(SOURCES_C)
	@echo $(START_DIR)

	@echo $(TEMP_SRC)


# Флаг создания файла зависимостей
GENDEPFLAGS = -MD -MF $(BIN_DIR).dep/$(@F).d


CFLAGS=-c -Os -Wall $(GENDEPFLAGS)
#CFLAGS += -static -static-libgcc
#LDFLAGS=-s -Wl,-subsystem,console
LDFLAGS=

# Компилятор
#CC=gcc
CC=gcc

# Вспомогательные программы
OBJCOPY = objcopy
OBJDUMP = objdump
SIZE = size
AR = ar rcs
NM = nm
REMOVE = rm -f
REMOVEDIR = rm -rf
COPY = cp
WINSHELL = cmd
# Команда запуска для Windows
#RUN_COMAND = start $(OUT)
# Команда запуска
RUN_COMAND = konsole -e "bash -c \"./$(OUT); exec bash\""


MSG_BEGIN = -------- Начало ---------
MSG_END =   ------ Завершение -------
MSG_SIZE_BEFORE = Размер программы до: 
MSG_SIZE_AFTER = Размер программы после:
MSG_LINKING = Сборка:
MSG_COMPILING = Компиляция C:
MSG_COMPILING_CPP = Компиляция C/C++:
MSG_DECODE_RUS = Русский в C/C++:

#all: begin  build  
all: begin sizebefore build sizeafter 

#Разный выпендреж
# begin sizebefore sizeafter sizeafter можно убрать
begin:
	@echo
	@echo $(MSG_BEGIN)

end:
	@echo $(MSG_END)
	@echo

EXE_SIZE = $(SIZE) --target=$(FORMAT) $(OUT)

sizebefore:
	@if test -f $(OUT); then echo; echo $(MSG_SIZE_BEFORE); $(EXE_SIZE); \
	2>/dev/null; echo; fi

sizeafter:
	@if test -f $(OUT); then echo; echo $(MSG_SIZE_AFTER); $(EXE_SIZE); \
	2>/dev/null; echo; fi

#Основная последовательность
build: $(TEMP_HDR)  $(TEMP_SRC)   $(OUT)


copy:
	cp $(SOURCES_C) $(SRCDIR) 
	cp $(HEADER_C) $(SRCDIR) 
#Сборка
$(OUT):    $(OBJECTS)
	@echo
	@echo $(MSG_LINKING) $(OUT)
	$(CC) $(LDFLAGS) -o $@ $(OBJECTS:%.o=$(OBJDIR)%.o)
	
#Перекодировка из .r в .c	
$(SRCDIR)%.c : $(SRC_RUS_DIR)%.r
	@echo
	@echo $(MSG_DECODE_RUS) 
	sed '1s/^/#line 1 "$(START_DIR)$(notdir $<)"\n/' $< |  sed -E -f ru-to-c > $@

#Перекодировка из .rpp в .cpp	
$(SRCDIR)%.cpp : $(SRC_RUS_DIR)%.rpp
	@echo
	@echo $(MSG_DECODE_RUS) 
	@echo "sed '1s/^/#line 1 "$(START_DIR)$(notdir $<)"\n/' $< | sed -f ru-to-c > $@"

#Перекодировка из .rh в .h	
$(SRCDIR)%.h : $(SRC_RUS_DIR)%.rh
	@echo
	@echo $(MSG_DECODE_RUS) 
	sed '1s/^/#line 1 "$(START_DIR)$(notdir $<)"\n/' $< | sed -f ru-to-c > $@

#Компиляция в объектные файлы	
#$(OBJDIR)%.o : $(SRCDIR)%.c
%.o : %.c
	@echo 
	@echo $(MSG_COMPILING_CPP) $<
	$(CC) $(CFLAGS)  -o  $(OBJDIR)$@ $<

		
%.o : %.cpp 
	@echo 
	@echo $(MSG_COMPILING_CPP) $<
	$(CC) $(CFLAGS)  -o  $(OBJDIR)$@ $<
	
run:	all
#	gnome-terminal --command "bash -c \"./$(RUN_COMAND); exec bash\""
#	konsole -e "bash -c \"./$(RUN_COMAND); exec bash\""
#	bash -c ./$(RUN_COMAND)
	$(RUN_COMAND)
#Очистка временных папок
clean:
	$(RM) $(wildcard $(SRCDIR)*)  $(wildcard $(OBJDIR)*) \
	$(wildcard $(BIN_DIR).dep/*)  $(OUT)

СТАРТ =

$(shell mkdir $(BIN_DIR) 2>/dev/null)
$(shell mkdir $(OBJDIR) 2>/dev/null)
$(shell mkdir $(SRCDIR) 2>/dev/null)
-include $(shell mkdir $(BIN_DIR).dep 2>/dev/null) $(wildcard $(BIN_DIR).dep/*)
#-include $(shell mkdir .src 2>/dev/null) $(wildcard .src/*)

# создаем резервную копию проекта
reserve: clean
	@echo $(MSG_RESERVE)
	cp -a ./. $$(pwd)$$(date +_%d%h%y_%H%M)
	@echo Резервная копия создана: $$(pwd)$$(date +_%d%h%y)


NEW_DIR =	$(shell pwd )/../new$(shell date +_%d%h%y)/
new:	clean
	@echo $(MSG_RESERVE)
	@echo Путь: $(NEW_DIR)
	cp -a ./. $(NEW_DIR)
#	$(RM) $(wildcard $(NEW_DIR)$(SRC_RUS_DIR)*.r) $(wildcard $(NEW_DIR)$(SRC_RUS_DIR)*.rpp) \
#	$(wildcard $(NEW_DIR)$(SRC_RUS_DIR)*.rh) $(wildcard $(NEW_DIR)$(SRC_C_DIR)*.c) \
#	$(wildcard $(NEW_DIR)$(SRC_C_DIR)*.cpp) $(wildcard $(NEW_DIR)$(SRC_C_DIR)*.h)
#S	@echo Резервная копия создана: $$(pwd)$$(date +_%d%h%y)

.PHONY: all build clean reserve run test



