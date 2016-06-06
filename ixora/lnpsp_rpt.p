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

def new shared temp-table flnpr
  field fid      as   int
  field fname    as   char.

def new shared temp-table lnpr
  field id       as   int
  field fid      as   int
  field kname    as   char
  field nsum     as   decimal extent 72.

def temp-table klnpr
  field id       as   int
  field kname    as   char
  field nsum     as   decimal extent 72.

def var i        as   int.
def var vnsum    as   decimal extent 72.
def var mname    as   char.
def var v_fid    as   int.


def var usrnm as char no-undo.
def var v-bank as char no-undo.

def var r1 as char no-undo.

def new shared var v-date1 as date.
def new shared var v-date2 as date.
def new shared var v_sel   as int.
def var vm      as   int.
def var vmm     as   int.
def var tmm     as   int.
def var vyy     as   int.
def var tyy     as   int.


run sel2 ("Выберите:", " 1. Ссудный портфель – план-факт  | 2. Выдача и погашение кредитов | 3. Прогноз погашений", output v_sel).

if v_sel = 1 then do:
    r1 = "Ссудный портфель – план-факт".
end.
if v_sel = 2 then do:
    r1 = "Выдача и погашение кредитов".
end.
if v_sel = 3 then do:
    r1 = "Прогноз погашений".
end.

do transaction:
     update v-date1 label 'ЗАДАЙТЕ ПЕРИОД С'
             help "Введите начальную дату."
            v-date2 label 'ПО'
             help "Введите конечную дату."
            with row 10 centered  side-label frame opt title r1.
  if v-date2 < v-date1 then
   do:
     message 'Конечная дата не может быть меньше начальной!' view-as alert-box.
     undo,retry.
   end.
end.
vm = (year(v-date2) - year(v-date1)) * 12 + (month(v-date2) - month(v-date1)).
vmm = month(v-date1) - 1. tmm = vmm.
vyy = year(v-date1). tyy = vyy.


{r-brfilial.i &proc = "lnpsp_rptf"}


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
      "<b>Дата:</b> " today " " string(time,"HH:MM:SS") skip.

i = 1.
repeat while i <= vm + 1:
  for each lnpr no-lock:
    find first klnpr where klnpr.id = lnpr.id no-lock no-error.
    if not avail klnpr then do:
      create klnpr.
       klnpr.id = lnpr.id.
       klnpr.kname = lnpr.kname.
    end.

    klnpr.nsum[i] = klnpr.nsum[i] + lnpr.nsum[i].
    klnpr.nsum[i] = klnpr.nsum[i] + lnpr.nsum[i].
    klnpr.nsum[i] = klnpr.nsum[i] + lnpr.nsum[i].
    klnpr.nsum[i] = klnpr.nsum[i] + lnpr.nsum[i].
  end.
i = i + 1.
end.

for each flnpr no-lock:
  i = 1.
  repeat while i <= vm + 1:
    find first lnpr where lnpr.id = 1 and lnpr.fid = flnpr.fid no-lock no-error.
    if avail lnpr then vnsum[1]=lnpr.nsum[i].
    find first lnpr where lnpr.id = 2 and lnpr.fid = flnpr.fid no-lock no-error.
    if avail lnpr then vnsum[2]=lnpr.nsum[i].
    find first lnpr where lnpr.id = 3 and lnpr.fid = flnpr.fid no-lock no-error.
    if avail lnpr then vnsum[3]=lnpr.nsum[i].
    find first lnpr where lnpr.id = 4 and lnpr.fid = flnpr.fid no-lock no-error.
    if avail lnpr then vnsum[4]=lnpr.nsum[i].

    find first lnpr where lnpr.id = 5 and lnpr.fid = flnpr.fid no-lock no-error.
    if avail lnpr then lnpr.nsum[i] = vnsum[1] - vnsum[2].
    find first lnpr where lnpr.id = 6 and lnpr.fid = flnpr.fid no-lock no-error.
    if avail lnpr then lnpr.nsum[i] = (vnsum[2] / vnsum[1]) * 100.
    find first lnpr where lnpr.id = 7 and lnpr.fid = flnpr.fid no-lock no-error.
    if avail lnpr then lnpr.nsum[i] = vnsum[3] - vnsum[4].
    find first lnpr where lnpr.id = 8 and lnpr.fid = flnpr.fid no-lock no-error.
    if avail lnpr then lnpr.nsum[i] = (vnsum[4] / vnsum[3]) * 100.
  i = i + 1.
  end.
