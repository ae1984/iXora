/* kfm.p
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
        10/06/2013 Luiza - ТЗ 1727
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



def var v-operType as char init 'cs'.
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
             kfmoper.operDoc label "Документ" format "x(14)"
             bookcod.name    label "Статус" format "x(10)"
             kfmoper.rem[1]  label "ФИО клиента" format "x(25)"
             kfmoper.rem[2]  label "Назначение платежа" format "x(20)"
             kfmoper.rwho    label "КтоРег" format "x(7)"
             kfmoper.rwhn    label "ДатаРег" format "99/99/9999"
             string(kfmoper.rtim, "hh:mm:ss") label "ВремяРег" format "x(8)"
             kfmoper.cwho    label "КтоАкц" format "x(7)"
             kfmoper.cwhn    label "ДатаАкц" format "99/99/9999"
             kfmoper.repwhn  label "ДатаОтпр" format "99/99/9999"
         with 29 down width 110 overlay no-label title " Операции расхода со счета клиента или карточки(<Enter>-Просмотр <INSERT> - разрешить <DELETE> - запретить)".

define frame f_oper b_oper help "<Enter>-Просмотр <INSERT> - разрешить <DELETE> - запретить "  with width 110 row 3 overlay no-box.

on "enter" of b_oper in frame f_oper do:
    if avail kfmoper then do:
        run kfm-cas2.
        open query q_oper for each kfmoper where kfmoper.operType = v-operType and kfmoper.bank = s-ourbank no-lock use-index banktype,each bookcod where bookcod.bookcod = "kfmcas2" and bookcod.code = string(kfmoper.sts,"99") no-lock.
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
            run mail(kfmoper.rwho + "@fortebank.com" ,g-ofc + "@fortebank.com>", "разрешено проведение операции расход со счета клиента",
                "Службой комплаенс разрешено проведение операции расход со счета клиента: " + kfmoper.rem[1] +
                "\n Номер документа в iXora: " + kfmoper.operDoc, "1", "","").

            run savelog('kfmlog', "operID=" + string(b-kfmoper.operId) + " sts 0(нов)->1(разрешено) Расход со счета клиента или карточки").
            open query q_oper for each kfmoper where kfmoper.operType = v-operType and kfmoper.bank = s-ourbank no-lock use-index banktype,each bookcod where bookcod.bookcod = "kfmcas2" and bookcod.code = string(kfmoper.sts,"99") no-lock.
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
            run mail(kfmoper.rwho + "@fortebank.com" ,g-ofc + "@fortebank.com>", "запрещено проведение операции расход со счета клиента",
                "Службой комплаенс запрещено проведение операции расход со счета клиента: " + kfmoper.rem[1] +
                "\n Номер документа в iXora: " + kfmoper.operDoc, "1", "","").

            run savelog('kfmlog', "operID=" + string(b-kfmoper.operId) + " sts 0(нов)->98(запрет) Расход со счета клиента или карточки").
            open query q_oper for each kfmoper where kfmoper.operType = v-operType and kfmoper.bank = s-ourbank no-lock use-index banktype,each bookcod where bookcod.bookcod = "kfmcas2" and bookcod.code = string(kfmoper.sts,"99") no-lock.
            reposition q_oper to rowid v-rid no-error.
            b_oper:refresh().
        end.
    end.
end.

open query q_oper for each kfmoper where kfmoper.operType = v-operType and kfmoper.bank = s-ourbank  no-lock use-index banktype,each bookcod where bookcod.bookcod = "kfmcas2" and bookcod.code = string(kfmoper.sts,"99") no-lock.
enable all with frame f_oper.

wait-for window-close of current-window.



procedure kfm-cas2:
    form
        joudoc.docnum  label " Документ            "  format "x(10)"  skip
        joudoc.dracc   label " Счет плательщика    "  format "x(20)" skip
        joudoc.benname label " Плательщик          "  format "x(60)" skip
        joudoc.drcur   label " Валюта              "  format ">9"     skip
        joudoc.dramt   LABEL " Сумма               "  format ">>>,>>>,>>>,>>>,>>9.99"  skip
        joudoc.info    label " ФИО получателя      "  format "x(50)" skip
        joudoc.passp   label " Документ получателя "  format "x(30)" skip
        joudoc.perkod  label " ИИН/БИН получателя  "  format "x(12)" skip
        joudoc.remark[1] label  " Назначение платежа  "  skip
        joudoc.remark[2] no-label colon 22 skip
        joudoc.rescha[3] no-label colon 22 skip(1)
        WITH  SIDE-LABELS CENTERED ROW 9 TITLE v-title width 100 overlay FRAME f_main.


    find first joudop where joudop.docnum = kfmoper.operDoc no-lock no-error.
    if not available joudop then message "Документ не найден!" view-as alert-box.
    else do:
        case joudop.type:
            when "CS2" or when "EK2" then v-title = "Расходная операция со счета клиента наличными".
            when "CS6" or when "EK6" then v-title = "Расходная операция по платежной карте".
            when "CS9" or when "EK9" then v-title = "Расход.операция по ПК других банков".
        end case.

        find first joudoc where joudoc.docnum = kfmoper.operDoc no-lock no-error.
        if not available joudoc then message "Документ не найден!" view-as alert-box.
        else do:
            displ joudoc.docnum joudoc.dracc joudoc.benname joudoc.drcur joudoc.dramt joudoc.info
            joudoc.passp joudoc.perkod  joudoc.remark[1] joudoc.remark[2] joudoc.rescha[3] with frame f_main.
            pause.
        end.
    end.

end procedure.
