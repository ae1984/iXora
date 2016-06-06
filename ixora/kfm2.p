/* kfm2.p
 * MODULE
        Финансовый мониторинг
 * DESCRIPTION
        Модуль фин. мониторинга операций
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
 * BASES
        BANK COMM
 * AUTHOR
        05/08/2013 Luiza - ТЗ 1728
 * CHANGES

*/

{global.i}
def var s-ourbank as char no-undo.

def var v-title as char no-undo.

/*проверка банка*/
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    MESSAGE "There is no record OURBNK in bank.sysc file !!" view-as alert-box.
    hide message.
    return.
end.
s-ourbank = trim(sysc.chval).



def var v-operType as char init 'br'.
def var v-yes as logic  no-undo format "Да/Нет" init no.

def var kfmsave as logi no-undo.
def var choice as logi no-undo.
def var opErr as logi no-undo.
def var opErrDes as char no-undo.

define query q_oper for kfmoper,bookcod.
def var v-rid as rowid.
def var v-rid2 as rowid.
def var v-oldsts as char no-undo.

def buffer b-kfmoper for kfmoper.

define browse b_oper query q_oper
       displ kfmoper.operId  label "nn" format ">>>>>9"
             kfmoper.operDoc label "cif-код" format "x(6)"
             bookcod.name    label "Статус" format "x(10)"
             kfmoper.rem[1]  label "ФИО клиента" format "x(25)"
             kfmoper.rem[2]  label "ИИН/БИН" format "x(12)"
             kfmoper.rwho    label "КтоРег" format "x(7)"
             kfmoper.rwhn    label "ДатаРег" format "99/99/9999"
             string(kfmoper.rtim, "hh:mm:ss") label "ВремяРег" format "x(8)"
             kfmoper.cwho    label "КтоАкц" format "x(7)"
             kfmoper.cwhn    label "ДатаАкц" format "99/99/9999"
             kfmoper.repwhn  label "ДатаОтпр" format "99/99/9999"
         with 29 down width 110 overlay no-label title " Операции открытия счета клиенту связ с банком ОО(<Enter>-Просмотр <INSERT>-разрешить <DELETE>-запретить)".

define frame f_oper b_oper help "<Enter>-Просмотр <INSERT> - разрешить <DELETE> - запретить "  with width 110 row 3 overlay no-box.

on "enter" of b_oper in frame f_oper do:
    if avail kfmoper then do:
        run kfm-cif.
        open query q_oper for each kfmoper where kfmoper.operType = v-operType and kfmoper.bank = s-ourbank no-lock use-index banktype,
        each bookcod where bookcod.bookcod = "kfmbr" and bookcod.code = string(kfmoper.sts,"99") no-lock.
        reposition q_oper to rowid v-rid no-error.
        b_oper:refresh().
    end.
end.

on "insert" of b_oper in frame f_oper do:
    if avail kfmoper and kfmoper.sts = 0 then do:
        message "Разрешить проведение операции?"  view-as alert-box question buttons yes-no title "" update v-yes .
        if v-yes then do:
            b_oper:set-repositioned-row(b_oper:focused-row, "always").
            v-rid = rowid(kfmoper).
            do transaction:
                find first b-kfmoper where rowid(b-kfmoper) = v-rid exclusive-lock.
                assign b-kfmoper.sts = 1 /* разрешить */
                       b-kfmoper.cwho = g-ofc
                       b-kfmoper.cwhn = g-today.
                find current b-kfmoper no-lock.
            end.
            run mail(kfmoper.rwho + "@fortebank.com" ,g-ofc + "@fortebank.com>", "разрешено проведение операции открытия счета клиенту связанному с банком особыми отношениями",
                "Службой комплаенс разрешено проведение операции открытия счета клиенту связанному с банком особыми отношениями: " + kfmoper.rem[1] +
                "\n ИИН/БИН: " + kfmoper.operDoc, "1", "","").

            run savelog('kfmlog', "operID=" + string(b-kfmoper.operId) + " sts 0(нов)->1(разрешено) открытия счета клиенту связанному с банком особыми отношениями").
            open query q_oper for each kfmoper where kfmoper.operType = v-operType and kfmoper.bank = s-ourbank no-lock use-index banktype,
            each bookcod where bookcod.bookcod = "kfmbr" and bookcod.code = string(kfmoper.sts,"99") no-lock.
            reposition q_oper to rowid v-rid no-error.
            b_oper:refresh().
        end.
    end.
