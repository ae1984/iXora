/* repnds.p
 * MODULE
        Налоговая отчетность
 * DESCRIPTION
        Реестр счетов-фактур
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
        02.08.2008 - marinav
 * CHANGES
        06.11.09 marinav - добавлено 2 отчета
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/


{global.i}
{nbankBik.i}

def new shared var dt1 as date .
def new shared var dt2 as date .

     update
              dt1 label "  С"  help " Задайте начальную дату отчета" skip
              dt2 label " ПО"  help " Задайте конечную дату отчета" skip
              with row 8 centered  side-label frame opt title "Задайте период отчета".
     hide frame  opt.


define new shared stream m-out.
output stream m-out to "rep.html".

define new shared stream m-out1.
output stream m-out1 to "rep1.html".

define new shared stream m-err.
output stream m-err to "err.html".

put stream m-out "<html><head><title>" + v-nbank1 + "</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>"  skip.

put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""style=""border-collapse: collapse"">".

put stream m-out "<tr align=""center""><td><h3> Реестр счетов-фактур по приобретению за период <br> c " string(dt1) " по " dt2 "<h3></td></tr><br><br>"  skip.
put stream m-out "<br><br><tr></tr>" skip.




put stream m-out1 "<html><head><title>" + v-nbank1 + "</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>"  skip.

put stream m-out1 "<table border=""0"" cellpadding=""0"" cellspacing=""0""style=""border-collapse: collapse"">".

put stream m-out1 "<tr align=""center""><td><h3> Счета-фактуры по приобретению с датой выписки ранее " string(dt1) " </h3></td></tr><br><br>".
put stream m-out1 "<br><br><tr></tr>" skip.



put stream m-err "<html><head><title>" + v-nbank1 + "</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>"  skip.

put stream m-err "<table border=""0"" cellpadding=""0"" cellspacing=""0""style=""border-collapse: collapse"">".

put stream m-err "<tr align=""center""><td><h3> Расхождения Реестра счетов-фактур по приобретению от поставщиков со счетом 185100 </h3></td></tr><br><br>".
put stream m-err "<br><br><tr></tr>" skip.



{r-branch.i &proc = "repnds1"}


put stream m-out "</table>" skip.
put stream m-out "</body></html>".
put stream m-out1 "</table>" skip.
put stream m-out1 "</body></html>".
put stream m-err "</table>" skip.
put stream m-err "</body></html>".

output stream m-out close.
output stream m-out1 close.
output stream m-err close.

unix silent cptwin rep.html excel.
unix silent cptwin rep1.html excel.
unix silent cptwin err.html excel.


