/* glarp-txb.p
 * MODULE
        Pragma
 * DESCRIPTION
        Список действующих счетов ГК с детализацией АРП - КОНСОЛИДАЦИЯ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        glarp.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        20/01/2005 sasco
 * CHANGES
        27/01/2005 sasco Вывод только действующих счетов ГК + последние проводки
        27/01/2005 sasco Поиск проводок по ГК в обратном порядке по датам
*/

{msg-box.i}
{gl-utils.i}

define shared variable g-today as date.

define variable tgl as int.
define variable cgl as int.

define variable tarp as int.
define variable carp as int.

define variable idat as date.

define temp-table tmpg
            field gl like txb.gl.gl
            field sub like txb.gl.subled
            field name as char
            field dt as date
            field rdt as date
            field ofc as char
            index itmpg is primary gl
            index itmpsub sub.

define temp-table tmpa
            field gl like txb.gl.gl
            field arp like txb.arp.arp
            field name as char
            field dt as date
            field rdt as date
            field ofc as char
            index itmpa is primary gl arp.


/* ************************************************** */
run SHOW-MSG-BOX ("Формирование списка счетов ГК ...").

glcycle:
for each txb.gl where txb.gl.subled <> "" no-lock:
    find first txb.sub-cod where txb.sub-cod.sub = "gld" and 
                                 txb.sub-cod.acc = string (txb.gl.gl) and 
                                 txb.sub-cod.d-cod = "clsa" and 
                                 txb.sub-cod.ccode ne "msc" 
                                 no-lock no-error . 
    if avail txb.sub-cod then next glcycle.
    create tmpg.
    tmpg.gl = txb.gl.gl.
    tmpg.sub = txb.gl.subled.
    tmpg.name = txb.gl.des.
    tmpg.rdt = txb.gl.whn.
    if txb.gl.subled ne "arp" then tgl = tgl + 1.
end.


/* ************************************************** */
run SHOW-MSG-BOX ("Формирование списка счетов АРП ...").

for each tmpg where tmpg.sub = "arp" use-index itmpsub:
    arpcycle:
    for each txb.arp where txb.arp.gl = tmpg.gl no-lock:
        find first txb.sub-cod where txb.sub-cod.sub = "arp" and 
                                 txb.sub-cod.acc = txb.arp.arp and 
                                 txb.sub-cod.d-cod = "clsa" and 
                                 txb.sub-cod.ccode ne "msc" 
                                 no-lock no-error . 
        if avail txb.sub-cod then next arpcycle.
        create tmpa.
        tmpa.gl = tmpg.gl.
        tmpa.arp = txb.arp.arp.
        tmpa.name = txb.arp.des.
        tmpa.rdt = txb.arp.rdt.
        tarp = tarp + 1.
    end.
end.

/* ************************************************** */
run SHOW-MSG-BOX ("Поиск проводок по счетам ГК ...").

for each tmpg where tmpg.sub ne "arp":
    cgl = cgl + 1.
    idat = today.
    run SHOW-MSG-BOX (SUBSTITUTE("Поиск проводок по ГК ... &1 из &2 за &3", cgl, tgl, idat)).
    datcycle:
    do while idat > 01/01/2000:
       run SHOW-MSG-BOX (SUBSTITUTE("Поиск проводок ГК ... &1 из &2 за &3", cgl, tgl, idat)).
       find last txb.jl where txb.jl.jdt = idat and txb.jl.gl = tmpg.gl no-lock use-index jdt no-error.
       if not avail txb.jl then do:
          idat = idat - 1.
          next datcycle.
       end.
       else leave datcycle.
    end.
    if not avail txb.jl then next.
    tmpg.dt = txb.jl.jdt.
    tmpg.ofc = txb.jl.who.
end.


/* ************************************************** */
run SHOW-MSG-BOX ("Поиск проводок по счетам АРП ...").

for each tmpa:
    carp = carp + 1.
    run SHOW-MSG-BOX (SUBSTITUTE("Поиск проводок по счетам АРП ... &1 из &2", carp, tarp)).
    find last txb.jl where txb.jl.gl = tmpa.gl and txb.jl.acc = tmpa.arp no-lock use-index acc no-error.
    if not avail txb.jl then next.
    tmpa.dt = txb.jl.jdt.
    tmpa.ofc = txb.jl.who.
end.

/* ************************************************** */
run SHOW-MSG-BOX ("Формирование отчета ...").

find txb.cmp no-lock.

output to rpt.csv.
put unformatted ";Действующие счета;дата: " g-today ";" cmp.name skip
                "Счет ГК;Наименование счета ГК;Номер АРП;Наименование АРП;Дата открытия счета;Последняя транзакция;Исполнитель" skip.

for each tmpg:
    put unformatted "[" tmpg.gl "];" tmpg.name "; ; ;" tmpg.rdt ";" tmpg.dt ";" tmpg.ofc skip.
    for each tmpa where tmpa.gl = tmpg.gl:
        put unformatted " ; ;[" tmpa.arp "];" tmpa.name ";" tmpa.rdt ";" tmpa.dt ";" tmpa.ofc skip.
    end.
end.
output close.

unix silent cptwin rpt.csv excel.
