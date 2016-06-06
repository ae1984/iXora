/* sf_rnn.p
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


/* Поиск РНН для физ. лиц  - по ФИО, документа, РНН, адресу */

def var vrnn as char.
def var vlname as char.
def var vfname as char.
def var vmname as char.
def var vcity as char.
def var vpost as char.
def var vstreet as char.
def var vraj as char.
def var vhouse as char.
def var vapart as char. 
def var vdist as char.
def var vserpas as char.
def var vnompas as char.
def var vdatepas as date.
def var vorgpas as char.
def var sm as decimal init 0.

def frame sf
    vrnn skip
    vlname skip
    vfname skip
    vmname skip
    vserpas skip
    vnompas skip
    vstreet vhouse vapart skip
    vraj skip
    vdist skip
    vcity vpost
    with side-labels centered overlay view-as dialog-box
    title "РНН - физ. лица".

def var fio as char format "x(73)".

def frame sfdet
    rnn.trn label "РНН" skip
    fio label "ФИО" skip
    rnn.byear label "Дата рожденья" skip
    "Документ  " rnn.serpas label "Серия"
                rnn.nompas label "Номер"
                rnn.datepas label "Дата" skip "          "
                rnn.orgpas label "Выдан" skip
                    "Телефоны: " rnn.humtel label "Дом" rnn.citytel label "  Раб" skip
"__________________________________________________________________________" 
    skip(1) 
    rnn.street1 format "x(22)" label "Улица" 
    rnn.housen1 format "x(7)" label "Дом" 
    rnn.apartn1 format "x(5)" label "Кв." skip
    rnn.raj1 label "Район" skip
    rnn.dist1 label "Область" skip 
    rnn.city1 label "Город"
    rnn.post1 label "Индекс" skip
"__________________________________________________________________________"
    skip
    rnn.street2 format "x(22)" label "Улица"
    rnn.housen2 format "x(7)" label "Дом"
    rnn.apartn2 format "x(5)" label "Кв." skip
    rnn.raj2 label "Район" skip
    rnn.dist2 label "Область" skip
    rnn.city2 label "Город" 
    rnn.post2 label "Индекс" skip
    with side-labels row 2 centered overlay view-as dialog-box
    title "Детали".

DEFINE QUERY q1 FOR rnn.

def browse b1 
    query q1 no-lock
    display 
        trn label "РНН" 
        trim(lname) + " " + trim(fname) + " " + trim(mname) format "x(30)"                 label "ФИО"
        trim(street1) + " " + trim(housen1) + "/" + trim(apartn1) format           "x(28)" label "Адрес" 
        with 14 down title "РНН".

def frame fr1 
    b1
    with centered overlay view-as dialog-box.
    
on return of b1 in frame fr1
    do: 
        apply "endkey" to frame fr1.
    end.  
    
vdatepas = ?.
update
vrnn format "999999999999" label "РНН"
vlname format "x(35)" label "Фамилия"
vfname format "x(20)" label "Имя"
vmname format "x(20)" label "Отчество"
vserpas format "x(7)" label "Документ серии"
vnompas format "x(10)" label "Номер документа"
vstreet format "x(30)" label "Улица"
help "----- Можете использовать шаблон -----"
vhouse format "x(7)" label "Дом"
vapart format "x(5)" label "Кв."
vraj format "x(22)" label "Район"
vdist format "x(22)" label "Область"
vcity  format "x(22)" label "Город"
vpost  format "x(6)" label "Почт.Индекс"
WITH side-labels 1 column row 3 FRAME sf.
hide frame sf.

vlname = caps(trim(vlname)).                          
vfname = caps(trim(vfname)).
vmname = caps(trim(vmname)).
vstreet = caps(trim(vstreet)).
vdist = caps(trim(vdist)).
vcity = caps(trim(vcity)).
vhouse = caps(trim(vhouse)).
vraj = caps(trim(vraj)).
vapart = caps(trim(vapart)).
vserpas = caps(trim(vserpas)).
vnompas = caps(trim(vnompas)).
vorgpas = caps(trim(vorgpas)).

