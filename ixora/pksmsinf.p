/* pksmsinf.p
 * MODULE
        Потреб. кредитование
 * DESCRIPTION
        Отчет по пакету СМС
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
        17/09/2009 madiyar
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def var v-batchid as integer no-undo.
/*def var prefixes as char no-undo extent 17 init ['A','B','C','D','E','F','H','K','L','M','N','O','P','Q','R','S','T'].*/
def var stss as char no-undo extent 4 init ['отправлено','на отправке','на отправке','ошибка отправки'].

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

v-batchid = 0.

repeat on endkey undo, return:
    update v-batchid label ' Номер пакета' validate(v-batchid > 0, "Введено некорректное значение!") format '>>>,>>>,>>9'
           with side-labels row 13 centered frame fr.
    find first smspool where smspool.batchid = v-batchid no-lock no-error.
    if avail smspool then do:
        if smspool.bank = s-ourbank then leave.
        else message "Пакет СМС другого филиала" view-as alert-box error.
    end.
    else message "Нет СМС с таким номером пакета" view-as alert-box error.
end.

output to rep.htm.
{html-title.i
 &stream = " "
 &title = " "
 &size-add = "x-"
}

put unformatted
    "<br><P align=""left"" style=""font:bold""> Отчет по пакету N " + string(v-batchid) + "</P>" skip.

find first smspool where smspool.batchid = v-batchid no-lock no-error.

put unformatted
    "Дата отправки: <b>" string(smspool.pdate,"99/99/9999") "</b><br>" skip
    "Время отправки: <b>" string(smspool.ptime,"hh:mm:ss") "</b><br>" skip
    "Логин отправителя: <b>" smspool.pwho "</b><br>" skip
    "&nbsp;<br>" skip.

put unformatted
     "<TABLE cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
      "<TR align=""center"" style=""font:bold"" bgcolor=""#C0C0C0"">" skip
      "<td align=center>КодКл</td>"
      "<td align=center>ФИО</td>"
      "<td align=center>Тел</td>"
      "<td align=center>Статус</td>"
      /*"<td align=center>Текст сообщения</td>"*/
    "</tr>" skip.


for each smspool where smspool.batchid = v-batchid no-lock:
    find first cif where cif.cif = smspool.cif no-lock no-error.
    put unformatted
        "<TR><TD>" smspool.cif "</TD>" skip
        "<TD>" if avail cif then trim(cif.name) else '' "</TD>" skip
        "<TD>" smspool.tell "</TD>" skip
        "<TD>" stss[smspool.state + 1] "</TD>" skip
        /*"<TD>" smspool.mess "</TD>" skip*/
        "</TR>" skip.
end.

put unformatted "</table>" skip.
put unformatted "</body></html>" skip.
output close.

unix silent cptwin rep.htm excel.
pause 0.
