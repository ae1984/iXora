/* analtax.p
 * MODULE
        Название Программного Модуля
        отчет
 * DESCRIPTION
        Анализ налоговых платежей по диапазонам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
        из меню
 * CALLER
        Список процедур, вызывающих этот файл
        меню
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
        5.4
 * AUTHOR
        21/03/2006 u00568 Evgeniy
 * CHANGES
        27/03/2006 u00568 Evgeniy - увеличил количество знаков для чисел.
*/

{comm-txb.i}
def var seltxb as int no-undo.
seltxb = comm-cod().
def stream st1.

def var dt1  as date no-undo.
def var dt2  as date no-undo.
def var kbks as char no-undo init ''.

def shared var g-today as date.
dt1 = g-today.
dt2 = g-today.

def var sum1  as decimal extent 8  init 0 no-undo.
def var count1  as int extent 8  init 0 no-undo.
def var com1  as decimal extent 8  init 0 no-undo.
def var i as int init 0 no-undo.
def var j as int init 0 no-undo.
def var vilki as int format ">,>>>,>>>,>>9" extent 8 init 0 no-undo.
def var tot_sum1  as decimal init 0 no-undo.
def var tot_count1  as int init 0 no-undo.
def var tot_com1  as decimal init 0 no-undo.
def var tot_test  as decimal init 0 no-undo.
def var str_branch_name as char no-undo.
def var temp4 as decimal init 0 no-undo.
def var temp6 as decimal init 0 no-undo.


find first txb no-lock where txb.consolid and txb.txb = seltxb.
if avail txb then
  str_branch_name = txb.info.
else
  str_branch_name = 'Новый Филиал'.


update
  dt1 format '99/99/9999' label "от Даты " skip
  dt2 format '99/99/9999' label "до Даты " skip

  kbks format 'x(30)' label "перечень КБК" skip
  "КБК через (,) - иначе - все КБК"
with side-labels centered frame df.

output stream st1 to anal_tax_rep.img.

{html-title.i
 &stream = " stream st1 "
 &title = " "
 &size-add = "x-"
}

put stream st1 unformatted
   "<P align=""center"" style=""font:bold"">
     Анализ налоговых платжей по диапазонам. <br> За период с "
     string(dt1, "99/99/9999") " по " string(dt2, "99/99/9999")
   "<BR>"
skip.

kbks = trim(kbks).

if kbks = '' then do:
  put stream st1 unformatted   " По всем КБК." skip.
end. else do:
  put stream st1 unformatted   " По следующим КБК: " kbks "." skip.
end.

put stream st1 unformatted   " <br> По " str_branch_name skip.


put stream st1 unformatted
  "<TABLE cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
    "<TR align=""center"" style=""font:bold"">" skip
      "<TD>Диапазон сумм налоговых платежей</TD>" skip
      "<TD>Кол-во платежей</TD>" skip
      "<TD>Сумма платежей</TD>" skip
      "<TD>средняя сумма платежа</TD>" skip
      "<TD>Комиссия </TD>" skip
      "<TD>% доля Кол-ва платежей </TD>" skip
  "</TR>" skip.
put stream st1 unformatted
    "<TR align=""center"" style=""font:bold"">" skip
      "<TD>1</TD>" skip
      "<TD>2</TD>" skip
      "<TD>3</TD>" skip
      "<TD>4 = 3 / 2</TD>" skip
      "<TD>5 </TD>" skip
      "<TD>6 = 2/ общее кол-во платежей </TD>" skip
  "</TR>" skip.

vilki[1] = 0.
vilki[2] = 100.
vilki[3] = 1000.
vilki[4] = 3000.
vilki[5] = 5000.
vilki[6] = 10000.
vilki[7] = 100000.
vilki[8] = 1000000.

