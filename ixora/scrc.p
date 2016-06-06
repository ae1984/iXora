/* scrc.p
 * MODULE
        Казначейство
 * DESCRIPTION
        Установка опорных курсов
 * RUN
        7-3-6
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        14.03.2011 aigul
 * BASES
        BANK COMM
 * CHANGES
        05.01.2012 aigul - начинать номер с единицы при начале нового года
*/
{global.i}
def new shared var s-order as integer.
def new shared var s-dt as date.
def var v-rid as rowid.
def var v-code as int.
def var i as int init 0.
def var choice as logi no-undo.
def var v-bank as char.
def buffer b-scrc for scrc.
def var p-crc as int.

def temp-table t-scrc
    field i as int
    field crc as int
    field ccode as char
    field buy as decimal
    field sell as decimal
    field spred as decimal
    field dt as date
    field order as int
    field chk as logi.

def var v-year as int.
v-year = year(g-today).
do i = 1 to 3:
    create  t-scrc.
    assign  t-scrc.i = i.
    t-scrc.dt = g-today.

    if i = 1 then t-scrc.crc = 02.
    if i = 2 then t-scrc.crc = 03.
    if i = 3 then t-scrc.crc = 04.
    t-scrc.order = 1.
    for each scrc no-lock break by scrc.scrc:
        find last b-scrc where b-scrc.scrc = scrc.scrc and b-scrc.crc = scrc.crc no-lock no-error.
        if avail b-scrc then do:
            if v-year > year(b-scrc.regdt) then  t-scrc.order = 1.
            if v-year = year(b-scrc.regdt) then  t-scrc.order = b-scrc.order + 1.
            if b-scrc.crc = i + 1 then t-scrc.buy = scrc.buycrc.
            if b-scrc.crc = i + 1 then t-scrc.sell = scrc.sellcrc.
            if b-scrc.crc = i + 1 then t-scrc.spred = scrc.minspr.
        end.
    end.
    find first ncrc where ncrc.crc = t-scrc.crc no-lock no-error.
    if avail ncrc then t-scrc.ccode = ncrc.code.
    t-scrc.chk = no.
end.
define buffer b-t-scrc for t-scrc.
def query qt for t-scrc.

def browse bt
    query qt no-lock
    display
        t-scrc.i label '№' format "99"
        t-scrc.crc label 'Валюта' format ">>>9"
        t-scrc.ccode label 'Название валюты' format "x(15)"
        t-scrc.buy label 'Опорный курс покупки' format ">>>>>>>>>>>>>>>>9.99"
        t-scrc.sell label 'Опорный курс продажи' format ">>>>>>>>>>>>>>>>>>9.99"
        t-scrc.spred label 'Минимальный спрэд' format ">>>>>>>>>>>>>>>9.99"
        t-scrc.dt label 'Дата' format "99/99/9999"
        with 6 down width 110 title "Установка опорных курсов".


define frame ft bt help "<Enter>-Ввод, <Ins>-Новый, <Ctrl+D>-Удалить, <F4>-Распоряжение" with width 150 row 3 overlay no-label no-box.


on "return" of bt in frame ft do:

    bt:set-repositioned-row(bt:focused-row, "always").
    v-rid = rowid(t-scrc).

    find first b-t-scrc where b-t-scrc.i = t-scrc.i exclusive-lock.
    displ b-t-scrc.i format "99"
          b-t-scrc.crc format ">>>>>9"
          b-t-scrc.ccode format "x(15)"
          b-t-scrc.buy format ">>>>>>>>>>>>>>>>9.99"
          b-t-scrc.sell format ">>>>>>>>>>>>>>>>>>9.99"
          b-t-scrc.spred format ">>>>>>>>>>>>>>>9.99"
          b-t-scrc.dt format "99/99/9999"
    with width 110 no-label overlay row bt:focused-row + 5 column 4 no-box frame fr2.

    update b-t-scrc.crc with frame fr2.
    if b-t-scrc.crc entered or b-t-scrc.crc <> 0 then do:
      find first ncrc where ncrc.crc = b-t-scrc.crc no-lock no-error.
      if avail ncrc then do:
        b-t-scrc.ccode = ncrc.code.
        /*find last scrc where scrc.crc = b-t-scrc.crc no-lock no-error.
        if avail scrc then do:
            b-t-scrc.spred = scrc.minspr.
            b-t-scrc.sell = scrc.sellcrc.
            b-t-scrc.buy = scrc.buycrc.
        end.*/
      end.
      else do:
        message "Неверный код валюты!" view-as alert-box.
        return.
      end.
      displ b-t-scrc.ccode with frame  fr2.
    end.
    if b-t-scrc.crc = 0 then do:
        message "Введите код валюты!" view-as alert-box.
        return.
    end.
    update b-t-scrc.buy b-t-scrc.sell b-t-scrc.spred b-t-scrc.dt t-scrc.chk = yes with frame fr2.

    open query qt for each t-scrc no-lock.
    reposition qt to rowid v-rid no-error.
    bt:refresh().

