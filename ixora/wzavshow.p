/* wzavshow.p
 * MODULE
        Кассовый модуль
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
 * AUTHOR
        23.08.2004 tsoy
 * CHANGES
*/


define var remark as char.
define var remark2 as char.
define var remarkwho like ofc.name.
define var remarkofc like ofc.name.
define var varofc like ofc.ofc label "Кассир".
define shared variable g-today as date.

define frame zsh
           remarkofc label "КОМУ" at 6
           remarkwho label "KTO" at 7
           cwayofc.whn label "КОГДА" at 5
           remark2 label "ВАЛЮТА" at 4
           cwayofc.amt label "СУММА" at 5
           remark  format "x(20)" label "ОПИСАНИЕ" at 2
       with row 7 centered side-labels overlay.
       
update varofc with centered row 8.
find ofc where ofc.ofc eq varofc no-error.
if not avail ofc then do: message "NO SUCH OFFICER!". return. end.

for each cwayofc where whn eq g-today and ofc eq varofc by crc by sts:
    case cwayofc.sts:
       when 1 then remark = "ABAHC".
       when 2 then remark = "ТЕКУЩЕЕ СОСТОЯНИЕ".
       when 3 then remark = "ПОДКРЕПЛЕНИЕ".
       when 4 then remark = "ВОЗВРАТ ДЕНЕГ".
    end case.
    find crc where crc.crc eq cwayofc.crc no-lock no-error.
    if avail crc then 
       remark2 = crc.code.
    find ofc where ofc.ofc eq cwayofc.who no-lock no-error.
            if avail ofc then remarkwho = ofc.name.
    find ofc where ofc.ofc eq cwayofc.ofc no-lock no-error.
            if avail ofc then remarkofc = ofc.name.
                    
    displ cwayofc.whn cwayofc.amt
           with frame zsh. 
    displ remarkwho with frame zsh.
    displ remarkofc with frame zsh.
    displ remark2 with frame zsh.
    displ remark with frame zsh.
 end.
