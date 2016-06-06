/* pkprtupd-6.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Печать пересчитанного графика
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-13-3 "ИзмГраф"
 * AUTHOR
        23/09/2003 marinav
 * CHANGES
        12.12.2003 nadejda - исправила закрытие потока - до вызова pkendtable
        01.02.2004 nadejda - адреса брать из cif.dnb (pkdefadrcif.p)
        03.02.2004 nadejda - уменьшен шрифт для размещения на 1 лист
        20/05/2004 madiar - в case добавлена схема 4
        31/05/2005 madiar - в case добавлена схема 5
        21/12/2005 madiar - электронная печать, добавился параметр в вызове проги pkendtable
*/


{global.i}
{pk.i}
{pk-sysc.i}

if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and
     pkanketa.ln = s-pkankln no-lock no-error.

def shared temp-table  wrk
    field nn     as integer
    field days   as integer
    field stdat  like lnsch.stdat
    field begs   like lnsch.stval
    field od     like lnsch.stval
    field proc   like lnsch.stval
    field ends   like lnsch.stval.

def new shared var v-bankname as char.
def new shared var v-bankadres as char.
def new shared var v-bankiik as char.
def new shared var v-bankbik as char.
def new shared var v-bankups as char.
def new shared var v-bankrnn as char.
def new shared var v-bankface as char.
def new shared var v-bankkomupos as char.
def new shared var v-bankkomufio as char.
def new shared var v-banksuff as char.
def new shared var v-bankosn as char.
def new shared var v-bankpodp as char.
def new shared var v-city as char.
def new shared var v-ofile as char.
def new shared var v-datastr as char.
def new shared var v-name as char.
def new shared var v-docnum as char.
def new shared var v-docdt as char.
def new shared var v-adres as char extent 2.
def new shared var v-adresfull as char.
def new shared var v-adreslabel as char.
def new shared var v-sumq as char.
def new shared var v-sumqwrd as char.
def new shared var v-predpr as char.
def new shared var v-telefon as char.
def new shared var v-rnn as char.
def new shared var v-namefull as char.
def new shared var v-nameshort as char.
def var v-datastrkz as char no-undo.

v-name = pkanketa.name.
v-rnn = pkanketa.rnn.
v-docnum = pkanketa.docnum.


find first cmp no-lock no-error.
if avail cmp then do:
  v-bankname = cmp.name.
  v-city = entry(1, cmp.addr[1]).
  v-bankadres = cmp.addr[1].
  v-bankrnn = cmp.addr[2].
end.

{sysc.i}
v-bankiik = get-sysc-cha ("bnkiik").
v-bankbik = get-sysc-cha ("clecod").
v-bankups = get-sysc-cha ("bnkups").

find bookcod where bookcod.bookcod = "credtype" and bookcod.code = s-credtype no-lock no-error.
v-bankface = entry(1, get-sysc-cha (bookcod.info[1] + "face")).
v-bankkomupos = entry(1, get-sysc-cha (bookcod.info[1] + "komu")) + " " + v-bankname.
v-bankkomufio = entry(2, get-sysc-cha (bookcod.info[1] + "komu")).
v-banksuff = get-sysc-cha (bookcod.info[1] + "suff").
v-bankosn = get-sysc-cha (bookcod.info[1] + "osn").
v-bankpodp = get-sysc-cha (bookcod.info[1] + "podp").
run pkdefadrcif (pkanketa.ln, no, output v-adres[1], output v-adres[2]).
run pkdefsfio (pkanketa.ln, output v-nameshort).
run pkdefdtstr(g-today, output v-datastr, output v-datastrkz).


if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln "не найдена !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

find lon where lon.lon = pkanketa.lon no-lock no-error.
if not avail lon then do:
  message skip " Ссудный счет N" pkanketa.lon "не найден !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

find first crc where crc.crc = pkanketa.crc no-lock no-error.
find first cmp no-lock no-error.

define stream v-out.
output stream v-out to dop.html.
v-ofile = "dop.html".

