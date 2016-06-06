/* bdto1c.p
 * MODULE
        Формирование dbf файла для загрузки в 1С
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
        BANK COMM Перечень пунктов Меню Прагмы
 * AUTHOR
        07/03/07 marinav
 * CHANGES
        08.06.07 marinav
                 marinav
        13.09.2012 Lyubov - закомментировала отправку писем, т.к. они отправлялий уволившимся сотрудникам
*/


{global.i}

def new shared temp-table t-jl
    field type as integer
    field deb1 as char
    field deb2 as char
    field deb3 as char
    field cre1 as char
    field cre2 as char
    field cre3 as char
    field amount as deci
    field des as char
    field data as date
    index main type .

def var outf as char.
def var crlf as char.
def var vfile1 as char.
def var vfile2 as char.
crlf = chr(13) + chr(10).
def new shared var v-dat as date .
def new shared var v-summ as deci init 0.

find last cls no-lock no-error.
v-dat = cls.whn.

update v-dat label " Укажите дату" format "99/99/9999"
                  skip with side-label row 5 centered frame dat .


def new shared temp-table t-comm
    field type as integer
    field deb1 as char
    field deb2 as char
    field deb3 as char
    field cre1 as char
    field cre2 as char
    field cre3 as char
    field amount as deci
    field des as char
    field data as date
    field grp as integer
    field grptype as integer
    index main type cre1.


message 'Формирование отчета за ' v-dat.

/*
if v-dat < 07/01/2007 then run bdto1cold.
                      else run bdto1cnew.
*/

{r-branch.i &proc = "bdto1cold"}
/*{r-branch.i &proc = "bdto1cnew.p"}*/


def stream s1.
OUTPUT STREAM s1 TO jl_lon.txt.

   for each t-jl no-lock :

        put stream s1 unformatted trim(string(t-jl.type,">9")) + "|" +
              trim(t-jl.deb1) + "|" +
              trim(t-jl.deb2) + "|" +
              trim(t-jl.deb3) + "|" +
              trim(t-jl.cre1) + "|" +
              trim(t-jl.cre2) + "|" +
              trim(t-jl.cre3) + "|" +
              trim(string(t-jl.amount,">>>>>>>>>>>>>>>9.99")) + "|" +
              trim(t-jl.des) + "|" +
              string(year(t-jl.data),"9999") + string(month(t-jl.data),"99") + string(day(t-jl.data),"99")
              crlf.

   end.

OUTPUT STREAM s1 CLOSE.


   outf = "MK" + substr(string(year(v-dat),"9999"),3,2) + string(month(v-dat),"99") + string(day(v-dat),"99").

           unix silent value('un-dos jl_lon.txt ' + outf ).

           unix SILENT value ('1c_dbf.pl ' + outf).

           unix silent value('cp txb.dbf ' + outf + '.dbf' ).

           unix SILENT value('rm -f jl_lon.txt').


find first cmp.
define stream rep.
output stream rep to rkc.htm.

put stream rep unformatted "<html><head><title>МКО НАРОДНЫЙ КРЕДИТ</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.

put stream rep unformatted "<br><br><tr align=""left""><td><h3>" cmp.name format 'x(79)'
                 "</h3></td></tr><br><br>" skip.

put stream rep unformatted "<tr align=""center""><td><h3>Движения по кредитам за " string(v-dat) "<BR>".
put stream rep unformatted "</h3></td></tr><br><br>" skip.

put stream rep unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"" align=""center"" valign=""top"" bgcolor=""#C0C0C0"">"
                  "<td>Тип</td>"
                  "<td>Субконто <br> Дебета 1</td>"
                  "<td>Субконто <br> Дебета 2</td>"
                  "<td>Субконто <br> Дебета 3</td>"
                  "<td>Субконто <br> Кредита 1</td>"
                  "<td>Субконто <br> Кредита 2</td>"
                  "<td>Субконто <br> Кредита 3</td>"
                  "<td>Сумма</td>"
                  "<td>Содержание</td>"
                  "<td>Дата</td>" skip.

