/* nomer.i
 * MODULE
        Переводы
 * DESCRIPTION
        Переводы (выгрузка в файл)
 * RUN
        create-file.p, payment-file.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        .
 * AUTHOR
        18/07/05 nataly
 * BASES
        BANK COMM
 * CHANGES
        13.01.2012 damir - добавил printord.p
        07.03.2012 damir - добавил входной параметр в printord.p.

*/

find last acheck where acheck.jh = string(s-jh) and acheck.dt = g-today no-lock no-error.
if not avail acheck then do:
    v-chk = "".
    v-chk = string(NEXT-VALUE(krnum)).
    create acheck.
    acheck.jh = string(s-jh).
    acheck.num = string(day(g-today),"99") + string(month(g-today),"99") + string(year(g-today)) + substr(g-ofc, 4, 3) + v-chk.
    acheck.dt = g-today.
    acheck.n1 = v-chk.
    release acheck.
end.

find last acheck where acheck.jh = string(s-jh) and acheck.dt = g-today no-lock no-error.
if avail acheck then do:
    find first jl where  jl.jh = s-jh and jl.gl = 100100 no-lock no-error.
    if avail jl and dc = 'd' then do:
        if v-noord = no then run vou_bank2(2,1, "").
        else run printord(s-jh,"").
    end.
    if avail jl and dc = 'c' then do:
        if v-noord = no then run vou_bank2(2,2, "").
        else run printord(s-jh,"").
    end.
end.
else do:
    if v-noord = no then run vou_bank(2).
    else run printord(s-jh,"").
end.
