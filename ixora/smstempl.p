/* smstempl.p
 * MODULE
        Потреб. кредитование
 * DESCRIPTION
        Настройка шаблонов SMS-сообщений
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
        11/12/2009 madiyar
 * BASES
        BANK COMM
 * CHANGES
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

if s-ourbank <> "txb00" then do:
    message "Настройка шаблонов SMS-сообщений производится только в ЦО!" view-as alert-box.
    return.
end.

def temp-table wrk no-undo
  field id as integer
  field tit as char
  field txt as char
  index idx is primary id
  index idx2 is unique tit.

define query qt for wrk.
define buffer b-wrk for wrk.
def var v-rid as rowid.
def var i as integer no-undo.
def var j as integer no-undo.
def var choice as logi no-undo.
def var ss as char no-undo.

define browse bt query qt
    displ wrk.tit label "Имя" format "x(15)"
          wrk.txt label "Текст" format "x(88)"
          with centered 31 down overlay no-label title " Шаблоны ".

define frame ft bt help "<Insert>-Новый, <Enter>-Редактирование, <F4>-Выход" with width 110 row 3 overlay no-box.

on "return" of bt in frame ft do:
    if avail wrk then do:
        bt:set-repositioned-row(bt:focused-row, "always").
        v-rid = rowid(wrk).
        find first b-wrk where rowid(b-wrk) = rowid(wrk) exclusive-lock.
        displ b-wrk.tit format "x(15)" validate (b-wrk.tit <> '',"Введите имя шаблона!")
              b-wrk.txt format "x(160)" validate(b-wrk.txt <> '',"Введите текст шаблона!") view-as fill-in size 88 by 1
        with width 106 no-label overlay row bt:focused-row + 5 column 4 no-box frame fr2.

        update b-wrk.tit b-wrk.txt with frame fr2
        editing:
            readkey.
            if frame-field = "tit" then do:
                apply lastkey.
                if go-pending then leave.
                else next.
            end.
            if frame-field = "txt" then do:
                if keyfunction(lastkey) = '^' then next.
                if lookup(caps(keyfunction(lastkey)),'0^1^2^3^4^5^6^7^8^9^A^B^C^D^E^F^G^H^I^J^K^L^M^N^O^P^Q^R^S^T^U^V^W^X^Y^Z^;^,^.^(^)^-^*^_^+^/^=^%^$^@^!^\{^\}^ ^~^"^:^?^CURSOR-LEFT^CURSOR-RIGHT^RETURN^TAB^BACKSPACE^HOME^END^GO^END-ERROR^DELETE-CHARACTER','^') > 0 then apply lastkey.
                else next.
            end.
        end.

        open query qt for each wrk no-lock.
        reposition qt to rowid v-rid no-error.
        bt:refresh().
    end.
end. /* on "return" of bt */

on "insert-mode" of bt in frame ft do:
    i = 0.
    find last b-wrk no-lock no-error.
    if avail b-wrk then i = b-wrk.id.
    create wrk.
    wrk.id = i + 1.
    v-rid = rowid(wrk).
    open query qt for each wrk no-lock.
    reposition qt to rowid v-rid no-error.
    bt:refresh().
    apply "return" to bt.
end. /* on "insert-mode" of bt */

on "delete-character" of bt in frame ft do:
    if avail wrk then do:
        choice = no.
        message "Удалить шаблон """ + wrk.tit + """?" view-as alert-box question buttons ok-cancel update choice.
        if choice then do:
            bt:set-repositioned-row(bt:focused-row, "always").
            v-rid = rowid(wrk).
            find first b-wrk where rowid(b-wrk) = rowid(wrk) no-lock no-error.
            find next b-wrk no-lock no-error.
            if avail b-wrk then v-rid = rowid(b-wrk).
            else do:
                find first b-wrk where rowid(b-wrk) = rowid(wrk) no-lock no-error.
                find prev b-wrk no-lock no-error.
                if avail b-wrk then v-rid = rowid(b-wrk).
            end.

            find b-wrk where rowid(b-wrk) = rowid(wrk) exclusive-lock.
            delete b-wrk.

            open query qt for each wrk no-lock.
            reposition qt to rowid v-rid no-error.
            if avail wrk then bt:refresh().
        end.
    end.
end. /* on "delete-character" of bt */

do transaction:
    find first pksysc where pksysc.credtype = '0' and pksysc.sysc = "smstmp" no-lock no-error.
    if not avail pksysc then do:
        create pksysc.
        assign pksysc.credtype = '0'
               pksysc.sysc = 'smstmp'
               pksysc.des = "Шаблоны СМС-сообщений".
    end.
    find current pksysc no-lock.
end.


empty temp-table wrk.
if pksysc.chval <> '' then do:
    j = 0.
    do i = 1 to num-entries(pksysc.chval,"|"):
        ss = entry(i,pksysc.chval,"|").
        if num-entries(ss,"^") = 2 then do:
            j = j + 1.
            create wrk.
            assign wrk.id = j
                   wrk.tit = entry(1,ss,"^")
                   wrk.txt = entry(2,ss,"^").
        end.
    end.
end.

open query qt for each wrk no-lock.
enable all with frame ft.
wait-for end-error of current-window.
pause 0.

choice = yes.
message "Сохранить все произведенные изменения?" view-as alert-box question buttons ok-cancel update choice.
if choice then do transaction:
    find first pksysc where pksysc.credtype = '0' and pksysc.sysc = "smstmp" exclusive-lock no-error.
    if not avail pksysc then do:
        create pksysc.
        assign pksysc.credtype = '0'
               pksysc.sysc = 'smstmp'
               pksysc.des = "Шаблоны СМС-сообщений".
    end.
    pksysc.chval = ''.
    for each wrk no-lock:
        if pksysc.chval <> '' then pksysc.chval = pksysc.chval + '|'.
        pksysc.chval = pksysc.chval + wrk.tit + '^' + wrk.txt.
    end.
    release pksysc.
end.
