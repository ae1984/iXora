/* pkgok.p
 * MODULE
        ПотребКредиты
 * DESCRIPTION
        ОТЧЕТ - Ведомость для ГОК-Хромтау       
        ТЗ 393      
 * RUN
 * CALLER
 * SCRIPT
 * INHERIT
 * MENU
        
 * AUTHOR
        07.07.2006 marinav
 * CHANGES
        11/07/06 marinav - историю записываем в таблицу pkgok
        27/07/06 marinav - плюс 400 тенге комиссии
*/

{global.i}
{pk.i "new"}

/* период отчета */
def var d1 as date no-undo init today format '99/99/9999'.
def var d2 as date no-undo init today format '99/99/9999'.
def var i as int no-undo.
def var v-rnn as char init '061600005040'.
def var v-podr as char.
def var v-sum as deci.
def var v-sumall as deci.
def var v-nom as inte.

update d1 label "Начало периода" d2 label "Конец периода"
       with side-labels centered overlay frame dtfr.
hide frame dtfr.

output to pkgok.html.

put unformatted 
                "<HTML> <HEAD> <TITLE>TEXAKABANK</TITLE>" skip
                "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
                "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip.
/*
put unformatted 
                "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: xx-small;" skip
                "</STYLE></HEAD>" skip
                "<BODY LEFTMARGIN=""20"">" skip.
*/
put unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0""  style=""border-collapse: collapse"">" skip.

put unformatted "<tr align=""right""><td colspan = 8>Приложение N 2 к Договору N 1-ПК от  </td></tr>".
put unformatted "<tr align=""right""><td colspan = 8> '_____' ________________ 2006 г. </td></tr>".

find first sysc where sysc.sysc = 'bdgok' exclusive-lock no-error.
if not avail sysc then do:
    message "Нет настройки sysc = 'bdgok' !!! " view-as alert-box. return. end.

v-nom = sysc.inval.
sysc.inval = sysc.inval + 1.
release sysc.
put unformatted "<tr align=""center""><td colspan = 8><h4>Сводная ведомость N " string(v-nom) " на  " string(g-today) "</td></tr>".

put unformatted "<tr align=""center""><td colspan = 8><h4>удержание из заработной платы клиентов </td></tr>".
put unformatted "<tr align=""center""><td colspan = 8><h4>в счет погашения кредита за период " string(d1) " - " string(d2) "</td></tr>".
put unformatted "<tr></tr><tr></tr>" skip(1).


put unformatted "<table border=""1"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" SKIP. 

put unformatted "<tr style=""background: #D0D0D0;"">"
                "<td ><b> N п/п </b></td>"
                "<td ><b> ФИО клиента </b></td>"
                "<td ><b> Номер текущего <br> счета клиента </b></td>"
                "<td ><b> Подразделение <br> по месту работы <br> заемщика </b></td>"
                "<td ><b> Табельный <br> номер по месту <br> работы</b></td>"
                "<td ><b> Сумма очередного <br> платежа заемщика</b></td>"
                "<td ><b> Сумма по тарифу <br> за перечисление <br> (0.25% от суммы платежа) </b></td>"
                "<td ><b> Итого к удержанию <br> из зарплаты заемщика </b></td>"
                "</tr>" skip.

