/* budrep1.p
 * MODULE

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
        14/07/2012 Luiza
 * BASES
	BANK COMM
 * CHANGES

*/

{mainhead.i}

def new shared temp-table lnpr no-undo
  field gl       as   int
  field code     as   char
  field s1       as   char
  field nf       as   decimal
  index ind is primary gl code.

def var vgl     as   int.
def var vnf     as   decimal.

def var usrnm as char no-undo.

def new shared var v-date as date.
def new shared var v-date2 as date.
def new shared var v-gl as char.
def new shared var ii   as   int.
ii = 0.


do transaction:
     update v-date label 'ЗАДАЙТЕ ПЕРИОД С'
             validate(v-date <= today,   "Дата не может быть больше текущей даты..... ")
             help "Введите начальную дату."
            v-date2 label 'ПО'
             validate(v-date2 <= today,   "Дата не может быть больше текущей даты..... ")
             help "Введите конечную дату."
              v-gl label 'Введите счет ГК для расшифровки'  format 'x(4)'
             help "Введите счет ГК."
            with row 8 centered  side-label frame opt.
  if v-date2 < v-date then
   do:
     message 'Конечная дата не может быть меньше начальной!' view-as alert-box.
     undo,retry.
   end.
end.

def var v-bank as char no-undo.

{r-brfilial.i &proc = "budrep2(output v-bank)" }

def stream rep.
output stream rep to rep.htm.

  put stream rep unformatted
      "<html><head>" skip
      "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
      "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
      "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
      "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
      "</head><body>" skip.

  find first ofc where ofc.ofc = g-ofc no-lock no-error.
  if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

  put stream rep unformatted
      "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
      "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip.

if ii > 1 then v-bank = "консолидированный".
  put stream rep unformatted
      "<BR><b>Доходы/Расходы по кодам операций за период с " +
          string(v-date) + " по " + string(v-date2) + " " + v-bank + "</b><BR><br>" skip.

  put stream rep unformatted
  "<table border=1 cellpadding=0 cellspacing=0>" skip
  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
  "<td>Счет ГК</td>" skip
  "<td>Код дох/расх</td>" skip
  "<td>Наименование (код опер.)</td>" skip
  "<td>сумма</td>" skip.

vgl = 0.
for each lnpr no-lock:

    if vgl <> lnpr.gl then do:

        if vgl <> 0 then do:
             put stream rep unformatted "<tr style=""font:bold;"">" skip.

             put stream rep unformatted
             "<td>" 'Итого:' "</td>" skip.
             put stream rep unformatted
             "<td></td>" skip.
             put stream rep unformatted
             "<td></td>" skip.
             put stream rep unformatted
             "<td align=""right"">" replace(string(vnf),".",",") "</td>" skip.
             put stream rep unformatted "<tr>" skip.
        end.
        vnf = lnpr.nf.
        vgl = lnpr.gl.
    end.
    else vnf = vnf + lnpr.nf.

    put stream rep unformatted "<tr>" skip.

    put stream rep unformatted
    "<td>" lnpr.gl "</td>" skip.
    put stream rep unformatted
    "<td>" lnpr.code "</td>" skip.
    put stream rep unformatted
    "<td>" lnpr.s1 "</td>" skip.
    put stream rep unformatted
    "<td align=""right"">" replace(string(lnpr.nf),".",",") "</td>" skip.
end.

  if vgl <> 0 then do:
     put stream rep unformatted "<tr style=""font:bold;"">" skip.

     put stream rep unformatted
     "<td>" 'Итого:' "</td>" skip.
     put stream rep unformatted
     "<td></td>" skip.
     put stream rep unformatted
     "<td></td>" skip.
     put stream rep unformatted
     "<td align=""right"">" replace(string(vnf),".",",") "</td>" skip.
  end.


  put stream rep unformatted "</table></body></html>".
  output stream rep close.
  unix silent cptwin rep.htm excel.

hide message no-pause.































































