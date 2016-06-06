/* pkrpvyd.p

 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Просмотр непринятых досье и принятие на рассмотрение в ГБ
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
        21/06/2004 madiyar - объединил отчеты по каждому типу кредита (pkrepday) в один
 * CHANGES
        22/06/2004 madiyar - добавил в меню запуск общего отчета по потребкредитам (pkdays.p)
        13/04/2006 madiyar - добавил колонку с логином акцептовавшего менеджера
        23/05/2006 madiyar - добавил колонку с признаком рефинансирования (БД)
        25.05.2009 galina - добавила колонки "Дата выдачи кредита" и "Номер договора"
*/

{mainhead.i}
{comm-txb.i}
define var s-ourbank as char no-undo.
s-ourbank = comm-txb().

def var cust-list as character no-undo view-as selection-list single size 50 by 15 label " Выберите тип кредита: ".
def var ok-status as logical no-undo.
def var chosen_one as char no-undo.
def var coun as int no-undo.
define variable datums as date no-undo format '99/99/9999'.
define variable datums1 as date no-undo format '99/99/9999'.
def var data_ar as char no-undo extent 10.
def var common as logi no-undo init false.
def var v-job as char no-undo.
def var v-refin as char no-undo.

form
  cust-list
  with frame sel-frame centered.

on default-action of cust-list
   do:
     chosen_one = data_ar[integer(entry(1,cust-list:screen-value,'.'))].
     if entry(2,cust-list:screen-value,'.') = ' Общий отчет' then common = true.
   end.

coun = 1.
for each bookcod where bookcod.bookcod = 'credtype' no-lock use-index bookcod:
  ok-status = cust-list:ADD-LAST(string(coun) + '. ' + bookcod.name).
  data_ar[coun] = bookcod.code.
  coun = coun + 1.
end. /* for each bookcod */

/* добавим общий отчет */
ok-status = cust-list:ADD-LAST(string(coun) + '. Общий отчет').

enable cust-list with frame sel-frame.

wait-for default-action of current-window.

if common then do:
  run pkdays.
  return.
end.

datums = g-today.
datums1 = g-today.

update datums label ' Укажите дату с ' format '99/99/9999' datums1 label ' по ' format '99/99/9999' skip
       with side-label row 5 centered frame dat .

find first cmp no-lock no-error.

define stream m-out.
output stream m-out to repday.htm.

put stream m-out unformatted
                 "<html><head><title>TEXAKABANK</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>"
                 skip.


put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.

put stream m-out unformatted
                 "<br><br><tr align=""left""><td><h3>" cmp.name format 'x(79)' 
                 "</h3></td></tr><br><br>"
                 skip(1).

find bookcod where bookcod.bookcod = "credtype" and bookcod.code = chosen_one no-lock no-error.
put stream m-out unformatted
                 "<tr align=""center""><td><h3>Сведения о выданных займах по программе " skip
                 caps(bookcod.name) format "x(60)" skip
                 " с " string(datums) " по " string(datums1)
                 "</h3></td></tr><br><br>"
                 skip(1).

put stream m-out unformatted "<tr></tr><tr></tr>" skip(1).

put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                 "<tr style=""font:bold"">"
                 "<td bgcolor=""#C0C0C0"" align=""center"">П/п</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"">Анкета</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"">Акцептовал</td>".
if chosen_one = '6' then put stream m-out unformatted "<td bgcolor=""#C0C0C0"" align=""center"">Рефин.</td>".
put stream m-out unformatted "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"">РНН</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"">Ссудный счет</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"">Дата выдачи кредита</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"">Номер договора</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"">Текущий счет</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"">Рейтинг</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"">Сумма займа,тенге</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"">Срок займа,мес</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"">Дата погашения</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"">Наименование товара</td>"
                 "<td bgcolor=""#C0C0C0"" align=""center"">Оценочная стоимость</td>" 
                 "<td bgcolor=""#C0C0C0"" align=""center"">Комиссия банка,тенге</td>" 
                 "<td bgcolor=""#C0C0C0"" align=""center"">Место работы клиента</td></tr>"
                 skip.

coun = 1.
for each pkanketa no-lock where pkanketa.bank = s-ourbank and pkanketa.credtype = chosen_one and 
         pkanketa.docdt >= datums and pkanketa.docdt <= datums1 and pkanketa.lon ne '' 
         break by pkanketa.ln.
  find first loncon where loncon.lon = pkanketa.lon no-lock no-error. 
  v-job = ''.
  find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype 
           and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'joborg' no-lock no-error.
  if avail pkanketh then v-job = pkanketh.value1.
        put stream m-out unformatted
               "<tr align=""right"">"
               "<td align=""center"">" coun "</td>"
               "<td align=""center"">" pkanketa.ln "</td>"
               "<td align=""center"">" pkanketa.cwho "</td>".
        if chosen_one = '6' then do:
           find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype 
                               and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'rnn' no-lock no-error.
           if avail pkanketh and pkanketh.rescha[1] <> '' then v-refin = "Рефин.". else v-refin = ''.
           put stream m-out unformatted "<td align=""center"">" v-refin "</td>".
        end.
        put stream m-out unformatted "<td align=""left"">" pkanketa.name "</td>"
               "<td align=""left"">&nbsp;" pkanketa.rnn format "x(12)" "</td>"
               "<td align=""center"">&nbsp;" pkanketa.lon "</td>"
               "<td align=""center"">&nbsp;" pkanketa.docdt "</td>"
               "<td align=""center"">&nbsp;" loncon.lcnt "</td>"
               "<td align=""center"">&nbsp;" pkanketa.aaa "</td>"
               "<td align=""center"">" pkanketa.rating format '>>9' "</td>"
               "<td>" pkanketa.summa format '>>>>>>>>>>>9.99' "</td>"
               "<td align=""center"">" pkanketa.srok "</td>"
               "<td>" pkanketa.duedt "</td>"
               "<td align=""left"">" pkanketa.goal format 'x(40)' "</td>"
               "<td>" pkanketa.billsum format '>>>>>>>>>>>9.99' "</td>"
               "<td>" (pkanketa.summa - pkanketa.sumq) format '->>>>>>>>>>>9.99' "</td>"
               "<td align=""left"">" v-job "</td>"
               "</tr>" skip.
         coun = coun + 1.
end.                       

put stream m-out unformatted "</table>" skip.
output stream m-out close.

unix silent cptwin repday.htm excel.