{html-title.i &stream = "stream v-out" &title = "Доп.соглашение" &size-add = "x-"}
/*
put stream v-out "<html><head><title>TEXAKABANK</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru"">"
                 "<STYLE TYPE=""text/css"">" skip
                 "body, H4, H3 {margin-top:0pt; margin-bottom:0pt}" skip
                 "</STYLE></head><body>" skip.
*/
  
put stream v-out unformatted
  "<table WIDTH=""95%"" border=""0"" cellpadding=""0"" cellspacing=""0"" align=""center"">" skip
    "<tr align=""center""><td>" skip
      "<table WIDTH=""90%"" border=""0"" cellpadding=""0"" cellspacing=""0"">" skip
        "<tr><td><B>" cmp.name "</b></td><td align=""right"">100203-2-017/2.ПК</td></tr>" skip
      "</table>" skip
    "</td></tr>" skip
    "<tr align=""center""><td><b>ДОПОЛНИТЕЛЬНОЕ СОГЛАШЕНИЕ N 1</b></td></tr>" skip
    "<tr align=""center""><td><b>к Договору о предоставлении кредита N "
                 entry(1,pkanketa.rescha[1]) " от " pkanketa.docdt    "<b></td></tr>".

put stream v-out unformatted
    "<TR><TD><TABLE width=""80%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
      "<TR>" skip
        "<TD width=""50%"" align=""left"">" skip
        v-city skip
        "</TD>" skip
        "<TD width=""50%"" align=""right""><U>" skip
        v-datastr skip
        "</U> г.</TD>" skip
      "</TR>"
    "</TABLE><br></td></tr><TR><TD>" skip.

put stream v-out unformatted
  "<SPAN align=""justify"">" v-bankname skip
  ", именуемое в дальнейшем ""Банк"", в лице "
  v-bankface skip
  ", действующе" + v-banksuff + " на основании " + v-bankosn + ", с одной стороны, и <U><I>" skip
  v-name skip
  "</I></U>, именуемый(ая) в дальнейшем ""Заемщик"", с другой стороны, далее вместе именуемые ""Стороны"", заключили настоящий Договор о нижеследующем.</SPAN><BR>" skip
  "<br>" skip.

put stream v-out unformatted
    "1. Приложение N1 к Договору о предоставлении потребительского кредита N "
        entry(1,pkanketa.rescha[1]) " от " pkanketa.docdt " изложить в следующей редакции:<BR></td></tr>" skip.

put stream v-out unformatted
 "<tr><td>&nbsp;</td></tr>" skip
 "<tr align=""center""><td><b>ГРАФИК ПЛАТЕЖЕЙ</b></td></tr>" skip
 "<tr><td>&nbsp;</td></tr>" skip
 "<tr align=""left""><td> ФИО заемщика     : " pkanketa.name "</td></tr>" skip
 "<tr align=""left""><td> РНН              : " pkanketa.rnn  "</td></tr>" skip
 "<tr align=""left""><td> Уд. личности     : " pkanketa.docnum "</td></tr>" skip
 "<tr align=""left""><td> Сумма кредита    : " string(pkanketa.summa, ">>>,>>>,>>9.99") " " crc.code " </td></tr>" skip
 "<tr align=""left""><td> Цель кредита     : Потребительские цели </td></tr>" skip
 "<tr align=""left""><td> Процентная ставка: " string(lon.prem, ">9.99") "%</td></tr>" skip
 "<tr align=""left""><td> Дата выдачи кредита : " pkanketa.docdt "</td></tr>" skip
 "<tr align=""left""><td> Дата погашения кредита : " pkanketa.duedt "</td></tr>" skip
 "<tr align=""left""><td> Текущий счет : " pkanketa.aaa "</td></tr>" skip
 "<tr><td>&nbsp;</td></tr>" skip.

