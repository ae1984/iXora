/* afn.p
 * MODULE
       Кредитный модуль
 * DESCRIPTION
       Отчеты по проверкам фин-хоз деятельности заемщиков и залогового обеспечения
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
       01/04/2011
 * BASES
	BANK, COMM
 * CHANGES

*/

{mainhead.i}

def new shared temp-table lnpr no-undo
  field id       as   int
  field kname    as   char
  field nsum     as   decimal extent 72.

def var i        as   int.
def var dt       as   date.
def var vnsum    as   decimal extent 72.
def var mname    as   char.

def var usrnm as char no-undo.
def var v-bank as char no-undo.

def var r1 as char no-undo.
r1 = "Кредиты по срокам просрочки".

def new shared var v-date1 as date.
def new shared var v-date2 as date.
def new shared var vsel    as int.
def var vm       as   int.
def var vmm      as   int.
def var vyy      as   int.
def var num_days as   int.

do transaction:
     update v-date1 label 'ЗАДАЙТЕ ПЕРИОД С'
             validate(v-date1 <= today,   "Дата не может быть больше текущей даты..... ")
             help "Введите начальную дату."
            v-date2 label 'ПО'
             validate(v-date2 <= today,   "Дата не может быть больше текущей даты..... ")
             help "Введите конечную дату."
            with row 3 centered  side-label frame opt title r1 .
  if v-date2 < v-date1 then
   do:
     message 'Конечная дата не может быть меньше начальной!' view-as alert-box.
     undo,retry.
   end.
end.
vm = (year(v-date2) - year(v-date1)) * 12 + (month(v-date2) - month(v-date1)).
vmm = month(v-date1) - 3. vyy = year(v-date1).

run sel2 ("Просрочка:", " 1. От 31 до 60  | 2. От 61 до 90 | 3. Более 90 ", output vsel).

create lnpr.
 lnpr.id = 1.
 lnpr.kname = "Экспресс-кредиты ".
create lnpr.
 lnpr.id = 2.
 lnpr.kname = "Сотрудники".
create lnpr.
 lnpr.id = 3.
 lnpr.kname = "Оборотный кредит ".
create lnpr.
 lnpr.id = 4.
 lnpr.kname = "Инвестиционный кредит ".
create lnpr.
 lnpr.id = 5.
 lnpr.kname = "Кредиты МСБ с упрощенным фин. анализом ".
create lnpr.
 lnpr.id = 6.
 lnpr.kname = "Овердрафт ".
create lnpr.
 lnpr.id = 7.
 lnpr.kname = "Факторинг".
create lnpr.
 lnpr.id = 8.
 lnpr.kname = "Прочие кредиты ФЛ ".
create lnpr.
 lnpr.id = 9.
 lnpr.kname = "Прочие кредиты ЮЛ ".
create lnpr.
 lnpr.id = 10.
 lnpr.kname = "Ипотека  ".

{r-brfilial.i &proc = "afn_rpt11f"}


def stream repdvk.
output stream repdvk to repdvk.htm.

  put stream repdvk unformatted
      "<html><head>" skip
      "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
      "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
      "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
      "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
      "</head><body>" skip.

  find first ofc where ofc.ofc = g-ofc no-lock no-error.
  if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

  put stream repdvk unformatted
      "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
      "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip.

  put stream repdvk unformatted
      "<BR><b>" r1 "</b><BR>" skip
      "<b>Отчет за период с " string(v-date1) " по " string(v-date2) "</b><br>" skip.

  if vsel = 1 Then do:
    put stream repdvk unformatted
      "<b> От 31 до 60</b><br>" skip.
  end.
  if vsel = 2 Then do:
    put stream repdvk unformatted
      "<b> От 61 до 90</b><br>" skip.
  end.
  if vsel = 3 Then do:
    put stream repdvk unformatted
      "<b> Более 90</b><br>" skip.
  end.

  put stream repdvk unformatted
  "<table border=1 cellpadding=0 cellspacing=0>" skip
  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
  "<td valign=""center""> Программа кредитования </td>" skip.

  i = 0.
  repeat while i <= vm:
    vmm =  vmm + 3.
    if vmm > 12 then do:
      vmm = vmm - 12.
      vyy = vyy + 1.
    end.

    run mondays(vmm, vyy, output num_days).
    if num_days < day(v-date1) then dt = date(string(num_days) + '.' + string(vmm) + '.' + string(vyy)).
    else dt = date(string(day(v-date1)) + '.' + string(vmm) + '.' + string(vyy)).

    put stream repdvk unformatted
    "<td valign=""center"">" string(dt) "</td>" skip.
  i = i + 3.
  end.


  i = 3.
  repeat while i <= vm + 3:
      vnsum[i] = 0.
      for each lnpr no-lock:
        vnsum[i] = vnsum[i] + lnpr.nsum[i].
      end.
  i = i + 3.
  end.

  for each lnpr no-lock:
    put stream repdvk unformatted "<tr>" skip.
    put stream repdvk unformatted
    "<td>" lnpr.kname "</td>" skip.
    i = 3.
    repeat while i <= vm + 3:
      put stream repdvk unformatted
      "<td>" replace(trim(string(lnpr.nsum[i],'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    i = i + 3.
    end.
  end.

    put stream repdvk unformatted "<tr style=""font:bold"">" skip.
    put stream repdvk unformatted
    "<td> Всего </td>" skip.
    i = 3.
    repeat while i <= vm + 3:
      put stream repdvk unformatted
      "<td>" replace(trim(string(vnsum[i],'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    i = i + 3.
    end.

  put stream repdvk unformatted "</table></body></html>".
  output stream repdvk close.
  unix silent cptwin repdvk.htm excel.

hide message no-pause.































































