/* aaasaldo.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Создание записи соответствия между счетами клиента в ЦО и Алм.фил.
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
        10/08/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        08.02.2013 evseev - tz-1704
*/

{global.i}

def new shared var v-cif-f as char.
def new shared var v-crc as integer.
def new shared var v-aaa-f as char.
def new shared var v-cifname-f as char.
def new shared var v-rnn-f as char.
def new shared var v-kbe as char no-undo.

def var v-cif as char no-undo.
def new shared var v-rnn as char no-undo.
def var v-aaafrom as char no-undo.
def var v-cifname as char no-undo.
def var v-rid as rowid.
def var v-kod as char no-undo.

def var v-cifold as char no-undo.
def var v-cifold-f as char no-undo.
def var v-aaafromold as char no-undo.
def var v-aaaold-f as char no-undo.
def var i as integer no-undo.
def var v-save as logi init yes.
def temp-table t-transfer like transfer.
def buffer b-transfer for t-transfer.

function aaachk returns char (input p-aaa as char).
    def var mes as char.
    mes = ''.
    find first aaa where aaa.aaa = p-aaa no-lock no-error.
    if not avail aaa then mes = 'Счет не найден!'.
    else do:
        if aaa.sta = 'C' then mes = 'Счет закрыт!'.
        else if aaa.cif <> v-cif then mes = 'Счет принадлежит другому клиенту!'.
    end.
    return mes.
end function.

form
    v-cif format "x(6)" label 'Код клиента ЦО' validate(can-find(cif where cif.cif = v-cif no-lock),'Не верный код клиента!') help 'F2 - поиск'  v-cifname no-label format "x(40)"  v-rnn no-label format "x(12)" skip
    v-aaafrom format "x(20)" label 'Счет клиента в ЦО' validate(aaachk(v-aaafrom) = '',aaachk(v-aaafrom)) skip
    v-cif-f format "x(6)" label 'Код клиента АФ' validate(v-cif-f <> '','Введите код клиента!') help 'F2 - поиск'  v-cifname-f no-label format "x(40)"  v-rnn-f no-label format "x(12)" skip
    v-aaa-f format "x(20)" label 'Счет клиента в АФ' validate(v-aaa-f <> '','Счет не найден!') skip
with side-label row 10 width 100 centered title "ПЕРЕНОС КОНТРАКТОВ"  frame fcif.
/**************/
define query q-transfer for t-transfer.
define button bsave label "Сохранить". /*для реквизитов просрочника*/

define browse b-transfer query q-transfer
displ t-transfer.ciffrom label "Клиент ЦО" format "x(6)"
      t-transfer.clnamefrom label "ФИО/Наименование" format "x(40)"
      t-transfer.aaafrom label "Счет ЦО" format "x(20)"
      t-transfer.cifto label "Клиент АФ" format "x(6)"
      t-transfer.aaato label "Счет АФ" format "x(20)"
      with 30 down overlay no-label no-box.

define frame ft b-transfer  help "<Enter>-Изменить, <Ins>-Ввод, <F4>-Выход" " " bsave
 with width 110 row 3 overlay no-label title "Ввод реквизитов задолжника".
/**************************/
find first sysc where sysc.sysc = 'ourbnk' no-lock no-error.
if not avail sysc then do:
    message 'Нет параметра ourbnk в sysc!' view-as alert-box title 'ВНИМАНИЕ'.
    return.
end.
if sysc.chval <> 'TXB00' then do:
    message 'Данный пукт только для ЦО' view-as alert-box title 'ВНИМАНИЕ'.
    return.
end.

for each transfer no-lock:
    create t-transfer.
    buffer-copy transfer to t-transfer.
    find first cif where cif.cif = transfer.ciffrom no-lock no-error.
    if avail cif then t-transfer.clnamefrom = trim(cif.prefix) + ' ' + trim(cif.name).
end.

on "end-error" of b-transfer in frame ft do:
    message 'Сохранить изменения?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE " ВНИМАНИЕ !"
    update v-save.
    if v-save then apply 'choose' to bsave in frame ft.
end.

