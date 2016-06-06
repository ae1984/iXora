/* dsrlist.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Управление досье клиентв - импорт, замена, списки файлов
        Список всех досье
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        1-13-6
 * AUTHOR
        07.02.2005 marinav
 * CHANGES
	30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
    04/08/2011 dmitriy - убрал консолидацию для всех филиалов, кроме ЦО
*/

{mainhead.i}
{dsr.i}

def input parameter p-new as inte.  /*1 - все документы,  2 - если нужно показать только новые документы , 3 - если нужны только удаленные*/

def var i as integer.
def var j as inte.
def var v-sts as char.
def var v-bank as char.
def new shared var v-bankname as char.
def var v-docs as char.
def var cmp-code as integer.

find first cmp no-lock no-error.
if avail cmp then cmp-code = cmp.code.

if cmp-code = 0 then do:
{sel-filial.i}
end.
else v-select = cmp-code + 2.

message " Формируется отчет...".

def var v-file as char init "dsrlist.html".
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
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + txb.login + " -P " + txb.password).
    run dsrlistrdat (txb.bank).
end.
if connected ("txb")  then disconnect "txb".


output to value(v-file).

{html-title.i
 &stream = " "
 &title = " "
 &size-add = "x-"
}


  if p-new ne 1
      then put unformatted   "<P align=""center"" style=""font:bold"">Список досье клиентов, требующих акцепта </P>" skip.
      else put unformatted   "<P align=""center"" style=""font:bold"">Список досье клиентов</P>" skip.


put unformatted
  "<P>" v-bankname "</P>" skip
  "<P>" string(today, "99/99/9999") "</P>" skip
  "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
    "<TR align=""center"" style=""font:bold;font-size:xx-small"">" skip
      "<TD>N</TD>" skip
      "<TD>Банк</TD>" skip
      "<TD>Код клиента</TD>" skip
      "<TD>Наименование клиента</TD>" skip
      "<TD>Документ</TD>" skip
      "<TD>Дата добавления</TD>" skip
      "<TD>Добавил</TD>" skip
      "<TD>Дата изменения</TD>" skip
      "<TD>Изменил</TD>" skip
      "<TD>Дата акцепта</TD>" skip
      "<TD>Акцептовал</TD>" skip
      "<TD>Статус</TD>" skip
  "</TR>" skip.

i = 0.
for each dsr no-lock:
  if v-bank <> "" and dsr.bank <> v-bank then next.
  if p-new = 2  and (dsr.awho ne '' or dsr.sts = 'D') then next.
  if p-new = 3  and (dsr.awho ne '' or  dsr.sts ne 'D') then next.

  i = i + 1.

  find bookcod where bookcod.bookcod = "sgnsts" and bookcod.code = dsr.sts no-lock no-error.
  if avail bookcod then v-sts = bookcod.name.
                   else v-sts = "".

  find t-cif where t-cif.cif = dsr.cif no-lock no-error.

/*  find first sysc where sysc.sysc = 'dsrdoc'.
  j = lookup(dsr.docs, sysc.chval).
  if j > 0 then v-docs = entry(j + 1,sysc.chval).
           else v-docs = 'не определен'.
 */

  find bookcod where bookcod.bookcod = 'sgndoc' and bookcod.code = dsr.docs no-lock no-error.
  if avail bookcod then v-docs = bookcod.name.
                   else v-docs = 'не определен'.

  put unformatted
    "<TR><TD>" i "</TD>" skip
      "<TD align=""center"">" dsr.bank "</TD>" skip
      "<TD align=""center"">" dsr.cif "</TD>" skip
      "<TD>" t-cif.name "</TD>" skip
      "<TD align=""left"">" v-docs "</TD>" skip
      "<TD align=""center"">" string(dsr.rdt, "99/99/9999") "</TD>" skip
      "<TD align=""center"">" dsr.rwho "</TD>" skip
      "<TD align=""center"">" if dsr.sts <> "N" then string(dsr.udt, "99/99/9999") else "" "</TD>" skip
      "<TD align=""center"">" if dsr.sts <> "N" then string(dsr.uwho) else "" "</TD>" skip
      "<TD align=""center"">" string(dsr.adt, "99/99/9999") "</TD>" skip
      "<TD align=""center"">" dsr.awho "</TD>" skip
      "<TD>" v-sts "</TD>" skip
    "</TR>" skip.
end.

put unformatted "</TABLE>" skip.

{html-end.i " "}
output close.

hide message no-pause.

unix silent cptwin value(v-file) iexplore.
pause 0.

