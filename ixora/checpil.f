/* checpil.f
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/*checpil.f*/

form
c-non format ">>>>>>>999" label "С #" colon 8 c-lid format ">>>>>>>999" label "ПО #" colon 30
c-cek label "ЦЕНА" format "zzzz9.99" colon 50 skip
"-------------------Клиент--------------------------" skip
c-cif label "КЛИЕНТ" colon 8
cif.sname format "x(40)" colon 10 label "НАИМЕНОВ." skip(1)
"----------------Регистрация------------------------" skip
c-whi colon 8 label "ИСПОЛН." c-ien colon 30 label "ДАТА" skip(1)
"------------------Признак--------------------------" skip
c-izm colon 8 label "Использ"
c-anu colon 42 label "Аннулир." skip
c-wha colon 8 label "ИСПОЛН." c-dat colon 30 label "ДАТА" skip
checks.jh colon 8 label "TRX#" skip
with side-label row 8 width 65 frame checpil.

form
c-non format ">>>>>>>999" label "С #" colon 8 c-lid format ">>>>>>>999" label "ПО #" colon 30
c-cek label "ЦЕНА" format "zzzz9.99" colon 50 skip
"------------------Клиент---------------------------" skip
c-cif format "x(30)" label "КЛИЕНТ" colon 8 skip
"----------------Регистрация------------------------" skip
c-whi colon 8 label "ИСПОЛН." c-ien colon 30 label "ДАТА " skip(1)
"------------------Признак--------------------------" skip
c-izm colon 8 label "Использ"
c-anu colon 42 label "Аннулир." skip
c-wha colon 8 label "ИСПОЛН." c-dat colon 30 label "ДАТА "
with side-label row 8 width 65 frame checpol.

