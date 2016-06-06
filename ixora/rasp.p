/* rasp.p
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
 * BASES
        BANK COMM
 * AUTHOR
        23/09/04 dpuchkov
 * CHANGES
        30.01.2009 id00209 - нумерация распоряжений
        24/03/2009 madiyar - теперь номера распоряжений формируются здесь, а не в bccur.p, и номера копируются на филиал г.Алматы
        25/03/2009 madiyar - перекомпиляция
        26/03/2009 madiyar - оказывается, распоряжения рассылаются и в филиалах; внес соотв. изменения в форм. номеров
                             автоматическая рассылка при старте процессов - под superman'ом диалогов не нужно
        27/03/2009 madiyar - файлы на разных филиалах называются по-разному (т.к. могут формироваться одновременно под одним пользователем при старте процессов)
        30/03/2009 madiyar - номер последнего распоряжения передается параметром
        03/04/2009 madiyar - в распоряжениях филиалов указывается название филиала и ставится подпись директора филиала; кодировка win1251
        03/04/2009 madiyar - мелкое исправление
        03/04/2009 madiyar - еще одно мелкое исправление
        03/04/2009 madiyar - поправил тэг img
        03/04/2009 madiyar - последнее исправление
        05/08/2009 madiyar - поставил забытую кавычку в тексте распоряжения
        27/08/2009 galina - добавила в колонку время уточнение, что время по астане
        31/12/2009 madiyar - сброс нумерации распоряжений с нового года
        09/11/2010 id00477 - изменил "Главный специалист Генеральной бухгалтерии" на "Директор департамента казначейства"
        18.04.2011 aigul - добавила в crchis номер распоряжения
        19.04.2011 aigul - рассылка всем кроме, тех у кого тип - oporn
        20.04.2011 aigul - вернула рассылку для всех сотрудников
        21.04.2011 aigul - убрала копирование номера распоряжения в Алмату, так как теперь Алмата сама будет устанавливать курсы.
        08.08.2011 aigul - добавила запись номера распоряжения в tcrc
        09.08.2011 aigul - recompile
        10.08.2011 aigul - записать в справочник о смене курсов
        11.08.2011 aigul - перенесла запись в справочник о смене курсов в menu-bccur.p
        02.09.2011 aigul - добавила название новых курсов, но исключила их вывод в распоряжении
        08/05/2012 evseev - rebranding
*/

{global.i}

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

function month-des returns char (num as date):
   case month(num):
       when  1 then return "января".
       when  2 then return "февраля".
       when  3 then return "марта".
       when  4 then return "апреля".
       when  5 then return "мая".
       when  6 then return "июня".
       when  7 then return "июля".
       when  8 then return "августа".
       when  9 then return "сентября".
       when 10 then return "октября".
       when 11 then return "ноября".
       when 12 then return "декабря".
   end case.
end function.

def var l_name as logical init True.
def var i as integer .
def var ch_crcName as char.
def var ch_rkoName as char.
def var j as integer.
def var file1 as char.
def var  s-tempfolder as char.

input through localtemp.
repeat:
  import s-tempfolder.
end.

if substr(s-tempfolder, length(s-tempfolder), 1) <> "\\" then s-tempfolder = s-tempfolder + "\\".

def var v-numobm as char no-undo.
do transaction:
    find first sysc where sysc.sysc = 'numobm' exclusive-lock no-error.
    if not avail sysc then do:
        create sysc.
        assign sysc.sysc = "numobm" sysc.inval = 0 sysc.deval = 0 sysc.des = "Номер распоряжения по обменному пункту" sysc.daval = g-today.
    end.
    /*if s-ourbank <> "txb16" then do:*/
        sysc.inval = sysc.inval + 1.
        sysc.deval = 0.
        if sysc.daval ne g-today then do:
            if year(sysc.daval) <> year(g-today) then sysc.inval = 1. /* если новый год - начинаем нумерацию распоряжений с 1 */
            assign sysc.chval = "" sysc.daval = g-today.
        end.
        if sysc.chval ne "" then sysc.chval = sysc.chval + ",".
        sysc.chval = sysc.chval + string(sysc.inval).
        for each exch_lst exclusive-lock:
            exch_lst.numr = sysc.chval.
        end.
    /*end.*/
    find current sysc no-lock.
    v-numobm = string(sysc.inval).
