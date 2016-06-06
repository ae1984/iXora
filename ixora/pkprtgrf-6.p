/* pkprtgrf-6.p
 * MODULE
        ПотребКредит КОПИЯ pkprtgrf-6
 * DESCRIPTION
        Печать графика погашения кредита
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
        16.02.2007 marinav
 * CHANGES
        19/02/2007 madiyar - изменил шаренную таблицу
        24/04/2007 madiyar - веб-анкеты
        11/10/07 marinav - комиссия берется из списка tarifex2
        12/08/2008 madiyar - исправил опечатку
        06.04.2009 galina - если кредит не в тенге, берем валютный текущий счет
        20/04/2009 madiyar - if avail tarifex2
        09/09/2009 madiyar - добавил поле com в шаренную таблицу
        30/09/2009 galina - изменила форму вывода графика
        27/10/2009 galina - небольшие изменения в выводе печати и подписи
        20/12/2009 galina - убрала вывод текущего счета клиента
        19/01/2010 galina - добавила ИИН
        23/08/10 aigul - Изменила вывод ОД
        13.04.2011 lyubov - добавила текст договора
        25/04/2012 evseev  - rebranding. Название банка из sysc.
        27/04/2012 evseev  - повтор
        */

{global.i}
{pk.i}
{pk-sysc.i}
{nbankBik.i}

def var v-mpro as deci init 0.
def var v-datastr as char.
def var v-comved as deci init 0.
def var v-file as char.
def var v-refdat as date.
def var v-bal as deci.
def var v-datastrkz as char no-undo.

/*
def buffer b-lon for lon.

def shared temp-table  wrk
    field nn     as integer
    field days   as integer
    field stdat  like lnsch.stdat
    field begs   like lnsch.stval
    field od     like lnsch.stval
    field proc   like lnsch.stval
    field ends   like lnsch.stval.
*/

def shared temp-table wrk no-undo
    field nn     as integer
    field stdat  like lnsch.stdat
    field od     like lnsch.stval
    field proc   like lnsch.stval
    field com    as logi init no
    index idx is primary stdat.

if s-pkankln = 0 then return.

procedure fmsg-w.
    def input parameter p-bank as char no-undo.
    def input parameter p-credtype as char no-undo.
    def input parameter p-ln as integer no-undo.
    def input parameter p-msg as char no-undo.
    find first pkanketh where pkanketh.bank = p-bank and pkanketh.credtype = p-credtype and pkanketh.ln = p-ln and pkanketh.kritcod = "fmsg" exclusive-lock no-error.
    pkanketh.value1 = p-msg.
    find current pkanketh no-lock.
end procedure.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then do:
    message skip " Анкета N" s-pkankln "не найдена !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
end.

def var v-inet as logi init no.
if pkanketa.id_org = "inet" then v-inet = yes.

if trim(pkanketa.lon) <> '' then do:
    find lon where lon.lon = pkanketa.lon no-lock no-error.
    if not avail lon then do:
        if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"pkprtgrf-6 - Ссудный счет N " + pkanketa.lon + " не найден!").
        else message skip " Ссудный счет N" pkanketa.lon "не найден !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
        return.
    end.
end.

find first crc where crc.crc = pkanketa.crc no-lock no-error.
find first cmp no-lock no-error.

run pkdefdtstr(pkanketa.docdt, output v-datastr, output v-datastrkz).
if pkanketa.lon <> '' then do:
    find first tarifex2 where tarifex2.aaa = lon.aaa and tarifex2.cif = lon.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
    if avail tarifex2 then v-comved = tarifex2.ost. else v-comved = 0.
end.
else do:
  v-comved = 0.
/*расчет суммы комиссии*/
  find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "bdacc" no-lock no-error.
  if avail pksysc then v-comved = pkanketa.summa * pksysc.deval / 100.
  else message "Ошибка определения суммы комиссии за обслуживание кредита" view-as alert-box error.
end.

def var v-stamp as char no-undo.
if v-inet then v-stamp = "c:\\tmp\\pkstamp.jpg".
else v-stamp = get-pksysc-char ("dcstmp").

