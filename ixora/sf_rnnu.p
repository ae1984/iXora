/* sf_rnnu.p
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


/* Поиск РНН для юрид. лиц  - по названию, юрид адресу, фактич адресу */
                                                                     
def var vrnnu as char.
def var vname as char.
def var vcity as char.
def var vpost as char.
def var vstreet as char.
def var vraj as char.
def var vhouse as char.
def var vapart as char. 
def var vdist as char.
def var vtel as char.
def var sm as decimal init 0.

def frame sf
    vrnnu skip
    vname help "----- Можете использовать шаблон -----" skip
    vtel skip
    vstreet help "----- Можете использовать шаблон -----"
    vhouse vapart skip
    vraj skip
    vdist skip
    vcity vpost
    with side-labels centered overlay view-as dialog-box
    title "РНН - юр. лица".

def var fio as char format "x(73)".

def frame sfdet
    rnnu.trn label "РНН" skip
    rnnu.busname label "Название" skip
    "Телефоны: " rnnu.numtelr label "1)" rnnu.numtelb label "  2)" 
    rnnu.citytel label "  код" skip(1)
"____________________________________________________[ Юридический адрес ]_" 
    skip(1) 
    rnnu.street1 format "x(22)" label "Улица" 
    rnnu.housen1 format "x(7)" label "Дом" 
    rnnu.apartn1 format "x(5)" label "Кв." skip
    rnnu.raj1 label "Район" skip
    rnnu.dist1 label "Область" skip 
    rnnu.city1 label "Город"
    rnnu.post1 label "Индекс" skip(1)
"____________________________________________________[ Фактический адрес ]_"
    skip
    rnnu.street2 format "x(22)" label "Улица"
    rnnu.housen2 format "x(7)" label "Дом"
    rnnu.apartn2 format "x(5)" label "Кв." skip
    rnnu.raj2 label "Район" skip
    rnnu.dist2 label "Область" skip
    rnnu.city2 label "Город" 
    rnnu.post2 label "Индекс" skip
    with side-labels row 2 centered overlay view-as dialog-box
    title "Детали".

DEFINE QUERY q1 FOR rnnu.

def browse b1 
    query q1 no-lock
    display 
        trn label "РНН" 
        trim(busname) label "Название" format "x(50)"
        with 14 down title "РНН".

def frame fr1 
    b1
    with centered overlay view-as dialog-box.
    
on return of b1 in frame fr1
    do: 
        apply "endkey" to frame fr1.
    end.  
    
                    
update
vrnnu format "999999999999" label "РНН"
vname format "x(50)" label "Название"
vtel format "x(7)" label "Телефон"
vstreet format "x(30)" label "Улица"
vhouse format "x(7)" label "Дом"
vapart format "x(5)" label "Кв."
vraj format "x(22)" label "Район"
vdist format "x(22)" label "Область"
vcity  format "x(22)" label "Город"
vpost  format "x(6)" label "Почт.Индекс"
WITH side-labels 1 column row 4 FRAME sf.
hide frame sf.

vname = caps(trim(vname)).                          
vtel = caps(trim(vtel)).
vstreet = caps(trim(vstreet)).
vcity = caps(trim(vcity)).
vhouse = caps(trim(vhouse)).
vapart = caps(trim(vapart)).
vraj = caps(trim(vraj)).
vdist = caps(trim(vdist)).

def var llen as integer.
def var flen as integer.
def var mlen as integer.
def var clen as integer.
def var slen as integer.
def var rlen as integer.
def var hlen as integer.
def var alen as integer.
def var dlen as integer.
def var tlen as integer.

llen = length(vname).
clen = length(vcity).
slen = length(vstreet).
rlen = length(vraj).
hlen = length(vhouse).
alen = length(vapart).
dlen = length(vdist).
tlen = length(vtel).

on "enter" of browse b1
do:
    disp rnnu except rnnu.fil rnnu.grnom rnnu.grdate rnnu.activity rnnu.organiz
         rnnu.owner rnnu.grname rnnu.okpo rnnu.buss rnnu.enterp rnnu.glava
         rnnu.stat rnnu.datdok rnnu.datdoki
         with frame sfdet.
    hide frame sfdet.
end.

if vrnnu="" then 
open query q1 for each rnnu where 
    (vname="" or caps(busname) matches ("*" + vname + "*"))
and (vtel=""  or caps(substr(numtelr, 1, tlen)) = vtel
              or caps(substr(numtelb, 1, tlen)) = vtel)
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
open query q1 for each rnnu where trn=vrnnu 
and (vname="" or caps(substr(busname, 1, llen)) = vname) 
and (vtel=""  or caps(substr(numtelr, 1, tlen)) = vtel
              or caps(substr(numtelb, 1, tlen)) = vtel)
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

