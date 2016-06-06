/* kb_priz.p
 * MODULE
        Отчет о признаке в кредитное бюро
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
 * BASES
        BANK COMM
 * AUTHOR
        16/04/08 marinav
 * CHANGES
        19/08/2013 Sayat(id01143) - ТЗ 1776 от 27/03/2013 "Изменения в отчете «Признак согласия на отправку в Кредитное Бюро»"
*/


/*output to kb.txt.
 for each cif no-lock.
     find lon where lon.cif = cif.cif no-lock no-error.
     if avail lon then do:

         find sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'lonkb' no-lock no-error.

          if not avail sub-cod then put cif.cif '  --------------------- '  cif.name '   ' skip.
          else
          if sub-cod.ccode = '01' then put cif.cif '   '  cif.name '   есть' skip.
                                  else put cif.cif '   ' cif.name '   нет' skip.
      end.

 end.


unix silent cptwin kb.txt winword.
*/

def new shared temp-table kbpriz
  field cif     as  char
  field fil     as  char
  field cifname as  char
  field lon     as  char
  field vid     as  char
  field isdt    as  date
  field duedt   as  date
  field amt     as  deci
  field priz    as  char.

def new shared var d-rates as deci no-undo extent 20.

for each crc no-lock:
  d-rates[crc.crc] = crc.rate[1].
end.

empty temp-table kbpriz.

{r-brfilial.i &proc = "kb_prizf"}

def stream m-out.
output stream m-out to kb.htm.

put stream m-out unformatted
      "<html><head>" skip
      "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
      "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
      "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
      "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
      "</head><body>" skip.

put stream m-out unformatted
      "<BR><BR>" skip
      "<b> Признак согласия на отправку в Кредитное Бюро </b>" skip.

put stream m-out unformatted
     "<table border=1 cellpadding=0 cellspacing=0>" skip
     "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
     "<td valign=""center""> Код клиента </td>" skip
     "<td valign=""center""> Филиал </td>" skip
     "<td valign=""center""> Наименование заемщика </td>" skip
     "<td valign=""center""> Ссудный счет </td>" skip
     "<td valign=""center""> Вид кредлита </td>" skip
     "<td valign=""center""> Дата выдачи </td>" skip
     "<td valign=""center""> Срок погашения </td>" skip
     "<td valign=""center""> Сумма </td>" skip
     "<td valign=""center""> Наличие согласия в КБ </td>" skip
     "</tr>" skip.

for each kbpriz no-lock:
    put stream m-out unformatted
        "<tr><td>" kbpriz.cif "</td>" skip
        "<td>" kbpriz.fil "</td>" skip
        "<td>" kbpriz.cifname "</td>" skip
        "<td>&nbsp;" kbpriz.lon "</td>" skip
        "<td>" kbpriz.vid "</td>" skip
        "<td>" string(kbpriz.isdt) "</td>" skip
        "<td>" string(kbpriz.duedt) "</td>" skip
        "<td>" replace(string(kbpriz.amt, "->>>>>>>>>>>>>>9.99"),".",",") "</td>" skip
        "<td>" kbpriz.priz "</td></tr>" skip.
end.

put stream m-out unformatted "</table></body></html>".
output stream m-out close.

unix silent cptwin kb.htm excel.