end.

  i = 1.
  repeat while i <= vm + 1:
    find first klnpr where klnpr.id = 1  no-lock no-error.
    if avail klnpr then vnsum[1]=klnpr.nsum[i].
    find first klnpr where klnpr.id = 2 no-lock no-error.
    if avail klnpr then vnsum[2]=klnpr.nsum[i].
    find first klnpr where klnpr.id = 3 no-lock no-error.
    if avail klnpr then vnsum[3]=klnpr.nsum[i].
    find first klnpr where klnpr.id = 4 no-lock no-error.
    if avail klnpr then vnsum[4]=klnpr.nsum[i].

    find first klnpr where klnpr.id = 5 no-lock no-error.
    if avail klnpr then klnpr.nsum[i] = vnsum[1] - vnsum[2].
    find first klnpr where klnpr.id = 6 no-lock no-error.
    if avail klnpr then klnpr.nsum[i] = (vnsum[2] / vnsum[1]) * 100.
    find first klnpr where klnpr.id = 7 no-lock no-error.
    if avail klnpr then klnpr.nsum[i] = vnsum[3] - vnsum[4].
    find first klnpr where klnpr.id = 8 no-lock no-error.
    if avail klnpr then klnpr.nsum[i] = (vnsum[4] / vnsum[3]) * 100.
  i = i + 1.
  end.

i = 0.
for each flnpr no-lock:
  i = i + 1.
end.

  if i > 1 then do:
       put stream repdvk unformatted
         "<BR><BR>" skip
         "<b> КОНСОЛИДИРОВАННЫЙ ОТЧЕТ </b>" skip
         "<BR><b>" r1 " (в тыс. тенге) </b><BR>" skip
         "<b>Отчет за период с " string(v-date1) " по " string(v-date2) "</b><br>" skip.

     put stream repdvk unformatted
     "<table border=1 cellpadding=0 cellspacing=0>" skip
     "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
     "<td valign=""center""> Статья </td>" skip.

     i = 0. vmm = tmm.  vyy = tyy.
     repeat while i <= vm:
       vmm =  vmm + 1.
       if vmm > 12 then do:
         vmm = 1.
         vyy = vyy + 1.
       end.
       put stream repdvk unformatted
       "<td valign=""center"">" string(vmm) + '/' + string(vyy) "</td>" skip.
     i = i + 1.
     end.

     for each klnpr no-lock:
        put stream repdvk unformatted "<tr>" skip.
        put stream repdvk unformatted
        "<td>" klnpr.kname "</td>" skip.
        i = 1.
        repeat while i <= vm + 1:
          if (klnpr.id = 6) or (klnpr.id = 8) then do:
            put stream repdvk unformatted
            "<td>" replace(trim(string(klnpr.nsum[i] ,'->>>>>>>>>>>>>9.99')),'.',',') "%</td>" skip.
          end.
          else do:
            put stream repdvk unformatted
            "<td>" replace(trim(string(klnpr.nsum[i] ,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
          end.
        i = i + 1.
        end.
     end.

     put stream repdvk unformatted "</table><tr>" skip.
  end.

  for each flnpr no-lock:

     put stream repdvk unformatted
         "<BR><BR>" skip
         "<b>" flnpr.fname "</b>" skip
         "<BR><b>" r1 " (в тыс. тенге) </b><BR>" skip
         "<b>Отчет за период с " string(v-date1) " по " string(v-date2) "</b><br>" skip.

     put stream repdvk unformatted
     "<table border=1 cellpadding=0 cellspacing=0>" skip
     "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
     "<td valign=""center""> Статья </td>" skip.

     i = 0. vmm = tmm.  vyy = tyy.
     repeat while i <= vm:
       vmm =  vmm + 1.
       if vmm > 12 then do:
         vmm = 1.
         vyy = vyy + 1.
       end.
       put stream repdvk unformatted
       "<td valign=""center"">" string(vmm) + '/' + string(vyy) "</td>" skip.
     i = i + 1.
     end.

     for each lnpr where lnpr.fid = flnpr.fid no-lock:
        put stream repdvk unformatted "<tr>" skip.
        put stream repdvk unformatted
        "<td>" lnpr.kname "</td>" skip.
        i = 1.
        repeat while i <= vm + 1:
          if (lnpr.id = 6) or (lnpr.id = 8) then do:
            put stream repdvk unformatted
            "<td>" replace(trim(string(lnpr.nsum[i] ,'->>>>>>>>>>>>>9.99')),'.',',') "%</td>" skip.
          end.
          else do:
            put stream repdvk unformatted
            "<td>" replace(trim(string(lnpr.nsum[i] ,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
          end.
        i = i + 1.
        end.
     end.

     put stream repdvk unformatted "</table><tr>" skip.
  end.

  put stream repdvk unformatted "</body></html>".
  output stream repdvk close.
  unix silent cptwin repdvk.htm excel.































































