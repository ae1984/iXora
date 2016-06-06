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
   kapar - 06.12.2012 СЗ включить в данный отчет возможность выгрузки детализированных данных в разрезе заемщиков

*/

{mainhead.i}

def new shared temp-table lnpr
  field id      as   int
  field name    as   char
  field nsum    as   decimal extent 4
  field tsum    as   decimal extent 4.

def new shared temp-table dlnpr
  field id      as   int
  field cif     as   char
  field cname   as   char
  field lon     as   char
  field nsum    as   decimal extent 4
  field tsum    as   decimal extent 4.

def var usrnm as char no-undo.
def var v-bank as char no-undo.

def new shared var v-date1 as date.
def new shared var v-date2 as date.
def new shared var v-sel   as deci.


do transaction:
     update v-date1 label 'ЗАДАЙТЕ ПЕРИОД С'
             help "Введите начальную дату."
            v-date2 label 'ПО'
             help "Введите конечную дату."
            with row 10 centered  side-label frame opt title 'Начисленные и полученные доходы по займам'.
  if v-date2 < v-date1 then
   do:
     message 'Конечная дата не может быть меньше начальной!' view-as alert-box.
     undo,retry.
   end.
end.

run sel2 (" Выбор: ", " 1. Сводный | 2. Расшифрованный ", output v-sel).

{r-brfilial.i &proc = "rnpdf.p"}


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
      "<b>Начисленные и полученные доходы по займам за период с " string(v-date1) " по " string(v-date2) "</b><br>" skip.

  if v-sel = 1 then do:
      put stream repdvk unformatted
      "<table border=1 cellpadding=0 cellspacing=0>" skip
      "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
      "<td valign=""center"" rowspan=2 > Филиал </td>" skip
      "<td valign=""center"" colspan=3> ЮЛ, МСБ, ИП </td>" skip
      "<td valign=""center"" colspan=3> ФЛ </td> </tr>" skip.
      put stream repdvk unformatted
      "<td bgcolor=""#C0C0C0"" valign=""center""> Всего доходов по займам </td>" skip
      "<td bgcolor=""#C0C0C0"" valign=""center""> Начисленные </td>" skip
      "<td bgcolor=""#C0C0C0"" valign=""center""> Полученные </td>" skip
      "<td bgcolor=""#C0C0C0"" valign=""center""> Всего доходов по займам </td>" skip
      "<td bgcolor=""#C0C0C0"" valign=""center""> Начисленные </td>" skip
      "<td bgcolor=""#C0C0C0"" valign=""center""> Полученные </td>" skip.


      for each lnpr no-lock:
        put stream repdvk unformatted "<tr>" skip.
        put stream repdvk unformatted
        "<td>" lnpr.name "</td>" skip.
        put stream repdvk unformatted
        "<td>" replace(trim(string(lnpr.nsum[1] + lnpr.nsum[2] ,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
        put stream repdvk unformatted
        "<td>" replace(trim(string(lnpr.nsum[1] ,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
        put stream repdvk unformatted
        "<td>" replace(trim(string(lnpr.nsum[2] ,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
        put stream repdvk unformatted
        "<td>" replace(trim(string(lnpr.nsum[3] + lnpr.nsum[4] ,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
        put stream repdvk unformatted
        "<td>" replace(trim(string(lnpr.nsum[3] ,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
        put stream repdvk unformatted
        "<td>" replace(trim(string(lnpr.nsum[4] ,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
      end.
  end.
  else do:
      put stream repdvk unformatted
      "<table border=1 cellpadding=0 cellspacing=0>" skip
      "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
      "<td valign=""center"" rowspan=2 > Филиал </td>" skip
      "<td valign=""center"" rowspan=2 > Код клиента </td>" skip
      "<td valign=""center"" rowspan=2 > Наименование </td>" skip
      "<td valign=""center"" rowspan=2 > Ссудный счет </td>" skip
      "<td valign=""center"" colspan=3> ЮЛ, МСБ, ИП </td>" skip
      "<td valign=""center"" colspan=3> ФЛ </td> </tr>" skip.
      put stream repdvk unformatted
      "<td bgcolor=""#C0C0C0"" valign=""center""> Всего доходов по займам </td>" skip
      "<td bgcolor=""#C0C0C0"" valign=""center""> Начисленные </td>" skip
      "<td bgcolor=""#C0C0C0"" valign=""center""> Полученные </td>" skip
      "<td bgcolor=""#C0C0C0"" valign=""center""> Всего доходов по займам </td>" skip
      "<td bgcolor=""#C0C0C0"" valign=""center""> Начисленные </td>" skip
      "<td bgcolor=""#C0C0C0"" valign=""center""> Полученные </td>" skip.


      for each lnpr no-lock:

          put stream repdvk unformatted "<tr>" skip.
          put stream repdvk unformatted
          "<td>" lnpr.name "</td>" skip.
          put stream repdvk unformatted
          "<td></td>" skip.
          put stream repdvk unformatted
          "<td></td>" skip.
          put stream repdvk unformatted
          "<td></td>" skip.
          put stream repdvk unformatted
          "<td>" replace(trim(string(lnpr.nsum[1] + lnpr.nsum[2] ,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
          put stream repdvk unformatted
          "<td>" replace(trim(string(lnpr.nsum[1] ,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
          put stream repdvk unformatted
          "<td>" replace(trim(string(lnpr.nsum[2] ,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
          put stream repdvk unformatted
          "<td>" replace(trim(string(lnpr.nsum[3] + lnpr.nsum[4] ,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
          put stream repdvk unformatted
          "<td>" replace(trim(string(lnpr.nsum[3] ,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
          put stream repdvk unformatted
          "<td>" replace(trim(string(lnpr.nsum[4] ,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.

          for each dlnpr where dlnpr.id = lnpr.id and (dlnpr.nsum[1] <> 0 or dlnpr.nsum[2] <> 0 or dlnpr.nsum[3] <> 0 or dlnpr.nsum[4] <> 0) no-lock:
            put stream repdvk unformatted "<tr>" skip.
            put stream repdvk unformatted
            "<td></td>" skip.
            put stream repdvk unformatted
            "<td>" dlnpr.cif "</td>" skip.
            put stream repdvk unformatted
            "<td>" dlnpr.cname "</td>" skip.
            put stream repdvk unformatted
            "<td>'" dlnpr.lon "</td>" skip.
            put stream repdvk unformatted
            "<td>" replace(trim(string(dlnpr.nsum[1] + dlnpr.nsum[2] ,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
            put stream repdvk unformatted
            "<td>" replace(trim(string(dlnpr.nsum[1] ,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
            put stream repdvk unformatted
            "<td>" replace(trim(string(dlnpr.nsum[2] ,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
            put stream repdvk unformatted
            "<td>" replace(trim(string(dlnpr.nsum[3] + dlnpr.nsum[4] ,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
            put stream repdvk unformatted
            "<td>" replace(trim(string(dlnpr.nsum[3] ,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
            put stream repdvk unformatted
            "<td>" replace(trim(string(dlnpr.nsum[4] ,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
          end.

      end.
  end.

  put stream repdvk unformatted "</table></body></html>".
  output stream repdvk close.
  unix silent cptwin repdvk.htm excel.

hide message no-pause.































