for each tax where dt1 <= tax.cdate and tax.cdate <= dt2 no-lock:
  if tax.txb = seltxb
    and duid = ?
    and (index(kbks, string(tax.kb, '999999')) > 0 or kbks = '') then
  do:
    i = 0.
    j = 8.
    if vilki[j] < tax.sum then do:
      i = j.
    end.
    do j = 1 to 7 :
      if vilki[j] < tax.sum and tax.sum <= vilki[ j + 1 ] then do:
        i = j.
      end.
    end.

    /*if 0 < tax.sum and tax.sum <= 100 then
     i = 1.
    if 100 < tax.sum and tax.sum <= 1000 then
     i = 2.
    if 1000 < tax.sum and tax.sum <= 3000 then
     i = 3.
    if 3000 < tax.sum and tax.sum <= 5000 then
     i = 4.
    if 5000 < tax.sum and tax.sum <= 10000 then
     i = 5.
    if 10000 < tax.sum and tax.sum <= 100000 then
     i = 6.
    if 100000 < tax.sum and tax.sum <= 1000000 then
     i = 7.
    if 1000000 < tax.sum then
     i = 8.
    */
    if i <> 0 then do:
      sum1[i] = sum1[i] + tax.sum.
      count1[i] = count1[i] + 1.
      com1[i] = com1[i] + tax.comsum.
    end.
  end.
end.

do i = 1 to 8 :
  tot_sum1 = tot_sum1 + sum1[i].
  tot_count1 = tot_count1 + count1[i].
  tot_com1 = tot_com1 + com1[i].
end.

do i = 1 to 7 :
  temp4 = 0.
  temp6 = 0.
  temp4 = sum1[i] / count1[i] no-error.
  temp6 = count1[i] * 100 / tot_count1 no-error.
  put stream st1 unformatted
    "<TR align=""center"" style=""font:bold"">" skip
      "<TD> ОТ " vilki[i] " До " vilki[i + 1] "</TD>" skip
      "<TD>" replace(trim(string(count1[i], ">>>>>>>>>>>9"   )), ".", ",")  "</TD>" skip
      "<TD>" replace(trim(string(sum1[i],   ">>>>>>>>>>>9.99")), ".", ",") "</TD>" skip
      "<TD>" replace(trim(string(temp4 ,    ">>>>>>>>>>>9.99")), ".", ",")  "</TD>" skip
      "<TD>" replace(trim(string(com1[i],   ">>>>>>>>>>>9.99")), ".", ",") "</TD>" skip
      "<TD>" replace(trim(string(temp6,     ">>>>>>>>>>>9.99")), ".", ",")  " </TD>" skip
    "</TR>" skip.
end.

i=8.
temp4 = 0.
temp6 = 0.
temp4 = sum1[i] / count1[i] no-error.
temp6 = count1[i] * 100 / tot_count1 no-error.
put stream st1 unformatted
  "<TR align=""center"" style=""font:bold"">" skip
    "<TD> больше " vilki[i] "</TD>" skip
    "<TD>" replace(trim(string(count1[i], ">>>>>>>>>>>9"   )), ".", ",")  "</TD>" skip
    "<TD>" replace(trim(string(sum1[i],   ">>>>>>>>>>>9.99")), ".", ",") "</TD>" skip
    "<TD>" replace(trim(string(temp4 ,    ">>>>>>>>>>>9.99")), ".", ",")  "</TD>" skip
    "<TD>" replace(trim(string(com1[i],   ">>>>>>>>>>>9.99")), ".", ",") "</TD>" skip
    "<TD>" replace(trim(string(temp6,     ">>>>>>>>>>>9.99")), ".", ",")  " </TD>" skip
  "</TR>" skip.


do i = 1 to 8 :
  tot_test = tot_test + (count1[i] * 100) / tot_count1 no-error.
end.

put stream st1 unformatted
  "<TR align=""center"" style=""font:bold"">" skip
    "<TD> Всего </TD>" skip
    "<TD>" replace(trim(string(tot_count1, "->>>>>>>>>>>9"   )), ".", ",") "</TD>" skip
    "<TD>" replace(trim(string(tot_sum1,   "->>>>>>>>>>>9.99")), ".", ",") "</TD>" skip
    "<TD> </TD>" skip
    "<TD>" replace(trim(string(tot_com1,   "->>>>>>>>>>>9.99")), ".", ",") "</TD>" skip
    "<TD>" replace(trim(string(tot_test,   "->>>>>>>>>>>9.99")), ".", ",")  " </TD>" skip
  "</TR>" skip.


put stream st1 unformatted "</TABLE>" skip.
{html-end.i " stream st1 "}

output stream st1 close.

unix silent cptwin anal_tax_rep.img excel.