end.
on "delete" of b_oper in frame f_oper do:
    if avail kfmoper and kfmoper.sts = 0 then do:
        message "Запретить проведение операции?"  view-as alert-box question buttons yes-no title "" update v-yes .
        if v-yes then do:
            b_oper:set-repositioned-row(b_oper:focused-row, "always").
            v-rid = rowid(kfmoper).
            do transaction:
                find first b-kfmoper where rowid(b-kfmoper) = v-rid exclusive-lock.
                assign b-kfmoper.sts = 98 /* запретить */
                       b-kfmoper.cwho = g-ofc
                       b-kfmoper.cwhn = g-today.
                find current b-kfmoper no-lock.
            end.
            run mail(kfmoper.rwho + "@fortebank.com" ,g-ofc + "@fortebank.com>", "запрещено проведение операции открытия счета клиенту связанному с банком особыми отношениями",
                "Службой комплаенс запрещено проведение операции открытия счета клиенту связанному с банком особыми отношениями: " + kfmoper.rem[1] +
                "\n ИИН/БИН: " + kfmoper.operDoc, "1", "","").

            run savelog('kfmlog', "operID=" + string(b-kfmoper.operId) + " sts 0(нов)->98(запрет) открытия счета клиенту связанному с банком особыми отношениями").
            open query q_oper for each kfmoper where kfmoper.operType = v-operType and kfmoper.bank = s-ourbank no-lock use-index banktype,
            each bookcod where bookcod.bookcod = "kfmbr" and bookcod.code = string(kfmoper.sts,"99") no-lock.
            reposition q_oper to rowid v-rid no-error.
            b_oper:refresh().
        end.
    end.
end.

open query q_oper for each kfmoper where kfmoper.operType = v-operType and kfmoper.bank = s-ourbank  no-lock use-index banktype,
each bookcod where bookcod.bookcod = "kfmbr" and bookcod.code = string(kfmoper.sts,"99") no-lock.
enable all with frame f_oper.

wait-for window-close of current-window.



procedure kfm-cif:
    def var v-chief as char.
    def var v-type as char.
    v-chief = "".

    define query qfounder for founder.

    define browse bfounder query qfounder
    displ founder.name label "ФИО/Наимен-е учредителя " format "x(30)"
          founder.bin label "БИН" format "x(12)"
          founder.res label "Резидентство" format "9"
          founder.country label "Страна" format "x(2)"
          founder.reschar[1] label 'Доля(%)' format "x(3)"
          with 10 down overlay no-label no-box.

    form
        cif.cif    label " cif-код                      "  format "x(6)"  skip
        v-type     label " тип клиента                  "  format "x(10)" skip
        cif.prefix label " ФИО/Наименование             "  format "x(5)"
        cif.name   no-label colon 36 format "x(30)"
        cif.bin    label " БИН/ИИН                      "  format "x(12)" skip
        v-chief    label " ФИО руководителя организации "  format "x(30)" skip
        WITH  SIDE-LABELS CENTERED ROW 9 TITLE v-title width 100 overlay FRAME f_main.


    find first cif where cif.cif = kfmoper.operDoc no-lock no-error.
    if not available cif then message "cif-код не найден!" view-as alert-box.
    else do:
        if cif.type = "P" then do:
            v-type = "Физ.лицо".
            displ cif.cif v-type cif.prefix cif.name cif.bin v-chief  with frame f_main.
            pause.
        end.
        else do:
            v-type = "Юр.лицо".
            find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and  sub-cod.d-cod = 'clnchf' no-lock no-error.
            if avail sub-cod then v-chief = sub-cod.rcode.
            displ cif.cif v-type cif.prefix cif.name cif.bin v-chief  with frame f_main.
            open query qfounder for each founder where founder.cif = cif.cif no-lock.
            enable bfounder with frame ffounder.
            wait-for return of current-window .
            pause 0.
        end.
    end.
end procedure.
