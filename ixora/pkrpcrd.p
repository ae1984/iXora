/* pkrpcrd.p
 * MODULE
        Потребкредиты
 * DESCRIPTION
        Отчеты для выпуска карт
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        07/09/2006 madiyar
 * BASES
        bank, comm
 * CHANGES
        08/09/2006 madiyar - код СПФ
*/

{global.i}

define new shared temp-table wrk no-undo
  field bank as character
  field cif as character /* 3- */
  field fio as character
  field fiolat as character
  field rnn as character
  field lonrdt as date /* 3- */
  field londuedt as date
  field numpr as integer
  field maxpr as integer
  field jobp as character
  field position as character
  field bdt as date
  field addr_fact as character
  field addr_prop as character
  field phones as character
  field docnum as character
  field spf_name as character
  field spf as integer
  field sum as decimal /* сумма кредита, или одобренная сумма для отказников */
  field dohgcvp as decimal
  field krlim as decimal
  field card as character
  index idx is primary bank cif fio.

def new shared var v-cif like cif.cif no-undo.
def new shared var v-rnn as char no-undo.
def new shared var v-nmonths as integer no-undo.
def new shared var dt1 as date no-undo.
def new shared var dt2 as date no-undo.
def new shared var v-ref as logical no-undo.
v-cif = ''. v-rnn = ''.
v-nmonths = 6.
dt1 = ?.
dt2 = ?.
v-ref = no.

def var v-select_rep as integer no-undo.
def var v-select_type as integer no-undo.
def var coun as integer no-undo.
def var usrnm as character no-undo.
def var v-title as character no-undo extent 3.
v-title[1] = "Отчет по действующему портфелю БД".
v-title[2] = "Отчет по погашенным займам".
v-title[3] = "Клиенты, отказавшиеся от БД".

v-select_rep = 4.
run sel2 ("Отчеты по выпуску карт:"," 1. " + v-title[1] + " | 2. " + v-title[2] + " | 3. " + v-title[3] + " | 4. ВЫХОД ",output v-select_rep).
if v-select_rep < 1 or v-select_rep > 3 then return.

v-select_type = 3.
run sel2 ("Отчеты по выпуску карт:"," 1. По одному клиенту | 2. Выборка | 3. ВЫХОД ",output v-select_type).
if v-select_type < 1 or v-select_type > 2 then return.

define frame fr_one1
  v-cif format "x(6)" label "Код клиента" " или "
  v-rnn format "x(12)" label "РНН" validate (v-rnn <> '',"Введите РНН клиента") skip
  v-nmonths format ">9" label "Кол-во месяцев погашения" validate (v-nmonths > 0,"Некорректное кол-во месяцев погашения")
  with centered row 6 side-labels title " Параметры ".

define frame fr_one2
  v-cif format "x(6)" label "Код клиента" " или "
  v-rnn format "x(12)" label "РНН" validate (v-rnn <> '',"Введите РНН клиента") skip
  with centered row 6 side-labels title " Параметры ".

define frame fr_many1
  dt1 format "99/99/9999" label "Выдан с" validate(dt1 = ? or ((dt1 <= g-today) or (dt2 <> ? and dt1 <= dt2)),"Некорректная дата!")
  dt2 format "99/99/9999" label "по" validate(dt2 = ? or ((dt2 <= g-today) or (dt1 <> ? and dt1 <= dt2)),"Некорректная дата!") skip
  v-nmonths format ">9" label "Кол-во месяцев погашения" validate (v-nmonths > 0,"Некорректное кол-во месяцев погашения") skip
  v-ref format "Да/Нет" label "Клиенты, получившие рефинансирование" skip
  with centered row 6 side-labels title " Параметры ".

define frame fr_many2
  dt1 format "99/99/9999" label "Выдан с" validate(dt1 = ? or ((dt1 <= g-today) or (dt2 <> ? and dt1 <= dt2)),"Некорректная дата!")
  dt2 format "99/99/9999" label "по" validate(dt2 = ? or ((dt2 <= g-today) or (dt1 <> ? and dt1 <= dt2)),"Некорректная дата!") skip
  v-ref format "Да/Нет" label "Клиенты, получившие рефинансирование" skip
  with centered row 6 side-labels title " Параметры ".

