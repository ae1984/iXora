/* comcon.p
 * MODULE
        ОД
 * DESCRIPTION
        Акцепт справочника списания комиссий

 * BASES
        BANK COMM
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        25/11/2013 Luiza ТЗ № 2181
 * CHANGES

*/


{mainhead.i}
{yes-no.i}

def var v-cif as char no-undo.
def  var vj-label  as char no-undo.
def  var v-aaac    as char no-undo.
def  var v-aaa     as char no-undo.
def  var v-crcc    as int no-undo.
def  var v-crc     as int no-undo.
def  var v-name    as char no-undo.
def  var v-bank    as char no-undo.
def  var v-control as logic  no-undo format "Есть/Нет" init no.
def  var v-contrname as char no-undo.
def  var v-title as char no-undo.
def var v-id     as int no-undo.
def var v-nom    as int no-undo.
def var v-dt     as date no-undo.


find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    message "Нет параметра ourbnk sysc!" view-as alert-box.
    return.
end.
v-bank = sysc.chval.
define buffer b-comon  for comon.

DEFINE QUERY q-list FOR comon, cif .

DEFINE BROWSE b-list QUERY q-list
       DISPLAY
       comon.id     label "Ном " format ">>9"
       comon.cif    label " Cif " format "x(6)"
       cif.name     label "Наименование " format "x(30)"
       comon.aaa    label "Счет операции " format "x(20)"
       comon.aaac   label "Счет комиссии " format "x(20)"
       comon.con    label "Контроль"
       comon.conwho label "Контролер" format "x(7)"
       with 29 down  overlay width 110 no-label title " АКЦЕПТ справочника списания комиссии  <INSERT>-акцепт, <DEL>-удаление акцепта" .

define frame f-list b-list help " <INSERT>-акцепт, <DEL>-удаление акцепта"   with width 110 row 5 COLUMN 3 overlay no-box.

     Form
        skip(1)
        v-cif         label " Cif код       " format "x(6)"  skip
        v-name        label " Наименование  " format "x(35)" skip
        v-aaa         label " Счет операции " format "x(20)" skip
        v-crc         label " Вал  операции " format ">9" skip
        v-aaac        label " Счет комиссии " format "x(20)" skip
        v-crcc        label " Вал комиссии  " format ">9" skip
        v-control     label " Контроль      " skip
        v-contrname   label " Контролер     " format "x(25) " skip
        v-dt          label " Дата контроля " skip
    WITH  SIDE-LABELS  ROW 7 column 5 width 80 overlay  FRAME f_main.


on "END-ERROR" of frame f_main do:
  hide frame f_main no-pause.
end.

on "INSERT-MODE" of b-list in frame f-list do:
    if comon.con then message "Запись уже акцептована!" view-as alert-box.
    else do:
        clear frame f_main.
        v-cif  = comon.cif.
        v-name = cif.prefix + " " + cif.name.
        v-aaac = comon.aaac.
        v-aaa  = comon.aaa.
        v-crcc = int(substring(comon.aaac,8,1)).
        v-crc  = int(substring(comon.aaa,8,1)).
        v-control = comon.con.
        v-contrname = comon.conwho.
        v-dt = comon.condt.
        displ v-cif v-name v-aaac v-crcc v-aaa v-crc v-control v-contrname v-dt with frame f_main.
        pause 0.
        if yes-no ("Внимание!", "Акцептовать?") then do:
            v-nom = comon.id.
            run copyrec.
            find first comon where comon.id = v-nom exclusive-lock.
            assign comon.con = yes comon.conwho = g-ofc comon.condt = today comon.timcon = time.
            v-control = comon.con.
            v-contrname = comon.conwho.
            v-dt = comon.condt.
            displ v-control v-contrname v-dt with frame f_main.
        end.
        pause.
        hide frame f_main.
        open query q-list FOR EACH comon use-index id no-lock, each cif where comon.cif = cif.cif no-lock.
        enable all with frame f-list.
    end.
end.
on "DELETE-CHARACTER" of b-list in frame f-list do:
    if comon.con = no then message "Запись не акцептована!" view-as alert-box.
    else do:
        clear frame f_main.
        v-cif  = comon.cif.
        v-name = cif.prefix + " " + cif.name.
        v-aaac = comon.aaac.
        v-aaa  = comon.aaa.
        v-crcc = int(substring(comon.aaac,8,1)).
        v-crc  = int(substring(comon.aaa,8,1)).
        v-control = comon.con.
        v-contrname = comon.conwho.
        v-dt = comon.condt.
        displ v-cif v-name v-aaac v-crcc v-aaa v-crc v-control v-contrname v-dt with frame f_main.
        pause 0.
        if yes-no ("Внимание!", "Снять акцепт?") then do:
            v-nom = comon.id.
            run copyrec.
            find first comon where comon.id = v-nom exclusive-lock.
            assign comon.con = no comon.conwho = g-ofc comon.condt = today comon.timcon = time.
            v-control = comon.con.
            v-contrname = comon.conwho.
            v-dt = comon.condt.
            displ v-control v-contrname v-dt with frame f_main.
        end.
        pause.
        hide frame f_main.
        open query q-list FOR EACH comon use-index id no-lock, each cif where comon.cif = cif.cif no-lock.
        enable all with frame f-list.
    end.
end.

open query q-list FOR EACH comon use-index id no-lock, each cif where comon.cif = cif.cif no-lock.
enable all with frame f-list.

wait-for window-close of current-window.

procedure copyrec.
        create comonhis.
        assign comonhis.id = comon.id  comonhis.stat = "acp" comonhis.cif = comon.cif comonhis.aaa = comon.aaa
        comonhis.aaac = comon.aaac comonhis.bin = comon.bin comonhis.who = comon.who comonhis.regdt = comon.regdt
        comonhis.timupd = comon.timupd comonhis.upwho = comon.upwho comonhis.updt = comon.updt
        comonhis.timdel = comon.timdel comonhis.delwho = comon.delwho comonhis.deldt = comon.deldt comonhis.del = comon.del
        comonhis.timcon = comon.timcon comonhis.conwho = comon.conwho comonhis.condt = comon.condt comonhis.con = comon.con.
end.