i = 0.
v-sumall = 0.
/* ГОК начали выдавать в июне 2006*/
for each pkanketa where bank = s-ourbank and pkanketa.credtype = '6 ' and pkanketa.docdt >= 05/01/06 and pkanketa.jobrnn = v-rnn no-lock.

          find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.ln = pkanketa.ln
               and pkanketh.kritcod = 'jobpodr' and pkanketh.credtype = '6' no-lock no-error.
          if avail pkanketh then v-podr = pkanketh.value1. 
                            else v-podr = ''.
          v-sum = 0.
          for each lnsch where lnsch.lnn = pkanketa.lon and lnsch.f0 > 0 and stdat >= d1 and stdat <= d2  no-lock.
              v-sum = v-sum + lnsch.stval.
          end.
          for each lnsci where lnsci.lni = pkanketa.lon and lnsci.f0 > 0 and idat >= d1 and idat <= d2  no-lock.
              v-sum = v-sum + lnsci.iv-sc.
          end.
          if v-sum > 0 then do:
                i = i + 1.
                put unformatted "<tr>"
                                "<td> " i " </td>"
                                "<td>    " pkanketa.name " </td>"
                                "<td>&nbsp;" pkanketa.aaa  "</td>"
                                "<td>    " v-podr        "</td>"
                                "<td>     </td>"
                                "<td>    " replace(trim(string(v-sum + 400, "->>>>>>>>>>>9.99")),".",",") "</td>"
                                "<td>    " replace(trim(string((v-sum + 400)* 0.0025, "->>>>>>>>>>>9.99")),".",",") "</td>"
                                "<td>    " replace(trim(string(((v-sum + 400) * 1.0025), "->>>>>>>>>>>9.99")),".",",") "</td>"
                                "</tr>" skip.
                v-sumall = v-sumall + v-sum + 400.
                /*записать в таблицу для дальнейшей обработки*/
                create pkgok.
                assign pkgok.bank = s-ourbank
                       pkgok.nom = string(v-nom)
                       pkgok.cif = pkanketa.cif
                       pkgok.name = pkanketa.name
                       pkgok.aaa = pkanketa.aaa
                       pkgok.jobpodr = v-podr
                       pkgok.jobrnn = v-rnn
                       pkgok.tabnom = ''
                       pkgok.sum = v-sum + 400
                       pkgok.sumcom = (v-sum + 400)* 0.0025
                       pkgok.rdt = g-today
                       pkgok.dt1 = d1
                       pkgok.dt2 = d2.  
           end.
end.

put  unformatted "<tr>"
                "<td> </td>"
                "<td> Итого </td>"
                "<td> </td>"
                "<td> </td>"
                "<td> </td>"
                "<td><b> " replace(trim(string(v-sumall, "->>>>>>>>>>>9.99")),".",",") "</b></td>"
                "<td><b> " replace(trim(string(v-sumall * 0.0025, "->>>>>>>>>>>9.99")),".",",") "</b></td>"
                "<td><b> " replace(trim(string((v-sumall * 1.0025), "->>>>>>>>>>>9.99")),".",",") "</b></td>"
                "</tr>" skip.

put unformatted "</table>".
put unformatted "<tr></tr><tr></tr></table><br><br>".

put unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0""  style=""border-collapse: collapse"">" skip.

put unformatted "<br><br><tr align=""left""><td colspan = 8>Сумма тарифа за перечислеине ___________  тенге  </td></tr>".
put unformatted "<tr align=""left""><td colspan = 8> Подлежит перечислению филиалу АО 'TEXAKABANK' в г Актобе ____________ тенге </td></tr>".
put unformatted "<tr></tr><tr></tr></table>".

put unformatted
  "<TABLE border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"" valign=""top"">" skip
    "<TR valign=""top"" align=""left"">" skip
      "<TD colspan = 4>Директор филиала АО 'TEXAKABANK' в г.Актобе</TD>" skip
      "<TD colspan = 3>Директор Донского горно-обогатительного комбината филиала АО 'ТНК Казхром'</TD>" skip
    "<TR></TR>"
    "</TR>"
    "<TR valign=""top"" align=""left"">" skip
        "<TD colspan = 4>_________________________________ Ташенова Е А</TD>" skip
        "<TD colspan = 3>_________________________________ Логинов Н М</TD>" skip
    "</TR>" skip
    "<TR valign=""top"" align=""left"">" skip
      "<TD colspan = 4>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(подпись, м.п.)</TD>" skip
      "<TD colspan = 3>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(подпись, м.п.)</TD>" skip
    "</TR>" skip.

put unformatted "</table></body></html>".

output close.
unix silent value ("cptwin pkgok.html excel").
unix silent value ("rm pkgok.html").