/*define stream m-out.
v-file = "rptgrf.htm".
output stream m-out to value(v-file).

put stream m-out unformatted "<!-- График платежей -->" skip
                 "<html><head><title>ForteBank</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru"">"
                 "<STYLE TYPE=""text/css"">" skip
                 "body, H4, H3 ~{margin-top:0pt; margin-bottom:0pt~}" skip
                 "</STYLE></head><body>" skip.

put stream m-out unformatted "<table WIDTH=100% border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.
put stream m-out unformatted "<tr align=""center""><td colspan=2 style=""font:bold;font-size:14px"">" cmp.name format 'x(79)' "</td></tr>" skip.
put stream m-out unformatted "<tr><td align=""left"" style=""font-size:x-small"" width=""50%"">" entry(1,cmp.addr[1]) "</td><td align=""right"" style=""font-size:x-small""  width=""50%"">" v-datastr "</td></tr>" skip.
put stream m-out unformatted "<tr align=""center""><td colspan=2 style=""font:bold;font-size:12px"">ПРИЛОЖЕНИЕ N 1</td></tr>" skip.

put stream m-out unformatted "<tr align=""center""><td colspan=2 style=""font-size:12px"">к Договору о предоставлении потребительского кредита N " entry(1,pkanketa.rescha[1]) " от " pkanketa.docdt "</td></tr>" skip.

put stream m-out unformatted "<tr align=""center""><td colspan=2 style=""font:bold;font-size:16px"">ГРАФИК ПЛАТЕЖЕЙ</td></tr>" skip.
put stream m-out unformatted "<tr align=""left""><td colspan=""2"" style=""font:bold;font-size:12px"">&nbsp;<br> ФИО заемщика     : " pkanketa.name "</td></tr>" skip.
put stream m-out unformatted "<tr align=""left"">" skip
                             "<td style=""font:bold;font-size:12px""> РНН              : " pkanketa.rnn  "</td>" skip
                             "<td style=""font:bold;font-size:12px""> Дата выдачи кредита : " pkanketa.docdt "</td>"
                             "</tr>" skip.
put stream m-out unformatted "<tr align=""left"">" skip
                             "<td style=""font:bold;font-size:12px""> Уд. личности     : " pkanketa.docnum "</td>" skip
                             "<td style=""font:bold;font-size:12px""> Срок кредита : " pkanketa.srok "</td>" skip
                             "</tr>" skip.
put stream m-out unformatted "<tr align=""left"">" skip
                             "<td style=""font:bold;font-size:12px""> Сумма кредита    : " pkanketa.summa format '>>>,>>>,>>9.99' " " crc.code "</td>" skip
                             "<td style=""font:bold;font-size:12px""> Текущий счет : " if pkanketa.crc = 1 then pkanketa.aaa else pkanketa.aaaval "</td>" skip
                             "</tr>" skip.

put stream m-out unformatted "<tr><td><table border=""1"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">"
                  "<tr style=""font:bold;font-size:x-small"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Основной долг</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Вознаграждение</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">&nbsp;&nbsp;&nbsp;Комиссии&nbsp;&nbsp;&nbsp;</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Итого сумма <br> Очередного платежа</td></tr>" skip.

for each wrk.

     put stream m-out unformatted "<tr align=""right"" style=""font-size:x-small"">"
               "<td align=""left""> " wrk.stdat "</td>"
               "<td> " wrk.od format '>>>,>>>,>>9.99' "</td>" skip
               "<td> " wrk.proc format '>>>,>>>,>>9.99' "</td>" skip
               "<td> " v-comved format '>>>,>>>,>>9.99' "</td>" skip
               "<td> " wrk.od + wrk.proc + v-comved format '>>>,>>>,>>9.99' "</td></tr>" skip.
end.

put stream m-out unformatted "</table></td>" skip.


put stream m-out unformatted "</tr>" skip.
put stream m-out unformatted "<tr align=""left""><td colspan=""2"" style=""font:bold; font-size:16px""><br> С условиями графика платежей ознакомлен(а) и согласен(а).</td></tr>".
put stream m-out unformatted "<tr align=""left""><td colspan=""2"" style=""font:bold; font-size:14px""> Заемщик <br>&nbsp;</td></tr>".
put stream m-out unformatted "<tr align=""left""><td colspan=""2"" style=""font:bold; font-size:16px"">_____________________________________________&nbsp;&nbsp;__________________<br>&nbsp;</td></tr>" skip.
put stream m-out unformatted "<tr align=""left""><td colspan=""2"" style=""font:bold; font-size:14px""> От Банка</td></tr>".

def var v-stamp as char no-undo.
if v-inet then v-stamp = "c:\\tmp\\pkstamp.jpg".
else v-stamp = get-pksysc-char ("dcstmp").

find bookcod where bookcod.bookcod = "credtype" and bookcod.code = s-credtype no-lock no-error.
find first sysc where sysc.sysc = bookcod.info[1] + "podp" no-lock no-error.

put stream m-out unformatted "<tr align=""left""><td colspan=""2"">" skip
  "<table width=""100%"" cellpadding=""0"" cellspacing=""0"" border=""0"">" skip
  "<tr align=""left""><td width=""20""><h4>" + replace(sysc.chval, " ", "&nbsp;") + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</h4></td>" skip.
put stream m-out unformatted "<td height=""50"" valign=""center"">" s-dogsign
                 "<IMG border=""0"" src=""" + v-stamp + """ width=""160"" height=""160"" >"
                 "</td></tr></table></td></tr>" skip.
put stream m-out unformatted "</table></body></html>".

output stream m-out close.

if v-inet then unix silent value("mv " + v-file + " /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "; chmod 666 /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "/" + v-file).
else unix silent value("cptwin " + v-file + " iexplore").*/