def var llen as integer.
def var flen as integer.
def var mlen as integer.
def var clen as integer.
def var slen as integer.
def var rlen as integer.
def var hlen as integer.
def var alen as integer.
def var dlen as integer.
def var plen as integer.
def var nlen as integer.
def var olen as integer.

llen = length(vlname).
flen = length(vfname).
mlen = length(vmname).
clen = length(vcity).
slen = length(vstreet).
rlen = length(vraj).
hlen = length(vhouse).
alen = length(vapart).
dlen = length(vdist).
plen = length(vserpas).
nlen = length(vnompas).
olen = length(vorgpas).

on "enter" of browse b1
do:
    fio = caps(trim(rnn.lname) + ' ' + 
          trim(rnn.fname) + ' ' + trim(rnn.mname)). 
    disp fio with frame sfdet.
    disp rnn except mname fname lname datdok datdoki
         with frame sfdet.
    hide frame sfdet.
end.

if vrnn="" then 
open query q1 for each rnn where 
(vlname="" or caps(substr(lname, 1, llen)) = vlname)  
and (vfname="" or caps(substr(fname, 1, flen)) = vfname)
and (vmname="" or caps(substr(mname, 1, mlen)) = vmname)  
and (vserpas="" or caps(substr(serpas, 1, plen)) = vserpas)
and (vnompas="" or caps(substr(nompas, 1, nlen)) = vnompas)
and (vcity="" or caps(substr(city1, 1, clen)) = vcity
              or caps(substr(city2, 1, clen)) = vcity)
and (vdist="" or caps(substr(dist1, 1, dlen)) = vdist
              or caps(substr(dist2, 1, dlen)) = vdist)
and (vstreet="" or caps(substr(street1, 1, slen)) = vstreet
                or caps(substr(street2, 1, slen)) = vstreet
                or caps(street1 + "$" + street2) matches ("*" + vstreet + "*"))
and (vraj="" or caps(substr(raj1, 1, rlen)) = vraj
             or caps(substr(raj2, 1, rlen)) = vraj)
and (vhouse="" or caps(substr(housen1, 1, hlen)) = vhouse
               or caps(substr(housen2, 1, hlen)) = vhouse)
and (vapart="" or caps(substr(apartn1, 1, alen)) = vapart
               or caps(substr(apartn2, 1, alen)) = vapart)
use-index rnn no-lock.

else
open query q1 for each rnn where trn=vrnn 
and  (vlname="" or caps(substr(lname, 1, llen)) = vlname)   
and (vfname="" or caps(substr(fname, 1, flen)) = vfname)    
and (vmname="" or caps(substr(mname, 1, mlen)) = vmname)
and (vserpas="" or caps(substr(serpas, 1, plen)) = vserpas)
and (vnompas="" or caps(substr(nompas, 1, nlen)) = vnompas)
and (vcity="" or caps(substr(city1, 1, clen)) = vcity
              or caps(substr(city2, 1, clen)) = vcity)
and (vdist="" or caps(substr(dist1, 1, dlen)) = vdist
              or caps(substr(dist2, 1, dlen)) = vdist)
and (vstreet="" or caps(substr(street1, 1, slen)) = vstreet
                or caps(substr(street2, 1, slen)) = vstreet
                or caps(street1 + "$" + street2) matches ("*" + vstreet + "*"))
and (vraj="" or caps(substr(raj1, 1, rlen)) = vraj
             or caps(substr(raj2, 1, rlen)) = vraj)
and (vhouse="" or caps(substr(housen1, 1, hlen)) = vhouse
               or caps(substr(housen2, 1, hlen)) = vhouse)
and (vapart="" or caps(substr(apartn1, 1, alen)) = vapart
               or caps(substr(apartn2, 1, alen)) = vapart)
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
return trn.

