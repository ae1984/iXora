/* steprep9.p
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
 * CHANGES
*/


{get-dep.i}
{comm-txb.i}

def var seltxb as int.
seltxb = comm-cod().

def var dt1 as date.
def var dt2 as date.
def shared var g-today as date.
dt1 = g-today.
dt2 = g-today.
def var i as int.
def var counts as int extent 24.

define temp-table ttax like tax
    field dep as int.

do i = 8 to 22:
    counts[i] = 0.
end.
update dt1 label "Начальная дата" dt2 label "Конечная дата" 
with centered frame df.

for each tax where tax.txb = seltxb and date >= dt1 and date <= dt2 and duid = ? no-lock:
    create ttax.
    buffer-copy tax to ttax.
    ttax.dep = get-dep(tax.uid, tax.date).
end.

for each commonpl where commonpl.txb = seltxb and date >= dt1 and date <= dt2 and deldate = ? no-lock:
    create ttax.
    ttax.date = commonpl.date.
    ttax.uid = commonpl.uid.
    ttax.created = commonpl.cretime.
    ttax.dep = get-dep(commonpl.uid, commonpl.date).
end.

for each p_f_payment where p_f_payment.txb = seltxb and date >= dt1 and date <= dt2 no-lock:
    create ttax.
    ttax.date = p_f_payment.date.
    ttax.uid = p_f_payment.uid.
    ttax.dep = get-dep(p_f_payment.uid, p_f_payment.date).
end.

output to rpt.img.
put unformatted  "Отчет о платежах СПФ по часам"
skip 
"за период с " 
dt1 format "99.99.9999"
" по "
dt1 format "99.99.9999"
skip(2)
fill("-", 31) format "x(31)" skip(0)
"часы  количество  " skip
fill("-", 31) format "x(31)" skip(0).

FOR EACH ttax NO-LOCK BREAK BY ttax.dep BY ttax.uid:
    
    IF FIRST-OF(ttax.dep) THEN do:
        find first ppoint where point = 1 and depart = ttax.dep no-lock.
        put unformatted skip(1) ppoint.name skip(1).
    end.
                        
    IF FIRST-OF(ttax.uid) THEN do:
        find first ofc where ofc.ofc = ttax.uid no-lock.
        put unformatted skip(1) ofc.name skip(1).
    end.

    counts[int(truncate(ttax.created / 3600,0)) + 1] = 
            counts[int(truncate(ttax.created / 3600, 0)) + 1] + 1.

    if last-of(ttax.uid) then do:
        do i = 8 to 21:
            put unformatted i format '99' ".00 - " (i + 1) format "99" ".00"
            counts[i + 1] format ">>>>>>>9" skip.
            counts[i + 1] = 0.
        end.
    end.
                            
END.


output close.

run menu-prt("rpt.img").
