
#ifndef  RU_STDIO_H
#define    RU_STDIO_H
#include    <stdio.h>
//Стандартные потоки
#define стдвх stdin
#define стдвых stdout
#define стдош stderr
//Функция вывода printf
#define пчтф(format, args...)  \
       printf (format , ## args)

#define    пчтс(x) puts((x))						// печатать строку
#define    пчтз(x) putchar((x))						// печатать символ
#define    читс(x) gets((x))						// читать строку
#define    читз() getchar()						// читать символ


#endif // RU_STDIO_H
