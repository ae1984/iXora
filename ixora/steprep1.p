/* steprep1.p
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

define temp-table ttax like tax
    field dep as int.
                
update dt1 label "Начальная дата" dt2 label "Конечная дата" 
with centered frame df.

for each tax where date >= dt1 and date <= dt2 and duid = ? and comm.tax.txb = ourcode no-lock:
    create ttax.
    buffer-copy tax to ttax.
    ttax.dep = get-dep(tax.uid, tax.date).
end.

output to rpt.img.
put unformatted  "Отчет о налоговых платежах по СПФ"
skip
"за период с "
dt1 format "99.99.9999"
" по "
dt2 format "99.99.9999"
skip(2)
fill("-", 47) format "x(47)" skip(0)
"код бюдж количество       сумма        комиссия" skip
fill("-", 47) format "x(47)" skip(0).

FOR EACH ttax NO-LOCK BREAK BY ttax.dep BY ttax.kb:

accumulate ttax.sum
    (sub-count by ttax.kb).
    
accumulate ttax.sum
    (sub-total by ttax.kb).

accumulate ttax.sum
    (sub-count by ttax.dep).
        
accumulate ttax.sum
    (sub-total by ttax.dep).

accumulate ttax.sum
    (count).
        
accumulate ttax.sum
    (total).
            
accumulate ttax.comsum
    (sub-total by ttax.kb).
    
accumulate ttax.comsum
    (sub-total by ttax.dep).
        
accumulate ttax.comsum
    (total).
                    
    IF FIRST-OF(ttax.dep) THEN do:
        find first ppoint where point = 1 and depart = ttax.dep no-lock.
        put unformatted skip(1) ppoint.name skip(1).
    end.
    
    if last-of(ttax.kb) then do:
        put 
            ttax.kb format "999999" 
            (accum sub-count by ttax.kb ttax.sum) format ">>>>>>>>9"
            (accum sub-total by ttax.kb ttax.sum) format ">>>>>>>>>>>>9.99"
            (accum sub-total by ttax.kb ttax.comsum) 
            format ">>>>>>>>>>>>9.99"
            skip.
    end.

    if last-of(ttax.dep) then do:
        put 
            fill("-", 47) format "x(47)" skip(0)
            (accum sub-count by ttax.dep ttax.sum) format ">>>>>>>>>>>>>>9"
            (accum sub-total by ttax.dep ttax.sum) format ">>>>>>>>>>>>9.99"
            (accum sub-total by ttax.dep ttax.comsum)
            format ">>>>>>>>>>>>9.99"
            skip.
    end.
                            
END.

put
    skip(1) "Всего" skip 
    fill("=", 47) format "x(47)" skip(0)
    (accum count ttax.sum) format ">>>>>>>>>>>>>>9"
    (accum total ttax.sum) format ">>>>>>>>>>>>9.99"
    (accum total ttax.comsum)
    format ">>>>>>>>>>>>9.99"
    skip.

output close.

run menu-prt("rpt.img").
