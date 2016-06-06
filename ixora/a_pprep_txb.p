/* a_pprep_txb.p
 * MODULE
        Длительные платежные поручения
 * DESCRIPTION
        отчет
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
        16/07/2013 Luiza ТЗ № 1738
 * BASES
        BANK COMM TXB
 * CHANGES
         30/09/2013 Luiza  - ТЗ 2047
*/

def shared var v-dt1 as date.
def shared var v-dt2 as date.


def shared temp-table lst no-undo
    field  txb    as char
    field  fil    as char
    field  cif    as char
    field  iin    as char
    field  fio    as char
    field  stat   as char
    field  aaa    as char
    field  sum    as decim
    field  crc    as int
    field  who    as char
    field  con    as char
    field  ben    as char
    field  rem    as char
    field  rmz    as char
    field  rmztim as int
    field  knp    as char
    field  fin    as date
    field  dtout  as date
    field  dtin   as date
    field  opl    as int
    field  id     as int
    field  nom    as int
    field  dtnom  as date
    index  idx is primary dtout fil fio .


def var v-bank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
    message "Нет параметра ourbnk sysc!" view-as alert-box.
    return.
end.
v-bank = txb.sysc.chval.

find first txb.cmp no-lock no-error.
if available txb.cmp then displ ("Ждите идет сбор данных " + txb.cmp.name) format "x(70)".
pause 0.
for each pplisthis where pplisthis.dtout >= v-dt1 and pplisthis.dtout <= v-dt2 and pplisthis.txb = v-bank no-lock.
    create lst.
    find first txb.cif where txb.cif.cif  = pplisthis.cif no-lock no-error.
    if available txb.cif then lst.fio = txb.cif.name.
    find first txb.ppout where txb.ppout.id  = pplisthis.id no-lock no-error.
        if available txb.ppout then do:
            lst.iin    = txb.ppout.bin.
            lst.who    = txb.ppout.who.
            lst.con    = txb.ppout.conwho.
            lst.ben    = txb.ppout.benname + " ИИН:" + txb.ppout.binben + " бик: " + txb.ppout.bic + " банк:" + txb.ppout.bankben + " счет " + txb.ppout.iikben.
            lst.rem    = trim(txb.ppout.remark[1])  + " " +  trim(txb.ppout.remark[2]) + " " +  trim(txb.ppout.remark[3]).
            lst.knp    = txb.ppout.knp.
            lst.fin    = txb.ppout.dtcl.
        end.
    lst.txb    = pplisthis.txb.
    find first txb where txb.bank = pplisthis.txb no-lock no-error.
    if available txb then lst.fil = txb.name.
    lst.cif    = pplisthis.cif.
    if pplisthis.stat = "Новый" then lst.stat   = "не был отправлен".
    else do:
        if pplisthis.stat = "OW" then lst.stat   = "на обработке в ДПК".
        else lst.stat   = pplisthis.stat.
    end.
    lst.aaa    = pplisthis.aaa.
    lst.sum    = pplisthis.sum.
    lst.crc    = pplisthis.crc.
    lst.dtout  = pplisthis.dtout.
    lst.opl    = pplisthis.opl.
    lst.nom    = pplisthis.nom.
    lst.dtnom  = pplisthis.dtnom.
    lst.rmz    = pplisthis.remtrz.
    find first txb.remtrz where txb.remtrz.remtrz = pplisthis.remtrz no-lock no-error.
    if available txb.remtrz then lst.rmztim = txb.remtrz.rtim.
end.