def var v-filkz as char no-undo.
def var v-fil as char no-undo.
def var v-citykz  as char no-undo.
def var v-city  as char no-undo.
def var v-dognomkz  as char no-undo.
def var v-dognom as char no-undo.
def var v-clname  as char no-undo.
def var v-clrnn as char no-undo.
def var v-cldoc as char no-undo.
def var v-stdt  as char no-undo.
def var v-duedt as char no-undo.
def var v-cliik as char no-undo.
def var v-clname1  as char no-undo.
def var v-graf as char no-undo.
def var v-clname1_1  as char no-undo.
def var v-clnamekz1_1 as char no-undo.
def var v-bankpod as char no-undo.
def var v-ostsum as deci no-undo.
def var v-iin as char no-undo.
def buffer b-pkanketa for pkanketa.

/*ИИН*/
find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "iin" no-lock no-error.
if avail pkanketh and pkanketh.value1 <> "" then v-iin = pkanketh.value1.

run pkdefdtstr(g-today, output v-datastr, output v-datastrkz).
v-graf = "".
v-city = entry(1,cmp.addr[1]).
v-clname1 = "".
find sysc where sysc.sysc = "bnkadr" no-lock no-error.
if avail sysc then v-citykz = entry(12, sysc.chval, "|") no-error.
if v-citykz <> '' then v-citykz = v-citykz + '.'.

find first sysc  where sysc.sysc = 'ourbnk' no-lock no-error.
if not avail sysc then do:
  message "" view-as alert-box.
  return.
end.
if sysc.chval <> 'TXB00' then v-filkz = '-ныѕ ' + entry(1,v-citykz,' ') + ' ќаласындаєы филиалы'.
else v-filkz = ''.