end.
for each crchis where crchis.order = "" and crchis.rdt = g-today exclusive-lock:
    crchis.order = v-numobm.
end.
for each crchis where crchis.rdt = g-today no-lock.
end.
for each tcrc where tcrc.order = "" and tcrc.whn = g-today exclusive-lock:
    tcrc.order = v-numobm.
end.
for each tcrc where tcrc.whn = g-today no-lock.
end.


/* копирование номеров распоряжений на филиалы - сейчас только филиал Алматы */
/*if s-ourbank = "txb00" then do:
    find first comm.txb where comm.txb.bank = "txb16" and comm.txb.consolid no-lock no-error.
    if avail comm.txb then do:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run rasp2(input v-numobm).
    end.
    if connected ("txb") then disconnect "txb".
end.*/

file1 = "Kurs" + substring(s-ourbank,4,2) + ".html".
ch_rkoName = "".
output to value(file1).

put {&stream} unformatted
      "<HTML>" skip
      "<HEAD>" skip
      "<TITLE>" skip.

put {&stream} unformatted '{&title}' skip.

put {&stream} unformatted
      "</TITLE>" skip
      "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
      "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
      "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: " skip.

put {&stream} unformatted
      "{&size-add}".

put {&stream} unformatted
      "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
      "</HEAD>" skip
      "<BODY>" skip.

put unformatted
            "</body></html>" skip
            "<BODY>" skip
            "<P align=""center"" style=""font:bold;font-size:14.0pt""> F o r t e B a n k  </P>" skip.

if s-ourbank <> "txb00" then do:
    find first cmp no-lock no-error.
    put unformatted
        "<P align=""center""  style=""font:bold;font-size:small"">" trim(cmp.name) "</P>" skip.
end.

put unformatted
            "<P align=""right""  style=""font:bold;font-size:small""> " day(g-today) " " month-des(g-today) " " year(g-today) " г.  </P>" skip
            "<P align=""center"" style=""font:bold;font-size:small"">  <u><span style=""font-size:14.0pt; mso-bidi-font-size:10.0pt;font-family:Courier New;mso-bidi-font-family:Times New Roman"">Р А С П О Р Я Ж Е Н И Е	N " + v-numobm + "</span></u></b></p>" skip
            "<P align=""center"" style=""font:bold;font-size:small"">  <span style=""font-size:14.0pt; mso-bidi-font-size:10.0pt;font-family:Courier New;mso-bidi-font-family:Times New Roman"">ПО ОБМЕННОМУ  <span>   </span>     ПУНКТУ    <span>   </span>  " /*ch_rkoName*/ " </span></b></p>" skip
            "<P align=""center"" style=""line-height:2%;font:bold;font-size:small""><span style=""line-height:2%;font-size:14.0pt; mso-bidi-font-size:10.0pt;font-family:Courier New;mso-bidi-font-family:Times New Roman"">Установить  следующие  курсы  покупки  и </span></u></p>" skip
            "<P align=""center"" style=""line-height:2%;font:bold;font-size:small""><span style=""line-height:2%;font-size:14.0pt; mso-bidi-font-size:10.0pt;font-family:Courier New;mso-bidi-font-family:Times New Roman"">продажи наличных  валют </span></b></p>" skip.
put unformatted
             "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""70%"">" skip
             "<TR align=""center"" style=""font:bold;background:white "">"  skip.
put unformatted
            "<td> <p> </p></td>" skip
            "<td align=""center""> <p><u><span style=""font-size:14.0pt; mso-bidi-font-size:10.0pt;font-family:Courier New;mso-bidi-font-family:Times New Roman""> Покупка </span></u></p></td>" skip
            "<td align=""center""> <p><u><span style=""font-size:14.0pt; mso-bidi-font-size:10.0pt;font-family:Courier New;mso-bidi-font-family:Times New Roman""> Продажа </span></u></p></td>" skip
            "<td align=""center""> <p><u><span style=""font-size:14.0pt; mso-bidi-font-size:10.0pt;font-family:Courier New;mso-bidi-font-family:Times New Roman""> Время Астаны</span></u></p></td>" skip
            "</TR>" skip.

