/* r-astopv.p
 * MODULE
        Основные средства
 * DESCRIPTION
        Отчет - Операции с осн.средствами по видам операций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        6-1-4-4
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        27.06.06 sasco   - Переделал поиск в hist (по ындэксу opdate)
        25/04/2012 evseev  - rebranding. Название банка из sysc.
*/

{mainhead.i}
{nbankBik.i}
define var vmc1 as date.
define var vmc2 as date.
define variable v-ast like ast.ast.
define variable v-gl like ast.gl.
define variable v-fag like ast.fag.
define variable vib as integer format "9".
def var v-asttr as char.

{astvib.i " Операции с основными средствами "}

pause 0.
form skip(1)  	" ОПЕРАЦИЯ    :" v-asttr at 26 format "x(8)" asttr.atdes with row 15 frame am centered no-labels .
update v-asttr validate(can-find(asttr where asttr.asttr=v-asttr no-lock) or v-asttr="", "проверьте код опер. ") with frame am.

if v-asttr ne "" then
do:
    find asttr where asttr.asttr=v-asttr no-lock no-error.
    if avail asttr then displ asttr.atdes with frame am.
end.
pause 0.


define new shared stream m-out.
output stream m-out to "rep.html".
put stream m-out "<html><head><title>" + v-nbank1 + "</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>"  skip.

put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""style=""border-collapse: collapse"">".


{r-brfilial.i &proc = "r-astopv2.p(vmc1,vmc2,v-fag,v-gl,v-ast,vib,v-asttr)"}



put stream m-out "</table>" skip.
put stream m-out "</body></html>".
output stream m-out close.
unix silent cptwin rep.html excel.




