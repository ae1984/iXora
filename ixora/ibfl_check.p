/* ibfl_check.p
 * MODULE
        ИБФЛ
 * DESCRIPTION
        Соник-сервис для проверки данных клиента ИБФЛ
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
        13/05/2013 madiyar
 * BASES
        COMM TXB
 * CHANGES
*/

define input parameter p-acc as character no-undo.
define input parameter p-phone as character no-undo.
define input parameter p-idn as character no-undo.
define output parameter p-replyText as character.
define output parameter p-err as character no-undo.


define variable r-phone   as character no-undo.

{ibfl.i}

define variable s-ourbank as character no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not available txb.sysc or txb.sysc.chval = "" then 
do:
    display " There is no record OURBNK in bank.sysc file !!".
    return.
end.
s-ourbank = trim(txb.sysc.chval).


find first txb.aaa where txb.aaa.aaa = p-acc no-lock no-error.
if not available txb.aaa then 
do:
    p-err = "ERR: ibfl_check -> no aaa".
    message p-err.
    return.
end.
find first txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock no-error.
if (not available txb.lgr) or (txb.lgr.led = "ODA") then 
do:
    p-err = "ERR: ibfl_check -> no lgr or lgr.led=ODA".
    message p-err.
    return.
end.
find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
if not available txb.cif then 
do:
    p-err = "ERR: ibfl_check -> no cif (" + txb.aaa.cif + ")".
    message p-err.
    return.
end.
if txb.cif.type = "B" then 
do:
    p-err = "ERR: ibfl_check -> not a personal account (" + txb.aaa.cif + "), cif.type=B".
    message p-err.
    return.
end.
if txb.cif.bin <> p-idn then 
do:
    p-err = "ERR: ibfl_check -> incorrect IDN (" + p-idn + "<>" + txb.cif.bin + ")".
    message p-err.
    return.
end.

r-phone = GetNormTel(p-phone).
if GetNormTel(txb.cif.fax) <> r-phone /*and GetNormTel(txb.cif.tel) <> r-phone and GetNormTel(txb.cif.tlx) <> r-phone*/ then 
do:
    p-err = "ERR: ibfl_check -> incorrect phone # (" + p-phone + '<>' + txb.cif.fax + ")".
    return.
    /*
    find first pcstaff0 where pcstaff0.iin = p-idn no-lock no-error.
    if (not available pcstaff0) or (GetNormTel(pcstaff0.tel[2]) <> r-phone) then 
    do:
        p-err = "ERR: ibfl_check -> incorrect phone # (" + p-phone + '<>' + txb.cif.fax.
        if available pcstaff0 then p-err = p-err + ' or ' + pcstaff0.tel[2].
        p-err = p-err + ")".
        message p-err.
        return.
    end.
    */
end.
message "ibfl_check -> OK, msgBody=" + txb.cif.cif.
p-replyText = txb.cif.cif.
    