﻿/* jat0.f
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

repeat :
display "Дата ...   с " v-dbeg format "99/99/9999"
"  по " v-dend format "99/99/9999" with frame cc row 14
column 30 no-label no-box.
update   v-dbeg v-dend with frame cc.
if v-dbeg <= v-dend and v-dend <= g-today then leave.
end.
/*
update "Klienta grupa " v-cgr  with centered row 16 no-label no-box frame ll.

v-cgr validate(s-type = "b" or s-type = "p" or s-type = "m"
                       or s-type = "n" or s-type = "x" or s-type = " ","")
       label "Klienta tips"
       help "B-juridiskie, P-fiziskie, M-municip–lie, N-bezpёµ‡as, X-kodёtie"
       with centered row 16 side-label no-box frame ll.
*/
