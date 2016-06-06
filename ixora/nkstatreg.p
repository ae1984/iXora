/* nkstatreg.p
 * MODULE

 * DESCRIPTION

 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
        25.05.2012 evseev
 * BASES
        BANK COMM
 * CHANGES

*/

function GetDocType returns char (input parm1 as char):
 case parm1:
        when "R40"  then return trim("Реестр инкассовых распоряжений                                                                        ").
        when "WAR"  then return trim("Инкассовое распоряжение                                                                               ").
        when "P01"  then return trim("Подтверждение получения инкассовых распоряжений                                                       ").
        when "P03"  then return trim("Помещение инк. распоряжений в картотеку                                                               ").
        when "WR1"	then return trim("Возврат инкассового распоряжения                                                                      ").
        when "RWP"	then return trim("Реестр инкассовых распоряжений по ОПВ                                                                 ").
        when "W91"	then return trim("Инкассовое распоряжение по ОПВ                                                                        ").
        when "P1P"	then return trim("Подтверждение получения инкассовых распоряжений по ОПВ                                                ").
        when "P3P"	then return trim("Помещение инкассовых распоряжений по ОПВ в картотеку                                                  ").
        when "WRP"	then return trim("Возврат инкассового распоряжения по ОПВ                                                               ").
        when "RWS"	then return trim("Реестр инкассовых распоряжений по СО                                                                  ").
        when "W92"	then return trim("Инкассовые распоряжения по СО                                                                         ").
        when "P1S"	then return trim("Подтверждение получения инкассовых распоряжений по СО                                                 ").
        when "P3S"	then return trim("Помещение инкассовых распоряжений по СО в картотеку                                                   ").
        when "WRS"	then return trim("Возврат инкассового распоряжения по СО                                                                ").
        when "OR1"	then return trim("Отзыв инкассового распоряжения                                                                        ").
        when "P02"	then return trim("Подтверждение о принятии отзывов инкассовых распоряжений                                              ").
        when "A01"	then return trim("Уведомления об открытии и закрытии банковских счетов                                                  ").
        when "A1C"	then return trim("Подтверждение о получении уведомлений об открытии и закрытии банковских счетов.                       ").
        when "A03"	then return trim("Увед. об изменении номеров банковских счетов                                                          ").
        when "A3C"	then return trim("Подтв.о получ.увед.об измен.номеров банк.счетов                                                       ").
        when "AC"   then return trim("Распоряжение о приостановлении расходных операций по счетам налогоплательщика                         ").
        when "ACL"	then return trim("Реестр распоряжений о приостановлении расходных операций по счетам налогоплательщика                  ").
        when "PAC"	then return trim("Подтверждение получения распоряжений о приостановлении расходных операций по счетам налогоплательщика ").
        when "ACP"	then return trim("Распоряжение о приостановлении расходных операций по счетам агента ОПВ                                ").
        when "APL"	then return trim("Реестр распоряжений о приостановлении расходных операций агента ОПВ                                   ").
        when "PAP"	then return trim("Подтверждение получения распоряжений о приостановлении расходных операций агента ОПВ»                 ").
        when "ASD"	then return trim("Распоряжения о приостановлении расходных операций плательщика СО»                                     ").
        when "ASL"	then return trim("Реестр распоряжений о приостановлении расходных операций плательщика СО                               ").
        when "PAS"	then return trim("Подтверждение получения распоряжений о приостановлении расходных операций плательщика СО              ").
        when "ACR"	then return trim("Отзыв распоряжения о приостановлении расходных операций                                               ").
        when "PAR"	then return trim("Подтверждение о получении отзывов распоряжений о приостановлении расходных операций                   ").
        when "ACV"	then return trim("Возврат РПРО налогопл.                                                                                ").
        when "APV"	then return trim("Возврат РПРО агента ОПВ                                                                               ").
        when "ASV"	then return trim("Возврат РПРО плательщика СО                                                                           ").
 end case.
end function.

function GetStsName returns char (input parm1 as integer):
 case parm1:
    when 1	then return "1 - Отправлено в банк".
    when 11	then return "11 - Обработано. Cообщение, отправленное в БВУ, принято в БВУ; сообщение, отправленное из БВУ в НК, принято в НК.".
    when 21	then return "21 - Пропущенные. В сообщении, отправленном из БВУ в НК, есть пропущенные строки в списковом сообщении или пропущено само сообщение, если оно содержит только одно сведение.".
    when 31	then return "31 - Ошибочное. Не принято в ИНИС РК из-за ошибок.".
 end case.
end function.






def var v-dt as date.
def stream file.

find last nkstatreg no-lock.
if avail nkstatreg then v-dt = nkstatreg.docdt. else v-dt = today.
update v-dt label "Введите дату за которую необходим Стат.реестр".

output stream file to file.html.

{html-title.i
  &stream = " stream file "
  &size-add = "1"
  &title = "Статистический реестр за " + string(v-dt).
}


put stream file unformatted
  "<table  border=1 cellpadding=0 cellspacing=0>" skip
  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
  "<td>Дата</td>" skip
  "<td>Признак<br>сообщения</td>" skip
  "<td>Тип сообщения</td>" skip
  "<td>Дата и время<br>отправки/получения</td>" skip
  "<td>Референс сообщения</td>" skip
  "<td>Код состояния сообщения</td>" skip
  "</tr>" skip.

def var v-tmpdt as date.
for each nkstatreg where nkstatreg.docdt = v-dt no-lock:
    for each nkstatreg_det where nkstatreg_det.ref = nkstatreg.ref no-lock:
        v-tmpdt = ?.
        v-tmpdt = date(substr(nkstatreg_det.dttime,5,2) + "/" + substr(nkstatreg_det.dttime,3,2) + "/" + substr(nkstatreg_det.dttime,1,2)) no-error.
        put stream file unformatted
          "<tr>" skip
          "<td>" + string(nkstatreg.docdt) + "</td>" skip
          "<td>" + if nkstatreg_det.io = 'i' then 'Получен из НК' else 'Отправлен в НК' + "</td>" skip
          "<td>" + GetDocType(nkstatreg_det.dtype) + "</td>" skip
          "<td>" + string(v-tmpdt) + " " + substr(nkstatreg_det.dttime,7,2)+ ":" + substr(nkstatreg_det.dttime,9,2) + "</td>" skip
          "<td>'" + nkstatreg_det.docref + "</td>" skip
          "<td>" + GetStsName(nkstatreg_det.sts) + " " + nkstatreg_det.err + "</td>" skip
          "</tr>" skip.
    end.
end.
put stream file unformatted "</table>".

{html-end.i}

output stream file close.
unix silent value ("cptwin file.html excel").
unix silent value ("rm file.html").



