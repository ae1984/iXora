/* printord.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание - Печать ордеров
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
        16.01.2012 damir - small changess
        07.03.2012 damir - убрал shared parameter s-jh, выходила ошибка....
        11.03.2012 damir - добавил счет ГК при расчете КОД, КБЕ, КНП.
        12.03.2012 damir - добавил расчет КОД, КБЕ, КНП при сторнировании кассовой проводки.
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        23.05.2012 damir - добавил defprint.i.
        21.06.2012 damir - начальное значение l-prn = yes.
        12.07.2012 damir - убрал input parameters (КОд,КБе,КНП) передаваемые в printord2.p.
        30.07.2013 damir - Внедрено Т.З. № 1494.
        30.09.2013 damir - Внедрено Т.З. № 1648.
*/
{global.i}

def input parameter jh as inte.
def input parameter str as char.

{defprint.i "new"}

def var vcash as logi.
def var l-prn as logi init yes format "да/нет".

find first jh where jh.jh = jh no-lock no-error.
if not avail jh then return.

jhnum = jh.jh. v-info = trim(str).
empty temp-table ljl.
for each jl where jl.jh = jh.jh no-lock:
    create ljl.
    buffer-copy jl to ljl.
end.

vcash = no.
for each ljl where ljl.jh = jh.jh and ljl.ln <> 0 no-lock:
    if ljl.gl = 100100 or ljl.gl = 100500 then vcash = yes.
end.

if vcash then do:
    message "Печатать кассовый ордер?" update l-prn.
    if l-prn then run printord2.
end.
empty temp-table ljl.


