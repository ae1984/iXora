/* dirarc.p
 * MODULE
        Прямые корр. отношения
 * DESCRIPTION
        Архивация программ по загружаемым MT100
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
       03/28/2005 kanat
 * CHANGES
       01/04/2005 kanat - добавил команды пересылки файлов.
       13/04/2005 kanat - добавил копирование 
       24/05/2005 kanat - добавил обработку файлов по их расширениям, которые берутся из настроек банков
       07/06/2005 kanat - добавил дополнительное условие - если пользователь хочет прервать операцию
       10/06/2005 kanat - добавил очередность выполнения команд
*/

{global.i}

define variable v-result1 as char.
define variable v-bta-ip as character init "bta".
define variable v-bta-path as character init "/home/pc/branch/in/".

define variable v-unibank as char.
define temp-table cms-direct like direct_bank.

define stream str1.
define stream str2.
define stream str3.

run direct_select.
v-unibank = return-value.

if v-unibank = "" then
return.

     MESSAGE "Произвести перенос файлов платежей ?"
     VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
     TITLE "" UPDATE choice1 as logical.
     if not choice1 then return.

find first direct_bank where direct_bank.bank1 = v-unibank no-lock no-error.
if avail direct_bank then do:

input stream str1 through value("rsh NTMAIN mkdir " + replace(direct_bank.aux_string[2],"/","\\\\") + string(day(g-today), "99") + string(month(g-today), "99") + string(year(g-today)) + "; ") no-echo.
input stream str2 through value("rsh NTMAIN move "  + replace(direct_bank.aux_string[2],"/","\\\\") + "*" + trim(direct_bank.ext[1]) + " " + replace(direct_bank.aux_string[2],"/","\\\\") + string(day(g-today), "99") + string(month(g-today), "99") + string(year(g-today)) + "; ") no-echo.
input stream str3 through value("rsh NTMAIN move "  + replace(direct_bank.aux_string[2],"/","\\\\") + "*" + trim(direct_bank.ext[2]) + " " + replace(direct_bank.aux_string[2],"/","\\\\") + string(day(g-today), "99") + string(month(g-today), "99") + string(year(g-today)) + "; ") no-echo.

input stream str1 through value("rsh NTMAIN mkdir " + replace(direct_bank.aux_string[4],"/","\\\\") + string(day(g-today), "99") + string(month(g-today), "99") + string(year(g-today))) no-echo.
input stream str2 through value("rsh NTMAIN move "  + replace(direct_bank.aux_string[4],"/","\\\\") + "*" + trim(direct_bank.ext[1]) + " " + replace(direct_bank.aux_string[4],"/","\\\\") + string(day(g-today), "99") + string(month(g-today), "99") + string(year(g-today)) + "; ") no-echo.
input stream str2 through value("rsh NTMAIN move "  + replace(direct_bank.aux_string[4],"/","\\\\") + "*" + trim(direct_bank.ext[2]) + " " + replace(direct_bank.aux_string[4],"/","\\\\") + string(day(g-today), "99") + string(month(g-today), "99") + string(year(g-today)) + "; ") no-echo.

/*
unix silent value("rsh NTMAIN mkdir " + replace(direct_bank.aux_string[2],"/","\\\\") + string(day(g-today), "99") + string(month(g-today), "99") + string(year(g-today))).
unix silent value("rsh NTMAIN move "  + replace(direct_bank.aux_string[2],"/","\\\\") + "*.970 " +  replace(direct_bank.aux_string[2],"/","\\\\") + string(day(g-today), "99") + string(month(g-today), "99") + string(year(g-today))).
unix silent value("rsh NTMAIN move "  + replace(direct_bank.aux_string[2],"/","\\\\") + "*.exp " +  replace(direct_bank.aux_string[2],"/","\\\\") + string(day(g-today), "99") + string(month(g-today), "99") + string(year(g-today))).
*/

if v-unibank = "190501319" then do:
input through value ("rsh " + v-bta-ip + " rm -f " + v-bta-path + "*.*" + ";echo $?"). 
repeat:
  import v-result1.
end.
if integer(v-result1) <> 0 then do:
message "Произошла ошибка при удалении файлов со СПЭД" view-as alert-box title "Внимание".
return.
end.
end.
end.

pause 3.

message "Перенос файлов завершен" view-as alert-box title "Внимание".


procedure direct_select.
for each cms-direct:
delete cms-direct.
end.
  
for each direct_bank no-lock:
    do transaction on error undo, next:
        create cms-direct.
        buffer-copy direct_bank to cms-direct.
    end.
end.
        
define query q1 for cms-direct.
define browse b1 
    query q1 no-lock
    display 
        cms-direct.bank1 label "БИК" format "x(10)" 
        cms-direct.bank2 label "Корр. счет" format "x(10)" 
        cms-direct.aux_string[1] label  "Наименование" format 'x(50)'
        with 10 down title "Список банков".
                                         
define frame fr1 
    b1
    with no-labels centered overlay view-as dialog-box.  
on return of b1 in frame fr1
    do: 
        apply "endkey" to frame fr1.
    end.  
                    
open query q1 for each cms-direct.
if num-results("q1") = 0 then
do:
    MESSAGE "Справочник пуст ?!"
    VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
    TITLE "Внимание".
    return.                 
end.

b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

hide frame fr1.
return cms-direct.bank1.
end.

