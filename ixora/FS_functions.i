/* FS_functions.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - FS_GA.p,FS_KA.p,7SB_rep.p.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK
 * CHANGES
        28.01.2013 damir - Внедрено Т.З. № 1217,1218,1227.
*/
function GetDate returns char (input dt as date):
    return replace(string(dt,"99/99/9999"),"/",".").
end function.

function GetNormSummRash returns char (input summ as deci):
    def var ss1 as deci.
    def var ret as char.

    if summ ge 0 then ss1 = summ.
    else if summ lt 0 then ss1 = - summ.
    else ss1 = 0.
    case r-type1:
        when "В тенге" then ret = string(round(ss1,2),"-zzzzzzzzzzzzzzzzzzzzzzzzz9.99").
        when "В тиынах" then ret = string(round(ss1 * 100,2),"-zzzzzzzzzzzzzzzzzzzzzzzzz9.99").
        when "В тыс.тенге" then ret = string(round(ss1 / 1000,2),"-zzzzzzzzzzzzzzzzzzzzzzzzz9.99").
    end case.

    if summ lt 0 then ret = "-" + ret.
    return trim(replace(ret,".",",")).
end function.

function GetNormSumm returns char (input summ as deci):
    def var ss1 as deci.
    def var ret as char.

    if summ ge 0 then ss1 = summ.
    else if summ lt 0 then ss1 = - summ.
    else ss1 = 0.
    case r-type2:
        when "В тенге" then ret = string(round(ss1,2),"-zzzzzzzzzzzzzzzzzzzzzzzzz9.99").
        when "В тиынах" then ret = string(round(ss1 * 100,0),"-zzzzzzzzzzzzzzzzzzzzzzzzz9").
        when "В тыс.тенге" then ret = string(round(ss1 / 1000,0),"-zzzzzzzzzzzzzzzzzzzzzzzzz9").
    end case.

    if summ lt 0 then ret = "-" + ret.
    return trim(replace(ret,".",",")).
end function.

function GetNormAll returns char (input summ as deci):
    def var ss1 as deci.
    def var ret as char.

    if summ ge 0 then ss1 = summ.
    else if summ lt 0 then ss1 = - summ.
    else ss1 = 0.

    ret = string(ss1,"-zzzzzzzzzzzzzzzzzzzzzzzzz9.99").

    if summ lt 0 then ret = "-" + ret.
    return trim(replace(ret,".",",")).
end function.

function GetLoansType returns char(input p-gl4 as inte).
    def var v-res as char.

    v-res = "".

    if lookup(string(p-gl4),"1401,1403,1411") gt 0 then v-res = "Краткосрочные".
    else if lookup(string(p-gl4),"1417") gt 0 then v-res = "Долгосрочные".
    else if lookup(string(p-gl4),"1424") gt 0 then v-res = "Linking".

    return v-res.
end function.

function GetCrcType returns char(input p-crccode as char).
    def var v-res as char.
    def var v-NAT as char init "KZT".
    def var v-SKV as char init "AUD,KRW,HKD,DKK,USD,EUR,JPY,CAD,MXN,NZD,ILS,NOK,SGD,GBP,SEK,CHF,ZAR". /*Свободно-конвертируемые валюты*/

    v-res = "".
    if lookup(p-crccode,v-NAT) gt 0 then v-res = "Национальная".
    else if lookup(p-crccode,v-SKV) gt 0 then v-res = "Свободно-конвертируемая".
    else v-res = "Другая".

    return v-res.
end function.

function GetTypeDate returns char(input p-dt as date).
    def var v-res as char.

    v-res = "".
    if p-dt ne ? then v-res = string(p-dt,"99/99/9999").
    else v-res = "".

    return v-res.
end function.

function GetTypeClass returns char(input p-code as inte).
    def var v-res as char.

    v-res = "".
    if p-code ne 0 then v-res = string(p-code).
    else v-res = "".

    return v-res.
end function.


