/* bankaedt.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Редактрование и просмотр таблицы banka
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
        02/10/2013 galina  ТЗ2104
 * BASES
        BANK COMM
 * CHANGES
        08/10/2013 galina - перекомпеляция
*/

def var v-rid as rowid.
def new shared temp-table t-banka like banka.
def temp-table t-bankadel like banka.
def query q-banka for t-banka.
def query q-bankaf for t-banka.

def var v-ourbnk as char.
def var v-sel as int.
def var v-sellist1 as char.
def var v-sellist2 as char.
def button bsave label 'СОХРАНИТЬ'.
def var v-new as logi.
def buffer buf-banka for banka.
def buffer buf-tbanka for t-banka.
def var v-bank as char.
def var v-bankname as char.
def var v-crc as int.
def var v-crccode as char.
def var v-dacc as char.
def var v-cacc as char.
def var v-save as logi init yes.
def var v-mess as char.
def var v-mess2 as char.
def var v-pschk as logi.
def var v-ans as logi.
def var v-banklist as char.

define browse b-banka query q-banka
    displ t-banka.bank label "Код филиала" format "x(5)"
          t-banka.crc label "Код валюты" format ">9"
          t-banka.dacc label "Тр/С Расчета с филиалом" format "x(20)"
          t-banka.cacc label "Тр/С Расчета с ГБ" format "x(20)"
          with centered 30 down overlay no-label title " Редактирование графика комиссии " .


define frame f-banka b-banka help "<Enter>-Изменить, <Ins>-Ввод, <Ctrl+D>-удаление, <F4>-Выход" skip bsave with width 110 row 3 overlay no-box.

define browse b-bankaf query q-bankaf
    displ t-banka.bank label "Код филиала" format "x(5)"
          t-banka.crc label "Код валюты" format ">9"
          t-banka.dacc label "Тр/С Расчета с филиалом" format "x(20)"
          t-banka.cacc label "Тр/С Расчета с ГБ" format "x(20)"
          with centered 30 down overlay no-label title " Редактирование графика комиссии " .


define frame f-bankaf b-bankaf help "<F4>-Выход" with width 110 row 3 overlay no-box.

define frame fupd
v-bank label "Код филиала" validate(can-find(first bankl where bankl.bank = v-bank no-lock) and v-bank begins 'TXB' and v-bank <> 'TXB00','Неверное значение кода филиала!') format "x(5)" v-bankname no-label format "x(40)" skip
v-crc label "Код валюты" format ">9" validate(can-find(first crc where crc.crc = v-crc no-lock),'Неверное значение кода валюты') v-crccode format "x(3)" no-label skip
v-dacc label "Тр/С Расчеты с филиалом" format "x(20)" validate(index(v-sellist1,v-dacc) > 0,'Не найден счет!') skip
v-cacc label "Тр/С Расчеты с ГБ" format "x(20)" validate(index(v-sellist2,v-cacc) > 0 ,'Не найден счет!')
with width 60 row 3 overlay side-label.

on help of v-crc in frame fupd do:
    {itemlist.i
        &file    = "crc"
        &set     = "1"
        &frame   = "row 6 centered scroll 1 10 down width 30 overlay "
        &where   = " crc.crc >= 1 "
        &flddisp = " crc.crc label ' Код '  format '>9' crc.code label ' Валюта ' format 'x(3)' "
        &chkey   = "crc"
        &chtype = "int"
        &index   = "crc"
        &end     = "if keyfunction(lastkey) = 'end-error' then return."
     }
    assign v-crc = crc.crc v-crccode = crc.code.
    displ v-crc v-crccode with frame fupd.
end.

on help of v-bank in frame fupd do:
    {itemlist.i
        &file    = "txb"
        &set     = "2"
        &frame   = "row 6 centered scroll 1 10 down width 60 overlay "
        &where   = " txb.bank <> 'TXB00' and txb.bank begins 'TXB' "
        &flddisp = " txb.bank label ' Код '  format 'x(5)' 'АО ''ForteBank'' в ' + txb.info label ' Наименование ' format 'x(30)' "
        &chkey   = "bank"
        &index   = "bank"
        &end     = "if keyfunction(lastkey) = 'end-error' then return."
     }
    assign v-bank = txb.bank v-bankname = 'АО "ForteBank" в ' + txb.info.
    displ v-bank v-bankname with frame fupd.
