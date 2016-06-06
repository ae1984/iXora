/* r-cifofc.p
 * MODULE
        Название Программного Модуля
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/*  r-cifbyofc.p
    Отчет по всем клиентам одного менеджера счетов, с указанием тенгового счета

   20.12.2002 nadejda
*/

{mainhead.i CIFBYOFC }
{name2sort.i}

def var v-ofc like ofc.ofc.
def var v-filename as char init "clients.htm".
def var v-name as char.
def var v-aaa as char.
def var v-numcif as integer init 0.

def temp-table t-data
  field cif like cif.cif
  field name as char
  field namesort as char
  field aaa as char
  index main is primary namesort cif.

v-ofc = g-ofc.

update skip(1) v-ofc label " Логин менеджера счета " help "F2 - список офицеров"
  validate(v-ofc = "" or can-find(ofc where ofc.ofc = v-ofc no-lock), 
           "Неверный логин менеджера счета!")
  skip(1)
  with side-label centered title " СПИСОК КЛИЕНТОВ ОДНОГО МЕНЕДЖЕРА " row 5 frame fofc.

v-filename = v-ofc + "-" + v-filename.

def stream rpt.
output stream rpt to value(v-filename).

{html-title.i 
 &stream = " stream rpt "
 &title = "Список клиентов по менеджеру счета"
 &size-add = " "
}

if v-ofc = "" then v-name = " менеджер не указан".
else do:
  find ofc where ofc.ofc = v-ofc no-lock no-error.
  v-name = " " + ofc.name.
end.

put stream rpt unformatted 
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>СПИСОК КЛИЕНТОВ</B></FONT></P>" skip
   "<P align = ""left""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" skip
   "Менеджер счета : " + v-name + " (" + v-ofc + ")</FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip
   "<TR align=""center"">" skip
     "<TD><FONT size=""1""><B>N</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Текущий счет KZT</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Наименование</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Код клиента</B></FONT></TD>" skip
   "</TR>" skip.

for each cif where trim(substring(trim(fname), 1, 8)) = v-ofc no-lock:
  create t-data.

  find first aaa where aaa.cif = cif.cif and aaa.lgr = "151" no-lock no-error.
  if avail aaa then v-aaa = aaa.aaa. 
  else do:
    find first aaa where aaa.cif = cif.cif and aaa.lgr = "152" no-lock no-error.
    if avail aaa then v-aaa = aaa.aaa. 
    else v-aaa = "&nbsp;".
  end.

  t-data.cif = cif.cif.
  t-data.name = trim(trim(cif.name) + " " + trim(cif.prefix)).
  t-data.namesort = name2sort(t-data.name).
  t-data.aaa = v-aaa.
end.

for each t-data:
  v-numcif = v-numcif + 1.

  put stream rpt unformatted
    "<TR valign=""top"">" skip 
      "<TD align=""left"">" + string(v-numcif) + "</TD>" skip
      "<TD align=""center"">" + t-data.aaa + "</TD>" skip
      "<TD align=""left"">" + t-data.name + "</TD>" skip
      "<TD align=""center"">" + t-data.cif + "</TD>" skip
    "</TR>" skip.
end.

put stream rpt unformatted
    "</TABLE>" skip
    "<BR><BR>" skip.

{html-end.i "stream rpt" }

output stream rpt close.

unix silent value("cptwin " + v-filename + " iexplore").

