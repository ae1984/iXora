/* anoper.p
 * MODULE
        Операционист
 * DESCRIPTION
        АНАЛИЗ НАГРУЗКИ ОПЕРАЦИОНИСТА ПО ВРЕМЕНИ ИСПОЛНЕНИЯ
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        2-3-4
 * AUTHOR
        28/04/01  kim
 * CHANGES
        09.04.2004 nadejda - добавлены no-lock
*/

def var c as int.
def var intTotal as int.
def var strOfficer as char format "x(8)".
def var datBegin as date.
def var datEnd as date.
def var strName as char format "x(107)".
def stream m-out.


{global.i}

{functions-def.i}
find last cls where whn <= g-today no-lock no-error. 
datBegin = cls.whn.
datEnd = datBegin.
strOfficer = g-ofc.

display strOfficer label "LOGIN" datBegin label " с " datEnd label " по "
    with row 8 centered  side-labels frame opt title "Введите:".

update strOfficer with frame opt.    
update datBegin with frame opt.
update datEnd with frame opt.

find ofc where ofc = strOfficer no-lock no-error.
strName = ofc.name.
display 'Ждите...   '  with row 5 frame ww centered .
hide frame opt.   

output stream m-out to rpt.img.
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
for each jh no-lock where jdt >= datBegin and jdt <= datEnd and who = strOfficer break by substring(string(jh.tim, "hh:mm:ss"),1,2):
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