end.

on "insert-mode" of bt in frame ft do:
    find last t-scrc no-lock no-error.
    if avail t-scrc then v-code = t-scrc.i + 1.
    create t-scrc.
    t-scrc.i = v-code.
    t-scrc.dt = g-today.
    t-scrc.chk = yes.
    for each scrc no-lock break by scrc.scrc:

        find last b-scrc where b-scrc.scrc = scrc.scrc no-lock no-error.
        if avail b-scrc then do:
            if v-year > year(b-scrc.regdt) then t-scrc.order = 1.
            if v-year = year(b-scrc.regdt) then t-scrc.order = b-scrc.order + 1.
        end.
        else t-scrc.order = 1.

    end.
    find last scrc where scrc.crc = t-scrc.crc no-lock no-error.
    if avail scrc then t-scrc.spred = scrc.minspr.
    bt:set-repositioned-row(bt:focused-row, "always").
    v-rid = rowid(t-scrc).
    open query qt for each t-scrc no-lock.
    reposition qt to rowid v-rid no-error.
    bt:refresh().
    apply "return" to bt in frame ft.
end.

on "delete-line" of bt in frame ft do:
    choice = no.
    message "Запрос на удаление! Продолжить?"
              view-as alert-box question buttons yes-no title "Внимание!" update choice.
    if choice then do:
        bt:set-repositioned-row(bt:focused-row, "always").
        v-rid = ?.
        find first b-t-scrc  where b-t-scrc.i <> t-scrc.i no-lock no-error.
        if not avail b-t-scrc then find last b-t-scrc where t-scrc.i <> t-scrc.i no-lock no-error.
        if avail b-t-scrc then v-rid = rowid(b-t-scrc).
        find first b-t-scrc where b-t-scrc.i = t-scrc.i exclusive-lock.
        delete b-t-scrc.

        open query qt for each t-scrc no-lock.
        if v-rid <> ? then reposition qt to rowid v-rid no-error.
        bt:refresh().
    end.
end.
on "END-ERROR" of bt in frame ft do:
    choice = no.
    message "Создать распоряжение?" view-as alert-box question buttons yes-no title "Внимание!" update choice.
    if choice = yes then do:
        for each t-scrc where t-scrc.crc <> 0 and (t-scrc.buy <> 0 or t-scrc.sell <> 0) and t-scrc.chk = yes no-lock:
            create scrc.
            scrc.scrc = next-value(scrc).
            scrc.crc = t-scrc.crc.
            scrc.who = g-ofc.
            scrc.whn = g-today.
            scrc.tim = time.
            scrc.regdt = t-scrc.dt.
            scrc.buycrc = t-scrc.buy.
            scrc.sellcrc = t-scrc.sell.
            scrc.minspr = t-scrc.spred.
            scrc.order = t-scrc.order.
            s-order = t-scrc.order.
            s-dt = t-scrc.dt.
            find cmp no-lock no-error.
            if avail cmp then scrc.bank = string(cmp.code).
       end.
       for each scrc where scrc.order = s-order no-lock:
           for each txb where txb.consolid no-lock:
            connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
                run scrc-sysc(scrc.crc).
                disconnect txb.
           end.
       end.
       find first scrc where scrc.order = s-order no-lock no-error.
       if avail scrc then do:
         run scrc_print.
       end.
   end.
end.
open query qt for each t-scrc no-lock.
enable bt with frame ft.

wait-for window-close of current-window.
pause 0.

