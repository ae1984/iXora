/* steprep2.p
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

def var ourbank as char.
def var ourcode as integer.
ourbank = comm-txb().
ourcode = comm-cod().
def var dt1 as date.
def var dt2 as date.
def shared var g-today as date.
dt1 = g-today.
dt2 = g-today.
def var i as int.
def var counts as int extent 24.

define temp-table ttax like tax
    field dep as int.

do i = 1 to 24:
    counts[i] = 0.
end.
update dt1 label "Начальная дата" dt2 label "Конечная дата" 
with centered frame df.

for each tax where date >= dt1 and date <= dt2 and duid = ? and comm.tax.txb = ourcode no-lock:
    create ttax.
    buffer-copy tax to ttax.
    ttax.dep = get-dep(tax.uid, tax.date).
end.

output to rpt.img.
put unformatted  "Отчет о налоговых платежах по часам"
skip 
"за период с " 
dt1 format "99.99.9999"
" по "
dt1 format "99.99.9999"
skip(2)
fill("-", 31) format "x(31)" skip(0)
"часы  количество  " skip
fill("-", 31) format "x(31)" skip(0).

FOR EACH ttax NO-LOCK BREAK BY ttax.dep BY ttax.kb:
    
    IF FIRST-OF(ttax.dep) THEN do:
        find first ppoint where point = 1 and depart = ttax.dep no-lock.
        put unformatted skip(1) ppoint.name skip(1).
    end.
                        

    counts[int(truncate(ttax.created / 3600,0)) + 1] = 
            counts[int(truncate(ttax.created / 3600, 0)) + 1] + 1.

    if last-of(ttax.dep) then do:
        do i = 0 to 23:
            put unformatted i format '99' ".00 - " (i + 1) format "99" ".00"
            counts[i + 1] format ">>>>>>>9" skip.
            counts[i + 1] = 0.
        end.
    end.
                            
END.


output close.

run menu-prt("rpt.img").