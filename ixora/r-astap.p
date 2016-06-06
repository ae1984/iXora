/* r-astap.p
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        27.04.2010 marinav - консолидация
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
define variable vibk as integer format "9" init 1.


{astvib.i " ОБОРОТЫ ПО ОСНОВНЫМ СРЕДСТВАМ "}

pause 0.
if vib=4 then  message " 1- по карточкам  2- по группам 3- по счетам " update vibk.
if vib=3 then  message " 1- по карточкам  2- по группам 3- по счетам " update vibk.
if vib=2 then  message " 1- по карточкам  2- по группам " update vibk.


define new shared stream m-out.
output stream m-out to "rep.html".
put stream m-out "<html><head><title>" + v-nbank1 + "</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>"  skip.

put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""style=""border-collapse: collapse"">".


{r-brfilial.i &proc = "r-astap2(vmc1,vmc2,v-fag,v-gl,v-ast,vib,vibk)"}



put stream m-out "</table>" skip.
put stream m-out "</body></html>".
output stream m-out close.
unix silent cptwin rep.html excel.


