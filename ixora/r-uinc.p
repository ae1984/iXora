/* r-uinc.p
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
        06/09/06 marinav - изменила условие по jl под индекс jdt
 */

/*
   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/

define var dtFirst as date init today.
define var dtSecond as date init today.
define var strCif as character.
define var strName as character format "x(30)".
def stream  m-out.
def var date$ as date.
def var total$ as dec format "->>>,>>>,>>>,>>9.99".
def var totsum$ as dec format "->>>,>>>,>>>,>>9.99".
def var totacc$ as dec format "->>>,>>>,>>>,>>9.99". 
def var USD$ as dec.
def var val$ as char format "x(3)".
{global.i}
{functions-def.i}
find last cls.
date$ = cls.whn.
find last crchis where crchis.crc = 2 and crchis.whn <= date$.
USD$ = crchis.rate[1].
/*dtFirst = g-today.
dtSecond = g-today.*/
display dtFirst label " с " dtSecond label " по "
    with row 8 centered  side-labels frame opt title "Введите :".
    
update dtFirst with frame opt.
update dtSecond with frame opt.
display '   Ждите...   '  with row 5 frame ww centered .
hide frame opt.
    
output stream m-out to rpt.img.
put stream m-out skip
'                      '
'       ОТЧЕТ ПО ИНКАССАЦИИ'  skip
'                      '
'ЗА ПЕРИОД С ' dtFirst ' ПО ' dtSecond skip(1).

displ 'begin ' string(time, "HH:MM") skip.

put stream m-out " " skip.
put stream m-out fill(" ", 60) format "x(60)" "          в тенге" skip.
put stream m-out fill("=", 79) format "x(79)" skip.
put stream m-out "КОД     СЧЕТ           НАИМЕНОВАНИЕ                                     СУММА" skip.
put stream m-out fill("=", 79) format "x(79)" skip.

for each jl where jl.jdt >= dtFirst and jl.jdt <= dtSecond and jl.dc = "C" and jl.acc matches ("...729...") no-lock break by jl.acc:

    accumulate jl.cam (total by jl.acc).
    if last-of(jl.acc) then do:
        find first arp where arp.arp = jl.acc no-error.
        strCif = arp.cif.
        find first cif where cif.cif = strCif no-error.
        strName = trim(trim(cif.prefix) + " " + trim(cif.name)).
        total$ = (accum total by jl.acc jl.cam).
        totsum$ = totsum$ + total$.
        put stream m-out strCif jl.acc "     " strName format "x(35)" total$ skip.
    end.
end.
displ 'end ' string(time, "HH:MM") skip.
put stream m-out fill("=", 79) format "x(79)" skip.
put stream m-out "ИТОГО: " totsum$ at 59 skip.
output stream m-out close.
if not g-batch then do:
   pause 0 before-hide.
   run menu-prt('rpt.img').
   pause before-hide.
end.
{functions-end.i}                                    
                                    
