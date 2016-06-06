/* tarch1.p
 * MODULE
        Тарификатор
 * DESCRIPTION
        Отчет по измененым тарифам.
 * RUN
        9-1-2-6-5-1
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        19/01/05 saltanat
 * CHANGES
        28.03.05 saltanat - Убрала вывод льготников по Потреб.кредитам.
        05.07.2005 saltanat - Выборка льгот по счетам.
*/

{mainhead.i}
{get-dep.i}

def var v-dtb     as date.
def var v-dte     as date.
def var v-num     as integer.
def var v-stat    as char.

def temp-table t-tarif   like tarif.  
def temp-table t-tarif2  like tarif2.
def temp-table t-tarifex like tarifex.
def temp-table t-tarifex2 like tarifex2.

form
   skip(1)
   v-dtb label 'Начало периода' format '99/99/9999' skip
   v-dte label ' Конец периода' format '99/99/9999' skip(1)
   with centered side-label row 5 title "УКАЖИТЕ ПЕРИОД ОТЧЕТА" frame f-dt.

v-dtb = g-today.
v-dte = g-today.

update v-dtb v-dte with frame f-dt.

for each tarif where (tarif.whn    >= v-dtb and tarif.whn    <= v-dte)
                  or (tarif.akswhn >= v-dtb and tarif.akswhn <= v-dte)
                  or (tarif.delwhn >= v-dtb and tarif.delwhn <= v-dte) no-lock.
    create t-tarif.
    buffer-copy tarif to t-tarif.
end.

for each tarif2 where (tarif2.whn    >= v-dtb and tarif2.whn    <= v-dte)
                   or (tarif2.akswhn >= v-dtb and tarif2.akswhn <= v-dte)
                   or (tarif2.delwhn >= v-dtb and tarif2.delwhn <= v-dte) no-lock.
    create t-tarif2.
    buffer-copy tarif2 to t-tarif2.
end.

for each tarifex where (tarifex.whn    >= v-dtb and tarifex.whn    <= v-dte)
                    or (tarifex.akswhn >= v-dtb and tarifex.akswhn <= v-dte)
                    or (tarifex.delwhn >= v-dtb and tarifex.delwhn <= v-dte) no-lock.
    if tarifex.pakalp = 'Временно - потреб кредит' then next.                
    create t-tarifex.
    buffer-copy tarifex to t-tarifex.
end.

for each tarifex2 where (tarifex2.whn    >= v-dtb and tarifex2.whn    <= v-dte)
                     or (tarifex2.akswhn >= v-dtb and tarifex2.akswhn <= v-dte)
                     or (tarifex2.delwhn >= v-dtb and tarifex2.delwhn <= v-dte) no-lock.
    if tarifex2.pakalp = 'Временно - потреб кредит' then next.                
    create t-tarifex2.
    buffer-copy tarifex2 to t-tarifex2.
end.

v-num = 0.

/* вывод отчета в HTML */
def stream vcrpt.
output stream vcrpt to vcreestr.htm.

{html-title.i 
 &stream = " stream vcrpt "
 &title = "Изменения по тарифам"
 &size-add = "xx-"
}

put stream vcrpt unformatted 
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>ИЗМЕНЕНИЯ ПО ТАРИФАМ<BR>за период с " + string(v-dtb, "99/99/9999") + 
       " по " + string(v-dte, "99/99/9999") + "</B></FONT></P>" skip(1).

/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   T A R I F   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
find first t-tarif no-lock no-error.
if avail t-tarif then do:

put stream vcrpt unformatted 
   "<P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Комиссии по услугам</B></FONT></P>" 
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.
put stream vcrpt unformatted 
    "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>Nr</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Nr</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Услуга</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Изменил</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Когда изм.</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Акцептовал</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Когда акц.</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Удалил</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Когда удал.</B></FONT></TD>" skip
    "</TR>" skip.

