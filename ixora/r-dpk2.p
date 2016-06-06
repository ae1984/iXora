/* r-dpk2.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Отчет о состоянии выпуска загруженных карт
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        16.1.6
 * AUTHOR
        20.02.2013 dmitriy
 * BASES
        BANK COMM TXB
 * CHANGES
        04.07.2013 dmitriy - ТЗ 1940
        30.09.2013 dmitriy - ТЗ 1983
*/

def input parameter p-type as int.

def shared temp-table wrk no-undo
field branch as char
field cmpcode as int
field name as char
field bin as char
field acc as char
field sts as char
field whn as date
field comp as char
field prod as char
field ofc as char
field load_type as char
field profit as char
field ofc2 as char
field deb as char
field cred as char
index acc is primary branch acc.

def shared var v-dt1 as date.
def shared var v-dt2 as date.

def var v-compname as char.
def var v-bank as char.
def var v-bankcode as char.
def var v-profit as char.
def var v-who as char.

find first txb.cmp no-lock no-error.
if txb.cmp.code < 10 then v-bankcode = "TXB0" + string(txb.cmp.code). else v-bankcode = "TXB" + string(txb.cmp.code).

CASE p-type:
    /* 1) Все загруженные 2) Отконтролированные 3) Неотконтролированные 4) Выпущенные */
    WHEN 1 THEN DO:
        for each comm.pcstaff0 where comm.pcstaff0.bank = v-bankcode and comm.pcstaff0.ldt >= v-dt1 and comm.pcstaff0.ldt <= v-dt2 no-lock:
            run CreateWrk.
        end.
    END.

    WHEN 2 THEN DO:
        for each comm.pcstaff0 where comm.pcstaff0.bank = v-bankcode /* and lookup(comm.pcstaff0.sts, "ready,open") > 0 */ no-lock:
            find last txb.crg where txb.crg.des = comm.pcstaff0.cif and txb.crg.regdt >= v-dt1 and txb.crg.regdt <= v-dt2 and txb.crg.stn = 1 no-lock no-error.
            if avail txb.crg then
            run CreateWrk.
        end.
    END.

    WHEN 3 THEN DO:
        for each comm.pcstaff0 where comm.pcstaff0.bank = v-bankcode and comm.pcstaff0.whn >= v-dt1 and comm.pcstaff0.whn <= v-dt2 and lookup(comm.pcstaff0.sts, "edit,reject,aaa,new,print,finmon") > 0 no-lock:
            run CreateWrk.
        end.
    END.

    WHEN 4 THEN DO:
        for each comm.pcstaff0 where comm.pcstaff0.bank = v-bankcode /* and lookup(comm.pcstaff0.sts, "OK,CLOSED") > 0*/  no-lock:
            find last comm.pccards where comm.pccards.aaa = comm.pcstaff0.aaa and comm.pccards.issdt >= v-dt1 and comm.pccards.issdt <= v-dt2 no-lock no-error.
            if avail comm.pccards then
            run CreateWrk.
        end.
    END.
END CASE.


procedure CreateWrk:
        v-compname = "".
        v-profit = "".
        v-who = "".
    find first txb.cif where txb.cif.cif = comm.pcstaff0.cifb no-lock no-error.
    if avail txb.cif then do:
        v-compname = txb.cif.name.

        find first txb.ofc where txb.ofc.ofc = txb.cif.who /*trim(substr(txb.cif.fname,1,8))*/ no-lock no-error.
        if avail txb.ofc then
        find first txb.codfr where txb.codfr.codfr = "sproftcn" and txb.codfr.code = ofc.titcd no-lock no-error.
        if avail txb.codfr then v-profit = txb.codfr.name[1].

        v-who = txb.cif.who.
    end.
    else do:
        v-compname = "".
        v-profit = "".
        v-who = "".
    end.

    find first comm.txb where comm.txb.bank = comm.pcstaff0.bank no-lock no-error.
    if avail comm.txb then v-bank = comm.txb.info. else v-bank = "".

    create wrk.
    wrk.branch  =  v-bank.
    wrk.cmpcode =  txb.cmp.code.
    wrk.name    =  comm.pcstaff0.sname + " " + comm.pcstaff0.fname + " " + comm.pcstaff0.mname.
    wrk.bin     =  comm.pcstaff0.iin.
    wrk.acc     =  comm.pcstaff0.aaa.
    wrk.sts     =  comm.pcstaff0.sts.
    wrk.comp    =  v-compname.
    wrk.prod    =  comm.pcstaff0.pcprod.
    wrk.ofc     =  comm.pcstaff0.who.
    wrk.profit  =  v-profit.
    wrk.ofc2 = /*trim(substr(txb.cif.fname,1,8))*/ v-who.

    if p-type = 1 then wrk.whn  =  comm.pcstaff0.ldt.
    if p-type = 2 then wrk.whn  =  txb.crg.regdt.
    if p-type = 3 then wrk.whn  =  comm.pcstaff0.whn.
    if p-type = 4 then wrk.whn  =  comm.pccards.issdt.

    if comm.pcstaff0.idload = 0 then wrk.load_type = "Ручная 16.1.1".
    else wrk.load_type = "ИБ".


end procedure.

