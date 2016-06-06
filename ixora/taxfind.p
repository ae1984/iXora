/* taxfind.p
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
        24/04/06 u00568 Evgeniy - в getfromrnn.i функция getfioadr() - возвращает адрес и фио из таблицы рнн

*/

{getfromrnn.i}

def var vrnn as char.
def var vlname as char.
def var vfname as char.
def var vmname as char.
def var sm as decimal init 0.

def frame sf
    vrnn skip
    vlname skip
    vfname skip
    vmname
    with side-labels centered overlay view-as dialog-box.

DEFINE QUERY q1 FOR comm.rnn.

def browse b1
    query q1 no-lock
    display
        rnn.trn label "РНН"
        getfio() format "x(30)"  label "ФИО"
        getadr() format "x(28)"  label "Адрес"
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
vlname format "x(35)" label "Фамилия"
vfname format "x(20)" label "Имя"
vmname format "x(20)" label "Отчество"
WITH side-labels 1 column  FRAME sf.
hide frame sf.

vlname = caps(trim(vlname)).
vfname = caps(trim(vfname)).
vmname = caps(trim(vmname)).
def var llen as integer.
def var flen as integer.
def var mlen as integer.
llen = length(vlname).
flen = length(vfname).
mlen = length(vmname).

if vrnn="" then
open query q1 for each comm.rnn where
(vlname="" or caps(substr(lname, 1, llen)) = caps(vlname))
and (vfname="" or caps(substr(fname, 1, flen)) = caps(vfname))
and (vmname="" or caps(substr(mname, 1, mlen)) = caps(vmname))
use-index rnn no-lock.
else
open query q1 for each comm.rnn where rnn.trn=vrnn
and  (vlname="" or caps(substr(lname, 1, llen)) = caps(vlname))
and (vfname="" or caps(substr(fname, 1, flen)) = caps(vfname))
and (vmname="" or caps(substr(mname, 1, mlen)) = caps(vmname))
use-index rnn no-lock.

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
return rnn.trn.
