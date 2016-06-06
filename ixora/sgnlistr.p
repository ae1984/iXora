/* sgnlistr.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Хранилище карточек подписей
        Список файлов в хранилище
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-13-4
 * AUTHOR
        29.02.2004 nadejda
 * CHANGES
	30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/

{mainhead.i}
{sgn.i new}


def var i as integer.
def var v-sts as char.
def var v-bank as char.
def new shared var v-bankname as char.

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

if not connected ("comm") then run comm-con.
for each txb where txb.consolid = true and (if v-select = 1 then true else txb.txb = v-select - 2) no-lock:
    if connected ("ast") then disconnect "ast".
    connect value(" -db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld ast -U " + txb.login + " -P " + txb.password). 
    run sgnlistrdat (txb.bank).
end.
if connected ("ast")  then disconnect "ast".


output to value(v-file).

{html-title.i 
 &stream = " "
 &title = " "
 &size-add = "x-"
}

put unformatted   
  "<P align=""center"" style=""font:bold"">Ведомость файлов карточек подписей клиентов</P>" skip
  "<P>" v-bankname "</P>" skip
  "<P>" string(today, "99/99/9999") "</P>" skip
  "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
    "<TR align=""center"" style=""font:bold;font-size:xx-small"">" skip
      "<TD>N</TD>" skip
      "<TD>Банк</TD>" skip
      "<TD>Код клиента</TD>" skip
      "<TD>Наименование клиента</TD>" skip
      "<TD>Доп.номер карт.</TD>" skip
      "<TD>Дата добавления</TD>" skip
      "<TD>Добавил</TD>" skip
      "<TD>Дата изменения</TD>" skip
      "<TD>Изменил</TD>" skip
      "<TD>Статус</TD>" skip
  "</TR>" skip.

i = 0.
for each sgn no-lock:
  if v-bank <> "" and sgn.bank <> v-bank then next.

  i = i + 1.

  find bookcod where bookcod.bookcod = "sgnsts" and bookcod.code = sgn.sts no-lock no-error.
  if avail bookcod then v-sts = bookcod.name.
                   else v-sts = "".
  
  find t-cif where t-cif.cif = sgn.cif no-lock no-error.

  put unformatted 
    "<TR><TD>" i "</TD>" skip
      "<TD align=""center"">" sgn.bank "</TD>" skip
      "<TD align=""center"">" sgn.cif "</TD>" skip
      "<TD>" t-cif.name "</TD>" skip
      "<TD align=""center"">" if sgn.num > 0 then string(sgn.num, ">>>>>>>>>>>9") else "" "</TD>" skip
      "<TD align=""center"">" string(sgn.rdt, "99/99/9999") "</TD>" skip
      "<TD align=""center"">" sgn.rwho "</TD>" skip
      "<TD align=""center"">" if sgn.sts <> "N" then string(sgn.udt, "99/99/9999") else "" "</TD>" skip
      "<TD align=""center"">" if sgn.sts <> "N" then string(sgn.uwho) else "" "</TD>" skip
      "<TD>" v-sts "</TD>" skip
    "</TR>" skip.
end.

put unformatted "</TABLE>" skip.

{html-end.i " "}
output close.

hide message no-pause.

unix silent cptwin value(v-file) iexplore.
pause 0.

