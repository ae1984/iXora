/* pmpletter.p
 * MODULE
        Социальные платежи
 * DESCRIPTION
        Печать письма для клиента по возврату социальных платежей
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
        31.03.2005 kanat
 * CHANGES
*/

{pnjcommon.i}

define input parameter v-outnum as character.
define input parameter v-header as character.
define input parameter v-remark as character.
define input parameter v-footer as character.

define shared variable g-ofc as character.
define variable v-bankfull as character.
define variable dep-title as character initial "Директор".
define variable dep-head as character initial " ".

define variable v-temp as character.
define variable v-sign as character.

define variable is-signed as logical initial no.

/* Адрес банка и телефоны */
run defbnkreq (output v-bankfull).

/* Ссылка на факсимиле */
/* определение каталога временных файлов на локальной машине юзера */
v-sign = "&nbsp;".
input through localtemp.
repeat: import v-temp. end.
input close.
pause 0.

if substr(v-temp, length(v-temp), 1) <> "\\" then v-temp = v-temp + "\\".

find sysc where sysc.sysc = "GCVPHD" no-lock no-error.
if not available sysc then message "Предупреждение! Не найстроена sysc для GCVPHD" view-as alert-box title ''.
else do:
    dep-title = ENTRY (1, sysc.chval, "|").
    dep-head = ENTRY (2, sysc.chval, "|").

    if num-entries (sysc.chval, "|") = 3 then do:
       if trim(entry (3, sysc.chval, "|")) = "1" then is-signed = true.
                                                 else is-signed = false.
    end. 
    else is-signed = false.

end.

if is-signed then v-sign = "<IMG border=""0"" src=""" + v-temp +  "rr1sign.jpg"" width=""180"" height=""60"" v:shapes=""_x0000_s1026"">".
             else v-sign = "&nbsp;".

find ofc where ofc.ofc = g-ofc no-lock no-error.
find first cmp no-lock no-error.

output to rpt.html.
{html-start.i}.

run savelog ("pnjletter", " - Сформировано письмо, исх. номер = " + v-outnum).

put unformatted "<img src=""http://www.texakabank.kz/images/top_logo_bw.gif"" valign=""top""  height=""33"" width=""180""> <br>" skip.

put unformatted "<table width=""600"" border=""0"" cellpadding=""0"" cellspacing=""0"" style=""font-size:12px; border-collapse: collapse"">" SKIP. 
put unformatted "<tr><td>" skip.
put unformatted "<br>" v-bankfull skip.
put unformatted "</tr></td>" skip.
put unformatted "</table>" skip.

put unformatted "<HR><br>" skip.
put unformatted "<H4><b>Дата: " today "</b><br>" skip.
put unformatted "Исх.N: " v-outnum "</H4><br><br>" skip.

put unformatted "<table width=""600"" border=""0"" cellpadding=""0"" cellspacing=""0"" style=""font-size:14px; border-collapse: collapse"">" SKIP. 
put unformatted "<tr><td>" v-header "</td></tr>" skip.
put unformatted "</table><br><br>" skip.

put unformatted "<table width=""600"" border=""0"" cellpadding=""0"" cellspacing=""0"" style=""font-size:14px; border-collapse: collapse"">" SKIP. 
put unformatted "<tr><td align=""center""><b>Уважаемый клиент!</b></td></tr>" skip.

put unformatted "<tr><td>" skip.
put unformatted "Вы отправляли через наш банк платеж в ГЦВП. К сожалению, Вы неверно указали реквизиты.<br><br>" skip(1).
put unformatted "Обращаемся к Вам с просьбой уточнить СИК вкладчика (-ов). Вы можете предоставить" skip.
put unformatted "правильные реквизиты и всю необходимую информацию в банк в рабочее время с 9.00 до 16.00, и мы отправим деньги повторно.<br><br>" skip.
put unformatted "</td></tr>" skip.

put unformatted "<tr><td>" skip.
put unformatted "Наш адрес: " cmp.name "," cmp.addr[1] "<br>" skip.
put unformatted "Дополнительную информацию можно получить по телефону: <b> 500-060 </b>" skip.
put unformatted "</td></tr>" skip.
put unformatted "</table>" skip.

put unformatted "<br><br><b>Причина возврата платежа:</b><br>" skip.
put unformatted "<table width=""600"" border=""0"" cellpadding=""0"" cellspacing=""0"" style=""font-size:14px; border-collapse: collapse"">" SKIP. 
put unformatted "<tr><td>" v-remark "</td> </tr>" skip.
put unformatted "</table>" skip.

put unformatted "<br>" v-footer "<br> <br>" skip.

put unformatted "<table width=""600"" border=""0"">" skip.
put unformatted "<tr>".
put unformatted "<td><H4>" dep-title "</H4></td>" skip.
put unformatted "<td height=""50"" width=""180"">" v-sign "</td>" skip.
put unformatted "<td><H4>" dep-head "</H4></td>" skip.
put unformatted "</tr>".
put unformatted "</table><br>" skip.

put unformatted "<H5> Исполнитель: " CAPS(ofc.name) " </H5> <br> <br>" skip.

{html-end.i}.
output close.

unix silent cptwin rpt.html winword.
unix silent rm rpt.html.
