 /* gcvp_send.p
 * MODULE
        экспресс кредиты по ПК
 * DESCRIPTION
        Запрос в ГЦВП
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
        11/11/2013 Luiza ТЗ 1831
 * BASES
 		BANK COMM
 * CHANGES
*/

{global.i}

def var s-credtype as char init '10' no-undo.
def shared var v-cifcod   as char no-undo.
def shared var s-ln       as inte no-undo.
def var p-sik as char.
def var p-lastname as char.
def var p-firstname as char.
def var p-midname as char.
def var p-plastname as char.
def var p-birthdt as char.
def var p-numpas as char.
def var p-dtpas as char.
def var v-file as char.
def var v-date as char.
def var v-sr as char.
def var v-dirq as char. /*/data/import/gcvp/ */
def var num as inte.
def var v-codrel as char.
def var v-qtype as inte.

def var fname as char.
def var v-dira as char.
def var v-diri as char.
def var i as inte.
def var v-suma as deci.
def var v-gcvptxt as char.
def var v-select  as inte.

define temp-table t-gcvp
field txt as char format "x(50)".

def stream out1.

{sysc.i}
{pk-sysc.i}
{srvcheck.i}

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
 display " There is no record OURBNK in bank.sysc file !!".
 pause.
 return.
end.
s-ourbank = trim(sysc.chval).

find first pcstaff0 where pcstaff0.bank = s-ourbank and pcstaff0.cif = v-cifcod use-index bc no-lock no-error.
if not available pcstaff0 then do:
    message 'Не найдены данные по ПК' view-as alert-box.
    return.
end.
find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.cif = v-cifcod and pkanketa.ln = s-ln and pkanketa.credtype = "10" use-index bankcif no-lock no-error.


find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.cif = v-cifcod and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'gcvpres' no-lock no-error.
if avail pkanketh then do:
    message 'Запрос в ГЦВП уже был отправлен' pkanketh.rdt '. Отправить еще раз?' view-as alert-box buttons yes-no title '' update v-ans as logical.
end.
if not avail pkanketh or v-ans then do:
    assign num = next-value(pk-gcvp,COMM).
    v-sr = string(get-pksysc-int("gcvpsr")).
    v-date = substr(string(g-today), 1, 6) + string(year(g-today)).
    v-dirq = get-sysc-cha ("pkgcvq").
    v-file = fill("0", 8 - length(trim(string(num)))) + trim(string(num)).
    v-codrel = "".
    v-qtype = 2.

    output stream out1 to rpt.txt.
    put stream out1 unformatted  v-file + "|" + string(g-today,'99.99.9999') +  "|" + pcstaff0.iin + "|" + pcstaff0.sname + "|" + pcstaff0.fname + "|" +
    pcstaff0.mname + "|" + string(pcstaff0.birth,'99.99.9999') +  "|" + pcstaff0.nomdoc +  "|" + string(pcstaff0.issdt,'99.99.9999') +  "|" + v-file + "|" +
    v-date + "|" + string(v-qtype) + "|" skip.

    output stream out1 close.

    unix silent un-win rpt.txt value(v-file).

    if isProductionServer() then do:
        unix silent cp value(v-file) value(v-dirq + v-file).
        find sysc where sysc.sysc = "pkgcvm" no-lock no-error.

        run mail(trim(sysc.chval), "MKO NK <abpk@fortebank.kz>", "Fdjkl358Jd", "" , "1", "", v-file).
        run savelog( "gcvpout", "Отправка файла в ГЦВП экспресс кредиты: " + v-file).

        unix silent cp value(v-file) value(v-dirq + v-file).
        unix silent rm -f value(v-file).
    end.
    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.cif = v-cifcod and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'gcvpres' no-lock no-error.
    if not avail pkanketh then do:
        create pkanketh.
        assign pkanketh.bank     = pcstaff0.bank
               pkanketh.cif      = pcstaff0.cif
               pkanketh.credtype = '10'
               pkanketh.ln       = pkanketa.ln
               pkanketh.kritcod  = 'gcvpres'
               pkanketh.value1   = "metrocombank" + v-file
               pkanketh.rescha[3] = "metrocombank" + v-file
               pkanketh.rdt      = g-today
               pkanketh.rwho     = g-ofc.
    end.
    else do:
        find current pkanketh exclusive-lock no-error.
        pkanketh.value1    = "metrocombank" + v-file.
        pkanketh.rescha[3] = "metrocombank" + v-file.
        pkanketh.rdt       = g-today.
        pkanketh.rwho      = g-ofc.
        find current pkanketh no-lock no-error.
    end.
    create gcvp.
    assign gcvp.bank = s-ourbank
           gcvp.lname = pcstaff0.sname
           gcvp.fname = pcstaff0.fname
           gcvp.mname = pcstaff0.mname
           gcvp.dtb = date(pcstaff0.birth)
           gcvp.iin = pcstaff0.iin
           gcvp.ofc = g-ofc
           gcvp.rdt = g-today
           gcvp.nfile = v-file.
end.
else return.