if v-select_type = 1 then do:
  if v-select_rep = 1 then do:
    displ v-cif v-rnn v-nmonths with frame fr_one1.
    update v-cif with frame fr_one1.
    if v-cif = '' then update v-rnn with frame fr_one1.
    update v-nmonths with frame fr_one1.
    hide frame fr_one1.
  end.
  else
  if v-select_rep = 2 then do:
    displ v-cif v-rnn with frame fr_one2.
    update v-cif with frame fr_one2.
    if v-cif = '' then update v-rnn with frame fr_one2.
    hide frame fr_one2.
  end.
  else do:
    update v-rnn format "x(12)" label "РНН" validate(v-rnn <> '',"Введите РНН клиента") skip
           with centered row 6 side-labels title " Параметры " frame fr_one3.
    hide frame fr_one3.
  end.
end.
else do:
  if v-select_rep = 1 then do:
    displ dt1 dt2 v-nmonths v-ref with frame fr_many1.
    update dt1 dt2 v-nmonths v-ref with frame fr_many1.
    hide frame fr_many1.
  end.
  else
  if v-select_rep = 2 then do:
    displ dt1 dt2 v-ref with frame fr_many2.
    update dt1 dt2 v-ref with frame fr_many2.
    hide frame fr_many2.
  end.
  else do:
    update dt1 format "99/99/9999" label "Анкета зарегистрирована с" validate(dt1 = ? or ((dt1 <= g-today) or (dt2 <> ? and dt1 <= dt2)),"Некорректная дата!")
           dt2 format "99/99/9999" label "по" validate(dt2 = ? or ((dt2 <= g-today) or (dt1 <> ? and dt1 <= dt2)),"Некорректная дата!") skip
           with centered row 6 side-labels title " Параметры " frame fr_many3.
    hide frame fr_many3.
  end.
end.

{r-brfilial.i &proc = "pkrpcrd0 (v-select_rep)"}
/*
run value("pkrpcrd" + string(v-select,"9")).
*/

def stream rep.
output stream rep to pkrpcrd.htm.

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
    "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
    "<center><b>" v-title[v-select_rep] "</b></center><BR>" skip
    "<center><b>" v-bankname "</b></center><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"" valign=""top"">" skip
    "<td>пп</td>" skip
    "<td>Код<BR>заемщика</td>" skip
    "<td>ФИО</td>" skip
    "<td>ФИО(лат)</td>" skip
    "<td>РНН</td>" skip
    "<td>Дата<BR>открытия<BR>кредита</td>" skip
    "<td>Дата<BR>погашения<BR>по договору</td>" skip
    "<td>Кол-во<br>просрочек</td>" skip
    "<td>Дней<BR>максим.<br>просрочка</td>" skip
    "<td>Место<BR>работы</td>" skip
    "<td>Должность</td>" skip
    "<td>Дата<BR>рождения</td>" skip
    "<td>Факт.<BR>адрес</td>" skip
    "<td>Адрес<BR>прописки</td>" skip
    "<td>Телефоны</td>" skip
    "<td>N удост.<br>личности</td>" skip
    "<td>СПФ-код</td>" skip
    "<td>СПФ</td>" skip
    "<td>Сумма<BR>кредита</td>" skip
    "<td>Доход из<BR>ГЦВП</td>" skip
    "<td>Сумма<BR>лимита</td>" skip
    "<td>Вид<BR>карты</td>" skip
    "</tr>" skip.

coun = 0.
for each wrk no-lock:
  coun = coun + 1.
  put stream rep unformatted
    "<tr>" skip
    "<td>" coun "</td>" skip
    "<td>" wrk.cif "</td>" skip
    "<td>" wrk.fio "</td>" skip
    "<td>" wrk.fiolat "</td>" skip
    "<td>" wrk.rnn "</td>" skip
    "<td>" wrk.lonrdt format "99/99/9999" "</td>" skip
    "<td>" wrk.londuedt format "99/99/9999" "</td>" skip
    "<td>" wrk.numpr "</td>" skip
    "<td>" wrk.maxpr "</td>" skip
    "<td>" wrk.jobp "</td>" skip
    "<td>" wrk.position "</td>" skip
    "<td>" wrk.bdt format "99/99/9999" "</td>" skip
    "<td>" wrk.addr_fact "</td>" skip
    "<td>" wrk.addr_prop "</td>" skip
    "<td>" wrk.phones "</td>" skip
    "<td>" wrk.docnum "</td>" skip
    "<td>" wrk.spf "</td>" skip
    "<td>" wrk.spf_name "</td>" skip
    "<td>" replace(trim(string(wrk.sum, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.dohgcvp, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.krlim, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" wrk.card "</td>" skip
    "</tr>" skip.
end.

put stream rep unformatted "</table></body></html>" skip.
output stream rep close.
unix silent cptwin pkrpcrd.htm excel.
