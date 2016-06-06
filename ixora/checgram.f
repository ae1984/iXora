/* checgram.f
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

/* checgram.f
14.07.95
*/

form
s-cif label "КЛИЕНТ" colon 12 skip  g-today label "ДАТА"colon 50 skip
cif.sname colon 12 label "ИМЯ КЛИЕНТА" skip(1)
casne colon 12 label "КАССА/НЕТ" skip (1)
s-aaa colon 12 label "СЧЕТ" skip(1)
"---------------------Валюта------------------------------" skip
s-crc colon 12 label "КОД" crc.code label "НАЗВАНИЕ" colon 42 skip(1)
s-non colon 12 label "С #"
s-lid colon 27 label "ПО #" v-ser colon 43 label "Серия"  skip(1)
"---------------Оплата чековых книжек---------------------" skip
coco colon 12 label "ЦЕНА" koko colon 28 label "ВАЛЮТА" skip
with side-label row 4 width 65 frame checgram.
