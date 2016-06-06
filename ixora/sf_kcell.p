/* sf_kcell.p
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/*
if not connected("ib") then do:
find sysc where sysc.sysc = "IBHOST" no-lock no-error.
if not avail sysc or sysc.chval = "" then do :
   message "Невозможно подключиться к БД Internet-Office.  Нет IBHOST записи в SYSC файле".
   return.
end.

connect value(sysc.chval) no-error.
end.
if not connected("ib") then do: message "Connection lost...". pause. return. end.

*/
                
def var vrnn as char.
def var vname as char.
def var vphone as char format "x(8)".
def var sm as decimal init 0.

def frame sf
    vrnn skip
    vname skip
    vphone
    with side-labels centered overlay view-as dialog-box title "Номера K-CELL".
 
def frame sfdet
    k-cell.phone label "Номер" skip
    k-cell.name[1] label "Имя" skip
    k-cell.rnn label "РНН" skip
    k-cell.amt label "Сумма"
    with side-labels row 2 centered overlay view-as dialog-box
    title "Детали".

DEFINE QUERY q1 FOR k-cell.

def browse b1 
    query q1 no-lock
    display 
        rnn label "РНН" 
        name[1] label "FIO"
        phone label "Телефон"
        with 14 down title "Номера K-CELL".

def frame fr1 
    b1
    with centered overlay view-as dialog-box.
    
on return of b1 in frame fr1
    do: 
        apply "endkey" to frame fr1.
    end.  

on "enter" of browse b1
do:
   disp 
   k-cell.phone k-cell.name[1] k-cell.rnn k-cell.amt
   with frame sfdet.
   hide frame sfdet.
end.   
     
update
vrnn format "999999999999" label "РНН"
vname format "x(40)" label "Фамилия"
vphone format "x(8)" label "Телефон"
WITH side-labels 1 column row 8 FRAME sf.
hide frame sf.

vname = caps(trim(vname)).
vphone = caps(trim(vphone)).

def var nlen as integer.
nlen = length(vname).

if vrnn="" then 
open query q1 for each k-cell 
where 
    (vname="" or caps(name[1] + name[2] + name[3] + name[4]) 
     matches ("*" + vname + "*"))
and (vphone = "" or phone = vphone) 
and (phone <> "")
and (name[1] + name[2] + name[3] + name[4] <> "")
use-index phone no-lock.
else
open query q1 for each k-cell where rnn=vrnn 
and (vname="" or caps(name[1] + name[2] + name[3] + name[4])
     matches ("*" + vname + "*"))
and (vphone = "" or phone = vphone)
and (phone <> "") 
and (name[1] + name[2] + name[3] + name[4] <> "")
use-index phone no-lock.

if num-results("q1")=0 then
do:
    MESSAGE "Записи не найдены."
          VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
                 TITLE "Не найден номер K-CELL".
    return.                 
end.

b1:SET-REPOSITIONED-ROW (14, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

hide frame fr1.
/*
disconnect 'ib'.
*/
return .