end.

on help of v-dacc in frame fupd do:
    if v-sellist1 = '' then do:
        message 'Не найдены открытые транзиные счета расчетов с филиалами!' view-as alert-box.
        return.
    end.

    v-sel = 0.
    run sel2 (" Тр/С Расчета с филиалом ", v-sellist1, output v-sel).
    if v-sel > 0 then v-dacc = entry(1,entry(v-sel,v-sellist1,'|'),' ').
    display v-dacc with frame fupd.
end.

on help of v-cacc in frame fupd do:
    if v-sellist2 = '' then do:
        message 'Не найдены открытые транзиные счета расчетов с филиалами!' view-as alert-box.
        return.
    end.

    v-sel = 0.
    run sel2 (" Тр/С Расчета с филиалом ", v-sellist2, output v-sel).
    if v-sel > 0 then v-cacc = entry(1,entry(v-sel,v-sellist2,'|'),' ').
    display v-cacc with frame fupd.
end.


find first sysc where sysc.sysc = 'ourbnk' no-lock no-error.
if not avail sysc or sysc.chval = '' then do:
    message 'Нет настройки ourbnk в sysc!' view-as alert-box.
    return.
end.
else v-ourbnk = sysc.chval.


on "return" of b-banka in frame f-banka do:
    if v-ourbnk = 'TXB00' then do:
        b-banka:set-repositioned-row(b-banka:focused-row, "always").
        v-rid = rowid(t-banka).

        if v-new then do:
            assign v-bank = ''
                   v-bankname = ''
                   v-crc = 0
                   v-crccode = ''
                   v-dacc = ''
                   v-cacc = ''.
            display v-bank v-bankname v-crc v-crccode v-dacc v-cacc with frame fupd.
        end.
        else do:
            v-bank = t-banka.bank.
            find first txb where txb.bank = v-bank no-lock no-error.
            if avail txb then v-bankname = 'АО "ForteBank" в ' + txb.info.
            v-crc = t-banka.crc.
            find first crc where crc.crc = v-crc no-lock no-error.
            if avail crc then v-crccode = crc.code.
            v-dacc = t-banka.dacc.
            v-cacc = t-banka.cacc.
        end.
        if v-new then do:
            repeat:
                update v-bank with frame fupd.
                find first txb where txb.bank = v-bank no-lock no-error.
                if avail txb then v-bankname = 'АО "ForteBank" в ' + txb.info.
                display v-bankname with frame fupd.
                update v-crc with frame fupd.
                find first crc where crc.crc = v-crc no-lock no-error.
                if avail crc then v-crccode = crc.code.
                display v-crccode with frame fupd.
                find first buf-tbanka where buf-tbanka.bank = v-bank and buf-tbanka.crc = v-crc no-lock no-error.
                if not avail buf-tbanka then leave.
                else message "Настройка для филиала " + v-bankname + ' по валюте ' + v-crccode + ' уже есть в базе!'.
            end.
        end.
        else display v-bank v-bankname v-crc v-crccode with frame fupd.

        v-sellist2 = ''.
        find first txb where txb.bank = v-bank no-lock no-error.
        if avail txb then do:
            if connected ("txb") then disconnect "txb".
            connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password) no-error.
            run arplist_txb(v-crc,output v-sellist2).
            if connected ("txb") then disconnect "txb".
        end.

        v-sellist1 = ''.
        for each arp where string(arp.gl) begins '1352' and arp.crc = v-crc no-lock:
            find sub-cod where sub-cod.sub = "arp" and sub-cod.acc = arp.arp and sub-cod.d-cod = "clsa" no-lock no-error.
            if avail sub-cod and sub-cod.ccode <> "msc" then next.
            v-sellist1 = v-sellist1 + arp.arp + ' ' + arp.des + '|'.
        end.

        if v-bank <> '' and v-crc > 0 then update v-dacc v-cacc with frame fupd.
        assign t-banka.bank = v-bank
               t-banka.crc = v-crc
               t-banka.dacc = v-dacc
               t-banka.cacc = v-cacc.

        open query q-banka for each t-banka  no-lock.
        reposition q-banka to rowid v-rid no-error.
        b-banka:refresh().
        v-save = no.
        if v-banklist <> '' then v-banklist = v-banklist + ','.
        v-banklist = v-banklist + v-bank.
    end.
