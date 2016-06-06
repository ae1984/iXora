/* sf_alma.p
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


/* Поиск РНН для ALMA TV - по адресу */

def var vaddr as char.
def var vflat as char.
def var vhouse as char.
def var vfname as char.
def var vmname as char.
def var vlname as char.
def var sm as decimal init 0.

def frame sf
    vlname skip
    vfname skip
    vmname skip
    vaddr skip
    vhouse skip
    vflat skip
    with side-labels centered overlay row 6 view-as dialog-box
    title "Клиенты ALMATV".

def frame sfdet
    almatv.f label "     Фамилия" almatv.io label "Имя,отчество" skip
    almatv.address label "       Адрес" skip
    almatv.house label   "         Дом"
    almatv.flat label "Кв."
    skip
    almatv.summ label    "       Сумма" skip
    with side-labels row 2 centered overlay view-as dialog-box
    title "Детали".

DEFINE QUERY q1 FOR almatv.

def browse b1 
    query q1 no-lock
    display 
        almatv.f format "x(14)" label "Фамилия"
        io format "x(20)" label "Имя,отчество"
        address format "x(15)" label "Адрес" 
        house label "Дом"
        flat label "Кв."
        with 14 down title "ALMATV".

def frame fr1 
    b1
    with centered overlay view-as dialog-box.
    
on return of b1 in frame fr1
    do: 
        apply "endkey" to frame fr1.
    end.  
    
                    
update
vlname format "x(35)" label "Фамилия" 
 help "----- Можете использовать шаблон -----"
vfname format "x(15)" label "Имя"
 help "----- Можете использовать шаблон -----"
vmname format "x(15)" label "Отчество"
 help "----- Можете использовать шаблон -----"
vaddr  format "x(40)" label "Адрес"
 help "----- Можете использовать шаблон -----"
vhouse format "x(9)"  label "Дом"
 help " "
vflat  format "x(9)"  label "Кв."
 help " "
WITH side-labels 1 column  FRAME sf.
hide frame sf.

vfname = caps(trim(vfname)). 
vmname = caps (trim(vmname)).
vlname = caps (trim(vlname)).
vaddr = caps (trim(vaddr)).
vflat = caps (trim(vflat)).                          
vhouse = caps (trim(vhouse)).

def var flen as integer.
def var mlen as integer.
def var llen as integer.
def var alen as integer.
def var hlen as integer.
def var fllen as integer.

flen = length(vfname).
mlen = length(vmname).
llen = length(vlname).
alen = length(vaddr).
hlen = length(vhouse).
fllen = length(vflat).

on "enter" of browse b1
do:
    disp almatv.f 
         almatv.io
         almatv.address almatv.house almatv.flat
         almatv.summ with frame sfdet.
    hide frame sfdet.
end.

open query q1 for each almatv where 
    (vaddr="" or (caps(substr(address, 1, alen)) = vaddr)
    or caps(address) matches ("*" + vaddr + "*")
    )
and 
  (
   (  (vflat="" or caps(substr(flat, 1, fllen)) = vflat)
       and
      (vhouse="" or caps(substr(house, 1, hlen)) = caps(vhouse))
   )  
      or address matches ("*" + vhouse + "*" + vflat + "*")
  ) 
and(  /* FIO processing */
      (vlname="" or caps(substr(almatv.f, 1, llen)) = vlname
       or caps(io + " & " + almatv.f) matches ("*" + vlname + "*")
      ) /* surname */
and
      (vfname="" or caps(substr(io, 1, llen)) = vfname
       or caps(io) matches ("*" + vfname + "*")
      ) /* first name */
and
      (vmname="" or caps(io) matches ("*" + vmname + "*")
      ) /* middle name */       
   )
use-index ndoc no-lock.

if num-results("q1")=0 then
do:
    MESSAGE "Записи не найдены."
          VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
                 TITLE "Не найдены клиенты ALMATV".
    return.                 
end.

b1:SET-REPOSITIONED-ROW (14, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

hide frame fr1.
return.
