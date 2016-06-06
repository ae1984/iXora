/* dsrlist.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        просмотр досье
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        1-13-6
 * BASES
        BANK COMM
 * AUTHOR
        07.02.2005 marinav
 * CHANGES
	30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
    04/08/2011 dmitriy - убрал консолидацию для всех филиалов, кроме ЦО
*/

{mainhead.i}
{dsr.i "new"}



def new shared var v-dtb as date.
def new shared var v-dte as date.
def var v-ofc as char.

def var i as integer.
def var v-res as char.
def var v-bank as char.
def new shared var v-bankname as char.
def var cmp-code as integer.


form
  skip(1)
  v-dtb label " Начало периода " format "99/99/9999"
        help " Дата начала отчетного периода"
        validate (v-dtb <= g-today, " Дата начала периода должна быть не больше текущей!")
  skip
  v-dte label "  Конец периода " format "99/99/9999"
        help " Дата конца отчетного периода"
        validate (v-dtb <= v-dte, " Дата конца периода должна быть не меньше даты начала!")
  skip(1)
  v-ofc label "  По менеджерам " format "x(50)"
        help " Логины менеджеров через запятую, пустое поле - ВСЕ"
  skip(1)
  with centered row 5 side-label title " ПАРАМЕТРЫ ОТЧЕТА " frame f-param.

v-dtb = g-today.
v-dte = today.
displ v-dtb v-dte with frame f-param.

update v-dtb with frame f-param.
update v-dte v-ofc with frame f-param.


find first cmp no-lock no-error.
if avail cmp then cmp-code = cmp.code.

if cmp-code = 0 then do:
{sel-filial.i}
end.
else v-select = cmp-code + 2.

message " Формируется отчет...".


def var v-file as char init "sgnlist.html".
if v-select = 1 then do:
  v-bank = "".
  find first cmp no-lock no-error.
  v-bankname = cmp.name + "<BR>" + "Консолидированный отчет".
end.
else do:
  find txb where txb.consolid = true and txb.txb = v-select - 2 no-lock no-error.
  v-bank = txb.bank.
  v-bankname = txb.name.
end.

def new shared temp-table t-cif
  field cif as char
  field name as char
  index cif is primary unique cif.

def new shared temp-table t-ofc
  field ofc as char
  field name as char
  index cif is primary unique ofc.

if not connected ("comm") then run comm-con.
for each txb where txb.consolid = true and (if v-select = 1 then true else txb.txb = v-select - 2) no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + txb.login + " -P " + txb.password).
    run dsrviewrdat (txb.bank).
end.
if connected ("txb")  then disconnect "txb".


output to value(v-file).

{html-title.i
 &stream = " "
 &title = " "
 &size-add = "x-"
}

put unformatted
  "<P align=""center"" style=""font:bold"">Отчет о просмотрах файлов карточек подписей клиентов</P>" skip
  "<P align=""center"">за период с " string(v-dtb, "99/99/9999") " по " string(v-dte, "99/99/9999") "</P>" skip
  "<P>По менеджерам: " if v-ofc = "" then "ВСЕ МЕНЕДЖЕРЫ" else v-ofc "</P>" skip
  "<P>" v-bankname "</P>" skip
  "<P>" string(today, "99/99/9999") "</P>" skip
  "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
    "<TR align=""center"" style=""font:bold;font-size:xx-small"">" skip
      "<TD>N</TD>" skip
      "<TD>Дата просмотра</TD>" skip
      "<TD>Время просмотра</TD>" skip
      "<TD>Банк</TD>" skip
      "<TD>Код клиента</TD>" skip
      "<TD>Наименование клиента</TD>" skip
      "<TD>Логин сотрудника</TD>" skip
      "<TD>ФИО</TD>" skip
      "<TD>Результат</TD>" skip
  "</TR>" skip.

i = 0.
for each dsrview where dsrview.whn >= v-dtb and dsrview.whn <= v-dte no-lock break by dsrview.whn by dsrview.bank by dsrview.tim:
  if v-bank <> "" and dsrview.bank <> v-bank then next.

  i = i + 1.

  find bookcod where bookcod.bookcod = "sgnres" and bookcod.code = dsrview.result no-lock no-error.
  if avail bookcod then v-res = bookcod.name.
                   else v-res = "".

  find t-cif where t-cif.cif = dsrview.cif no-lock no-error.
  find t-ofc where t-ofc.ofc = dsrview.who no-lock no-error.

  put unformatted
    "<TR><TD>" i "</TD>" skip
      "<TD align=""center"">" string(dsrview.whn, "99/99/9999") "</TD>" skip
      "<TD align=""center"">" string(dsrview.tim, "HH:MM:SS") "</TD>" skip
      "<TD align=""center"">" dsrview.bank "</TD>" skip
      "<TD align=""center"">" dsrview.cif "</TD>" skip
      "<TD>" t-cif.name "</TD>" skip
      "<TD align=""center"">" dsrview.who "</TD>" skip
      "<TD>" t-ofc.name "</TD>" skip
      "<TD>" v-res "</TD>" skip
    "</TR>" skip.

  accumulate dsrview.cif (count by dsrview.whn by dsrview.bank).

  if last-of(dsrview.bank) then do:
    put unformatted
      "<TR style=""font:bold"">" skip
        "<TD align=""right"" colspan=4>ИТОГО ПО БАНКУ " dsrview.bank "</TD>" skip
        "<TD align=""right"">" accum sub-count by dsrview.bank dsrview.cif "</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
      "</TR>" skip.
  end.

  if last-of(dsrview.whn) then do:
    put unformatted
      "<TR style=""font:bold"">" skip
        "<TD align=""right"" colspan=4>ИТОГО ЗА ДАТУ " string(dsrview.whn, "99/99/9999") "</TD>" skip
        "<TD align=""right"">" accum sub-count by dsrview.whn dsrview.cif "</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
      "</TR>" skip.
  end.
end.
put unformatted
  "<TR style=""font:bold"">" skip
    "<TD align=""right"" colspan=4>ВСЕГО ЗА ПЕРИОД </TD>" skip
    "<TD align=""right"">" accum count dsrview.cif "</TD>" skip
    "<TD></TD>" skip
    "<TD></TD>" skip
    "<TD></TD>" skip
    "<TD></TD>" skip
  "</TR>" skip.


put unformatted "</TABLE>" skip.

{html-end.i " "}
output close.

hide message no-pause.

unix silent cptwin value(v-file) iexplore.
pause 0.

