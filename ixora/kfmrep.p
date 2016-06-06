/* kfmrep.p
 * MODULE
        Финансовый мониторинг
 * DESCRIPTION
        Отчет едежневный по фин.мониторингу
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
        25/03/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        27/05/2010 galina - перекомпиляция
*/
def stream rep.
def var v-dt as date.
def temp-table t-kfmoperrep
    field num as integer
    field sum as deci
    field crc as char
    field filial as char
    field prt as char
    field reas as char
    field who as char
    field sts as char
    index idx is primary num.

update v-dt format "99/99/9999" label 'Дата отчета' validate(v-dt <> ?,'') with frame fdt centered side-label row 5.

for each kfmoper where kfmoper.rwhn = v-dt no-lock:
  create t-kfmoperrep.
  assign t-kfmoperrep.num = kfmoper.operId
         t-kfmoperrep.who = kfmoper.rwho.
  find first txb where txb.consolid and txb.bank = kfmoper.bank no-lock no-error.
  if avail txb then t-kfmoperrep.filial = txb.info.

  find first kfmoperh where kfmoperh.bank = kfmoper.bank and kfmoperh.operId = kfmoper.operId and kfmoperh.dataCode = 'opSum' no-lock no-error.
  if avail kfmoperh then t-kfmoperrep.sum = deci(kfmoperh.dataValue).

  find first kfmoperh where kfmoperh.bank = kfmoper.bank and kfmoperh.operId = kfmoper.operId and kfmoperh.dataCode = 'msgReas' no-lock no-error.
  if avail kfmoperh then do:
     find first codfr where codfr.codfr = 'kfmReas' and codfr.code = kfmoperh.dataValue no-lock no-error.
     if avail codfr then t-kfmoperrep.reas = codfr.name[1].
  end.

  find first kfmoperh where kfmoperh.bank = kfmoper.bank and kfmoperh.operId = kfmoper.operId and kfmoperh.dataCode = 'opCrc' no-lock no-error.
  if avail kfmoperh then do:
     find first codfr where codfr.codfr = 'kfmCrc' and codfr.code = kfmoperh.dataValue no-lock no-error.
     if avail codfr then t-kfmoperrep.crc = codfr.name[1].
  end.
  find first bookcod where bookcod.bookcod = 'kfmSts' and bookcod.code = string(kfmoper.sts,'99') no-lock no-error.
  if avail bookcod then t-kfmoperrep.sts = bookcod.name.
  for each kfmprt where kfmprt.bank = kfmoper.bank and kfmprt.operId = kfmoper.operId no-lock:
     find first kfmprth where kfmprth.bank = kfmprt.bank and kfmprth.operId = kfmprt.operId and kfmprth.partId = kfmprt.partId and kfmprth.dataCode = 'prtNameU' no-lock no-error.
     if avail kfmprth and kfmprth.datavalue <> '' then do:
       if t-kfmoperrep.prt <> '' then t-kfmoperrep.prt = t-kfmoperrep.prt + ';'.
       t-kfmoperrep.prt = t-kfmoperrep.prt + kfmprth.dataValue.

     end.
     else do:

       find first kfmprth where kfmprth.bank = kfmprt.bank and kfmprth.operId = kfmprt.operId and kfmprth.partId = kfmprt.partId and kfmprth.dataCode = 'prtFLNam' no-lock no-error.
       if avail kfmprth and kfmprth.datavalue <> ''  then do:

          if t-kfmoperrep.prt <> '' and kfmprth.datavalue <> ''  then t-kfmoperrep.prt = t-kfmoperrep.prt + ';'.
          t-kfmoperrep.prt = t-kfmoperrep.prt + kfmprth.dataValue.
          find first kfmprth where kfmprth.bank = kfmprt.bank and kfmprth.operId = kfmprt.operId and kfmprth.partId = kfmprt.partId and kfmprth.dataCode = 'prtFFNam' no-lock no-error.
          t-kfmoperrep.prt = t-kfmoperrep.prt + ' ' + kfmprth.dataValue.
          find first kfmprth where kfmprth.bank = kfmprt.bank and kfmprth.operId = kfmprt.operId and kfmprth.partId = kfmprt.partId and kfmprth.dataCode = 'prtFMNam' no-lock no-error.
          t-kfmoperrep.prt = t-kfmoperrep.prt + ' ' + kfmprth.dataValue.
       end.
     end.
  end.
end.

find first t-kfmoperrep no-lock no-error.
if not avail t-kfmoperrep then return.
output stream rep to kfmrep.xls.
put stream rep unformatted "<html><head><title>METROCOMBANK</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep unformatted "<br><br><h3>METROCOMBANK</h3><br>" skip.
put stream rep unformatted "<h3>Финансовый мониторинг</h3><br>" skip.
put stream rep unformatted "<h3>Отчет на " string(v-dt) "</h3><br><br>" skip.

put stream rep unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                           "<tr style=""font:bold"">"
                           "<td bgcolor=""#C0C0C0"" align=""center"">№ операции</td>"
                           "<td bgcolor=""#C0C0C0"" align=""center"">Сумма операции</td>"
                           "<td bgcolor=""#C0C0C0"" align=""center"">Валюта<BR>операции</td>"
                           "<td bgcolor=""#C0C0C0"" align=""center"">Филиал</td>"
                           "<td bgcolor=""#C0C0C0"" align=""center"">Участники<BR>операции</td>"
                           "<td bgcolor=""#C0C0C0"" align=""center"">Причина создания<BR> сообщения</td>"
                           "<td bgcolor=""#C0C0C0"" align=""center"">№ ID менеджера<BR>создавшего сообщение</td>"
                           "<td bgcolor=""#C0C0C0"" align=""center"">Статус<BR>операции</td></tr>" skip.




for each t-kfmoperrep no-lock:
  put stream rep unformatted "<tr align=""right"">"
  "<td>" string(t-kfmoperrep.num) "</td>"
  "<td>" replace(string(t-kfmoperrep.sum,'>>>>>>>>>>>>>>>9.99'),'.',',') "</td>"
  "<td>" t-kfmoperrep.crc "</td>"
  "<td>" t-kfmoperrep.filial "</td>"
  "<td>" t-kfmoperrep.prt  "</td>"
  "<td>" t-kfmoperrep.reas "</td>"
  "<td>" t-kfmoperrep.who "</td>"
  "<td>" t-kfmoperrep.sts "</td></tr>" skip.
end.
put stream rep unformatted "</table></body></html>".
output stream rep close .
unix silent value("cptwin kfmrep.xls excel").
 unix silent rm -f kfmrep.xls.
