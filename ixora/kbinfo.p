/* kbinfo.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Отчет по коду бюджетной классификации
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
        08/12/2004 kanat
 * CHANGES
*/

{comm-txb.i}
{get-dep.i}
{global.i}

def var v-kbk as integer.
def var v-date-begin as date.
def var v-date-fin as date.
def var seltxb as integer.
def var v-depart as integer.
def var v-whole-sum as decimal init 0.
def var v-whole-count as decimal init 0.

def temp-table tax_temp 
         field date  as date
         field depart as integer
         field rnn_nk as char
         field kbk as integer
         field sum as decimal.

def temp-table tax_temp1 
         field date  as date
         field depart as integer
         field rnn_nk as char
         field kbk as integer
         field sum as decimal.

def var v-c1 as integer.
def var v-s1 as decimal.

seltxb = comm-cod().

form skip(1)
v-kbk          format "999999"     label " КБК " skip  
v-date-begin   format "99/99/9999" label " Начало периода" skip
v-date-fin     format "99/99/9999" label " Конец периода " skip(1)
with row 6 side-label centered title " Статистика по КБК НК " /*color messages*/ frame report_frame.

displ v-kbk v-date-begin v-date-fin with frame report_frame.

v-date-begin = today.
v-date-fin = v-date-begin.

update v-kbk v-date-begin v-date-fin with frame report_frame.


        find first budcodes where budcodes.code = v-kbk
        use-index code no-lock no-error.
        if not avail budcodes then do:
        message "Неверный КБК!" view-as alert-box title "Внимание".
        return.
        end.


message "Идет формирование данных ... ".


for each tax where tax.txb = seltxb and 
                   tax.date >= v-date-begin and 
                   tax.date <= v-date-fin and 
                   tax.kb = v-kbk and 
                   tax.duid = ? and 
                   tax.deldate = ? no-lock use-index datenum.
v-depart = integer(get-dep(tax.uid, tax.date)).
create tax_temp.
update tax_temp.date = tax.date.
       tax_temp.depart = v-depart.
       tax_temp.rnn_nk = tax.rnn_nk.
       tax_temp.kbk = tax.kb.
       tax_temp.sum = tax.sum.
end.


for each tax where tax.txb = seltxb and 
                   tax.date >= v-date-begin and 
                   tax.date <= v-date-fin and 
                   tax.sum = 276 and
                   tax.kb = v-kbk and 
                   tax.duid = ? and 
                   tax.deldate = ? no-lock use-index datenum.
v-depart = integer(get-dep(tax.uid, tax.date)).
create tax_temp1.
update tax_temp1.date = tax.date.
       tax_temp1.depart = v-depart.
       tax_temp1.rnn_nk = tax.rnn_nk.
       tax_temp1.kbk = tax.kb.
       tax_temp1.sum = tax.sum.
end.


output to reporth.htm.

put unformatted
   "<IMG border=""0"" src=""http://www.texakabank.kz/images/top_logo_bw.gif""><BR><BR><BR>" skip
   "<B><P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">" skip
   " Отчет по КБК "  " АО ""TEXAKABANK""</FONT><BR><BR>" skip
   "<FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans""><BR>" 
   "за период с " + string(v-date-begin, "99/99/9999") + " по " + string(v-date-fin, "99/99/9999") + "</FONT></P></B>" skip
   "<TABLE width=""70%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
   "<TR align=""center"" valign=""top"">" skip.


  put unformatted
     "<TD bgcolor=""#95B2D1""><FONT size=""2""><B>Структурное подразделение</B></FONT></TD>"  skip
     "<TD bgcolor=""#95B2D1""><FONT size=""2""><B>Количество</B></FONT></TD>"  skip
     "<TD bgcolor=""#95B2D1""><FONT size=""2""><B>Сумма</B></FONT></TD>" skip
   "</TR>".

for each tax_temp no-lock break by tax_temp.depart.

if first-of (tax_temp.depart) then do:
find first ppoint where ppoint.depart = tax_temp.depart no-lock no-error.
if avail ppoint then do:
put unformatted "<TR><TD>" ppoint.name "</TD>" skip
                "<TD></TD>" skip
                "<TD></TD></TR>" skip.

end.
end.

accumulate tax_temp.sum (sub-total by tax_temp.depart).
accumulate tax_temp.sum (sub-count by tax_temp.depart).

if last-of (tax_temp.depart) then do:
v-whole-sum = (accum sub-total by tax_temp.depart tax_temp.sum).
v-whole-count = (accum sub-count by tax_temp.depart tax_temp.sum).

put unformatted "<TR><TD><B> Итого </B></TD>" skip
                "<TD>" string(v-whole-count) "</TD>" skip
                "<TD>" string(v-whole-sum) "</TD></TR>" skip.

for each tax_temp1 where tax_temp1.depart = tax_temp.depart no-lock.
v-c1 = v-c1 + 1.
v-s1 = v-s1 + tax_temp1.sum.
end.

put unformatted "<TR><TD><B> Итого (276 тенге) </B></TD>" skip
                "<TD>" string(v-c1) "</TD>" skip
                "<TD>" string(v-s1) "</TD></TR>" skip.
v-c1 = 0.
v-s1 = 0.
end.
end.

output close.

unix silent value("cptwin reporth.htm excel").
pause 0.
