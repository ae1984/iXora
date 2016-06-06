/* AMT_ps.p
 * BASES
        -bank, -comm
 * MODULE
        Депозиты
 * DESCRIPTION
        Отправка отчетов пользователям в случае расхождения сумм по депозитам.
 * MENU
        Процесс
 * AUTHOR
        18.10.2006 u00124
 * CHANGES

*/


{global.i}

  def var v-depart as char      no-undo.
  def var file1 as char         no-undo.
  def var v-snd as char init "" no-undo.
  def var vpoint as integer     no-undo.
  def buffer b-sysc for sysc.

  file1 = "atime".

  find last b-sysc where b-sysc.sysc = 'depart' no-lock no-error.
  if not avail b-sysc then return.
  v-depart = b-sysc.chval.

  find last sysc where sysc.sysc  = 'ATIME' exclusive-lock no-error.
  if not avail sysc then return. 

  /* Время 17-00 */
  if time > 61200 then  do:
    if g-today <> date(sysc.chval) then do:


    for each ppoint where lookup(string(ppoint.depart), v-depart) <> 0  no-lock:

        file1 = "atm" + string(time) + ".htm".
        v-snd = "".
        output to value(file1).

        put {&stream} unformatted 
        "<HTML>"  skip 
        "<HEAD>"  skip
        "<TITLE>" skip.
        put {&stream} unformatted
        '{&title}' skip.
        put {&stream} unformatted 
        "</TITLE>" skip
        "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=koi8""/>" skip
        "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
        "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: " skip.
        put {&stream} unformatted    
        "{&size-add}". 
        put {&stream} unformatted        
        "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
        "</HEAD>" skip
        "<BODY>" skip.
        put unformatted
        "<P align=""center"" style=""font:bold;font-size:small"">Несоответствие сумм " ppoint.name "</P>"
        "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.

        put unformatted                         
        "<TR align=""center"" style=""font:bold;font-size:x-small;background:ghostwhite "">" skip
        "<TD>T-код клиента</TD>" skip
        "<TD>Ф.И.О клиента</TD>" skip
        "<TD>Номер счета</TD>"   skip
        "<TD>Сумма депозита</TD>" skip

        "<TD>Сумма поступивших средств</TD>" skip
        "<TD>Логин исполнителя</TD></TR>" skip.

        /*Цикл по всем группам депозитов физических лиц*/
        for each lgr where lgr.led = "TDA" no-lock:
            for each aaa where aaa.lgr = lgr.lgr and aaa.sta <> "C" and aaa.sta <> "E" and aaa.regdt = g-today no-lock:  
                if aaa.opnamt <> (aaa.cr[1] - aaa.dr[1]) then do:
                  find last cif where cif.cif = aaa.cif no-lock no-error.
                  if cif.jame <> '' then do:
                     vpoint = integer(cif.jame) / 1000 - 0.5.
                     if ppoint.depart = (integer(cif.jame) - vpoint * 1000) then do:
                     v-snd = "1".
                     put unformatted
                        "<TR align=""center"" style=""font-size:x-small;background:white "">" skip
                        "<TD>" cif.cif "</TD>"  skip
                        "<TD>" cif.name "</TD>" skip
                        "<TD>" aaa.aaa "</TD>"  skip
                        "<TD>" aaa.opnamt "</TD>" skip
                        "<TD>" aaa.cr[1] - aaa.dr[1] "</TD>" skip
                        "<TD>" aaa.who "</TD>"  skip.
   
                     end.
                  end.
                end.
            end.
        end.
        {html-end.i " "}
        output close .
     if v-snd = "1" and ppoint.mail <> "" then do:
        run mail("dpuchkov@elexnet.kz", "TEXAKABANK <abpk@elexnet.kz>", "Несоответствие сумм", "В приложении содержится отчет", "", "", file1).
        run mail(ppoint.mail, "TEXAKABANK <abpk@elexnet.kz>", "Несоответствие сумм", "В приложении содержится отчет", "", "", file1).
     end.
  end.
end.
  sysc.chval = string(g-today). 
end.


