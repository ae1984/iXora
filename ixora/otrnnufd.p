/* otrnnufd.p
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
        16/03/04 kanat
 * CHANGES
*/

def var vrnn as char.
def var vbusname as char.
def var sm as decimal init 0.

def frame sf
    vrnn skip
    vbusname skip     
    with side-labels centered overlay view-as dialog-box.

DEFINE QUERY q1 FOR comm.rnnu.

def browse b1 
    query q1 no-lock
    display 
        comm.rnnu.trn label "РНН" 
        trim(comm.rnnu.busname) format "x(40)" label "Наименование"
        with 14 down title "RNN".

def frame fr1 
    b1
    with centered overlay view-as dialog-box.
    
on return of b1 in frame fr1
    do: 
        apply "endkey" to frame fr1.
    end.  
                    
     
update
vrnn format "999999999999" label "РНН"
vbusname format "x(40)" label "Наименование"
WITH side-labels 1 column  FRAME sf.
hide frame sf.

vbusname = caps(trim(vbusname)).

def var llen as integer.
llen = length(vbusname).

if vrnn = "" then 
open query q1 for each comm.rnnu where (vbusname = "" or caps(substr(comm.rnnu.busname, 1, llen)) = caps(vbusname))  
use-index rnn no-lock.
else
open query q1 for each comm.rnnu where comm.rnnu.trn = vrnn 
and  (vbusname = "" or caps(substr(comm.rnnu.busname, 1, llen)) = caps(vbusname))   
use-index rnn no-lock.

if num-results("q1") = 0 then
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
return trn.

