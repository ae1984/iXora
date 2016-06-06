/* r-astopk.p
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
        25/04/2012 evseev  - rebranding. Название банка из sysc.
        27/04/2012 evseev  - повтор
*/

{mainhead.i}
{nbankBik.i}
define var vmc1 as date.
define var vmc2 as date.
define variable v-ast like ast.ast.
define variable v-gl like ast.gl.
define variable v-fag like ast.fag.
define variable vib as integer format "9".

{astvib.i " Операции с основными средствами "}

pause 0.
define new shared stream m-out.
output stream m-out to "rep.html".
put stream m-out "<html><head><title>" + v-nbank1 + "</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>"  skip.

put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""style=""border-collapse: collapse"">".


{r-brfilial.i &proc = "r-astopk2.p(vmc1,vmc2,v-fag,v-gl,v-ast,vib)"}



put stream m-out "</table>" skip.
put stream m-out "</body></html>".
output stream m-out close.
unix silent cptwin rep.html excel.



