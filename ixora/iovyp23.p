/* iovyp23.p
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Формирование кредитных графиков для интернет банкинга.
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
        BANK COMM TXB
 * AUTHOR
        10/16/2010 id00004
 * CHANGES
        30.01.2011 id00004 добавил формирование выписки в DBF
        02.01.2013 damir - Переход на ИИН/БИН. Оптимизация кода.
        28.01.2013 damir - <Доработка выписок, выгружаемых в DBF - файл>. Оптимизация кода.
*/
{chbin_txb.i}
{iovypshared.i}

def input  parameter pEXTID as char no-undo.
def input  parameter g_date as date no-undo.
def input  parameter pAccount as char no-undo.
def output parameter rdes as char no-undo.
def output parameter totalCount as inte no-undo.
def output parameter okpo as char no-undo.
def output parameter bankName as char no-undo.
def output parameter bankRNN as char no-undo.
def output parameter clientCode as char no-undo.
def output parameter clientName as char no-undo.
def output parameter clientRNN as char no-undo.
def output parameter sm as deci no-undo.
def output parameter sm1 as deci no-undo.

def buffer b-aaa for txb.aaa.
def buffer b-jl for txb.jl.

def var coun as inte.
def var v-ost as deci.
def var v-rem as char no-undo.
def var i as inte no-undo.
def var vln as inte no-undo.
def var acctype as char no-undo.
def var v-RnnBnn as char.

if length(pAccount) > 18 then do:
    find first txb.aaa where txb.aaa.aaa = pAccount no-lock no-error.
    if not avail txb.aaa then do: rdes = 'Счет не найден'. return. end.
end.

find txb.sysc where txb.sysc.sysc = "bnkbin" no-lock no-error.
find txb.cmp no-lock no-error.
find first txb.cif where txb.cif.cif =  pEXTID no-lock no-error.

clientCode = txb.cif.cif.
clientName = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).
if v-bin then do:
    clientRNN = txb.cif.bin.
    bankRNN = trim(txb.sysc.chval).
end.
else do:
    clientRNN = txb.cif.jss.
    bankRNN = trim(txb.cmp.addr[2]).
end.

okpo = ''.
find first txb.cmp no-lock no-error.


/*
if length(pAccount) > 18 then do:
    bankName = "".
    for each txb.lon where txb.lon.cif = txb.aaa.cif  and txb.lon.sts <> 'C' no-lock:
        bankName = bankName + txb.lon.lon + "/".
    end.
end.
else do:
    */
    bankName = ''.
    for each txb.lon where txb.lon.cif = pEXTID  and txb.lon.sts <> 'C' no-lock:
        bankName = bankName + txb.lon.lon + "/".
    end.

    find last txb.lon where txb.lon.lon = pAccount no-lock no-error.
    if avail txb.lon then do:
        v-ost = txb.lon.opnamt.
        coun = 1.
        for each txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.flp = 0 and txb.lnsci.f0 > 0 no-lock:
            create cred.
            cred.num = coun.
            cred.dt = txb.lnsci.idat.
           /* cred.sumcred= string(txb.lon.opnamt).*/
            cred.sumproc = string(txb.lnsci.iv-sc).
            coun = coun + 1.
        end.
        coun = 1.
        for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and lnsch.flp = 0 and lnsch.f0 > 0 no-lock:
            v-ost = v-ost - lnsch.stval.
            find last cred where cred.num = coun no-lock no-error.
            if avail cred then do:
                cred.sumcred= string(txb.lnsch.stval).
                cred.plateg = string(txb.lnsch.stval + decimal(cred.sumproc)).
                cred.ostat = string(v-ost).
            end.
            coun = coun + 1.
        end.
    end.
/*
end.
*/






































