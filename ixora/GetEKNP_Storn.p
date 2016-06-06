/* GetEKNP_Storn.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание - Определение Код,Кбе,КНП для сторнированных проводок.
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
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        12.03.2012 damir - changing copy GetEKNP.p
*/

def input parameter vjh as inte.
def input parameter vln as inte.
def input parameter vdc as char.
def input-output parameter KOd as char.
def input-output parameter KBe as char.
def input-output parameter KNP as char.

def var i as int.

find trxcods where trxcods.trxh = vjh and trxcods.trxln = vln and trxcods.codfr = "locat" no-lock no-error.
if available trxcods then do:
    if vdc = "C" then substring(KOd,1,1) = substring(trxcods.code,1,1).
    else substring(KBe,1,1) = substring(trxcods.code,1,1).
end.

find trxcods where trxcods.trxh = vjh and trxcods.trxln = vln and trxcods.codfr = "secek" no-lock no-error.
if available trxcods then do:
    if vdc = "C" then substring(KOd,2,1) = substring(trxcods.code,1,1).
    else substring(KBe,2,1) = substring(trxcods.code,1,1).
end.

find trxcods where trxcods.trxh = vjh and trxcods.trxln = vln and trxcods.codfr = "spnpl" no-lock no-error.
if available trxcods then KNP = trxcods.code.

/*aigul*/
find first jh where jh.jh = vjh no-lock no-error.
if avail jh then do:
    if jh.sub <> "RMZ" then do:
        find first jl where jl.jh = vjh no-lock no-error.
        if avail jl then do:
            i = r-index( jl.rem[1], 'RMZ' ).
            find first sub-cod where sub-cod.acc = trim( substring(jl.rem[1], i, 10 )) and sub-cod.ccod = "eknp" no-lock no-error.
            if avail sub-cod then KOd = substr(sub-cod.rcode,1,2).
        end.
    end.
end.