v-fil = cmp.name.
v-dognom = entry(1,pkanketa.rescha[1]) + " от " + string(pkanketa.docdt,'99/99/9999').
v-dognomkz = entry(1,pkanketa.rescha[1]) + " " + string(pkanketa.docdt,'99/99/9999').
v-clname = pkanketa.name.
v-clrnn = pkanketa.rnn.
v-cldoc = pkanketa.docnum.
v-stdt = string(pkanketa.docdt,'99/99/9999').
v-duedt = string(pkanketa.srok).
if pkanketa.crc = 1 then v-cliik = pkanketa.aaa.
else v-cliik = pkanketa.aaaval.
find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "subln" no-lock no-error.
if avail pkanketh and trim(pkanketh.value1) <> '' then do:
  find first b-pkanketa where b-pkanketa.bank = s-ourbank and b-pkanketa.credtype = s-credtype and b-pkanketa.ln = intege(entry(1,pkanketh.value1)) no-lock no-error.
  if avail b-pkanketa then do:
    v-clname1 = '<TR><TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top colSpan=2>
                 <P class=MsoNormal><SPAN lang=EN-US style=""mso-ansi-language: EN-US""><o:p>&nbsp;</o:p></SPAN></P></TD><TD></TD>
                 <TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top colSpan=2>
                 <P class=MsoNormal><SPAN lang=EN-US style=""mso-ansi-language: EN-US""><o:p>&nbsp;</o:p></SPAN></P></TD></TR>

                 <TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top colSpan=2>
                 <P class=MsoNormal style=""TEXT-ALIGN: left""><B><SPAN style=""FONT-SIZE: 12pt"">Ќосалќы ќарыз алушыныѕ аты-жґні:</B> ' + b-pkanketa.name + '</SPAN></P></TD><TD></TD>
                 <TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top colSpan=2>
                 <P class=MsoNormal style=""TEXT-ALIGN: left""><B><SPAN style=""FONT-SIZE: 12pt"">ФИО Созаемщика:</B> ' + b-pkanketa.name + '</SPAN></P></TD></TR>

                 <TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top colSpan=2>
                 <P class=MsoNormal style=""TEXT-ALIGN: left""><B><SPAN style=""FONT-SIZE: 12pt"">СТН:</B> ' + b-pkanketa.rnn + ' </SPAN></P></TD><TD></TD>
                 <TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top colSpan=2>
                 <P class=MsoNormal style=""TEXT-ALIGN: left""><B><SPAN style=""FONT-SIZE: 12pt"">РНН:</B> ' + b-pkanketa.rnn + '</SPAN></P></TD></TR>

                 <TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top colSpan=2>
                 <P class=MsoNormal style=""TEXT-ALIGN: left""><B><SPAN style=""FONT-SIZE: 12pt"">Жеке кујлігі:</B> ' + b-pkanketa.docnum +  ' </SPAN></P></TD><TD></TD>
                 <TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top colSpan=2>
                 <P class=MsoNormal style=""TEXT-ALIGN: left""><B><SPAN style=""FONT-SIZE: 12pt"">Уд. личности:</B> ' + b-pkanketa.docnum + '</SPAN></P></TD></TR>

                 <TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top colSpan=2>
                 <P class=MsoNormal style=""TEXT-ALIGN: left""><B><SPAN style=""FONT-SIZE: 12pt"">Несие сомасы:</B> ' + string(pkanketa.summa,'>>>,>>>,>>9.99') +  ' ' + crc.code + '</SPAN></P></TD><TD></TD>
                 <TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top colSpan=2>
                 <P class=MsoNormal style=""TEXT-ALIGN: left""><B><SPAN style=""FONT-SIZE: 12pt"">Сумма кредита:</B> ' + string(pkanketa.summa,'>>>,>>>,>>9.99') +  ' ' + crc.code + '</SPAN></P></TD>'.

    v-clname1_1 = "<br><b>Созаемщик</b> " + b-pkanketa.name + "<br><br>".
    v-clnamekz1_1 = "<br><b>Ќосалќы ќарыз алушы</b> " + b-pkanketa.name + "<br><br>".
  end.
end.

v-graf = "<td colspan = ""5""><br><br><table border=""1"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse;WIDTH: 100%""><tr style=""font:bold;FONT-SIZE: 12pt"">
         <td  align=""center"">Кїні/Дата</td>
         <td  align=""center"">Негізгі борыш/<br>Основной долг</td>
         <td  align=""center"">Сыйаќы/<br>Вознаграждение</td>
         <td  align=""center"">Комиссиялар/<br>Комиссии</td>
         <td  align=""center"">Кезекті тґлем <br> сомасыныѕ жиыны/<br>Итого сумма <br> Очередного платежа</td>
         <td  align=""center"">Кезекті тґлемді<br> тґлегеннен кейін <br>Негізгі борыш сомасыныѕ<br> ќалдыєы / Остаток суммы <br>Основного долга <br>после уплаты<br> Очередного платежа </td></tr>" .

v-ostsum = pkanketa.summa.
 /*aigul*/
for each wrk no-lock:
     v-ostsum = v-ostsum - wrk.od.
     v-graf = v-graf + "<tr align=""right"" style=""FONT-SIZE: 12pt"">
                       <td align=""left""> " + string(wrk.stdat,'99/99/9999') + "</td>
                       <td> " + string(wrk.od,'>>>,>>>,>>9.99') +  "</td>
                       <td> " + string(wrk.proc,'>>>,>>>,>>9.99') +  "</td>".
                       if wrk.com then do:
                           v-graf = v-graf + "<td> " + string(v-comved,'>>>,>>>,>>9.99') +  "</td>".
                           v-graf = v-graf + "<td> " + string(wrk.od + wrk.proc + v-comved,'>>>,>>>,>>9.99') +  "</td>".
                       end.
                       else do:
                           v-graf = v-graf + "<td> " + string(0,'>>>,>>>,>>9.99') +  "</td>".
                           v-graf = v-graf + "<td> " + string(wrk.od + wrk.proc + 0,'>>>,>>>,>>9.99') +  "</td>".
                       end.
                       v-graf = v-graf + "<td> " + string(v-ostsum,'->>>,>>>,>>9.99') + "</td></tr>".


