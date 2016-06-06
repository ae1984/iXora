/* GetEKNP.p
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
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
        27.10.2011 aigul - исправила вывод КОД для RMZ
        30.07.2013 damir - Внедрено Т.З. № 1494.
        30.09.2013 damir - Внедрено Т.З. № 1648.
*/
def input parameter vjh as inte.
def input parameter vln as inte.
def input parameter vdc as char.
def input-output parameter KOd as char.
def input-output parameter KBe as char.
def input-output parameter KNP as char.

def var i as inte.

find trxcods where trxcods.trxh = vjh and trxcods.trxln = vln and trxcods.trxt <> ? and trxcods.codfr = "spnpl" no-lock no-error.
if available trxcods then KNP = trxcods.code.

find trxcods where trxcods.trxh = vjh and trxcods.trxln = vln and trxcods.trxt <> ? and trxcods.codfr = "locat" no-lock no-error.
if available trxcods then do:
    if vdc = "D" then substring(KOd,1,1) = substring(trxcods.code,1,1).
    else substring(KBe,1,1) = substring(trxcods.code,1,1).
end.

find trxcods where trxcods.trxh = vjh and trxcods.trxln = vln and trxcods.trxt <> ? and trxcods.codfr = "secek" no-lock no-error.
if available trxcods then do:
    if vdc = "D" then substring(KOd,2,1) = substring(trxcods.code,1,1).
    else substring(KBe,2,1) = substring(trxcods.code,1,1).
end.

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
