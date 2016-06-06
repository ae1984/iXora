/* almtvlog.p
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
        12/04/04 kanat поменял вычисление комиссии при формировании отчета
*/

{get-dep.i}
{comm-txb.i}
def var ourbank as char.
def var ourcode as integer.
def var ourlist as char init ''.
ourbank = comm-txb().
ourcode = comm-cod().

def var date as date initial today.
/*def var tsum as decimal.*/
def var totsumt as decimal initial 0.
def var totsum as decimal initial 0.
def var totcom as decimal initial 0.

update date with frame f1.
hide frame f1.

define temp-table tmp like almatv
                  field gdep as int
                  index idx_tmp is primary ndoc gdep.

for each almatv where dtfk = date and almatv.deluid = ? and almatv.txb = ourcode no-lock:
    create tmp.
    buffer-copy almatv to tmp.
    tmp.gdep = get-dep (tmp.uid, date).
end.

OUTPUT TO almatv.log.

put "АО TEXAKABANK" skip
    space(10)
    "Реестр платежей АЛМА ТВ за " date skip(2).

put "No Контракта  Фамилия            Выстав.cумма  Сумма факт.      Комиссия СПФ" 
    skip fill("-", 77) format "x(77)".

for each tmp use-index idx_tmp:  

put skip space(2)
    string(tmp.ndoc) format 'x(11)' " "
    tmp.f    format "x(20)" " "
    tmp.summ   format "->>>>>9.99" 
    tmp.summfk format ">>>>>>>>9.99"         
    round((tmp.summfk / 100), 2) format ">>>>>>>>9.99"
    tmp.gdep format ">>>>9"
    skip.
    assign
          totsum  = totsum  + tmp.summ
          totsumt = totsumt + tmp.summfk
          totcom  = totcom  + tmp.cursfk.
    delete tmp.
end.

put skip
    fill("-", 77) format "x(77)" 
    skip
    "Итого:" space(7)
    totsum format ">>>>>>>>9.99" 
    totsumt format ">>>>>>>>9.99"
    totcom format ">>>>>>>>9.99".
    
output close.

run menu-prt ("almatv.log")    
