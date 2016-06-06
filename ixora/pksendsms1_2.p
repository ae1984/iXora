/* pksendsms1_2.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Рассылка СМС-сообщений
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-2-3-12
 * AUTHOR
        09/11/06 Natalya D.
 * CHANGES
        26/08/2009 madiyar - переделал
        14/09/2009 madiyar - номер пакета в шаренной переменной
*/

def var stss as char extent 3 init ['','отправлено','некорректный номер'].

def shared temp-table wrk no-undo
  field bank as char
  field bankn as char
  field cif like cif.cif
  field lon like lon.lon
  field crc as integer
  field name as char
  field sumgr as deci
  field balanst as deci
  field mob as char
  field days as integer
  field credtype as char
  field ln as integer
  field sing as char
  field who as char
  field whn as char
  field sts as integer
  index idx is primary name cif.

def shared var v-bb as integer no-undo.

output to rep.html.

{html-title.i
 &stream = " "
 &title = " "
 &size-add = "x-"
}

put unformatted
    "<br><P align=""left"" style=""font:bold""> Отчет SMS-напоминание, пакет N " + string(v-bb) + "</P>" skip.

put  unformatted
         "<TABLE cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
          "<TR align=""center"" style=""font:bold"" bgcolor=""#C0C0C0"">" skip
          "<td align=center>Ссудный счет</td>"
          "<td align=center>ФИО</td>"
          "<td align=center>Номер моб. тел.</td>"
          "<td align=center>Филиал</td>"
          "<td align=center>Дата</td>"
          "<td align=center>Менеджер</td>"
          "<td align=center>Примечание</td>"
        "</tr>" skip.


for each wrk where wrk.sing = '*' no-lock:
    put unformatted
        "<TR><TD>&nbsp;" wrk.lon "</TD>" skip
        "<TD>" wrk.name "</TD>" skip
        "<TD>" wrk.mob "</TD>" skip
        "<TD>" wrk.bankn "</TD>" skip
        "<TD>" wrk.whn "</TD>" skip
        "<TD>" wrk.who "</TD>" skip
        "<TD>" stss[wrk.sts + 1] "</TD>" skip
        "</TR>" skip.
end.


put unformatted "</table>" skip.
put unformatted "</body></html>" skip.
output close.
unix silent cptwin rep.html excel.
pause 0.
