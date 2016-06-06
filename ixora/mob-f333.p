/* mob-f333.p
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


{yes-no.i}

def input parameter v-phone as char init "".

DEFINE QUERY q1 FOR k-mobile.

def browse b1 
    query q1 no-lock 
    display
        k-mobile.dates format "99.99.9999"
        k-mobile.bill 
        k-mobile.name[1] format "x(30)"
        k-mobile.amt     format ">>>,>>9.99"
        with 14 down title "Неоплаченные счета за телефон " + v-phone.

def frame f1 
    b1.

on return of b1
    do: 
       apply "endkey" to frame f1.
    end.   
     
open query q1 for each k-mobile where k-mobile.phone = v-phone and k-mobile.paydate = ? .

if num-results("q1")=0 then
do:
/*    MESSAGE "Записи не найдены." VIEW-AS ALERT-BOX INFORMATION BUTTONS ok TITLE "Нет информации".*/
    return "".
end.
                 
ENABLE all WITH centered FRAME f1.
b1:SET-REPOSITIONED-ROW(14, "CONDITIONAL") no-error.
APPLY "VALUE-CHANGED" TO BROWSE b1.
WAIT-FOR endkey OF frame f1.

hide frame f1.

return string(rowid(k-mobile)).

