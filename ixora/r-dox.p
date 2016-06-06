/* r-dox.p
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
 * BASES
        BANK
 * CHANGES
        07.08.2012 Lyubov - ТЗ №1471, добавлен вывод в Excel таблицы с суммами по ГК

*/

/* Обороты по доходным счетам.
   В.Ким. 15.03.01.
*/

def var f as integer.
def var dt as deci format "->>>,>>>,>>>,>>9.99".
def var ct as deci format "->>>,>>>,>>>,>>9.99".

def var sumd as deci format "->>>,>>>,>>>,>>9.99".
def var sumc as deci format "->>>,>>>,>>>,>>9.99".
def var sumd-c as deci format "->>>,>>>,>>>,>>9.99".
def var sumc-c as deci format "->>>,>>>,>>>,>>9.99".

def var datBegDay as date.
def var datEndDay as date.
def var sumDtKZT as dec format "->>>,>>>,>>>,>>9.99".
def var sumCtKZT as dec format "->>>,>>>,>>>,>>9.99".
def stream  m-out.

{global.i new}
{functions-def.i}
datBegDay = g-today.
datEndDay = g-today.
display datBegDay label " с " datEndDay label " по "
    with row 8 centered  side-labels frame opt title "Введите :".

update datBegDay with frame opt.
update datEndDay with frame opt.
display '   Ждите...   '  with row 5 frame ww centered .
hide frame opt.

define stream m-out1.
output stream m-out1 to glrep.htm.
put stream m-out1 unformatted "<html><head><title>Monthly Report</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out1 unformatted "<br><br><h3>FORTEBANK</h3><br>" skip.
put stream m-out1 unformatted "<h3>ОБОРОТЫ ПО ДОХОДАМ</h3><br>" skip.
put stream m-out1 unformatted "<h3>С " datBegDay " по " datEndDay "</h3><br><br>" skip.

put stream m-out1 unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                        "<tr style=""font:bold"">"
/*1 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Номер счета ГК</TD>"
/*2 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Итого по дебет (в тенге)</TD>"
/*3 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Итого по кредит (в тенге)</TD>"
                        "</TR>" skip.

output stream m-out to rpt.img.
put stream m-out skip
FirstLine( 1, 1 ) format 'x(107)' skip(1)
'                      '
'                     ОБОРОТЫ ПО ДОХОДАМ '  skip
'                      '
'                 ЗА ПЕРИОД ' datBegDay '-' datEndDay skip(1)
FirstLine( 2, 1 ) format 'x(107)' skip.

put stream m-out " " skip.
put stream m-out fill("=", 106) format "x(106)" skip.
put stream m-out "ТРАНЗАКЦИЯ              ДЕБЕТ                КРЕДИТ   ВАЛЮТА   ПРИМЕЧАНИЕ                      ИСПОЛНИТЕЛЬ" skip.
put stream m-out fill("=", 106) format "x(106)" skip.

for each jl where jdt >= datBegDay and jdt <= datEndDay and substring(string(gl),1,1) = "4" break by gl by crc:

    if first-of(jl.gl) then
        assign sumd = 0 sumc = 0.

    accumulate dam (total by gl by crc).
    accumulate cam (total by gl by crc).

        if jl.crc = 1 then do:
            sumd = sumd + jl.dam.
            sumc = sumc + jl.cam.
        end.

        if jl.crc <> 1 then do:
            find last crchis where crchis.rdt <= jl.jdt and crchis.crc = jl.crc no-lock no-error.
            if avail crchis then do:
                sumd-c = jl.dam * crchis.rate[1].
                sumc-c = jl.cam * crchis.rate[1].
            end.
            else do:
                find first crc where crc.crc = jl.crc no-lock no-error.
                message 'Отсутствует курс валюты' crc.code 'за' jl.jdt view-as alert-box.
            end.
            sumd = sumd + sumd-c.
            sumc = sumc + sumc-c.
        end.

    if f = 0 then do:
        put stream m-out "  Счет ГК " gl skip.
        f = 1.
    end.
    put stream m-out jl.jh " " jl.dam " " jl.cam " " jl.crc "        " jl.rem[1] format "x(30)" "  " jl.who skip.
    if jl.crc = 1 then do:
        sumDtKZT = sumDtKZT + jl.dam.
        sumCtKZT = sumCtKZT + jl.cam.
    end.
    if last-of(jl.crc) then do:

        dt = accum total by jl.crc jl.dam.
        ct = accum total by jl.crc jl.cam.

        put stream m-out "  ИТОГО: " format "x(10)" dt "   " ct jl.crc format "->>9" skip.
        put stream m-out " " skip.
    end.
    if last-of(jl.gl) then do:


        put stream m-out1 unformatted
                          "<tr>" skip
        /*1 */            "<td>" jl.gl "</TD>" skip
        /*2 */            "<td>" trim(replace(string(deci(sumd),'>>>>>>>>9.99'),'.',',')) "</td>" skip
        /*3 */            "<td>" trim(replace(string(deci(sumc),'>>>>>>>>9.99'),'.',',')) "</td>" skip
                          "</tr>" skip.
        put stream m-out fill("-", 106) format "x(106)" skip.
        f = 0.
    end.
end.

put stream m-out1 "</table></body></html>" skip.
put stream m-out fill("=", 106) format "x(106)" skip.
put stream m-out "  Итого: " format "x(10)" sumDtKZT "   " sumCtKZT "   1"skip.
output stream m-out close.
output stream m-out1 close.
unix silent cptwin glrep.htm excel.
if not g-batch then do:
   pause 0 before-hide.
   run menu-prt('rpt.img').
   pause before-hide.
end.

{functions-end.i}
