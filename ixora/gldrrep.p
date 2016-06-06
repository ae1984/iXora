/* gldrrep.p
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
       01/04/2011 kapar
 * BASES
	BANK, COMM
 * CHANGES

*/

{mainhead.i}

def new shared temp-table lnpr no-undo
  field gl       as   int
  field code     as   char
  field s1       as   char
  field nf       as   decimal extent 18
  index ind is primary gl code.

def new shared temp-table lnprDtl no-undo
  field gl       as   int
  field code     as   char
  field s1       as   char
  field bnk      as   char
  field dam      as   decimal
  field cam      as   decimal.

def var i       as   int.
def var vgl     as   int.
def var vnf     as   decimal extent 18.

def var usrnm as char no-undo.

def new shared var v-date as date.
def new shared var v-date2 as date.
def new shared var v-gl as char.


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

{r-branch.i &proc = "gldsdat(comm.txb.bank,output v-bank)" }

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


  put stream rep unformatted
      "<BR><b>Доходы/Расходы по кодам операций за период с " +
          string(v-date) + " по " + string(v-date2) + "</b><BR><br>" skip.

  put stream rep unformatted
  "<table border=1 cellpadding=0 cellspacing=0>" skip
  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
  "<td>Счет ГК</td>" skip
  "<td>Код дох/расх</td>" skip
  "<td>Наименование (код опер.)</td>" skip
  "<td>ЦО</td>" skip
  "<td>Алматы</td>" skip
  "<td>Астана</td>" skip
  "<td>Караганда</td>" skip
  "<td>Актобе</td>" skip
  "<td>Шымкент</td>" skip
  "<td>Усть-Каменогорск</td>" skip
  "<td>Костанай</td>" skip
  "<td>Актау</td>" skip
  "<td>Атырау</td>" skip
  "<td>Павлодар</td>" skip
  "<td>Уральск</td>" skip
  "<td>Петропавловск</td>" skip
  "<td>Кокшетау</td>" skip
  "<td>Жезказган</td>" skip
  "<td>Семей</td>" skip
  "<td>Тараз</td>" skip
  "<td>Консолидированный</td>" skip.

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
         "<td align=""right"">" replace(string(vnf[1]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[17]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[9]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[6]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[2]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[16]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[15]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[3]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[13]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[12]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[10]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[5]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[11]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[8]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[14]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[7]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[4]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[1] + vnf[2] + vnf[3] + vnf[4] + vnf[5] + vnf[6] + vnf[7] +
                                               vnf[8] + vnf[9] + vnf[10] + vnf[11] + vnf[12] + vnf[13] + vnf[14] +
                                               vnf[15] + vnf[16] + vnf[17]),".",",") "</td>" skip.
         put stream rep unformatted "<tr>" skip.
      end.

      do i = 1 to 18:
       vnf[i] = lnpr.nf[i].
      end.
     vgl = lnpr.gl.
     end.
     else do:
      do i = 1 to 18:
       vnf[i] = vnf[i] + lnpr.nf[i].
      end.
     end.

     put stream rep unformatted "<tr>" skip.

     put stream rep unformatted
     "<td>" lnpr.gl "</td>" skip.
     put stream rep unformatted
     "<td>" lnpr.code "</td>" skip.
     put stream rep unformatted
     "<td>" lnpr.s1 "</td>" skip.
     put stream rep unformatted
     "<td align=""right"">" replace(string(lnpr.nf[1]),".",",") "</td>" skip.
     put stream rep unformatted
     "<td align=""right"">" replace(string(lnpr.nf[17]),".",",") "</td>" skip.
     put stream rep unformatted
     "<td align=""right"">" replace(string(lnpr.nf[9]),".",",") "</td>" skip.
     put stream rep unformatted
     "<td align=""right"">" replace(string(lnpr.nf[6]),".",",") "</td>" skip.
     put stream rep unformatted
     "<td align=""right"">" replace(string(lnpr.nf[2]),".",",") "</td>" skip.
     put stream rep unformatted
     "<td align=""right"">" replace(string(lnpr.nf[16]),".",",") "</td>" skip.
     put stream rep unformatted
     "<td align=""right"">" replace(string(lnpr.nf[15]),".",",") "</td>" skip.
     put stream rep unformatted
     "<td align=""right"">" replace(string(lnpr.nf[3]),".",",") "</td>" skip.
     put stream rep unformatted
     "<td align=""right"">" replace(string(lnpr.nf[13]),".",",") "</td>" skip.
     put stream rep unformatted
     "<td align=""right"">" replace(string(lnpr.nf[12]),".",",") "</td>" skip.
     put stream rep unformatted
     "<td align=""right"">" replace(string(lnpr.nf[10]),".",",") "</td>" skip.
     put stream rep unformatted
     "<td align=""right"">" replace(string(lnpr.nf[5]),".",",") "</td>" skip.
     put stream rep unformatted
     "<td align=""right"">" replace(string(lnpr.nf[11]),".",",") "</td>" skip.
     put stream rep unformatted
     "<td align=""right"">" replace(string(lnpr.nf[8]),".",",") "</td>" skip.
     put stream rep unformatted
     "<td align=""right"">" replace(string(lnpr.nf[14]),".",",") "</td>" skip.
     put stream rep unformatted
     "<td align=""right"">" replace(string(lnpr.nf[7]),".",",") "</td>" skip.
     put stream rep unformatted
     "<td align=""right"">" replace(string(lnpr.nf[4]),".",",") "</td>" skip.
     put stream rep unformatted
     "<td align=""right"">" replace(string(lnpr.nf[1] + lnpr.nf[2] + lnpr.nf[3] + lnpr.nf[4] + lnpr.nf[5] + lnpr.nf[6] + lnpr.nf[7] +
                                           lnpr.nf[8] + lnpr.nf[9] + lnpr.nf[10] + lnpr.nf[11] + lnpr.nf[12] + lnpr.nf[13] + lnpr.nf[14] +
                                           lnpr.nf[15] + lnpr.nf[16] + lnpr.nf[17]),".",",") "</td>" skip.
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
         "<td align=""right"">" replace(string(vnf[1]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[17]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[9]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[6]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[2]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[16]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[15]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[3]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[13]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[12]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[10]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[5]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[11]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[8]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[14]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[7]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[4]),".",",") "</td>" skip.
         put stream rep unformatted
         "<td align=""right"">" replace(string(vnf[1] + vnf[2] + vnf[3] + vnf[4] + vnf[5] + vnf[6] + vnf[7] +
                                               vnf[8] + vnf[9] + vnf[10] + vnf[11] + vnf[12] + vnf[13] + vnf[14] +
                                               vnf[15] + vnf[16] + vnf[17]),".",",") "</td>" skip.
      end.


  put stream rep unformatted "</table></body></html>".
  output stream rep close.
  unix silent cptwin rep.htm excel.

If v-gl <> "" Then do:

  def stream repdtl.
  output stream repdtl to repdtl.csv.
  put stream repdtl unformatted "Счет ГК;Код дох/расх;Наименование (код опер.);Код филиала;Дебет;Кредит" skip.

  for each lnprDtl no-lock:
   put stream repdtl unformatted lnprDtl.gl ";" lnprDtl.code ";" lnprDtl.s1 ";" lnprDtl.bnk ";" replace(string(lnprDtl.dam),".",",") ";" replace(string(lnprDtl.cam),".",",") skip.
  end.

  output stream repdtl close.
  unix silent cptwin repdtl.csv excel.
end.

hide message no-pause.































































