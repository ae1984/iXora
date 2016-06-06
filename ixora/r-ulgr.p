/* r-ulgr.p
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

/*Программа, подсчитывающая количество счетов клиентов по группам*/
/*Отчет необходим для упр. отчета "Анализ деп. ф/л в долл"*/
def stream  m-out.
def var date$ as date.
def var total$ as dec format "->>>,>>>,>>>,>>9.99".
def var totsum$ as dec format "->>>,>>>,>>>,>>9.99". 
def var totacc$ as int.
def var USD$ as dec.
def var val$ as char format "x(3)".
{global.i new}
{functions-def.i}
find last cls.
date$ = cls.whn.
find last crchis where crchis.crc = 2 and crchis.whn <= date$.
USD$ = crchis.rate[1].
output stream m-out to rpt.img.
put stream m-out skip
FirstLine( 1, 1 ) format 'x(107)' skip(1)
'                      '
'АНАЛИЗ СЧЕТОВ КЛИЕНТОВ ПО ГРУППАМ '  skip
'                      '
'           ЗА ' date$ skip(1)
FirstLine( 2, 1 ) format 'x(107)' skip.

put stream m-out " " skip.
put stream m-out fill(" ", 60) format "x(60)" "в тыс. долларов США" skip.
put stream m-out fill("=", 79) format "x(79)" skip.
put stream m-out "ГРУППА    НАИМЕНОВАНИЕ                                СУММА    КОЛИЧЕСТВО" skip.
put stream m-out fill("=", 79) format "x(79)" skip.

/*define var datEnd as date.
update datEnd.
output to "lgr.txt".
put stream m-out datEnd skip. */
for each aaa where aaa.sta <> "C" and (aaa.whn <= date$) no-lock break by aaa.lgr:
    accumulate cbal(count by aaa.lgr).
    if aaa.crc = 1 then do:
        total$ = (total$ + aaa.cbal).
    end.
    else do:
        find last crchis where crchis.whn <= date$ and crchis.crc = aaa.crc.
        total$ = (total$ + (aaa.cbal * crchis.rate[1])).
    end.
            
    if last-of(aaa.lgr) then do:
        total$ = total$ / 1000 / USD$.
        totsum$ = totsum$ + total$.
        find lgr where lgr.lgr = aaa.lgr.
        totacc$ = totacc$ + accum count by aaa.lgr aaa.cbal.
        put stream m-out aaa.lgr "       " lgr.des format "x(30)" total$ "    "accum count by aaa.lgr aaa.cbal skip.
        total$ = 0.
    end.
end.
put stream m-out fill("=", 79) format "x(79)" skip.
put stream m-out "ИТОГО: " totsum$ at 41 "    " totacc$ skip.
output stream m-out close.
if not g-batch then do:
   pause 0 before-hide.
   run menu-prt('rpt.img').
   pause before-hide.
end.
{functions-end.i}
         
