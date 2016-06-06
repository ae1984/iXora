/* pnjrpout.p
 * MODULE
        Пенсионные платежи
 * DESCRIPTION
        Формирование реестра отправленных платежей в Excel
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-9-13-6
 * AUTHOR
        30.01.2004 sasco
 * CHANGES
*/

{pnjcommon.i}
{comm-txb.i}
{global.i}

define variable ourbnk as char.
ourbnk = comm-txb().

define variable vd as date.
define variable v-d1 as date initial today label "Период с...".
define variable v-d2 as date initial today label "по...".

update v-d1 v-d2 with row 2 centered side-labels frame getdat title "".
hide frame getdat.

def var i as integer.

define temp-table tmp like letters.

def stream lab.

output stream lab to rpt.html.


{html-title.i &stream = "stream lab" &title = " " &size-add = "x"}

find first cmp no-lock no-error.

put stream lab unformatted
"<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip
  "<TR><TD colspan=""6"">" cmp.name "</TD></TR>" skip
   "<TR><TD colspan=""6"" align=""left"">" string(today, "99/99/9999") "<BR><BR>" skip
  "<B>ПОЛУЧАТЕЛИ ПИСЕМ - ВОЗВРАТЫ ПЕНСИОННЫХ ПЛАТЕЖЕЙ</B><BR>" skip
  "<B>ПЕРИОД ЗАПРОСА С " v-d1 " ПО " v-d2 "</B><BR>" skip.

put stream lab unformatted
  "<BR></TD></TR>" skip
"</TABLE>"
"<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip
  "<TR style=""font:bold"">" skip
    "<TD align=""center"">N п/п</TD>" skip
    "<TD align=""center"">Исх. N письма</TD>" skip
    "<TD>Фамилия / Наименование организации</TD>" skip
    "<TD>Имя</TD>" skip
    "<TD>Отчество</TD>" skip
    "<TD align=""center"">Адрес</TD>" skip
  "</TR>" skip.

do vd = v-d1 to v-d2:
   for each letters where letters.rdt = vd and letters.bank = ourbnk and letters.type = "pnjrmz" no-lock use-index rdt:
       create tmp.
       buffer-copy letters to tmp.
   end.
   for each letters where letters.rdt = vd and letters.bank = ourbnk and letters.type = "pnjcas" no-lock use-index rdt:
       create tmp.
       buffer-copy letters to tmp.
   end.
end.
  
i = 0.

for each tmp by tmp.rdt:
  i = i + 1.
  put stream lab unformatted
    "<TR>"
      "<TD>" i "</TD>" skip
      "<TD>" tmp.docnum "</TD>" skip.

  put stream lab unformatted
      "<TD>" if tmp.info[2] <> "" then entry(1, tmp.info[2]) else "&nbsp;" "</TD>" skip.

  put stream lab unformatted
      "<TD>" if tmp.info[2] <> "" and num-entries(tmp.info[2]) > 1 then entry(2, tmp.info[2]) else "&nbsp;" "</TD>" skip.

  put stream lab unformatted
      "<TD>" if tmp.info[2] <> "" and num-entries(tmp.info[2]) > 2 then entry(3, tmp.info[2]) else "&nbsp;" "</TD>" skip.

  put stream lab unformatted
      "<TD>" tmp.addr[10] "</TD>" skip
    "</TR>" skip.
end.

put stream lab unformatted "</TABLE>" skip.

{html-end.i "stream lab"}


output stream lab close.

unix silent cptwin rpt.html excel.
