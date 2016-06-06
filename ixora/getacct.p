/* getacct.p
 * MODULE
    Комиссии
 * DESCRIPTION
    Опреление счета для снятия комиссии
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
 * CHANGES
        01.08.2003 nadejda - оптимизация циклов
        30.03.2006 u00121 - Добавил "шапку", добавил no-undo в описание локальных переменных
        09/10/2007 madiyar - переделал расчет взимаемой комиссии и остающегося долга
        12/10/2007 madiyar - мелкое исправление
        23.04.10 marinav  - переменная v-oda-accnt теперь like aaa.aaa.
*/

def input parameter v-cif like cif.cif.
def input parameter v-pref like aaa.aaa.
def input parameter v-amt as deci.
def input parameter v-crc like crc.crc.

def output parameter v-racct like aaa.aaa init "".
def output parameter v-ramt as deci.
def output parameter v-debt as deci.

def buffer bcrc for crc.

def var v-rate as deci no-undo.
def var v-rateb as deci no-undo.
def var v-bal as deci   no-undo.
def var v-avail-bal as deci no-undo.
def var v-hold-bal as deci no-undo.
def var v-frozen-bal as deci no-undo.
def var v-cred-line as deci no-undo.
def var v-cred-line-used as deci no-undo.
def var v-oda-accnt like aaa.aaa no-undo.

find first bcrc where bcrc.crc = v-crc no-lock no-error.
if not avail bcrc then do:
    message "Не найдена валюта с кодом " v-crc skip 
        "при определении счета для снятия комиссии!" skip 
        "Код клиента " v-cif skip 
        "Определение счета комиссии не возможно!" view-as alert-box.
    return.
end.
else v-rateb = bcrc.rate[1].


v-ramt = 0.
if v-pref <> "" and v-pref <> ? then do: /* с конкретного счета */
    
    find first aaa where aaa.aaa = v-pref no-lock no-error. 
    if avail aaa then do:
        find first lgr where lgr.lgr = aaa.lgr no-lock no-error.
        if avail lgr and lookup(lgr.led, "DDA,SAV") > 0 then do:
            find first sub-cod where sub-cod.acc = v-pref and sub-cod.sub = "cif" and sub-cod.d-cod = "flg90" no-lock no-error.
            if not (avail sub-cod and sub-cod.ccode = "no") then do:
                find first crc where crc.crc = aaa.crc no-lock.
                v-rate = crc.rate[1].
                v-racct = v-pref.
                if (aaa.cbal - aaa.hbal) * v-rate >= v-amt * v-rateb then do:
                    v-ramt = round(v-amt * v-rateb / v-rate,2).
                    v-debt = 0.
                end.
                else do:
                    v-ramt = aaa.cbal - aaa.hbal.
                    if v-ramt < 0 then v-ramt = 0.
                    v-debt = round((v-amt * v-rateb - v-ramt * v-rate) / v-rateb,2).
                end.
            end.
        end.
    end.
    
end.
else do: /* с любого счета */
    
    v-ramt = -1. v-rate = 1.
    for each crc no-lock:
    c-aaa:
        for each aaa where aaa.cif = v-cif no-lock:
            /*01.08.2003 nadejda*/
            if aaa.crc <> crc.crc or sta = "C" or aaa.lgr = "235" then next c-aaa.
            
            find first lgr where lgr.lgr = aaa.lgr no-lock no-error.
            if lookup(lgr.led, "DDA,SAV") = 0 then next c-aaa.
                    
            find first sub-cod where sub-cod.acc = aaa.aaa and sub-cod.sub = "cif" and sub-cod.d-cod = "flg90" no-lock no-error.
            if avail sub-cod and sub-cod.ccode = "no" then next c-aaa.
            
            run aaa-bal777 (input aaa.aaa,
                            output v-bal,
                            output v-avail-bal,
                            output v-hold-bal,
                            output v-frozen-bal,
                            output v-cred-line,
                            output v-cred-line-used,
                            output v-oda-accnt).
            if v-avail-bal * crc.rate[1] >= v-amt * v-rateb then do:
                v-racct = aaa.aaa.
                v-ramt = round(v-amt * v-rateb / crc.rate[1],2).
                v-debt = 0.
                return.
            end.
            else do:
                if v-avail-bal * crc.rate[1] >= v-ramt * v-rate then do:
                    v-racct = aaa.aaa.
                    v-ramt = v-avail-bal.
                    v-rate = crc.rate[1].
                end.
            end.
        end.
    end.
    
    if v-ramt < 0 then v-ramt = 0.
    v-debt = round((v-amt * v-rateb - v-ramt * v-rate) / v-rateb,2).
    
end.


