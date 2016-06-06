/* r-nagr.p
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

/* АНАЛИЗ НАГРУЗКИ ОПЕРАЦИОНИСТА ПО ВРЕМЕНИ ИСПОЛНЕНИЯ
   КИМ В.
   28/04/01
*/

def var c as int.
def var intTotal as int.
def var strOfficer as char format "x(8)".
def var datBegin as date.
def var datEnd as date.
def var strName as char format "x(107)".
def stream m-out.
output stream m-out to rpt.img.
{global.i new}
{functions-def.i}
find last cls where whn <= today. 
datBegin = cls.whn.
datEnd = datBegin.
display strOfficer label "LOGIN" datBegin label " с " datEnd label " по "
    with row 8 centered  side-labels frame opt title "Введите:".
update strOfficer with frame opt.    
update datBegin with frame opt.
update datEnd with frame opt.
find ofc where ofc = strOfficer.
strName = ofc.name.
display 'Ждите...   '  with row 5 frame ww centered .
hide frame opt.   
put stream m-out skip
FirstLine( 1, 1 ) format 'x(107)' skip(1)
'    '
'АНАЛИЗ НАГРУЗКИ ОПЕРАЦИОНИСТА '  skip
'    '
' ЗА ПЕРИОД ' datBegin '-' datEnd skip(1)
FirstLine( 2, 1 ) format 'x(107)' skip.
put stream m-out " " skip.
put stream m-out strName skip.
put stream m-out "=====================================" skip.
put stream m-out "| Начало интервала | Количество ТРЗ |" skip.
put stream m-out "=====================================" skip.
for each jh where jdt >= datBegin and jdt <= datEnd and who = strOfficer break by substring(string(jh.tim, "hh:mm:ss"),1,2):
    c = c + 1.
    if last-of(substring(string(jh.tim, "hh:mm:ss"),1,2)) then do:
        put stream m-out "| " trim(substring(string(jh.tim, "hh:mm:ss"),1,2)) format "x(2)" ".00"  "            | " c "     |" skip.
        put stream m-out "+------------------+----------------+" skip.
        intTotal = intTotal + c.
        c = 0.
    end.
end.
put stream m-out "| ИTOГО:           | " intTotal "     |" skip.
put stream m-out "+------------------+----------------+" skip.
put stream m-out " " skip.
put stream m-out "*за исключением платежей в пенс.фонд" skip.
put stream m-out " и интернет-платежей" skip.
output stream m-out close.
if not g-batch then do:
   pause 0 before-hide.
   run menu-prt('rpt.img').
   pause before-hide.
end.      
{functions-end.i}
