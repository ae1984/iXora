/* comon.p
 * MODULE
        ОД
 * DESCRIPTION
        Справочник списания комиссий

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
       comon.cif    label " Cif" format "x(6)"
       cif.name     label "Наименование " format "x(30)"
       comon.aaa    label "Счет операции " format "x(20)"
       comon.aaac   label "Счет комиссии " format "x(20)"
       comon.con    label "Контроль"
       comon.conwho label "Контролер" format "x(7)"
       with 29 down  overlay width 110 no-label title " Справочник списания комиссии  <INS>-Новая запись, <Enter>-Редактирование, <DEL>-удаление" .

define frame f-list b-list help "<INS>-Новая запись, <Enter>-Редактирование, <DEL>-удаление"   with width 110 row 5 COLUMN 3 overlay no-box.

     Form
        skip(1)
        v-cif         label " Cif код       " format "x(6)"  help "     <F2> - помощь" skip
        v-name        label " Наименование  " format "x(35)" skip
        v-aaa         label " Счет операции " format "x(20)" skip
        v-crc         label " Вал  операции " format ">9" skip
        v-aaac        label " Счет комиссии " format "x(20)" skip
        v-crcc        label " Вал комиссии  " format ">9" skip
        v-control     label " Контроль      " skip
        v-contrname   label " Контролер     " format "x(25) " skip
        v-dt          label " Дата контроля " skip
    WITH  SIDE-LABELS  ROW 7 column 5 width 100 overlay  FRAME f_main.

DEFINE QUERY q-helpc FOR aaa, lgr.
DEFINE BROWSE b-helpc QUERY q-helpc
       DISPLAY aaa.aaa label "Счет клиента " format "x(20)" aaa.crc label "Вл " format "z9" aaa.cr[1] - aaa.dr[1] label "доступный остаток" format "-z,zzz,zzz,zzz,zzz.99"
       aaa.sta label "Статус" format "x(1)" lgr.des label "описание" format "x(20)"
       WITH  15 DOWN title "Выберите счет для списании комиссии".
DEFINE FRAME f-helpc b-helpc  WITH overlay 1 COLUMN SIDE-LABELS row 15 COLUMN 25 width 89 NO-BOX.

DEFINE QUERY q-help FOR aaa, lgr.
DEFINE BROWSE b-help QUERY q-help
       DISPLAY aaa.aaa label "Счет клиента " format "x(20)" aaa.crc label "Вл " format "z9" aaa.cr[1] - aaa.dr[1] label "доступный остаток" format "-z,zzz,zzz,zzz,zzz.99"
       aaa.sta label "Статус" format "x(1)" lgr.des label "описание" format "x(20)"
       WITH  15 DOWN title " Выберите счет для операций ".
DEFINE FRAME f-help b-help  WITH overlay 1 COLUMN SIDE-LABELS row 12 COLUMN 25 width 89 NO-BOX.

on "END-ERROR" of frame f_main do:
  hide frame f_main no-pause.
end.
on "END-ERROR" of frame f-helpc do:
  hide frame f_main no-pause.
  hide frame f-helpc no-pause.
end.
on "END-ERROR" of frame f-help do:
  hide frame f_main no-pause.
  hide frame f-help no-pause.
end.
DEFINE VARIABLE phand AS handle.
on help of v-cif in frame f_main do:
    v-cif = "".
    run h-cif PERSISTENT SET phand.
    v-cif = frame-value.
    displ v-cif with frame f_main.
    DELETE PROCEDURE phand.
end.

on "enter" of b-list in frame f-list do:
    if comon.con then message "Для редактирования, необходимо снять акцепт в п.м. 1.3.9.2" view-as alert-box.
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
        OPEN QUERY  q-help FOR EACH aaa where  aaa.cif = v-cif and length(aaa.aaa) >= 20 and aaa.sta <> "C" and aaa.sta <> "E" no-lock,
                    each lgr where aaa.lgr = lgr.lgr and lgr.led <> "ODA" no-lock.
        ENABLE ALL WITH FRAME f-help.
        wait-for return of frame f-help
        FOCUS b-help IN FRAME f-help.
        v-aaa = aaa.aaa.
        v-crc = aaa.crc.
        find first  b-comon where b-comon.aaa = v-aaa no-lock no-error.
        if available b-comon and b-comon.id <> comon.id then do:
            hide frame f-help.
            message "Для счета " + b-comon.aaa + " счет комиссии уже привязан!" view-as alert-box.
            undo.
        end.
        pause 0.
        OPEN QUERY  q-helpc FOR EACH aaa where  aaa.cif = v-cif and length(aaa.aaa) >= 20 and aaa.sta <> "C" and aaa.sta <> "E" no-lock,
                    each lgr where aaa.lgr = lgr.lgr and lgr.led <> "ODA" no-lock.
        ENABLE ALL WITH FRAME f-helpc.
        wait-for return of frame f-helpc
        FOCUS b-helpc IN FRAME f-helpc.
        v-aaac = aaa.aaa.
        v-crcc = aaa.crc.
        hide frame f-helpc.
        displ v-aaac v-crcc with frame f_main.
        hide frame f-help.
        displ v-aaa v-crc with frame f_main.
        if yes-no ("Внимание!", "Сохранить изменения?") then do:
            v-nom = comon.id.
            run copyrec("upd").
            find first comon where comon.id = v-nom exclusive-lock.
            assign comon.aaa = v-aaa comon.aaac = v-aaac comon.upwho = g-ofc comon.updt = today comon.timupd = time.
        end.
        pause.
        hide frame f_main.
        open query q-list FOR EACH comon use-index id no-lock, each cif where comon.cif = cif.cif no-lock.
        enable all with frame f-list.
    end.
end.
on "INSERT-MODE" of b-list in frame f-list do:
    v-cif = "".
    clear frame f_main.
    update v-cif with frame f_main.
    find first cif where cif.cif = v-cif no-lock no-error.
    if not available cif then do:
        message "cif код не найден" view-as alert-box.
        undo.
    end.
    v-name = cif.prefix + " " + cif.name.
    v-control = no.
    v-contrname = "".
    v-dt = ?.
    displ v-name v-control v-contrname v-dt with frame f_main.
    pause 0.
    find first aaa where aaa.cif = v-cif and length(aaa.aaa) >= 20 and aaa.sta <> "C" and aaa.sta <> "E" no-lock no-error.
    if available aaa then do:
        OPEN QUERY  q-help FOR EACH aaa where  aaa.cif = v-cif and length(aaa.aaa) >= 20 and aaa.sta <> "C" and aaa.sta <> "E" no-lock,
                    each lgr where aaa.lgr = lgr.lgr and lgr.led <> "ODA" no-lock.
        ENABLE ALL WITH FRAME f-help.
        wait-for return of frame f-help
        FOCUS b-help IN FRAME f-help.
        v-aaa = aaa.aaa.
        v-crc = aaa.crc.
        find first  b-comon where b-comon.aaa = v-aaa no-lock no-error.
        if available b-comon and b-comon.id <> comon.id then do:
            hide frame f-help.
            message "Для счета " + b-comon.aaa + " счет комиссии уже привязан!" view-as alert-box.
            undo.
        end.
        OPEN QUERY  q-helpc FOR EACH aaa where  aaa.cif = v-cif and length(aaa.aaa) >= 20 and aaa.sta <> "C" and aaa.sta <> "E" no-lock,
                    each lgr where aaa.lgr = lgr.lgr and lgr.led <> "ODA" no-lock.
        ENABLE ALL WITH FRAME f-helpc.
        wait-for return of frame f-helpc
        FOCUS b-helpc IN FRAME f-helpc.
        v-aaac = aaa.aaa.
        v-crcc = aaa.crc.
        hide frame f-helpc.
        displ v-aaac v-crcc with frame f_main.
        pause 0.
        hide frame f-help.
        displ v-aaa v-crc with frame f_main.
        find last b-comon use-index id no-lock no-error.
        if available b-comon then v-id = b-comon.id.
        else v-id = 0.
        find last comonhis use-index id no-lock no-error.
        if available comonhis then do:
            if v-id < comonhis.id then v-id = comonhis.id.
        end.
        v-id = v-id + 1.
        create comon.
        assign comon.id = v-id comon.cif = v-cif comon.aaa = v-aaa comon.aaac = v-aaac comon.bin = cif.bin
        comon.who = g-ofc comon.regdt = today .
        pause.
        hide frame f_main.
        open query q-list FOR EACH comon use-index id no-lock, each cif where comon.cif = cif.cif no-lock.
        enable all with frame f-list.
    end.
    else do:
        v-aaac = "".
        MESSAGE "СЧЕТА КЛИЕНТА НЕ НАЙДЕНЫ.".
        displ v-aaac with frame f_main.
        return.
    end.
end.
on "DELETE-CHARACTER" of b-list in frame f-list do:
    if comon.con then message "Для удаления, необходимо снять акцепт в п.м. 1.3.9.2" view-as alert-box.
    else do:
        if yes-no ("Внимание!", "Вы действительно хотите удалить запись?")
        then do:
            v-nom = comon.id.
            run copyrec("del").
            find first comon where comon.id = v-nom exclusive-lock.
            delete comon.
        end.
        open query q-list FOR EACH comon use-index id no-lock, each cif where comon.cif = cif.cif no-lock.
        enable all with frame f-list.
    end.
end.

open query q-list FOR EACH comon use-index id no-lock, each cif where comon.cif = cif.cif no-lock.
enable all with frame f-list.

wait-for window-close of current-window.

procedure copyrec.
    define input parameter opr as char.
    if opr = "upd" then do:
            create comonhis.
            assign  comonhis.id = comon.id comonhis.stat = "upd" comonhis.cif = comon.cif comonhis.aaa = comon.aaa
            comonhis.aaac = comon.aaac comonhis.bin = comon.bin comonhis.who = comon.who comonhis.regdt = comon.regdt
            comonhis.timupd = comon.timupd comonhis.upwho = comon.upwho comonhis.updt = comon.updt
            comonhis.timdel = comon.timdel comonhis.delwho = comon.delwho comonhis.deldt = comon.deldt comonhis.del = comon.del
            comonhis.timcon = comon.timcon comonhis.conwho = comon.conwho comonhis.condt = comon.condt comonhis.con = comon.con.
    end.
    if opr = "del" then do:
            create comonhis.
            assign comonhis.id = comon.id comonhis.stat = "del" comonhis.cif = comon.cif comonhis.aaa = comon.aaa
            comonhis.aaac = comon.aaac comonhis.bin = comon.bin comonhis.who = comon.who comonhis.regdt = comon.regdt
            comonhis.timupd = comon.timupd comonhis.upwho = comon.upwho comonhis.updt = comon.updt
            comonhis.timdel = time comonhis.delwho = g-ofc comonhis.deldt = today comonhis.del = yes
            comonhis.timcon = comon.timcon comonhis.conwho = comon.conwho comonhis.condt = comon.condt comonhis.con = comon.con.
    end.
end.