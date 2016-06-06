
/* kdzakl.p
 * MODULE
        кредитное досье
 * DESCRIPTION
        Юридическое заключение
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
         
 * AUTHOR
        13.01.04 marinav  
 * CHANGES
        09.03.2004 marinav убраны столбцы дата , вид документа
                           не выводятся документы, не имеющие отметки юриста
        30/04/2004 madiar - Изменил pksysc на sysc
                          Для досье филиалов в ГБ - выводится юрид. заключение ГБ, а не филиала
        18/05/2004 madiar - добавил no-lock.
        20/05/2004 madiar - Поиск записей в kdaffil - не только по коду досье, но и по коду клиента
        27/05/2004 madiar - В put unformatted почти не было skip-ов - awk ругнулся на слишком длинную строку.
        25.04.2005 marinav - Столбец "примечание" заменено на 3 других столбца.
    05/09/06   marinav - добавление индексов
*/

{global.i}
{kd.i new}
{sysc.i}
/*
s-kdcif = 't26034'.
s-kdlon = 'KD26'.
*/

def var kdaffilcod as char init "".

form s-kdcif label ' Укажите номер клиента ' format 'x(10)' skip 
     s-kdlon label ' Укажите его досье     ' format 'x(10)' skip 
           with side-label row 5 centered frame dat .

update s-kdcif with frame dat.
update s-kdlon with frame dat.


def var v-ofc as char.
define buffer b-kdaffil for kdaffil.