end.
/**/
v-graf = v-graf + "</table></td>".

find bookcod where bookcod.bookcod = "credtype" and bookcod.code = s-credtype no-lock no-error.
find first sysc where sysc.sysc = bookcod.info[1] + "podp" no-lock no-error.
v-bankpod = sysc.chval + " " + s-dogsign + "<IMG border=""0"" src=""" + v-stamp + """ width=""160"" height=""160"" align=""left"">".

define stream m-out.
v-file = "rptgrf.htm".
output stream m-out to value(v-file).

put stream m-out unformatted "<!-- График платежей -->" skip
                 "<html><head><title>" + v-nbank1 + "</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru"">"
                 "<STYLE TYPE=""text/css"">" skip
                 "body, H4, H3 ~{margin-top:0pt; margin-bottom:0pt~}" skip
                 "</STYLE></head><body><TABLE class=MsoNormalTable style=""WIDTH: 100%; BORDER-COLLAPSE: collapse; mso-padding-alt: 0cm 0cm 0cm 0cm"" cellSpacing=0 cellPadding=0 width=""100%"" border=0>" skip.
put stream m-out unformatted  "<TBODY><TR style=""mso-yfti-irow: 0; mso-yfti-firstrow: yes"">"
                "<TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top colSpan=2>"
                "<P class=MsoNormal style=""TEXT-ALIGN: center"" align=center><B><SPAN style=""FONT-SIZE: 12pt; FONT-FAMILY: 'Times New Roman CYR'"">" + v-nbankkz + " " + v-filkz + "<o:p></o:p></SPAN></B></P></TD>"
                "<TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; WIDTH: 1%; PADDING-TOP: 0cm"" width=""1%""></TD>"
                "<TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top colSpan=2>"
                "<P class=MsoNormal style=""TEXT-ALIGN: center"" align=center><B><SPAN style=""FONT-SIZE: 12pt; FONT-FAMILY: 'Times New Roman CYR'"">" + v-fil +  "<o:p></o:p></SPAN></B></P></TD></TR>"
                "<TR style=""mso-yfti-irow: 1; mso-yfti-lastrow: yes"">"
                "<TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; WIDTH: 25%; PADDING-TOP: 0cm"" width=""25%"">"
                "<P class=MsoNormal<SPAN style=""FONT-SIZE: 12pt; FONT-FAMILY: 'Times New Roman CYR'""><SPAN class=SpellE>" + v-citykz + "</SPAN><o:p></o:p></SPAN></P></TD>"
                "<TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; WIDTH: 24%; PADDING-TOP: 0cm"" width=""24%"">"
                "<P class=MsoNormal style=""TEXT-ALIGN: right"" align=right><U><SPAN style=""FONT-SIZE: 12pt; FONT-FAMILY: 'Times New Roman CYR'"">" + v-datastrkz + " ж.<o:p></o:p></SPAN></U></P></TD>"
                "<TD></TD><TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; WIDTH: 25%; PADDING-TOP: 0cm"" width=""25%"">"
                "<P class=MsoNormal><SPAN style=""FONT-SIZE: 12pt; FONT-FAMILY: 'Times New Roman CYR'""><SPAN class=SpellE>" + v-city + "</SPAN><o:p></o:p></SPAN></P></TD>"
                "<TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; WIDTH: 24%; PADDING-TOP: 0cm"" width=""24%"">"
                "<P class=MsoNormal style=""TEXT-ALIGN: right"" align=right><U><SPAN style=""FONT-SIZE: 12pt; FONT-FAMILY: 'Times New Roman CYR'"">" + v-datastr + " г.<o:p></o:p></SPAN></U></P>"
            	"</TD></TR> <TR style=""mso-yfti-irow: 1; mso-yfti-lastrow: yes"">"
                "<TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top colSpan=2>"
                "<P class=MsoNormal><SPAN lang=EN-US style=""mso-ansi-language: EN-US""><o:p>&nbsp;</o:p></SPAN></P>"
                "<P class=MsoNormal style=""TEXT-ALIGN: center""><SPAN style=""FONT-SIZE: 12pt"">N " + v-dognomkz + " жылєы Тўтынушылыќ несие беру туралы Шартќа"
                "<B style=""mso-bidi-font-weight: normal""><o:p> № 1 ЌОСЫМША</o:p></B></SPAN></P></TD>"
                "<TD></TD> <TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top colSpan=2>"
                "<P class=MsoNormal><SPAN lang=EN-US style=""mso-ansi-language: EN-US""><o:p>&nbsp;</o:p></SPAN></P>"
                "<P class=MsoNormal style=""TEXT-ALIGN: center""><SPAN style=""FONT-SIZE: 12pt""><B style=""mso-bidi-font-weight: normal""><o:p>ПРИЛОЖЕНИЕ № 1</o:p></B> к Договору о предоставлении потребительского кредита N " + v-dognom + "</SPAN></P></TD></TR>"
                "<TR><TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top colSpan=2>"
                "<P class=MsoNormal><SPAN lang=EN-US style=""mso-ansi-language: EN-US""><o:p>&nbsp;</o:p></SPAN></P>"
                "<P class=MsoNormal style=""TEXT-ALIGN: center""><B><SPAN style=""FONT-SIZE: 12pt"">ТҐЛЕМДЕР КЕСТЕСІ<o:p></o:p></SPAN></B></P></TD>"
                "<TD></TD><TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top colSpan=2>"
                "<P class=MsoNormal><SPAN lang=EN-US style=""mso-ansi-language: EN-US""><o:p>&nbsp;</o:p></SPAN></P>"
                "<P class=MsoNormal style=""TEXT-ALIGN: center""><B><SPAN style=""FONT-SIZE: 12pt"">ГРАФИК ПЛАТЕЖЕЙ<o:p></o:p></SPAN></B></P>"
                "</TD></TR><TR><TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top colSpan=2>"

                "<table class=MsoNormalTable style=""WIDTH: 100%; BORDER-COLLAPSE: collapse; mso-padding-alt: 0cm 0cm 0cm 0cm"" cellSpacing=0 cellPadding=0 width=""100%"" border=0>"
                "<tr> <td style=""WIDTH: 50%"" vAlign=top><P class=MsoNormal style=""TEXT-ALIGN: left""><B><SPAN style=""FONT-SIZE: 12pt"">Ќарыз алушыныѕ аты-жґні:</B> " + v-clname + " </SPAN></P></td></tr>"
                "<tr><td style=""WIDTH: 50%"" vAlign=top><P class=MsoNormal style=""TEXT-ALIGN: left""><B><SPAN style=""FONT-SIZE: 12pt"">Несие берілген кїн:</B> " + v-stdt + "</SPAN></P></td></tr>"
                "<tr><td style=""WIDTH: 50%"" vAlign=top><P class=MsoNormal style=""TEXT-ALIGN: left""><B><SPAN style=""FONT-SIZE: 12pt"">СТН:</B> " + v-clrnn + "</SPAN></P></td>"
                "<tr><td style=""WIDTH: 50%"" vAlign=top><P class=MsoNormal style=""TEXT-ALIGN: left""><B><SPAN style=""FONT-SIZE: 12pt"">Несие мерзімі:</B> " + v-duedt + " </SPAN></P></td></tr>"
/*ИИН на казахском*/         "<tr><td style=""WIDTH: 50%"" vAlign=top><P class=MsoNormal style=""TEXT-ALIGN: left""><B><SPAN style=""FONT-SIZE: 12pt"">ЖСН:</B> " + v-iin + "</SPAN></P></td></tr>"
                "<td style=""WIDTH: 50%"" vAlign=top><P class=MsoNormal style=""TEXT-ALIGN: left""><B><SPAN style=""FONT-SIZE: 12pt"">Жеке кујлігі:</B> " + v-cldoc + " </SPAN></P></td>"

                "<TD><BR></BR></TD>"
                "<TD><TR><TD style=""WIDTH: 100%"" vAlign=top><P class=MsoNormal style=""TEXT-ALIGN: justify""><SPAN style=""FONT-SIZE: 12pt"">Заемшы Шартќа осы Ќосымша  № 1 ќол ќоя отырып, Банкпен  тїрлі јдістерімен есептеліп ўсынылєан  Несиені ґтеу кестесімен танысќанын растайды, Заемшымен  ґтеу јдісін таѕдауда  Тараптар келесіге тоќтады: <o:p></o:p></SPAN></P></TR><TD></TD>"
                "<TD><TR><TD style=""WIDTH: 100%"" vAlign=top><P class=MsoNormal style=""TEXT-ALIGN: justify""><SPAN style=""FONT-SIZE: 12pt"">1.	Заемшы аннуитетті тґлемдермен тґлеу јдістерінен, ґзге јдістерден тараптардыѕ келісуі бойынша бас тартады. <o:p></o:p></SPAN></P></TR><TD></TD>"
                "<TD><TR><TD style=""WIDTH: 100%"" vAlign=top><P class=MsoNormal style=""TEXT-ALIGN: justify""><SPAN style=""FONT-SIZE: 12pt"">2.	Заемшымен тґмендегі тґлем Кестесінде ќолданылатын Несиені пайдаланєаны їшін Несие Сомасына сыйаќы есептелуімен теѕ їлесте тґлеу јдісі таѕдалды: <o:p></o:p></SPAN></P></TR><TD></TD>".


                /*if v-cliik <> '' then put stream m-out unformatted
                "<td style=""WIDTH: 50%"" vAlign=top><P class=MsoNormal style=""TEXT-ALIGN: left""><B><SPAN style=""FONT-SIZE: 12pt"">Аєымдыќ есепшот:</B> " + v-cliik + "<o:p></o:p></SPAN></P></td></tr>".*/

                put stream m-out unformatted
                "</table></TD><TD></TD><TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top colSpan=2>"
                "<table class=MsoNormalTable style=""WIDTH: 100%; BORDER-COLLAPSE: collapse; mso-padding-alt: 0cm 0cm 0cm 0cm"" cellSpacing=0 cellPadding=0 width=""100%"" border=0>"
                "<tr><td style=""WIDTH: 50%"" vAlign=top><P class=MsoNormal style=""TEXT-ALIGN: left""><B><SPAN style=""FONT-SIZE: 12pt"">ФИО Заемщика:</B> " + v-clname + "</SPAN></P></td></tr>"
                "<tr><td style=""WIDTH: 50%"" vAlign=top><P class=MsoNormal style=""TEXT-ALIGN: left""><B><SPAN style=""FONT-SIZE: 12pt"">Дата выдачи кредита:</B> " + v-stdt + "</SPAN></P></td></tr>"
                "<tr><td style=""WIDTH: 50%"" vAlign=top><P class=MsoNormal style=""TEXT-ALIGN: left""><B><SPAN style=""FONT-SIZE: 12pt"">РНН:</B> " + v-clrnn + "</SPAN></B></P></td></tr>"
                "<tr><td style=""WIDTH: 50%"" vAlign=top><P class=MsoNormal style=""TEXT-ALIGN: left""><B><SPAN style=""FONT-SIZE: 12pt"">Срок кредита:</B> " + v-duedt + "</SPAN></P></td></tr>"
/*ИИН*/         "<tr><td style=""WIDTH: 50%"" vAlign=top><P class=MsoNormal style=""TEXT-ALIGN: left""><B><SPAN style=""FONT-SIZE: 12pt"">ИИН:</B> " + v-iin + "</SPAN></B></P></td></tr>"
                "<td style=""WIDTH: 50%"" vAlign=top><P class=MsoNormal style=""TEXT-ALIGN: left""><B><SPAN style=""FONT-SIZE: 12pt"">Уд.личности:</B> " + v-cldoc + "</SPAN></P></td>"

                "<TD><BR></BR></TD>"
                "<TD><TR><TD style=""WIDTH: 100%"" vAlign=top><P class=MsoNormal style=""TEXT-ALIGN: justify""><SPAN style=""FONT-SIZE: 12pt"">Подписанием настоящего Приложения № 1 к Договору, Заемщик подтверждает, что  ознакомлен с предложенными Банком графиками погашения Кредита, рассчитанными различными методами, таким образом, при выборе Заемщиком метода погашения Стороны пришли к следующему: <o:p></o:p></SPAN></P></TR><TD></TD>"
                "<TD><TR><TD style=""WIDTH: 100%"" vAlign=top><P class=MsoNormal style=""TEXT-ALIGN: justify""><SPAN style=""FONT-SIZE: 12pt"">1.	Заемщик от методов погашения аннуитетными платежами, других методов по соглашению сторон отказывается.<o:p></o:p></SPAN></P></TR><TD></TD>"
                "<TD><TR><TD style=""WIDTH: 100%"" vAlign=top><P class=MsoNormal style=""TEXT-ALIGN: justify""><SPAN style=""FONT-SIZE: 12pt"">2.	Заемщиком выбран метод погашения равными долями, с начислением вознаграждения за пользование Кредитом на Сумму Кредита,  применяемый в нижеследующем Графике платежей: <o:p></o:p></SPAN></P></TR><TD></TD>".

                /*if v-cliik <> '' then put stream m-out unformatted
                "<td style=""WIDTH: 50%"" vAlign=top><P class=MsoNormal style=""TEXT-ALIGN: left""><B><SPAN style=""FONT-SIZE: 12pt"">Текущий счет:</B> " + v-cliik + "</SPAN></P></td>".*/
                put stream m-out unformatted
                "</tr></table> </TD></TR>" +  v-clname1 + "<TR>" + v-graf + "</TR>"
                "<TR><TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top colSpan=2>"
                "<P class=MsoNormal><SPAN lang=EN-US style=""mso-ansi-language: EN-US""><o:p>&nbsp;</o:p></SPAN></P>"
                "<P class=MsoNormal style=""TEXT-ALIGN: left"" align=left><SPAN style=""FONT-SIZE: 12pt""><o:p><b>Тґлемдер кестесініѕ шарттарымен таныстым.</b><o:p></o:p></SPAN></P></TD>"
                "<TD></TD><TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top colSpan=2>"
                "<P class=MsoNormal><SPAN lang=EN-US style=""mso-ansi-language: EN-US""><o:p>&nbsp;</o:p></SPAN></P>"
                "<P class=MsoNormal style=""TEXT-ALIGN: left""  align=left><SPAN style=""FONT-SIZE: 12pt""><o:p><b>С условиями графика платежей ознакомлен(а) и согласен(а).</b><o:p></o:p></SPAN></P></TD></TR>"

                "<TR><TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top colSpan=2>"
                "<P class=MsoNormal><SPAN lang=EN-US style=""mso-ansi-language: EN-US""><o:p>&nbsp;</o:p></SPAN></P>"
                "<P class=MsoNormal style=""TEXT-ALIGN: left"" align=left><SPAN style=""FONT-SIZE: 12pt""><o:p><b>Ќарыз алушы</B> " + v-clname + v-clnamekz1_1 "<o:p></o:p></SPAN></P></TD>"

                "<TD></TD><TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top colSpan=2>"
                "<P class=MsoNormal><SPAN lang=EN-US style=""mso-ansi-language: EN-US""><o:p>&nbsp;</o:p></SPAN></P>"
                "<P class=MsoNormal style=""TEXT-ALIGN: left""  align=left><SPAN style=""FONT-SIZE: 12pt""><o:p><b>Заемщик</B> " + v-clname + v-clname1_1 "</o:p></SPAN></P></TD></TR>"


                "<TR><TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top colSpan=2>"
                "<P class=MsoNormal><SPAN lang=EN-US style=""mso-ansi-language: EN-US""><o:p>&nbsp;</o:p></SPAN></P>"
                "<P class=MsoNormal style=""TEXT-ALIGN: left"" align=left><SPAN style=""FONT-SIZE: 12pt""><o:p><B>Банктен</b> " + v-bankpod + "<o:p></o:p></SPAN></P></TD>"

                "<TD></TD><TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top colSpan=2>"
                "<P class=MsoNormal><SPAN lang=EN-US style=""mso-ansi-language: EN-US""><o:p>&nbsp;</o:p></SPAN></P>"
                "<P class=MsoNormal style=""TEXT-ALIGN: left""  align=left><SPAN style=""FONT-SIZE: 12pt""><o:p><B>От Банка</B> " + v-bankpod + "</o:p></SPAN></P></TD></TR>"
                "</TBODY></TABLE>".

output stream m-out close.

if v-inet then unix silent value("mv " + v-file + " /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "; chmod 666 /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "/" + v-file).
else unix silent value("cptwin " + v-file + " iexplore").




