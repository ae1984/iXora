/* vcrepub1.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Отчет по запросам в упалнамоченные банки
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
        28.01.2011 aigul
 * BASES
        BANK COMM
 * CHANGES
*/


def input parameter p-bank as char.
def input parameter dt as date.
def var v-client as char.
def var v-fil as char.
def var v-id as char.
def shared temp-table wrk
    field fil as char
    field num1 as char
    field num2 as char
    field dt as date
    field nameub as char
    field psnum as char
    field id as char
    field nameid as char.
for each vccontrs where (vccontrs.bank = p-bank or p-bank = "ALL") no-lock:
    for each vcdocs where vcdocs.contract = vccontrs.contract and vcdocs.dndate < dt and (vcdocs.dntype = "28" or vcdocs.dntype = "29") no-lock:
        create wrk.
        wrk.num1 = vcdocs.info[2].
        wrk.num2 = vcdocs.dnnum.
        wrk.dt = vcdocs.dndate.
        wrk.nameub = vcdocs.info[1].
        find first vcps where vcps.contract = vcdocs.contract and vcps.dntype = "01" no-lock no-error.
        if avail vcps then wrk.psnum = vcps.dnnum + string(vcps.num).
        if connected ("txb") then disconnect "txb".
        find first comm.txb where comm.txb.bank = vccontrs.bank and comm.txb.consolid = true no-lock no-error.
        if avail comm.txb then do:
            if connected ("txb") then disconnect "txb".
            connect value(" -db " + replace(comm.txb.path,"/data/","/data/b") + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
            run vcrequest-bank (vccontrs.bank,'', vcdocs.rwho, output v-client, output v-fil, output v-id).
            disconnect "txb".
        end.
        wrk.fil = v-fil.
        wrk.id = vcdocs.rwho.
        wrk.nameid = v-id.
    end.
end.