case lon.plan:
 when 2 then
       put stream v-out "<tr><td><table width=""600"" border=""1"" cellpadding=""1"" cellspacing=""0"">"  skip
           "<tr align=""center""  bgcolor=""#C0C0C0"" style=""font:bold"">" skip
           "<td>N<br>платежа</td>" skip
           "<td>Дата<br>погашения</td>" skip
           "<td>Кол-во<br>дней<br>поль-<br>зования<br>кредитом</td>" skip
           "<td>Сумма<br>кредита<br>на начало<br>периода</td>" skip
           "<td>Основной<br>долг</td>" skip
           "<td>Проценты</td>" skip
           "<td>Платеж<br>за период</td>" skip
           "<td>Сумма<br>кредита<br>на конец<br>периода</td></tr>" skip.

 when 3 or when 4 or when 5 then
       put stream v-out unformatted "<tr><td><table border=""1"" cellpadding=""1"" cellspacing=""0"">"  skip
                  "<tr bgcolor=""#C0C0C0"" align=""center"" style=""font:bold"">" skip
                  "<td>Дата погашения</td>" skip
                  "<td>Сумма кредита на начало</td>" skip
                  "<td>Ежемесячный платеж</td>" skip
                  "<td>Сумма кредита на конец</td></tr>" skip.

 otherwise put stream v-out unformatted "<tr><td><table border=""1"" cellpadding=""1"" cellspacing=""0"">"  skip
           "<tr align=""center"" bgcolor=""#C0C0C0"" style=""font:bold"">" skip
           "<td>Дата погашения</td>" skip
           "<td>Сумма кредита на начало</td>" skip
           "<td>Погашение основного долга</td>" skip
           "<td>Погашение процентов</td>" skip
           "<td>Ежемесячный платеж</td>" skip
           "<td>Сумма кредита на конец</td></tr>" skip.
end.

   
for each wrk .
  
case lon.plan:
 when 2 then
        put stream v-out unformatted "<tr align=""right"" style=""font-size:x-small"">" skip
               "<td>" wrk.nn "</td>" skip
               "<td align=""center"">" wrk.stdat "</td>" skip
               "<td>" wrk.days "</td>" skip
               "<td>" string(wrk.begs, ">>>,>>>,>>9.99") "</td>" skip
               "<td>" wrk.od "</td>" skip
               "<td>" wrk.proc "</td>" skip
               "<td>" string(wrk.od + wrk.proc, ">>>,>>>,>>9.99") "</td>" skip
               "<td>" string(wrk.ends, ">>>,>>>,>>9.99") "</td></tr>" skip.
 when 3 or when 4 or when 5 then
        put stream v-out unformatted "<tr align=""right"" style=""font-size:x-small"">" skip
               "<td align=""center"">" wrk.stdat "</td>" skip
               "<td>" string(wrk.begs, ">>>,>>>,>>9.99") "</td>" skip
               "<td>" string(wrk.od + wrk.proc, ">>>,>>>,>>9.99") "</td>" skip
               "<td>" string(wrk.ends, ">>>,>>>,>>9.99") "</td></tr>" skip.
 otherwise
        put stream v-out unformatted "<tr align=""right"" style=""font-size:x-small"">" skip
               "<td align=""center"">" wrk.stdat "</td>" skip
               "<td>" string(wrk.begs, ">>>,>>>,>>9.99") "</td>" skip
               "<td>" wrk.od "</td>" skip
               "<td>" wrk.proc "</td>" skip
               "<td>" string(wrk.od + wrk.proc, ">>>,>>>,>>9.99") "</td>" skip
               "<td>" string(wrk.ends, ">>>,>>>,>>9.99") "</td></tr>" skip.
 end case.
end.
put stream v-out unformatted "</table><BR></td></tr><tr><td>".

put stream v-out unformatted
    "2. Все остальные условия Договора займа остаются без изменений. <BR>" skip
    "3. Настоящее Дополнительное соглашение вступает в силу с момента его подписания Сторонами.<BR>" skip
    "4. Адреса и реквизиты сторон:</td></td></table>" skip.

output stream v-out close.

run pkendtable(v-ofile, "БАНК", "ЗАЕМЩИК", true, "", no, yes, yes).

unix silent cptwin dop.html iexplore.
