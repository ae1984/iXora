/* a_cur.p
 * MODULE
        Название модуля
 * DESCRIPTION
        проверка курсов для наличных обменных операций
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
        05/04/2013 Luiza
 * BASES
        BANK
 * CHANGES
*/

    define input parameter vcrc as int.
    define output parameter vcur as logical.

    def var c as char.
    def var d as char.
    vcur = no.
    find first sysc where sysc.sysc = "scrc-order" no-lock no-error.
    if avail sysc and sysc.loval = yes then do:
        message "Курс для работы с наличной валютой не установлен! Операция не возможна!!" view-as alert-box.
        vcur = yes.
        return.
    end.
    for each sysc where sysc.sysc = "scrc" no-lock:
        c = sysc.chval.
        if (index(c,string(vcrc)) > 0) then do:
            d = substr(c,index(c,string(vcrc)),3).
            if substr(d,3,1) = "1" then do:
                message "Курс валюты не соответствует опорному курсу! Операция не возможна!" view-as alert-box.
                vcur = yes.
                return.
            end.
        end.
    end.



