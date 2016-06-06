/* lnlib.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Библиотека процедур для классификации кредита на конец каждого месяца
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
        26.12.2003 marinav
 * CHANGES
        20/08/2004 madiyar - функции в зависимости от значения 2го вх. пар-ра меняют оценки кд-менеджера или риск-менеджера
        17/07/2008 madiyar - небольшие исправления
        12/04/2011 madiyar - возможность удаления проставленного признака пролонгации
        13/04/2011 madiyar - перекомпиляция
*/

{global.i}
{kd.i}

def shared temp-table t-klass no-undo like kdlonkl.

function defdata returns char (p-spr as char, p-value as char).
    def var vp-param as char.
    if p-spr = "" then vp-param = trim(p-value).
    else do:
        find bookcod where bookcod.bookcod = p-spr and bookcod.code = p-value no-lock no-error.
        if avail bookcod then vp-param = trim(bookcod.name).
    end.
    return vp-param.
end.

function defdata1 returns decimal (p-spr as char, p-value as char).
    def var vp-rat as decimal.
    if p-spr = "" then vp-rat = 0.
    else do:
        find bookcod where bookcod.bookcod = p-spr and bookcod.code = p-value no-lock no-error.
        if avail bookcod then vp-rat = deci(trim(bookcod.info[1])).
    end.
    return vp-rat.
end.

procedure prat.
    def input parameter v-cod as char.
    def var v-param as char.
    def var v-rat as deci.
    
    find first t-klass where  t-klass.kod = v-cod.
    find first kdklass where kdklass.kod = t-klass.kod no-lock no-error.
    
    v-param = defdata (kdklass.sprav, t-klass.val1).
    v-rat = defdata1 (kdklass.sprav, t-klass.val1).
    
    t-klass.valdesc = v-param.
    t-klass.rating = v-rat.
end.

procedure plong.
    def input parameter v-cod as char.
    def var v-param as char.
    def var v-rat as decimal.
    
    find first t-klass where t-klass.kod = v-cod.
    find first kdklas where kdklas.kod = t-klass.kod no-lock no-error.
    
    if trim(t-klass.val1) = '' then assign t-klass.valdesc = '' t-klass.rating = 0.
    else do:
        find bookcod where bookcod.bookcod = 'kdlong' and bookcod.code = '02' no-lock no-error.
        if avail bookcod then assign v-param = bookcod.name 
                                     v-rat = deci(trim(bookcod.info[1])).
        t-klass.valdesc = v-param.
        t-klass.rating = decimal(t-klass.val1) * v-rat no-error.
        if error-status:error then assign t-klass.val1 = '' t-klass.valdesc = '' t-klass.rating = 0.
    end.
end.
