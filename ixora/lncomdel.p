/* lncomdel.p
 * MODULE
        Кредитный
 * DESCRIPTION
        Списание начисленных комиссий за обслуживание кредита
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        19/03/2009 madiyar
 * BASES
        BANK
 * CHANGES
        14/07/2010 madiyar - 20-значный счет
*/

{mainhead.i}

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

def var v-cif as char no-undo.
define query q1 for bxcif.

def var v-rid as rowid.
def var v-riddel as rowid.
def var choice as logi no-undo.
def var crccode as char no-undo.
def var v-mess as char no-undo.

define browse b1 query q1
       displ bxcif.aaa label "Счет" format "x(20)"
             bxcif.whn label "Дата" format "99/99/99"
             bxcif.crc label "Вал" format ">9"
             bxcif.amount label "Сум.к опл." format ">>>,>>9.99"
             bxcif.amopl label "Сум.оплач." format ">>>,>>9.99"
             bxcif.opl label "ДатаОпл" format "99/99/99"
             bxcif.rem label "Описание" format "x(39)"
             with 30 down overlay no-label title " Начисленные комиссии ".

define frame ft b1 help "<Del>-Удалить <Tab>-Выбрать другого клиента <F4>-Выход" skip(1) with width 110 row 3 overlay no-label no-box.

procedure rec2log.
    def input parameter p-mess as char no-undo.
    output to value("/data/log/bxcif-del.log") append.
    put unformatted
        string(today,"99/99/9999") " "
        string(time, "hh:mm:ss") " "
        s-ourbank " "
        userid("bank") format "x(8)" " "
        p-mess skip.
    output close.
end procedure.

function val-cif returns logi (input parm1 as char).
    def var res as logi no-undo init yes.
    find first cif where cif.cif = parm1 no-lock no-error.
    if not avail cif then do:
        message " Некорректный код клиента " view-as alert-box error.
        res = no.
    end.
    find first bxcif where bxcif.cif = parm1 and bxcif.type = "195" no-lock no-error.
    if not avail bxcif then do:
        message " По данному клиенту нет комиссий по тарифу '195' " view-as alert-box information.
        res = no.
    end.
    return res.
end function.

define frame fr v-cif label "Введите код клиента" validate(val-cif(v-cif),"Повторите ввод данных!") with centered row 12 side-labels.

def buffer b-bxcif for bxcif.

on "delete-character" of b1 in frame ft do:
    if avail bxcif then do:
        choice = no.
        crccode = ''.
        find first crc where crc.crc = bxcif.crc no-lock no-error.
        if avail crc then crccode = crc.code.
        message "Вы уверены, что хотите удалить неоплаченную комиссию~nна сумму " + trim(string(bxcif.amount,">>>,>>>,>>>,>>9.99")) + " " + crccode + "~n от " + string(bxcif.whn,"99/99/9999") + "?" view-as alert-box question buttons yes-no title " Подтверждение " update choice.
        if choice then do:
            v-riddel = rowid(bxcif).
            v-mess = "(" + g-ofc + ") Удаление " + bxcif.cif + ' aaa=' + bxcif.aaa +
                     " amount=" + trim(string(bxcif.amount,">>>,>>>,>>>,>>9.99")) + "(" + crccode + ")" +
                     if bxcif.amopl > 0 then " amount_paid=" + trim(string(bxcif.amopl,">>>,>>>,>>>,>>9.99")) + "(" + crccode + ")" else ''.
            v-mess = v-mess + " period=" + bxcif.period + ' "' + trim(bxcif.rem) + '"'.
            b1:set-repositioned-row(b1:focused-row, "always").
            get next q1.
            if not avail bxcif then get last q1.
            v-rid = rowid(bxcif).

            do transaction:
                find first b-bxcif where rowid(b-bxcif) = v-riddel exclusive-lock no-error.
                if avail b-bxcif then delete b-bxcif.
            end.
            run rec2log(v-mess).

            open query q1 for each bxcif where bxcif.cif = v-cif and bxcif.type = "195" no-lock.
            reposition q1 to rowid v-rid no-error.
            if avail bxcif then b1:refresh().
        end. /* if choice */
    end.
end.

on "tab" of b1 in frame ft do:

    update v-cif with frame fr.
    b1:title = " (" + v-cif + ") " + trim(cif.sname) + " - начисленные комиссии ".
    open query q1 for each bxcif where bxcif.cif = v-cif and bxcif.type = "195" no-lock.
    if avail bxcif then b1:refresh().

end.

update v-cif with frame fr.
b1:title = " (" + v-cif + ") " + trim(cif.sname) + " - начисленные комиссии ".

open query q1 for each bxcif where bxcif.cif = v-cif and bxcif.type = "195" no-lock.
enable b1 with frame ft.

wait-for window-close of current-window.
pause 0.