for each t-jl.
     put stream rep unformatted "<tr align=""right"">"
               "<td align=""center"">" t-jl.type "</td>" skip
               "<td align=""left"">&nbsp;" t-jl.deb1 "</td>" skip
               "<td align=""left"">&nbsp;" t-jl.deb2 "</td>" skip
               "<td align=""left"">&nbsp;" t-jl.deb3 "</td>" skip
               "<td align=""left"">&nbsp;" t-jl.cre1 "</td>" skip
               "<td align=""left"">&nbsp;" t-jl.cre2 "</td>" skip
               "<td align=""left"">&nbsp;" t-jl.cre3 "</td>" skip
               "<td>" replace(trim(string(t-jl.amount, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td align=""left"">" t-jl.des "</td>" skip
               "<td>" t-jl.data "</td>" skip
               "</tr>".

end.
put stream rep "</table></body></html>" skip.
output stream rep close.

vfile1 = outf + ".html".
vfile2 = outf + ".dbf".

unix silent un-win rkc.htm value(vfile1).

/*run mail('id00139@metrobank.kz;id00149@metrobank.kz', "MKO NK <abpk@metrobank.kz>",
             "Файл для загрузки в 1С МКО за " + string(v-dat) , "" , "1", "", vfile1 + ";" + vfile2).*/


unix silent value ("rm txb.dbf").
unix silent value ("rm " + vfile1).
unix silent value ("rm " + vfile2).
unix silent value ("rm " + outf).

/*
OUTPUT STREAM s1 TO rkc.txt.

   for each t-comm no-lock :

        put stream s1 unformatted trim(string(t-comm.type,">9")) + "|" +
              trim(t-comm.deb1) + "|" +
              trim(t-comm.deb2) + "|" +
              trim(t-comm.deb3) + "|" +
              trim(t-comm.cre1) + "|" +
              trim(t-comm.cre2) + "|" +
              trim(t-comm.cre3) + "|" +
              trim(string(t-comm.amount,">>>>>>>>>>>>>>>9.99")) + "|" +
              trim(t-comm.des) + "|" +
              string(year(t-comm.data),"9999") + string(month(t-comm.data),"99") + string(day(t-comm.data),"99")
              crlf.

   end.

OUTPUT STREAM s1 CLOSE.


   outf = "RK" + substr(string(year(v-dat),"9999"),3,2) + string(month(v-dat),"99") + string(day(v-dat),"99").

           unix silent value('un-dos rkc.txt ' + outf ).

           unix SILENT value ('1c_dbf.pl ' + outf).

           unix silent value('cp txb.dbf ' + outf + '.dbf' ).

           unix SILENT value('rm -f rkc.txt').


output stream rep to rkc.htm.

put stream rep unformatted "<html><head><title>TEXAKABANK</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.

put stream rep unformatted "<br><br><tr align=""left""><td><h3> ТОО РКЦ-1</h3></td></tr><br><br>" skip.

put stream rep unformatted "<tr align=""center""><td><h3>Платежи ТОО РКЦ-1 за " string(v-dat) "<BR>".
put stream rep unformatted "</h3></td></tr><br><br>" skip.

put stream rep unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"" align=""center"" valign=""top"" bgcolor=""#C0C0C0"">"
                  "<td>Тип</td>"
                  "<td>Субконто <br> Дебета 1</td>"
                  "<td>Субконто <br> Дебета 2</td>"
                  "<td>Субконто <br> Дебета 3</td>"
                  "<td>Субконто <br> Кредита 1</td>"
                  "<td>Субконто <br> Кредита 2</td>"
                  "<td>Субконто <br> Кредита 3</td>"
                  "<td>Сумма</td>"
                  "<td>Содержание</td>"
                  "<td>Дата</td>" skip.

for each t-comm.
     put stream rep unformatted "<tr align=""right"">"
               "<td align=""center"">" t-comm.type "</td>" skip
               "<td align=""left"">" t-comm.deb1 "</td>" skip
               "<td align=""left"">" t-comm.deb2 "</td>" skip
               "<td align=""left"">" t-comm.deb3 "</td>" skip
               "<td align=""left"">" t-comm.cre1 "</td>" skip
               "<td align=""left"">" t-comm.cre2 "</td>" skip
               "<td align=""left"">" t-comm.cre3 "</td>" skip
               "<td>" replace(trim(string(t-comm.amount, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td align=""left"">" t-comm.des "</td>" skip
               "<td>" t-comm.data "</td>" skip
               "</tr>".

end.
put stream rep "</table></body></html>" skip.
output stream rep close.
vfile1 = outf + ".html".
vfile2 = outf + ".dbf".

unix silent un-win rkc.htm value(vfile1).

run mail('amarina@metrobank.kz', "RKC-1 <abpk@metrobank.kz>",
             "Файл для загрузки в 1С РКЦ за " + string(v-dat) , "" , "1", "", vfile1 + ";" + vfile2).


unix silent value ("rm txb.dbf").
unix silent value ("rm " + vfile1).
unix silent value ("rm " + vfile2).
unix silent value ("rm " + outf).
*/
hide message no-pause.





