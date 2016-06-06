/* pril.p
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
        22/06/2011 madiyar - убрал из шапки "кредитный деп-т", обеспечение выводится полностью
        25/04/2012 evseev  - rebranding. Название банка из sysc.
        27/04/2012 evseev  - повтор
*/
{nbankBik.i}
def shared var s-lon like lon.lon.
/*def new shared var s-lon like lon.lon.
s-lon = '000144342'.
*/
def var crlf as char.
crlf = chr(10) + chr(13).
def var v-cnt as int init 0.
def var vdat as date.

define stream m-out.
output stream m-out to rpt.html.

find first lon where lon.lon = s-lon.
find first cif where cif.cif = lon.cif.
find first crc where crc.crc = lon.crc.
find first loncon where loncon.lon = s-lon.
find first lonsec1 where lonsec1.lon = s-lon.
find first lnscg where lnscg.lng = s-lon and
            lnscg.f0 > - 1 and lnscg.fpn = 0 and lnscg.flp > 0
            no-lock no-error.
if avail lnscg then vdat = lnscg.stdat.


put stream m-out skip.

put stream m-out "<html><head><title>" + v-nbank1 + ":</title>" crlf
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" crlf
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>"
                 crlf.
put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""3""
                 style=""border-collapse: collapse"">"
                 crlf.
put stream m-out "<tr><td align=""right""><h3>" + v-nbankru + "<br>&nbsp;</td></tr>".

put stream m-out "<tr align=""center""><td><h1>КРЕДИТНОЕ ДОСЬЕ<br><br></td></tr>" crlf.

       put stream m-out "<tr align=""left""><td><h4> " cif.name format 'x(60)' "</td></tr>".
       put stream m-out "<tr align=""left""><td><h4> " cif.cif "</td></tr>".
       put stream m-out "<tr align=""left""><td><h4> Ссудный счет " s-lon "<br><br><br></td></tr>".



       put stream m-out "<tr><td><table border=""1"" cellpadding=""3"" cellspacing=""0""
                  style=""border-collapse: collapse"">" crlf
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""rigth"">--ИНФОРМАЦИЯ-- </td>"
                  "<td bgcolor=""#C0C0C0"" align=""rigth"">--ПО КРЕДИТУ :</td></tr>"
                  crlf crlf.



    put stream m-out "<tr align=""right"">"
               "<td align=""left""> Сумма кредита</td>"
               "<td align=""left""> " lon.opnamt format ">>>,>>>,>>>,>>9.99" " " crc.code "</td>"
               "</tr>"
               crlf.
    put stream m-out "<tr align=""right"">"
               "<td align=""left""> Срок кредита</td>"
               "<td align=""left""> " lon.duedt "</td>"
               "</tr>"
               crlf.
    put stream m-out "<tr align=""right"">"
               "<td align=""left""> Процентная ставка</td>"
               "<td align=""left""> " lon.prem format ">>>,>>>,>>>,>>9.99" "</td>"
               "</tr>"
               crlf.
    put stream m-out "<tr align=""right"">"
               "<td align=""left""> Дата выдачи</td>"
               "<td align=""left""> " vdat "</td>"
               "</tr>"
               crlf.
    put stream m-out "<tr align=""right"">"
               "<td align=""left""> Кредитное соглашение  </td>"
               "<td align=""left""> " loncon.lcnt " от " lon.rdt "</td>"
               "</tr>"
               crlf.
    put stream m-out "<tr align=""right"">"
               "<td align=""left""> Срок погашения процентов</td>"
               "<td> </td>"
               "</tr>"
               crlf.
    put stream m-out "<tr align=""right"">"
               "<td align=""left""> Пролонгация </td>"
               "<td> </td>"
               "</tr>"
               crlf.
    put stream m-out "<tr align=""right"">"
               "<td align=""left""> Цель кредита </td>"
               "<td align=""left""> " loncon.objekts "</td>"
               "</tr>"
               crlf.

    for each lonsec1 where lonsec1.lon = s-lon no-lock:
        if v-cnt = 0 then put stream m-out unformatted "<tr align=""right""><td align=""left"">Обеспечение</td><td align=""left""> " lonsec1.prm "</td></tr>" crlf.
        else put stream m-out unformatted "<tr align=""right""><td align=""left""></td><td align=""left"">" lonsec1.prm "</td></tr>" crlf.
        v-cnt = 1.
    end.

put stream m-out "</table>" crlf.



       put stream m-out "<br><br><br><br><tr><td><table border=""1"" cellpadding=""3"" cellspacing=""0""
                  style=""border-collapse: collapse"">" crlf
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""left"">-----------СВЕДЕНИЯ О ЗАЕМЩИКЕ------------- </td>"
                  "</tr>"
                  crlf crlf.


    put stream m-out "<tr align=""right"">"
               "<td align=""left"">" cif.name format 'x(60)' "</td>"
               "</tr>"
               crlf.
    put stream m-out "<tr align=""right"">"
               "<td align=""left"">" cif.addr[1] " " cif.addr[2] "</td>"
               "</tr>"
               crlf.
    find first aaa where aaa.cif = lon.cif and aaa.lgr begins '1' and aaa.crc = 1 and  aaa.sta ne "C" no-lock no-error.
    if avail aaa then do:
    put stream m-out "<tr align=""right"">"
               "<td align=""left""> т/сч." aaa.aaa " в " + v-nbankru + " </td>"
               "</tr>"
               crlf.
    end.
    put stream m-out "<tr align=""right"">"
               "<td align=""left"">РНН_"cif.jss "</td>"
               "</tr>"
               crlf.

put stream m-out "</table></body></html>" crlf.

output stream m-out close.
unix silent cptwin rpt.html winword.exe.
/*unix silent cptwin rpt.html iexplore.exe. */



