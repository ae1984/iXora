/* pkrepvzn.p
 * MODULE
        Потребительские кредиты
 * DESCRIPTION
        Отчет по выданным кредитам с учетом вознаграждения
 * RUN
        
 * CALLER
        
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU 
        4-14-8
 * AUTHOR
        03.02.2004 sasco
 * CHANGES

*/

{global.i}
{gl-utils.i}
{pk.i "new"}

def var coun as int init 1.
define variable datums  as date format '99/99/9999'.
define variable datums1  as date format '99/99/9999'.
define var v-sum as deci. 
define var v-amt as deci. 
define var v-sumcr as deci. 
define var v-sumcr% as deci. 

def temp-table  wrk
    field dat     as date
    field anknum  as integer
    field credtype as char
    field fio     as char
    field sum%%   as decimal
    field sum     as decimal
    field sum5    as decimal
    field partner as char
    field pname   as char
    field name    as char
    index idx_wrk is primary dat anknum.

datums = g-today.
datums1 = g-today.

update datums label ' Укажите дату с ' format '99/99/9999' datums1 label ' по ' format '99/99/9999' skip
       with side-label row 5 centered frame dat .

find first cmp no-lock no-error.

output to repday.html.

{html-start.i}

put unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip. 

put unformatted "<br><br><tr align=""left""><td colspan=""5""><h3>" cmp.name format 'x(79)' "</h3></td></tr><br><br>" skip(1).

put unformatted "<tr align=""center""><td colspan=""5""><h3>Сведения о выданных потребительских кредитах " skip
                 " с " string(datums) " по " string(datums1) "</h3></td></tr><br><br>" skip(1).

put unformatted "<tr></tr><tr></tr>"
                 skip(1).

for each pkanketa no-lock where pkanketa.bank = s-ourbank and 
         pkanketa.lon ne '' and pkanketa.docdt >= datums and  pkanketa.docdt <= datums1 
         and (if s-credtype = "0" then TRUE else pkanketa.credtype = s-credtype)
         and pkanketa.lon <> "" and pkanketa.trx2 <> 0 and pkanketa.trx2 <> ?
         and pkanketa.resdec[3] <> 0.0:

   find bookcod where bookcod.bookcod = "credtype" and bookcod.code = pkanketa.credtype no-lock no-error.
   find last crchis where crchis.crc = pkanketa.crc and crchis.regdt <= pkanketa.docdt no-lock no-error.
   create wrk.
   assign wrk.dat = pkanketa.docdt
          wrk.anknum = pkanketa.ln
          wrk.credtype = pkanketa.credtype
          wrk.fio = pkanketa.name
          wrk.sum = pkanketa.sumout * crchis.rate[1]
          wrk.sum5 = 0.0
          wrk.partner = pkanketa.partner
          wrk.pname = ''
          wrk.name = bookcod.name
          .

   if wrk.partner <> '' then 
   do:
      find codfr where codfr.codfr = "pkpartn" and codfr.code = pkanketa.partner no-lock no-error.
      if avail codfr then do:
         wrk.pname = codfr.name[1].
         if codfr.name[4] = '' or num-entries(codfr.name[4], "|") < 6 then 
         do:
            if codfr.name[3] <> '' then do:
               wrk.sum5 = pkanketa.sumout * pkanketa.resdec[2] / 100.
               wrk.sum5 = ROUND (wrk.sum5, 3).
               wrk.sum5 = ROUND (wrk.sum5, 2).
               wrk.sum%% = pkanketa.resdec[2].
            end.
         end.
      end.
   end.

end.

put unformatted "<table border=""1"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip. 
put unformatted "<TR>"
                "<TD bgcolor=""#C0C0C0"" >Вид кредита</TD>"
                "<TD bgcolor=""#C0C0C0"" >N анкеты</TD>"
                "<TD bgcolor=""#C0C0C0"" >Ф.И.О.</TD>"
                "<TD bgcolor=""#C0C0C0"" >Дата выдачи</TD>"
                "<TD bgcolor=""#C0C0C0"" >Сумма кредита<BR>(без комиссии) KZT</TD>"
                "<TD bgcolor=""#C0C0C0"" >Ставка вознаграждения, %%</TD>"
                "<TD bgcolor=""#C0C0C0"" >Сумма вознаграждения</TD>"
                "<TD bgcolor=""#C0C0C0"" >Компания-Партнер</TD>"
                "<TD bgcolor=""#C0C0C0"" >Счет партнера</TD></TR>" skip.
for each wrk:
    put unformatted "<TR>"
                    "<TD>" wrk.name "&nbsp;</TD>"
                    "<TD>" wrk.anknum "&nbsp;</TD>"
                    "<TD>" wrk.fio "&nbsp;</TD>"
                    "<TD>" dat "&nbsp;</TD>"
                    "<TD>" XLS-NUMBER (wrk.sum) "</TD>"
                    "<TD>" XLS-NUMBER (wrk.sum%%) "</TD>"
                    "<TD>" XLS-NUMBER (wrk.sum5) "</TD>"
                    "<TD>" wrk.pname "&nbsp;</TD>"
                    "<TD>" wrk.partner "&nbsp;</TD>"
                    "</TR>"
                    skip .
end.
put unformatted "</table>".

{html-end.i}

output close.

unix silent cptwin repday.html excel. 


