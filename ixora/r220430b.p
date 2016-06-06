/* r220430b.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Мониторинг карточных счетов
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
        05.02.2013 dmitriy. ТЗ 1641
 * BASES
        BANK COMM TXB
 * CHANGES
        12.08.2013 dmitriy - ТЗ 2026. Добавлен столбец "Продукт"
        08.10.2013 dmitriy - ТЗ 2037. Добавлен столбец "Спец.инструкции"
*/

def shared temp-table wrk
    field bank     as char
    field cif      as char
    field cifname  as char
    field cifacc   as char
    field acclgr   as int
    field gl       as int
    field ost      as deci
    field prod     as char
    field sp_inst  as char
    index ind is primary bank cifacc.

def shared var v-dt    as date.
def shared var v-today as date.
def var v-bank as char.
def var v-bal  as deci.
def var v-ost  as deci.
def var v-prod as char.
def var v-aas  as char.

find first txb.cmp no-lock no-error.
if avail txb.cmp then v-bank = txb.cmp.name.

for each txb.aaa where (txb.aaa.lgr = "138" or txb.aaa.lgr = "139" or txb.aaa.lgr = "140" or txb.aaa.lgr = "143" or txb.aaa.lgr = "144" or txb.aaa.lgr = "145") no-lock:
    v-ost = 0.
    v-aas = "".

    if v-dt < v-today then do:
        find last txb.histrxbal where txb.histrxbal.subled = "cif" and txb.histrxbal.acc = txb.aaa.aaa and txb.histrxbal.lev = 1 and txb.histrxbal.dt <= v-dt no-lock no-error.
        if avail txb.histrxbal then v-ost = txb.histrxbal.cam - txb.histrxbal.dam.
    end.
    else if v-dt = v-today then do:
        v-ost = txb.aaa.cr[1] - txb.aaa.dr[1].

        find first txb.aas where txb.aas.ln <> 7777777 and txb.aas.aaa = txb.aaa.aaa no-lock no-error.
        if avail txb.aas then v-aas = "Да".
        else v-aas = "Нет".
    end.

    find first comm.pcstaff0 where comm.pcstaff0.aaa = txb.aaa.aaa no-lock no-error.
    if avail comm.pcstaff0 then v-prod = comm.pcstaff0.pcprod.
    else v-prod = "".

    do transaction:
        create wrk.
        wrk.bank    = v-bank.
        wrk.cif     = txb.aaa.cif.
        wrk.cifname = txb.aaa.name.
        wrk.cifacc  = txb.aaa.aaa.
        wrk.acclgr  = int(txb.aaa.lgr).
        wrk.gl      = txb.aaa.gl.
        wrk.ost     = v-ost.
        wrk.prod    = v-prod.
        wrk.sp_inst = v-aas.
    end.
end.
