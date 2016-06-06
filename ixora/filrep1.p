/* filrep1.p
 * MODULE
        Межфилиальный переводы - отчет
 * DESCRIPTION
        Пополнение счетов за период
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK COMM
 * AUTHOR
        16.07.2010 marinav
 * CHANGES
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/


{mainhead.i}
{nbankBik.i}
def var v-date1 as date.
def var v-date2 as date.

def var s-ourbank as char.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    display " There is no record OURBNK in bank.sysc file !!".
    pause.
    return.
end.
s-ourbank = trim(sysc.chval).


update v-date1 label "Дата начала периода: " format "99/99/9999" skip
       v-date2 label "Дата конца периода:  " format "99/99/9999" with centered row 5 side-label frame getdats.
hide frame getdats.

if v-date1 = ? or v-date2 = ? then do:
   message "Ошибка ввода даты !" view-as alert-box.
   return.
end.

find first cmp no-lock no-error.
define new shared stream m-out.
output stream m-out to "rep.html".
put stream m-out "<html><head><title>" + v-nbank1 + "</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>"  skip.

put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""style=""border-collapse: collapse"">".
put stream m-out unformatted
  "<P style=""font:bold;font-size:x-small"">"  cmp.name  "</P>"
  "<P align=""left"" style=""font:bold;font-size:x-small"">ОТЧЕТ О ПОПОЛНЕНИИ счетов за период с " v-date1 " по " v-date2 "</P>" skip
  "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""100%"">" skip.

put stream m-out unformatted
      "<TR align=""center"" style=""font:bold"">" skip
        "<TD>Клиент</TD>" skip
        "<TD>ИИК</TD>" skip
        "<TD>Валюта </TD>" skip
        "<TD>Сумма <br>поступления</TD>" skip
        "<TD>Дата</TD>" skip
        "<TD>Банк <br>инициатор</TD>" skip
        "<TD>Банк <br>получатель</TD>" skip
        "</TR>" skip.

for each filpayment where filpayment.whn >= v-date1 and filpayment.whn <= v-date2 and filpayment.type = 'add' no-lock.

         find first crc where crc.crc = filpayment.crc no-lock no-error.
              put stream m-out unformatted
              "<TR align=""right"" >" skip
               "<TD align=""left"">" filpayment.name "</TD>" skip
               "<TD>" filpayment.iik "</TD>" skip
               "<TD>" crc.code "</TD>" skip
               "<TD>" replace(trim(string(filpayment.amount , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" filpayment.whn "</TD>" skip
               "<TD>" filpayment.bankfrom "</TD>" skip
               "<TD>" filpayment.bankto "</TD>"
               "</TR>" skip.

end.

put stream m-out unformatted "</table><br><br>" skip.
put stream m-out "</table>" skip.
put stream m-out "</body></html>".
output stream m-out close.
unix silent cptwin rep.html excel.


