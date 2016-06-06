/* pklettercl.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Формирование наклеек на конверты для писем клиентам-должникам
 * RUN
      
 * CALLER
        pkletter.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-14-6
 * AUTHOR
        19.12.2003 nadejda
 * CHANGES
        25/06/2004 madiar  - переделал цикл - теперь все типы писем попадают в одну ведомость, в разные таблицы
        28/12/2005 madiar  - в ведомость попадали письма всех филиалов с конкретным номером ведомости, исправил
*/

{global.i}
{pk.i}

def input parameter p-1letter as logical.
def input parameter p-param as char.

def shared var s-bookcod as char.
def var lettertypes_cl as char init "lndolgcl,lndolgcl1".
def var v-filename as char init "lbl".
def var i as integer.
def var v-roll as integer.
def var v-name as char.

def stream lab.

v-filename = v-filename + p-param + ".html".

output stream lab to value(v-filename).
{html-title.i &stream = "stream lab" &title = " " &size-add = "x"}
find first cmp no-lock no-error.
put stream lab unformatted
  "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip
  "<TR><TD colspan=""6"">" cmp.name "</TD></TR>" skip
  "<TR><TD colspan=""6"" align=""left"">" string(today, "99/99/9999") "<BR><BR>" skip
  "<B>ПОЛУЧАТЕЛИ ПИСЕМ - КЛИЕНТЫ КРЕДИТНОГО ДЕПАРТАМЕНТА</B><BR>" skip.

if not p-1letter then
  put stream lab unformatted
    "<BR>Ведомость N " p-param "<BR>" skip
    "<BR></TD></TR></TABLE>" skip.

/* put stream lab unformatted
  "<BR>" p-subtitle "<BR>" skip
  "</TABLE>"
  "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip
    "<TR style=""font:bold"">" skip
      "<TD align=""center"">N п/п</TD>" skip
      "<TD align=""center"">Исх. N письма</TD>" skip.
 
 if lookup(p-lettertype,lettertypes_cl) > 0 then
    put stream lab unformatted
      "<TD>Фамилия</TD>" skip
      "<TD>Имя</TD>" skip
      "<TD>Отчество</TD>" skip.
 else
    put stream lab unformatted "<TD>Наименование организации</TD>" skip.
 
 put stream lab unformatted
      "<TD align=""center"">Адрес</TD>" skip.
 
 if lookup(p-lettertype,lettertypes_cl) = 0 then
    put stream lab unformatted "<TD>ФИО задолжника</TD>" skip.
 
 put stream lab unformatted "</TR>" skip.

i = 0. */

if not p-1letter then v-roll = integer(p-param).

for each letters where letters.bank = s-ourbank and
    if p-1letter then lookup(letters.docnum, p-param) > 0
                 else letters.roll = v-roll
    use-index roll no-lock break by letters.type:
  
  if first-of(letters.type) then do:
      find bookcod where bookcod.bookcod = s-bookcod and bookcod.code = letters.type no-lock no-error.
      put stream lab unformatted
         "<BR>" bookcod.name "<BR><BR>" skip
         "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip
         "<TR style=""font:bold"">" skip
         "<TD align=""center"">N п/п</TD>" skip
         "<TD align=""center"">Исх. N письма</TD>" skip.
 
      if lookup(letters.type,lettertypes_cl) > 0 then
        put stream lab unformatted
          "<TD>Фамилия</TD>" skip
          "<TD>Имя</TD>" skip
          "<TD>Отчество</TD>" skip.
      else put stream lab unformatted "<TD>Наименование организации</TD>" skip.
 
      put stream lab unformatted "<TD align=""center"">Адрес</TD>" skip.
 
      if lookup(letters.type,lettertypes_cl) = 0 then
         put stream lab unformatted "<TD>ФИО задолжника</TD>" skip.
 
      put stream lab unformatted "</TR>" skip.

      i = 0.
  end. /* if first-of(letters.type) */
  
  
  i = i + 1.
  put stream lab unformatted
    "<TR>"
      "<TD>" i "</TD>" skip
      "<TD>" letters.docnum "</TD>" skip.

  put stream lab unformatted
      "<TD>" if letters.info[2] <> "" then entry(1, letters.info[2]) else "&nbsp;" "</TD>" skip.

  if lookup(letters.type,lettertypes_cl) > 0 then do:
    put stream lab unformatted
        "<TD>" if letters.info[2] <> "" and num-entries(letters.info[2]) > 1 then entry(2, letters.info[2]) else "&nbsp;" "</TD>" skip.
    put stream lab unformatted
        "<TD>" if letters.info[2] <> "" and num-entries(letters.info[2]) > 2 then entry(3, letters.info[2]) else "&nbsp;" "</TD>" skip.
  end.

  put stream lab unformatted "<TD>" letters.addr[10] "</TD>" skip.
  
  if lookup(letters.type,lettertypes_cl) = 0 then
     put stream lab unformatted "<TD>" letters.name "</TD>" skip.
     
  put stream lab unformatted "</TR>" skip.
  
  if last-of(letters.type) then do:
    put stream lab unformatted "</TABLE>" skip.
  end.
    
end.

{html-end.i "stream lab"}


output stream lab close.

unix silent cptwin value(v-filename) excel.