for each t-tarif break by t-tarif.stat by t-tarif.num by t-tarif.nr:

    if first-of(t-tarif.stat) then do:
     case t-tarif.stat:
          when 'r' then v-stat = 'Д Е Й С Т В У Ю Щ И Е'.
          when 'c' then v-stat = 'И З М Е Н Е Н Н Ы Е'.
          when 'n' then v-stat = 'Д О Б А В Л Е Н Н Ы Е'.
          when 'd' then v-stat = 'У Д А Л Е Н Н Ы Е'.
          when 'a' then v-stat = 'А Р Х И В Н Ы Е'.
     end case.
     put stream vcrpt unformatted 
       "<TR align=""center"" bgcolor=""#C0C0C0"">" skip
        "<TD colspan=""9""><FONT size=""3""><B>" v-stat "</B></FONT></TD>" skip
       "</TR>" skip.
    end.

   put stream vcrpt unformatted 
   "<TR align=""center"">" skip
     "<TD><FONT size=""2"">" + t-tarif.num + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-tarif.nr) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-tarif.pakalp + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-tarif.who    + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + if t-tarif.whn = ? then "" else string(t-tarif.whn, "99/99/99") + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-tarif.akswho + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + if t-tarif.akswhn = ? then "" else string(t-tarif.akswhn, "99/99/99") + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-tarif.delwho + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + if t-tarif.delwhn = ? then "" else string(t-tarif.delwhn, "99/99/99") + "</FONT></TD>" skip
   "</TR>" skip.

end.

put stream vcrpt unformatted  
"</TABLE>" skip.

end. /* if avail t-tarif */


/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   T A R I F 2   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
find first t-tarif2 no-lock no-error.
if avail t-tarif2 then do:

put stream vcrpt unformatted 
   "<P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Комиссии по услугам с разбивкой по счетам</B></FONT></P>" 
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.
put stream vcrpt unformatted 
    "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>Nr</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Nr</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Счет</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Пункт</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Услуга</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Вал</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Сумма</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>%</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Мин</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Макс</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Изменил</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Когда изм.</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Акцептовал</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Когда акц.</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Удалил</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Когда удал.</B></FONT></TD>" skip
    "</TR>" skip.

for each t-tarif2 break by t-tarif2.stat by t-tarif2.num by t-tarif2.kod by t-tarif2.kont by t-tarif2.pakalp:

    if first-of(t-tarif2.stat) then do:
     case t-tarif2.stat:
          when 'r' then v-stat = 'Д Е Й С Т В У Ю Щ И Е'.
          when 'c' then v-stat = 'И З М Е Н Е Н Н Ы Е'.
          when 'n' then v-stat = 'Д О Б А В Л Е Н Н Ы Е'.
          when 'd' then v-stat = 'У Д А Л Е Н Н Ы Е'.
          when 'a' then v-stat = 'А Р Х И В Н Ы Е'.
     end case.
     put stream vcrpt unformatted 
       "<TR align=""center"" bgcolor=""#C0C0C0"">" skip
        "<TD colspan=""16""><FONT size=""3""><B>" v-stat "</B></FONT></TD>" skip
       "</TR>" skip.
    end.

   put stream vcrpt unformatted 
   "<TR align=""center"">" skip
     "<TD><FONT size=""2"">" + t-tarif2.num + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-tarif2.kod + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-tarif2.kont) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-tarif2.punkt + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-tarif2.pakalp + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-tarif2.crc) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-tarif2.ost) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-tarif2.proc) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-tarif2.min1) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-tarif2.max1) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-tarif2.who    + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + if t-tarif2.whn = ? then "" else string(t-tarif2.whn, "99/99/99") + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-tarif2.akswho + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + if t-tarif2.akswhn = ? then "" else string(t-tarif2.akswhn, "99/99/99") + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-tarif2.delwho + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + if t-tarif2.delwhn = ? then "" else string(t-tarif2.delwhn, "99/99/99") + "</FONT></TD>" skip
   "</TR>" skip.

end.

put stream vcrpt unformatted  
"</TABLE>" skip.

end. /* if avail t-tarif */


/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   T A R I F E X   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
find first t-tarifex no-lock no-error.
if avail t-tarifex then do:

put stream vcrpt unformatted 
   "<P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Исключения по клиентам с разбивкой по счетам</B></FONT></P>" 
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.
put stream vcrpt unformatted 
    "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>Клиент</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Код</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Пункт</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Счет ГК</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Услуга</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Вал</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Сумма</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>%</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Мин</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Макс</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Изменил</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Когда изм.</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Акцептовал</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Когда акц.</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Удалил</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Когда удал.</B></FONT></TD>" skip
    "</TR>" skip.