find first kdlon where kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon and (bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.
 if not avail kdlon then do:   
   message skip " Заявка N" s-kdlon "не найдена !" skip(1)
     view-as alert-box buttons ok title " ОШИБКА ! ".
   return.
 end.
 
find first kdcif where kdcif.kdcif = kdlon.kdcif no-lock no-error.
 if not avail kdcif then do:
   message skip " Клиент N" kdlon.kdcif "не найден !" skip(1)
     view-as alert-box buttons ok title " ОШИБКА ! ".
   return.
 end.

define var v-zal as char extent 20.
define var i as inte.

define stream m-out.
output stream m-out to rpt.html.

put stream m-out skip.
           
put stream m-out "<html xmlns:o=""urn:schemas-microsoft-com:office:office""
xmlns:w=""urn:schemas-microsoft-com:office:word"">
<head><meta name=ProgId content=Word.Document>" skip.


put stream m-out "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""><title>TEXAKABANK:</title>".

put stream m-out unformatted "<style>" skip
 "@page Section1" skip
 "	\{size:841.7pt 595.45pt;" skip
 "	mso-page-orientation:landscape;}" skip
 "div.Section1" skip
 "	\{page:Section1;}" skip
 "</style>" skip.
put stream m-out "</head><body>".
put stream m-out "<div class=Section1>".

put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""3""
                 style=""border-collapse: collapse"">". 
put stream m-out "<tr><td align=""right""><h3>АО TEXAKABANK"
                 "<br></td></tr>" skip.
                 
if s-ourbank = kdlon.bank then
   put stream m-out "<tr align=""center""><td><h4> Юридическое заключение по документам 
                     на предоставление банковского займа <br><br></td></tr>" skip.
else
   put stream m-out "<tr align=""center""><td><h4> Юридическое заключение ГБ по документам 
                     на предоставление банковского займа <br><br></td></tr>" skip.

put stream m-out "<tr align=""left""><td> Кому: "  get-sysc-cha ("kdkomy") format 'x(60)' "</td></tr>".
put stream m-out "<tr align=""left""><td> Дата: " g-today "</td></tr>".

put stream m-out "<tr><td><table border=""0"" cellpadding=""3"" cellspacing=""0""
                  style=""border-collapse: collapse"">" skip.

put stream m-out "<br><tr><td align = ""center"" colspan = ""2""><b>Заемщик </td></tr>" skip.
put stream m-out "<tr><td>Наименование </td><td>" kdcif.name format 'x(60)' "</td></tr>" skip.
put stream m-out "<tr><td>Дата первичной регистрации </td><td>" kdcif.urdt1 "</td></tr>" skip.
put stream m-out "<tr><td>Дата регистрации </td><td>" kdcif.urdt "</td></tr>" skip.
put stream m-out "<tr><td>Регистрационный номер </td><td>" kdcif.regnom format 'x(15)' "</td></tr>" skip.
put stream m-out "<tr><td>Учредители, их доли </td><td></td></tr>" skip.
for each kdaffil where kdaffil.bank = s-ourbank and kdaffil.code = '01' and kdaffil.kdcif = s-kdcif no-lock.
   put stream m-out "<tr><td></td><td>" kdaffil.name format 'x(30)' "</td><td align = ""right"">" kdaffil.amount format '>>9.99%' "</td></tr>" skip.
end.
put stream m-out "<tr><td>Первый руководитель </td><td>" kdcif.chief[1] format 'x(60)' "</td></tr>" skip.
put stream m-out "<tr><td>Главный бухгалтер </td><td>" kdcif.chief[2] format 'x(60)' "</td></tr>" skip.

for each kdaffil where  kdaffil.kdcif = s-kdcif and 
                kdaffil.kdlon = s-kdlon and kdaffil.code = '20' and kdaffil.name = kdcif.name  no-lock break by kdaffil.kdcif.
   if first-of (kdaffil.kdcif) 
            then put stream m-out "<tr><td>Обеспечение </td><td>" kdaffil.info[1] format 'x(1000)' "</td></tr>" skip.
            else put stream m-out "<tr><td></td><td>" kdaffil.info[1] format 'x(200)' "</td></tr>" skip.
end.


for each kdaffil where  kdaffil.kdcif = s-kdcif and 
                kdaffil.kdlon = s-kdlon and kdaffil.code = '22' and kdaffil.res ne '' no-lock.
    put stream m-out "<br><tr><td align = ""center"" colspan = ""2""><b>Залогодатель </td></tr>" skip.
    put stream m-out "<tr><td>Наименование </td><td>" kdaffil.name format 'x(60)' "</td></tr>" skip.
    put stream m-out "<tr><td>Дата первичной регистрации </td><td>" kdaffil.datres[1] "</td></tr>" skip.
    put stream m-out "<tr><td>Дата регистрации </td><td>" kdaffil.datres[2] "</td></tr>" skip.
    put stream m-out "<tr><td>Регистрационный номер </td><td>" kdaffil.res format 'x(15)' "</td></tr>" skip.
    put stream m-out "<tr><td>Учредители, их доли </td><td></td></tr>" skip.
    do i = 1 to extent(v-zal): v-zal[i] = ''. end. 
    do i = 1 to extent(v-zal): v-zal[i] = entry(i, kdaffil.info[1]). end.
    do i = 1 to extent(v-zal) by 2:
      if v-zal[i] ne '' then put stream m-out "<tr><td></td><td>" v-zal[i] format 'x(30)' "</td><td align = ""right"">" deci(v-zal[i + 1])  format '>>9%' "</td></tr>" skip.
    end.
    put stream m-out "<tr><td>Первый руководитель </td><td>" kdaffil.info[2] format 'x(60)' "</td></tr>" skip.
    put stream m-out "<tr><td>Главный бухгалтер </td><td>" kdaffil.info[3] format 'x(60)' "</td></tr>" skip.

    for each b-kdaffil where  b-kdaffil.kdcif = s-kdcif and 
                b-kdaffil.kdlon = s-kdlon and b-kdaffil.code = '20' and b-kdaffil.name = kdaffil.name  no-lock break by b-kdaffil.kdcif.
       if first-of (b-kdaffil.kdcif) 
                then put stream m-out "<tr><td>Обеспечение </td><td>" b-kdaffil.info[1] format 'x(1000)' "</td></tr>".
                else put stream m-out "<tr><td></td><td>" b-kdaffil.info[1] format 'x(1000)' "</td></tr>".
    end.
end.
for each kdaffil where kdaffil.kdcif = s-kdcif and 
                kdaffil.kdlon = s-kdlon and kdaffil.code = '22' and kdaffil.res = '' no-lock.
    put stream m-out "<br><tr><td align = ""center"" colspan = ""2""><b>Залогодатель </td></tr>" skip.
    put stream m-out "<tr><td>ФИО </td><td>" kdaffil.name format 'x(60)' "</td></tr>" skip.

    for each b-kdaffil where  b-kdaffil.kdcif = s-kdcif and 
                b-kdaffil.kdlon = s-kdlon and b-kdaffil.code = '20' and b-kdaffil.name = kdaffil.name  no-lock break by b-kdaffil.kdcif.
       if first-of (b-kdaffil.kdcif) 
                then put stream m-out "<tr><td>Обеспечение </td><td>" b-kdaffil.info[1] format 'x(1000)' "</td></tr>" skip.
                else put stream m-out "<tr><td></td><td>" b-kdaffil.info[1] format 'x(1000)' "</td></tr>" skip.
    end.
end.

put stream m-out "<br><tr><td align = ""center""><b> Описание проекта </td></tr>" skip.
    find first crc where crc.crc = kdlon.crcz no-lock no-error.
    find first codfr where codfr.codfr = "lntgt" and codfr.code = kdlon.goalz no-lock no-error.
if avail crc then 
    put stream m-out "<tr><td>Сумма кредита </td><td>" replace(trim(string(deci(kdlon.amountz), "->>>>>>>>>>>9.99")),".",",") " " crc.code  "</td></tr>" skip.
    put stream m-out "<tr><td>Срок </td><td>" kdlon.srokz format '>>>9' " мес.</td></tr>" skip.
if avail codfr then
    put stream m-out "<tr><td>Целевое использование </td><td>" codfr.name[1] format 'x(40)' "</td></tr>" skip.

put stream m-out "</table><br><br>" skip.

put stream m-out "<br><tr><td align = ""center""><b> Анализ проекта </td></tr>" skip.


       put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование документа</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Замечания, подлежащие устранению <u><i> в обязательном порядке </i> до предоставления банковского займа</u></td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Замечания, подлежащие устранению <u><i> в обязательном порядке </i> после предоставления банковского займа</u></td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Замечания, носящие информационный характер</td></tr>" skip.


for each kddoclon where kdcif = s-kdcif and kdlon = s-kdlon and kddoclon.type = '00' 
                       and kddoclon.info[2] ne '' use-index ciflonln no-lock.
   find first kddocs where kddocs.ln = kddoclon.ln no-lock no-error.
   if avail kddocs then
    put stream m-out "<tr align=""left"">"
               "<td> " trim(kddocs.name) format "x(200)" "</td>"
               "<td> " kddoclon.info[2] format "x(300)"  "</td>"
               "<td> " kddoclon.info[3] format "x(300)"  "</td>"
               "<td> " kddoclon.info[4] format "x(300)"  "</td></tr>"
               skip.
end.

for each kddoclon where kdcif = s-kdcif and kdlon = s-kdlon and kddoclon.type ne '00' 
                        and kddoclon.type ne '10' and kddoclon.info[2] ne '' use-index ciflonlnn no-lock.
   find first kddocs where kddocs.ln = kddoclon.ln no-lock no-error.
   if avail kddocs then
    put stream m-out "<tr align=""left"">"
               "<td> " trim(kddocs.name) format "x(200)" "</td>"
               "<td> " kddoclon.info[2] format "x(300)"  "</td>"
               "<td> " kddoclon.info[3] format "x(300)"  "</td>"
               "<td> " kddoclon.info[4] format "x(300)"  "</td></tr>"
               skip.
end.
for each kddoclon where kdcif = s-kdcif and kdlon = s-kdlon and kddoclon.type = '10' 
                        and kddoclon.info[2] ne '' use-index ciflonln no-lock.
   find first kddocs where kddocs.ln = kddoclon.ln no-lock no-error.
   if avail kddocs then
    put stream m-out "<tr align=""left"">"
               "<td> " trim(kddocs.name) format "x(200)" "</td>"
               "<td> " kddoclon.info[2] format "x(300)"  "</td>"
               "<td> " kddoclon.info[3] format "x(300)"  "</td>"
               "<td> " kddoclon.info[4] format "x(300)"  "</td></tr>"
               skip.
end.
put stream m-out "</table><br><br>" .


put stream m-out "<br><br><tr align=""center""><td><b>Резюме </td></tr><tr></tr>" skip.
if s-ourbank <> kdlon.bank then kdaffilcod = '60'. else kdaffilcod = '23'.
find first kdaffil where  kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = kdaffilcod  no-lock no-error.
if avail kdaffil then 
   put stream m-out "<tr><td>" kdaffil.info[1] format 'x(1000)' "</td></tr>" skip.

put stream m-out "</table><br><br>" .


put stream m-out "<br><br><tr><td>Директор Юридического Департамента </td><td>___________________</td>" 
                 "<td>__________ " get-sysc-cha ("kddiru") format 'x(20)' "</td></tr><tr></tr>" skip.

if avail kdaffil then do:
find ofc where ofc.ofc = kdaffil.who no-lock no-error.
if avail ofc then do:
   v-ofc = entry(1, ofc.name, " ").
   if num-entries(ofc.name, " ") > 1 then v-ofc = v-ofc + " " + substr(entry(2, ofc.name, " "), 1, 1) + ".".
   if num-entries(ofc.name, " ") > 2 then v-ofc = v-ofc + substr(entry(3, ofc.name, " "), 1, 1) + ".".
   put stream m-out "<br><br><tr><td>Исп. " v-ofc format 'x(40)'  "</td></tr><br>" skip.
end.
end.

put stream m-out "</table></body></html>".
output stream m-out close.
unix silent cptwin rpt.html winword. 