on "return" of b-transfer in frame ft do:
    find current t-transfer no-lock no-error.
    if not avail t-transfer then return.

    assign v-cif = t-transfer.ciffrom
          v-cifname = t-transfer.clnamefrom
          v-aaafrom = t-transfer.aaafrom
          v-cif-f = t-transfer.cifto
          v-aaa-f = t-transfer.aaato
          v-rnn = t-transfer.rnnfrom
          v-rnn-f = t-transfer.rnnto
          v-cifname-f = t-transfer.clnameto.

    v-cifold = v-cif.
    v-cifold-f = v-cif-f.
    v-aaafromold = v-aaafrom.
    v-aaaold-f = v-aaa-f.


    display v-cif v-cifname v-aaafrom v-cif-f v-rnn v-aaa-f v-rnn-f v-cifname-f with frame fcif.

    update v-cif with frame fcif.
    find first cif where cif.cif = v-cif no-lock no-error.
    v-cifname = trim(cif.prefix) + ' ' + trim(cif.name).
    v-rnn = cif.bin.
    display v-cifname v-rnn with frame fcif.
    if cif.geo <> '021' then v-kod = '2'.
    else v-kod = '1'.
    find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and sub-cod.d-cod = 'secek' no-lock no-error.
    if avail sub-cod and sub-cod.ccode <> 'msc' then v-kod = v-kod + sub-cod.ccode.
    else v-kod = ''.

    repeat ON ENDKEY UNDO, RETURN:
        update v-aaafrom with frame fcif.
        find first b-transfer where b-transfer.aaafrom = v-aaafrom no-lock no-error.
        if avail b-transfer then message "Для данного счета ЦО уже есть соответствие!".
        else leave.
    end.
    find first aaa where aaa.aaa = v-aaafrom no-lock no-error.
    v-crc = aaa.crc.

    find first txb where txb.bank = 'TXB16' and txb.consolid no-lock no-error.
    if avail txb then do:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        repeat ON ENDKEY UNDO, RETURN:
           update v-cif-f with frame fcif.
           run almcif.
           if v-cif-f <> '' then leave.
        end.
        display v-cifname-f v-rnn-f with frame fcif.


        repeat ON ENDKEY UNDO, RETURN:
           update v-aaa-f with frame fcif.
           run vcchkaaa.
           find first b-transfer where b-transfer.aaato = v-aaa-f no-lock no-error.
           if avail b-transfer then do:
               message "Для данного счета АФ уже есть соответствие!".
               v-aaa-f = ''.
           end.
           if v-aaa-f <> '' then leave.
        end.
        if connected ("txb") then disconnect "txb".
    end.

    if v-kbe = '' and v-kod <> '' then v-kbe = v-kod.
    if v-kod = '' and v-kbe <> '' then v-kod = v-kbe.
    do transaction:
    find current t-transfer exclusive-lock.
    assign t-transfer.ciffrom = v-cif
          t-transfer.clnamefrom = v-cifname
          t-transfer.aaafrom = v-aaafrom
          t-transfer.cifto = v-cif-f
          t-transfer.aaato = v-aaa-f
          t-transfer.rnnfrom = v-rnn
          t-transfer.rnnto = v-rnn-f
          t-transfer.clnameto = v-cifname-f
          t-transfer.kod = v-kod
          t-transfer.kbe = v-kbe.


    if v-cifold <> v-cif or v-cifold-f <> v-cif-f or v-aaafromold <> v-aaafrom or v-aaaold-f <> v-aaa-f then
    assign t-transfer.uwhn = g-today
           t-transfer.uwho = g-ofc.
    end.
    open query q-transfer for each t-transfer no-lock.
    find first t-transfer no-lock no-error.
    if avail t-transfer then b-transfer:refresh().
end.

on "insert-mode" of b-transfer in frame ft do:
    create t-transfer.
    assign t-transfer.id = next-value(transferid)
           t-transfer.rwhn = g-today
           t-transfer.rwho = g-ofc.

    b-transfer:set-repositioned-row(b-transfer:focused-row, "always").
    v-rid = rowid(t-transfer).
    open query q-transfer for each t-transfer no-lock.
    reposition q-transfer to rowid v-rid no-error.
    find first t-transfer no-lock no-error.
    if avail t-transfer then b-transfer:refresh().

    apply "return" to b-transfer in frame ft.
    find first t-transfer where rowid(t-transfer) = v-rid no-lock.
    if t-transfer.ciffrom = '' or t-transfer.cifto = '' or t-transfer.aaafrom = '' or t-transfer.aaato = '' then do transaction:
        find current t-transfer exclusive-lock.
        delete t-transfer.
    end.

end.

on choose of bsave in frame ft do:
   i = 0.
   find first t-transfer no-lock no-error.
   if avail t-transfer then do:
       for each t-transfer no-lock:
         find first transfer where transfer.id = t-transfer.id exclusive-lock no-error.
         if not avail transfer then create transfer.
         buffer-copy t-transfer to transfer.
       end.
       i = i + 1.
   end.

   if i > 0 then  message " Данные сохранены " view-as alert-box information.
   else message " Данные для сохранения отсутствуют " view-as alert-box information.
end.

open query q-transfer for each t-transfer no-lock.
enable all with frame ft.
wait-for choose of bsave or window-close of current-window.