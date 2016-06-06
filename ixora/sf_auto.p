/* sf_auto.p
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


/* РНН для автомобилей */

def var vrnn as char.
def var vmodel as char.
def var vnumber as char. 
def var sm as decimal init 0.

def frame sf
    vrnn skip
    vmodel skip
    vnumber
    with side-labels centered overlay view-as dialog-box
    title "Автомобили".

def frame sfdet
    taxauto.rnn label "РНН" skip
    taxauto.model label "Модель" skip
    taxauto.number label "Номер" skip
    with side-labels row 2 centered overlay view-as dialog-box
    title "Детали".

DEFINE QUERY q1 FOR taxauto.

def browse b1 
    query q1 no-lock
    display 
        rnn label "РНН" 
        model label "Модель"
        number label "Номер"
        with 14 down title "Автомобили".

def frame fr1 
    b1
    with centered overlay view-as dialog-box.
    
on return of b1 in frame fr1
    do: 
        apply "endkey" to frame fr1.
    end.  
    
                    
update
vrnn format "999999999999" label "РНН" help " "
vmodel format "x(40)" label "Модель"
       help "----- Можете использовать шаблон -----"
vnumber  format "x(9)" label "Номер"
       help "----- Можете использовать шаблон -----"
WITH side-labels 1 column row 5 FRAME sf.
hide frame sf.

vmodel = caps(trim(vmodel)).
vnumber = caps(trim(vnumber)).
def var mlen as integer.
def var nlen as integer.
mlen = length(vmodel).
nlen = length(vnumber).

on "enter" of browse b1
do:
    disp taxauto.rnn taxauto.model taxauto.number
    with frame sfdet.
    hide frame sfdet.
end.

if vrnn="" then 
open query q1 for each taxauto where 
     (vmodel=""
     or caps(substr(model, 1, mlen)) = vmodel
     or caps(model) matches  ("*" + vmodel + "*"))
and (vnumber="" or caps(substr(number, 1, nlen)) = vnumber
     or caps(number) matches ("*" + vnumber + "*"))
use-index nk no-lock.
else
open query q1 for each taxauto where rnn=vrnn 
and (vmodel="" 
     or caps(substr(model, 1, mlen)) = vmodel
     or caps(model) matches  ("*" + vmodel + "*"))
and (vnumber="" or caps(substr(number, 1, nlen)) = vnumber)
use-index nk no-lock.

if num-results("q1")=0 then
do:
    MESSAGE "Записи не найдены."
          VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
                 TITLE "Не найден РНН".
    return.                 
end.

b1:SET-REPOSITIONED-ROW (14, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

hide frame fr1.
return rnn.

