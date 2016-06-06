/* audconv.p
 * MODULE
        Депозиты
 * DESCRIPTION
        Отчет по счетам сейфовых ячеек.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * BASES
        BANK COMM
 * AUTHOR
        28/03/09 id00004
 * CHANGES
        08/05/2012 dmitriy - отменил возможность формирования консолид.отчета во всех филиалах, кроме ЦО
*/






def var v-txb as char.
def var v-dep as integer.
def var v-ind as integer.
def new shared var v-dbeg as date.
def new shared var v-txbcode as char.

find last bank.sysc where bank.sysc.sysc = 'ourbnk' no-lock no-error.

if sysc.chval = 'TXB00' then do:
    v-txb = "Все филиалы|" .
    for each comm.txb where comm.txb.consolid = true no-lock:
        v-txb = v-txb + txb.info + "|" .
    end.
end.
else do:
    find first comm.txb where comm.txb.consolid = true and comm.txb.city = integer(substr(bank.sysc.chval,4,2)) no-lock no-error.
    if avail comm.txb then do:
        v-txb = txb.info + "|" .
    end.
end.

v-txb = SUBSTR (v-txb, 1, LENGTH(v-txb) - 1).



 update "Введите дату формирования отчета " v-dbeg  with frame cc row 14  column 30 no-label no-box.

 if v-dbeg = ? then do:
    message "Вы ввели неверную дату, продолжение невозможно ".
    return.
 end.
 hide frame  cc.



run sel2 (" Выберите филиал", v-txb, output v-dep).


v-ind = 1.
v-txbcode = "ALL" .
for each comm.txb where comm.txb.consolid = true no-lock:
    v-ind = v-ind + 1.
    if v-ind = v-dep then do:
       v-txbcode = comm.txb.bank.

       leave.
    end.
end.




def var file1 as char.



  file1 = "file1.html".
  output to value(file1).
    {html-title.i}


/******************************************************************************/

find last bank.sysc where bank.sysc.sysc = 'ourbnk' no-lock no-error.

if sysc.chval = 'TXB00' then do:
    for each comm.txb where comm.txb.consolid no-lock:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run audconv2.
    end.
    if connected ("txb")  then disconnect "txb".
end.
else  do:
    find first comm.txb where comm.txb.consolid and comm.txb.city = integer(substr(bank.sysc.chval,4,2)) no-lock no-error.
    if avail comm.txb then do:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run audconv2.
    end.
    if connected ("txb")  then disconnect "txb".
end.

/******************************************************************************/

  {html-end.i " "}
  output close .
  unix silent cptwin value(file1) excel.



