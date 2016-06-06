/* sbork3str.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
 * AUTHOR
        27/09/2012 id01143
 * BASES
        BANK COMM TXB
 * CHANGES
        06/02/2013 Sayat(id01143) - перекомпиляция в связи с изменениями по ТЗ 1697
 */

def new shared var g-today as date.
def var v-dt as date.
def var i as int initial 0.

def new shared temp-table t-deps /*временная таблица для сбора данных по депозитам*/
    field fil       as char
    field acc       as char
    field amt       as deci
    field opndt     as date
    field duedt     as date
    field intrate   as deci
    field client    as char
    field clrnn     as char
    field clbin     as char
    field depcrc    as int
    field depgl     as int.

def new shared temp-table t-clink
    field clname1   as char
    field clrnn1    as char
    field clbin1    as char
    field clname2   as char
    field clrnn2    as char
    field clbin2    as char
    field linktype  as char
    field pay       as char.


def new shared temp-table t-loan /*временная таблица для сбора данных по кредитам*/
    field fil       as char format "x(30)"   /*филиал*/
    field lon       as char  /*субсчет ГК*/
    field opnamt    as deci
    field amt       as deci
    field prsramt   as deci
    field prvzamt   as deci
    field intrate   as deci
    field zalamt    as deci
    field zalgar    as deci
    field zaldep    as deci
    field zalog     as char
    field zalog1    as char
    field sts       as char
    field opndt     as date
    field isdt      as date
    field duedt     as date
    field grp       as int
    field client    as char
    field clrnn     as char
    field clbin     as char
    field loncrc    as int
    field claddr    as char
    field vid       as char.

find last bank.cls no-lock no-error.
if available bank.cls then g-today = bank.cls.cls + 1.
v-dt = g-today.

empty temp-table t-loan.
empty temp-table t-clink.
empty temp-table t-deps.

/***Бегаем по филиалам*****************************/

find first bank.cmp no-lock no-error.
if not avail bank.cmp then do:
    message " Не найдена запись cmp " view-as alert-box error.
    return.
end.

def var v-path as char no-undo.

if bank.cmp.name matches ("*МКО*") then v-path = '/data/'.
else v-path = '/data/b'.

find bank.sysc where bank.sysc.sysc = "ourbnk" no-lock no-error.
find comm.txb where comm.txb.consolid and comm.txb.bank = bank.sysc.chval no-lock no-error.

for each comm.txb where comm.txb.consolid no-lock:
    if connected ("txb") then disconnect "txb".
    if bank.cmp.name matches ("*МКО*") and (comm.txb.txb=0 or comm.txb.txb=3 or comm.txb.txb=5 or comm.txb.txb=7 or comm.txb.txb=8 or comm.txb.txb=9 or comm.txb.txb=10 or comm.txb.txb=11 or comm.txb.txb=12 or comm.txb.txb=13 or comm.txb.txb=14 or comm.txb.txb=15) then next.
    connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run sbork3(v-dt).
end.

if connected ("txb")  then disconnect "txb".


/*{r-brfilial.i &proc = "sbork3(v-dt)" }*/
/**************************************************/
do transaction:
    for each comm.loansk3 exclusive-lock:
        if avail comm.loansk3 then do:
            delete comm.loansk3.
        end.
    end.
end.

do transaction:
    for each comm.clinksk3 exclusive-lock:
        if avail comm.clinksk3 then do:
            delete comm.clinksk3.
        end.
    end.
end.

do transaction:
    for each comm.depsk3 exclusive-lock:
        if avail comm.depsk3 then do:
            delete comm.depsk3.
        end.
    end.
end.

for each t-loan no-lock:
    do transaction:
        create comm.loansk3.
        assign  comm.loansk3.fil = t-loan.fil
                comm.loansk3.lon = t-loan.lon
                comm.loansk3.opnamt = t-loan.opnamt
                comm.loansk3.amt = t-loan.amt
                comm.loansk3.prsramt = t-loan.prsramt
                comm.loansk3.prvzamt = t-loan.prvzamt
                comm.loansk3.opndt = t-loan.opndt
                comm.loansk3.isdt = t-loan.isdt
                comm.loansk3.duedt = t-loan.duedt
                comm.loansk3.intrate = t-loan.intrate
                comm.loansk3.loncrc = t-loan.loncrc
                comm.loansk3.sts = t-loan.sts
                comm.loansk3.grp = t-loan.grp
                comm.loansk3.zalamt = t-loan.zalamt
                comm.loansk3.zalgar = t-loan.zalgar
                comm.loansk3.zaldep = t-loan.zaldep
                comm.loansk3.zalog = t-loan.zalog
                comm.loansk3.zalog1 = t-loan.zalog1
                comm.loansk3.client = t-loan.client
                comm.loansk3.clrnn = t-loan.clrnn
                comm.loansk3.clbin = t-loan.clbin
                comm.loansk3.claddr = t-loan.claddr
                comm.loansk3.vid = t-loan.vid.
    end.
end.

for each t-clink no-lock:
    do transaction:
        create comm.clinksk3.
        assign  comm.clinksk3.clname1 = t-clink.clname1
                comm.clinksk3.clrnn1 = t-clink.clrnn1
                comm.clinksk3.clbin1 = t-clink.clbin1
                comm.clinksk3.clname2 = t-clink.clname2
                comm.clinksk3.clrnn2 = t-clink.clrnn2
                comm.clinksk3.clbin2 = t-clink.clbin2
                comm.clinksk3.linktype = t-clink.linktype
                comm.clinksk3.pay = t-clink.pay.
    end.
end.

for each t-deps no-lock:
    do transaction:
        create comm.depsk3.
        assign  comm.depsk3.fil = t-deps.fil
                comm.depsk3.acc = t-deps.acc
                comm.depsk3.amt = t-deps.amt
                comm.depsk3.opndt = t-deps.opndt
                comm.depsk3.duedt = t-deps.duedt
                comm.depsk3.intrate = t-deps.intrate
                comm.depsk3.client = t-deps.client
                comm.depsk3.clrnn = t-deps.clrnn
                comm.depsk3.clbin = t-deps.clbin
                comm.depsk3.depcrc = t-deps.depcrc
                comm.depsk3.depgl = t-deps.depgl.
    end.
end.