for each t-tarifex break by t-tarifex.stat by t-tarifex.cif by t-tarifex.kont by t-tarifex.pakalp:

    if first-of(t-tarifex.stat) then do:
     case t-tarifex.stat:
          when 'r' then v-stat = 'Д Е Й С Т В У Ю Щ И Е'.
          when 'c' then v-stat = 'И З М Е Н Е Н Н Ы Е'.
          when 'n' then v-stat = 'Д О Б А В Л Е Н Н Ы Е'.
          when 'd' then v-stat = 'У Д А Л Е Н Н Ы Е'.
          when 'a' then v-stat = 'А Р Х И В Н Ы Е'.
     end case.
     put stream vcrpt unformatted 
       "<TR align=""center"" bgcolor=""#C0C0C0"">" skip
        "<TD colspan=""16""><FONT size=""3""><B>" v-stat "</B></FONT></TD>" skip
       "</TR>" skip.
    end.
   
   find first tarif2 where tarif2.str5 = t-tarifex.str5 no-lock no-error.
   
   put stream vcrpt unformatted 
   "<TR align=""center"">" skip
     "<TD><FONT size=""2"">" + t-tarifex.cif + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-tarifex.str5 + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + if avail tarif2 then tarif2.punkt else "" + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-tarifex.kont) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-tarifex.pakalp + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-tarifex.crc) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-tarifex.ost) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-tarifex.proc) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-tarifex.min1) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-tarifex.max1) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-tarifex.who    + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + if t-tarifex.whn = ? then "" else string(t-tarifex.whn, "99/99/99") + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-tarifex.akswho + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + if t-tarifex.akswhn = ? then "" else string(t-tarifex.akswhn, "99/99/99") + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-tarifex.delwho + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + if t-tarifex.delwhn = ? then "" else string(t-tarifex.delwhn, "99/99/99") + "</FONT></TD>" skip
   "</TR>" skip.

end.

put stream vcrpt unformatted  
"</TABLE>" skip.

end. /* if avail t-tarif */

/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   T A R I F E X 2   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
find first t-tarifex2 no-lock no-error.
if avail t-tarifex2 then do:


put stream vcrpt unformatted 
   "<P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Исключения по клиентам с разбивкой по счетам</B></FONT></P>" 
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.
put stream vcrpt unformatted 
    "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>Клиент</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Код</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Пункт</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Сч.клиента</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Счет ГК</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Услуга</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Вал</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Сумма</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>%</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Мин</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Макс</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Изменил</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Когда изм.</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Акцептовал</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Когда акц.</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Удалил</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Когда удал.</B></FONT></TD>" skip
    "</TR>" skip.

for each t-tarifex2 break by t-tarifex2.stat by t-tarifex2.cif by t-tarifex2.kont by t-tarifex2.pakalp:

    if first-of(t-tarifex2.stat) then do:
     case t-tarifex2.stat:
          when 'r' then v-stat = 'Д Е Й С Т В У Ю Щ И Е'.
          when 'c' then v-stat = 'И З М Е Н Е Н Н Ы Е'.
          when 'n' then v-stat = 'Д О Б А В Л Е Н Н Ы Е'.
          when 'd' then v-stat = 'У Д А Л Е Н Н Ы Е'.
          when 'a' then v-stat = 'А Р Х И В Н Ы Е'.
     end case.
     put stream vcrpt unformatted 
       "<TR align=""center"" bgcolor=""#C0C0C0"">" skip
        "<TD colspan=""17""><FONT size=""3""><B>" v-stat "</B></FONT></TD>" skip
       "</TR>" skip.
    end.
   
   find first tarif2 where tarif2.str5 = t-tarifex2.str5 no-lock no-error.
   
   put stream vcrpt unformatted 
   "<TR align=""center"">" skip
     "<TD><FONT size=""2"">" + t-tarifex2.cif + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-tarifex2.str5 + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + if avail tarif2 then tarif2.punkt else "" + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-tarifex2.aaa + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-tarifex2.kont) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-tarifex2.pakalp + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-tarifex2.crc) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-tarifex2.ost) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-tarifex2.proc) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-tarifex2.min1) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(t-tarifex2.max1) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-tarifex2.who    + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + if t-tarifex2.whn = ? then "" else string(t-tarifex2.whn, "99/99/99") + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-tarifex2.akswho + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + if t-tarifex2.akswhn = ? then "" else string(t-tarifex2.akswhn, "99/99/99") + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + t-tarifex2.delwho + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + if t-tarifex2.delwhn = ? then "" else string(t-tarifex2.delwhn, "99/99/99") + "</FONT></TD>" skip
   "</TR>" skip.

end.

put stream vcrpt unformatted  
"</TABLE>" skip.

end. /* if avail t-tarif */



{html-end.i "stream vcrpt" }

output stream vcrpt close.

unix silent value("cptwin vcreestr.htm iexplore").

pause 0.