end.

on "insert-mode" of b-banka in frame f-banka do:
    if v-ourbnk = 'TXB00' then do:
        v-new = yes.
        create t-banka.
        b-banka:set-repositioned-row(b-banka:focused-row, "always").
        v-rid = rowid(t-banka).
        open query q-banka for each t-banka no-lock.
        reposition q-banka to rowid v-rid no-error.
        b-banka:refresh().
        v-save = no.
        apply "return" to b-banka in frame f-banka.
    end.
end.
def var v-del as logi.
on "delete-line" of b-banka in frame f-banka do:
    if v-ourbnk = 'TXB00' then do:
        message "Удалить запись? " view-as alert-box question buttons yes-no title "" update v-del.
        if v-del then do:
            b-banka:set-repositioned-row(b-banka:focused-row, "always").
            create t-bankadel.
            buffer-copy t-banka to t-bankadel.
            find current t-banka  exclusive-lock.
            delete t-banka.
            open query q-banka for each t-banka no-lock.
            b-banka:refresh().
            v-save = no.
            if v-banklist <> '' then v-banklist = v-banklist + ','.
            v-banklist = v-banklist + t-bankadel.bank.
        end.
    end.
end.
empty temp-table t-banka.


ON CHOOSE OF bsave IN FRAME f-banka do:
    for each t-banka where t-banka.bank <> '' no-lock:
        find first banka where banka.bank = t-banka.bank and banka.crc = t-banka.crc no-lock no-error.
        if not avail banka then do:
            create banka.
            buffer-copy t-banka to banka.
        end.
        else do:
            find current banka exclusive-lock.
            buffer-copy t-banka except bank crc to banka.
        end.
        find current banka no-lock no-error.
    end.
    for each t-bankadel no-lock:
       find first banka where banka.bank = t-bankadel.bank and banka.crc = t-bankadel.crc and banka.dacc = t-bankadel.dacc and banka.cacc = t-bankadel.cacc exclusive-lock.
       delete banka.
    end.
    display 'Синхронизация с филиалами...' with frame fsinh centered overlay width 30 row 10.
    for each banka no-lock break by banka.bank:
        if first-of(banka.bank) and lookup(banka.bank,v-banklist) > 0 then do:
            find first txb where txb.bank = banka.bank no-lock no-error.
            if avail txb then do:
                if connected ("txb") then disconnect "txb".
                connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password) no-error.
                run banka_txb(banka.bank).
                if connected ("txb") then disconnect "txb".
            end.
        end.
    end.
    hide frame fsinh no-pause.
    message "Данные сохранены!" view-as alert-box.
    v-save  = yes.
end.

on "end-error" of frame f-banka do:
    if not v-save then do:
        message "Сохранить изменения? " view-as alert-box question buttons yes-no title "" update v-ans.
        if v-ans then  apply 'choose' to bsave in frame f-banka.
    end.
end.
if v-ourbnk = 'TXB00' then do:
    v-mess = "Перед настройкой расчетных счетов необходимо остановить все процессы во всех филиалах и ЦО! Процессы не остановлены ".
    v-mess2 = ''.
    find first dproc no-lock no-error.
    if avail dproc then v-mess2 = 'в ЦО'.
    for each txb where txb.bank <> 'TXB00' and txb.is_branch no-lock:
        v-pschk = no.
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password) no-error.
        run pschk_txb(output v-pschk).
        if connected ("txb") then disconnect "txb".
        if v-pschk then v-mess2 = v-mess2 + ', в филиале ' + txb.info.
    end.
end.

if v-mess2 <> '' then do:
    message v-mess + v-mess2 + '~n Доступен режим просмотра.' view-as alert-box title 'ВНИМАНИЕ'.
    /*return.*/
end.

if v-mess2 <> '' then v-ourbnk = ''.

for each banka no-lock:
    create t-banka.
    buffer-copy banka to t-banka.
end.

open query q-banka for each t-banka no-lock.
open query q-bankaf for each t-banka no-lock.
if v-ourbnk = 'TXB00' then enable all with frame f-banka.
else enable all with frame f-bankaf.
wait-for window-close of current-window.
pause 0.
