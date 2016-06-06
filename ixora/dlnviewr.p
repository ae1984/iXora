/* dlnviewr.p
 * MODULE

 * DESCRIPTION

 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * AUTHOR
        29.02.2004 nadejda
 * CHANGES
        02.07.2004 dpuchkov - изменил для юридических дел физ. лиц.
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/

{mainhead.i}
{dln.i new}



def new shared var v-dtb as date.
def new shared var v-dte as date.
def var v-ofc as char.

def var i as integer.
def var v-res as char.
def var v-bank as char.
def new shared var v-bankname as char.


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


{sel-filial.i}

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
    if connected ("ast") then disconnect "ast".
    connect value(" -db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld ast -U " + txb.login + " -P " + txb.password). 
    run dlnviewrdat (txb.bank).
end.
if connected ("ast")  then disconnect "ast".


output to value(v-file).

{html-title.i 
 &stream = " "
 &title = " "
 &size-add = "x-"
}

put unformatted
  "<P align=""center"" style=""font:bold"">Отчет о просмотрах файлах юридических дел клиентов</P>" skip
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
for each dlnview where dlnview.whn >= v-dtb and dlnview.whn <= v-dte no-lock break by dlnview.whn by dlnview.bank by dlnview.tim:
  if v-bank <> "" and dlnview.bank <> v-bank then next.

  i = i + 1.


  if dlnview.result = "err_view" then v-res = "ошибка при открытии дела для просмотра". else
  if dlnview.result = "no_card"  then v-res = "нет электронной копии дела". else
  if dlnview.result = "no_file"  then v-res = "ошибка при открытии дела для просмотра". else
  if dlnview.result = "success"  then v-res = "дело просмотрено".

  
  find t-cif where t-cif.cif = dlnview.cif no-lock no-error.
  find t-ofc where t-ofc.ofc = dlnview.who no-lock no-error.


  put unformatted
    "<TR><TD>" i "</TD>" skip
      "<TD align=""center"">" string(dlnview.whn, "99/99/9999") "</TD>" skip
      "<TD align=""center"">" string(dlnview.tim, "HH:MM:SS") "</TD>" skip
      "<TD align=""center"">" dlnview.bank "</TD>" skip
      "<TD align=""center"">" dlnview.cif "</TD>" skip
      "<TD>" t-cif.name "</TD>" skip
      "<TD align=""center"">" dlnview.who "</TD>" skip
      "<TD>" t-ofc.name "</TD>" skip
      "<TD>" v-res "</TD>" skip
    "</TR>" skip.

  accumulate dlnview.cif (count by dlnview.whn by dlnview.bank).

  if last-of(dlnview.bank) then do:
    put unformatted 
      "<TR style=""font:bold"">" skip
        "<TD align=""right"" colspan=4>ИТОГО ПО БАНКУ " dlnview.bank "</TD>" skip
        "<TD align=""right"">" accum sub-count by dlnview.bank dlnview.cif "</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
      "</TR>" skip.
  end.

  if last-of(dlnview.whn) then do:
    put unformatted 
      "<TR style=""font:bold"">" skip
        "<TD align=""right"" colspan=4>ИТОГО ЗА ДАТУ " string(dlnview.whn, "99/99/9999") "</TD>" skip
        "<TD align=""right"">" accum sub-count by dlnview.whn dlnview.cif "</TD>" skip
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
    "<TD align=""right"">" accum count dlnview.cif "</TD>" skip
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