DO i = 1 TO 4:
   if not l_name then do:
      put unformatted "<tr valign=top style=""background:"  "white " """>" skip.
      put unformatted "<td height=24></td>" skip. put unformatted "<td>"  "</td>" skip  "<td>"  "</td>" skip  "<td>"  "</td>" skip "</TR>" skip.
      put unformatted "<td height=24></td>" skip. put unformatted "<td>"  "</td>" skip  "<td>"  "</td>" skip  "<td>"  "</td>" skip "</TR>" skip.
      put unformatted "<td height=24></td>" skip. put unformatted "<td>"  "</td>" skip  "<td>"  "</td>" skip  "<td>"  "</td>" skip "</TR>" skip.
   end.

   l_name = True.
   for each tcrc where tcrc.whn = g-today and tcrc.crc = i no-lock break by tcrc.dtim:
       put unformatted
          "<tr valign=top style=""background:"  "white " """>" skip.
       if i = 1 then ch_crcName = "Тенге". else
       if i = 2 then ch_crcName = "Доллар США". else
       if i = 4 then ch_crcName = "Российские рубли". else
       /*if i = 6 then ch_crcName = "Фунты стерлингов". else
       if i = 7 then ch_crcName = "Шведская крона". else
       if i = 8 then ch_crcName = "Австралийский доллар". else
       if i = 9 then ch_crcName = "Швейцарский франк". else*/
       if i = 3 then ch_crcName = "Евро" .

       if l_name then
          put unformatted   "<td align=""center""><p><b>" ch_crcName "</b></p></td>" skip.
       else
          put unformatted   "<td align=""center""><p> </p></td>" skip.
          put unformatted
          "<td align=""center""><p>" tcrc.rate[2] format "zzz,zzz,zzz,zz9.99" "</p></td>" skip
          "<td align=""center""><p>" tcrc.rate[3] format "zzz,zzz,zzz,zz9.99" "</p></td>" skip
          "<td align=""center""><p>" string( tcrc.dtime, "HH:MM:SS" )  "</p></td>" skip
          "</TR>" skip.
          l_name = False.
   end.

end.


put unformatted
    "</TABLE>" skip(3).
put unformatted
    " <table cellpadding=0 cellspacing=0 align=left>"
    "<tr>"
    "<td width=25 height=36></td>"
    "</tr>"
    "<tr>"
    "<td width=50></td>" skip.

if s-ourbank = "txb00" then do:
    put unformatted
	/*		09/11/2010 id00477 - изменил "Главный специалист Генеральной бухгалтерии" на "Директор департамента казначейства" */
        "<td width=213  valign=""bottom"" ><p align=""left"" style=""font:bold;font-size:small;"">  Директор департамента казначейства </p></td>"
        "<td>               </td>"
        "<td><IMG border=""0"" src=""" s-tempfolder "antsign.jpg"" width=""180"" height=""60"" v:shapes=""_x0000_s1026""></p></td>" skip.
end.
else do:
    put unformatted
        "<td width=213  valign=""bottom"" ><p align=""left"" style=""font:bold;font-size:small;"">   Директор Филиала </p></td>"
        "<td>               </td>"
        "<td><IMG border=""0"" src=""file:///c:/tmp/pkdogsgn.jpg"" width=""180"" height=""60"" v:shapes=""_x0000_s1026""></p></td>" skip.

end.

put unformatted
    "</tr>"
    "<tr>"
    "<td height=20> </td>"
    "<td> </td>"
    "<td> </td>"
    "<td> </td>"
    "</tr>"
    "</table>" skip.

{html-end.i " "}
output close.
def var b as logical.

if g-ofc = "superman" then b = yes.
else do:
    unix silent cptwin value(file1) iexplore.
    message "Отправить распоряжение о смене курсов ?" view-as alert-box question buttons yes-no update b.
end.

if b then do:
    for each ofcsend where ofcsend.typ = "kurs" no-lock:
        run mail(ofcsend.ofc + "@metrocombank.kz", "BANK <abpk@metrocombank.kz>", "Курсы валют", "", "", "",file1).
    end.
end.


