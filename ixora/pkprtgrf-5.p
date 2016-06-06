/* pkprtgrf-5.p
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
        06.04.2009 galina - если кредит не в тенге, берем валютный текущий счет
        09/09/2009 madiyar - добавил поле com в шаренную таблицу
*/

{global.i}
{pk.i}
{pk-sysc.i}

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

find lon where lon.lon = pkanketa.lon no-lock no-error.
if not avail lon then do:
    if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"pkprtgrf-5 - Ссудный счет N " + pkanketa.lon + " не найден!").
    else message skip " Ссудный счет N" pkanketa.lon "не найден !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
end.

find first crc where crc.crc = pkanketa.crc no-lock no-error.
find first cmp no-lock no-error.

run pkdefdtstr(pkanketa.docdt, output v-datastr, output v-datastrkz).
/*
find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "bdacc" no-lock no-error.
if avail pksysc then v-comved = pkanketa.summa * pksysc.deval / 100. else v-comved = pkanketa.summa * 0.8 / 100.
*/

find first tarifex2 where tarifex2.aaa = lon.aaa and tarifex2.cif = lon.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
v-comved = tarifex2.ost.

define stream m-out.
v-file = "rptgrf.htm".
output stream m-out to value(v-file).

put stream m-out unformatted "<!-- График платежей -->" skip
                 "<html><head><title>ТОО ""МКО ""НАРОДНЫЙ КРЕДИТ""</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru"">"
                 "<STYLE TYPE=""text/css"">" skip
                 "body, H4, H3 ~{margin-top:0pt; margin-bottom:0pt~}" skip
                 "</STYLE></head><body>" skip.

put stream m-out unformatted "<table WIDTH=100% border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.
put stream m-out unformatted "<tr align=""center""><td colspan=2 style=""font:bold;font-size:14px"">" cmp.name format 'x(79)' "</td></tr>" skip.
put stream m-out unformatted "<tr><td align=""left"" style=""font-size:x-small"" width=""50%"">" entry(1,cmp.addr[1]) "</td><td align=""right"" style=""font-size:x-small""  width=""50%"">" v-datastr "</td></tr>" skip.
put stream m-out unformatted "<tr align=""center""><td colspan=2 style=""font:bold;font-size:12px"">ПРИЛОЖЕНИЕ N 1</td></tr>" skip.

put stream m-out unformatted "<tr align=""center""><td colspan=2 style=""font-size:12px"">к Договору о предоставлении микрокредита N " entry(1,pkanketa.rescha[1]) " от " pkanketa.docdt "</td></tr>" skip.

put stream m-out unformatted "<tr align=""center""><td colspan=2 style=""font:bold;font-size:16px"">ГРАФИК ПЛАТЕЖЕЙ</td></tr>" skip.
put stream m-out unformatted "<tr align=""left""><td colspan=""2"" style=""font:bold;font-size:12px"">&nbsp;<br> ФИО заемщика     : " pkanketa.name "</td></tr>" skip.
put stream m-out unformatted "<tr align=""left"">" skip
                             "<td style=""font:bold;font-size:12px""> РНН              : " pkanketa.rnn  "</td>" skip
                             "<td style=""font:bold;font-size:12px""> Дата выдачи Микрокредита : " pkanketa.docdt "</td>"
                             "</tr>" skip.
put stream m-out unformatted "<tr align=""left"">" skip
                             "<td style=""font:bold;font-size:12px""> Уд. личности     : " pkanketa.docnum "</td>" skip
                             "<td style=""font:bold;font-size:12px""> Срок Микрокредита : " pkanketa.srok "</td>" skip
                             "</tr>" skip.
put stream m-out unformatted "<tr align=""left"">" skip
                             "<td style=""font:bold;font-size:12px""> Сумма Микрокредита    : " pkanketa.summa format '>>>,>>>,>>9.99' " " crc.code "</td>" skip
                             "<td style=""font:bold;font-size:12px""> Код : " if pkanketa.crc = 1 then pkanketa.aaa else pkanketa.aaaval "</td>" skip
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
else unix silent value("cptwin " + v-file + " iexplore").
