/* vcreprslc1.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Отчет по по контрактам с РС/СУ
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
def input parameter v-dtb as date.
def input parameter v-dte as date.
def input parameter v-reptype as char.
def input parameter v-repvid as char.

def var v-client as char.
def var v-fil as char.
def var v-id as char.
def var v-txbbank as char.
def var i as integer.

def shared temp-table wrk
    field fil as char
    field cifname as char
    field rslc as char
    field num as char
    field dt as date
    field ctnum as char
    field ctdt as date
    field psnum as char
    field stat as char
    field sts as char
    field expimp as char.

i = 0.
for each vccontrs where (vccontrs.bank = p-bank or p-bank = "ALL") and (vccontrs.expimp = v-reptype or v-reptype = 'A')
and (vccontrs.sts = v-repvid or v-repvid = 'V') no-lock:
    for each vcrslc where vcrslc.contract = vccontrs.contract and vcrslc.dndate < v-dte  no-lock:
        create wrk.
        if connected ("txb") then disconnect "txb".
        find first comm.txb where comm.txb.bank = vccontrs.bank and comm.txb.consolid = true no-lock no-error.
        if avail comm.txb then do:
            if connected ("txb") then disconnect "txb".
            connect value(" -db " + replace(comm.txb.path,"/data/","/data/b") + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
            run vcrequest-bank (vccontrs.bank,vccontrs.cif, vcrslc.rwho, output v-client, output v-fil, output v-id).
            disconnect "txb".
        end.
        wrk.fil = v-fil.
        wrk.cifname = v-client.
        wrk.rslc = vcrslc.dntype.
        wrk.num = vcrslc.dnnum.
        wrk.dt = vcrslc.dndate.
        wrk.ctnum = vccontrs.ctnum.
        wrk.ctdt = vccontrs.ctdate.
        find first vcps where vcps.contract = vcrslc.contract and vcps.dntype = "01" no-lock no-error.
        if avail vcps then wrk.psnum = vcps.dnnum + string(vcps.num).
        wrk.stat = vcrslc.info[1].
        wrk.sts = vccontrs.sts.
        wrk.expimp = vccontrs.expimp.
    end.
end.

