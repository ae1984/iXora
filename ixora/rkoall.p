/* rkoall.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Процедура выбора СПФ из вертикального меню
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        txsdpp.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        19/12/03 kanat
 * CHANGES
*/

{comm-txb.i}

define temp-table temp_ppoint like ppoint.

DEFINE QUERY q1 FOR temp_ppoint.

def var ourbank as char.
ourbank = comm-txb().

for each ppoint no-lock break by ppoint.depart:
    if first-of(ppoint.depart) then do:
        create temp_ppoint.
        buffer-copy ppoint to temp_ppoint.
    end.    
end.

def browse b1 
     query q1 no-lock
     displ temp_ppoint.depart label "Код" format '>>>9'
           temp_ppoint.name   label "Наименование" format 'x(45)' with 13 down title "Список структурных подразделений".

def frame fr1 
     b1 with centered overlay view-as dialog-box.

on return of b1 in frame fr1 do:
     apply "endkey" to frame fr1. 
end.  

open query q1 for each temp_ppoint no-lock.

if num-results("q1") = 0 then
do:
     MESSAGE "1:Записи не найдены." VIEW-AS ALERT-BOX INFORMATION BUTTONS ok TITLE "Не найдено структурное подразделение".
     return.                 
end.

b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

hide frame fr1.

return string(temp_ppoint.depart).
