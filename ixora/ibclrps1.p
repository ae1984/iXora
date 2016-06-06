/* ibclrps1.p
 * MODULE
       Internet Office
 * DESCRIPTION
       ОТчет по клиентам Internet Office по филиалу
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        nmenu.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR

 * CHANGES
        17/09/04 sasco добавил вывод данных: - открыт/закрыт договор
                                             - код филиала
                                             - список использованных таблиц
                       для Алматы - все клиенты, для филиалов - только филиальские

*/

{global.i}
{comm-txb.i}

define variable seltxb as char.
seltxb = comm-txb().

def var v-mname as char.

find first cmp no-lock no-error.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then 
   v-mname = ofc.name.
else do:
   v-mname = "Неизвестный офицер".
   message "Неизвестный офицер" view-as alert-box title "Внимание".
   return.
end.

output to reprts.htm.
{html-start.i}
put unformatted
   "<IMG border=""0"" src=""http://www.texakabank.kz/images/top_logo_bw.gif""><BR><BR><BR>" skip
   "<B><P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">" skip
   "Отчет по клиентам Internet Office " cmp.name "</FONT><BR><BR>" skip
   "<TABLE width=""140%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
   "<TR align=""center"" valign=""top"">" skip.

  put unformatted
     "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Филиал </B></FONT></TD>"  skip
     "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Код CIF </B></FONT></TD>"  skip
     "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Наименование клиента </B></FONT></TD>"  skip
     "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Рег.номер </B></FONT></TD>" skip
     "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Входное имя </B></FONT></TD>" skip
     "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Договор открыт? </B></FONT></TD>"  skip
     "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Блокирован? </B></FONT></TD>"  skip
     "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Использованные таблицы</B></FONT></TD>" skip
     "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Текущая таблица </B></FONT></TD>" skip
     "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Неиспользованные таблицы </B></FONT></TD>" skip
     "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Текущий ключ </B></FONT></TD>" skip
   "</TR>".

/* for each cif no-lock. --- */
for each usr where usr.bnkplc = seltxb or seltxb = "TXB00" no-lock.
    
/*    put unformatted "<TR><TD bgcolor=""#95B2D1""><B>" string(v-count) "<B></TD>" skip */
    put unformatted "<TD align=""center"">" usr.bnkplc "</TD>" skip                                    /* Филиал */
                    "<TD align=""center"">" usr.cif "</TD>" skip                                       /* CIF */
                    "<TD align=""left""><B>" REPLACE (usr.contact[1], "+", "") "</B></TD>" skip        /* ФИО */
                    "<TD align=""center"">" string(usr.id) "</TD>" skip                                /* ID */
                    "<TD align=""center"">" usr.login "</TD>" skip                                     /* логин */
                    "<TD align=""center"">" if usr.perm[6] = 0 then "+" else "<B>-</B>" "</TD>" skip   /* открыт? */
                    "<TD align=""center"">" if usr.perm[3] <> 0 then "<B>+</B>" else "-" "</TD>" skip. /* блокирован? */


                                                                                      
    put unformatted "<TD align=""center"">" skip. /* использованные таблицы ключей */
    for each  otktd no-lock where otktd.id_usr = usr.id and otktd.state = 0 use-index idx_own by otktd.tnum:
        put unformatted otktd.tnum "&nbsp;&nbsp;" skip.
    end.
    put unformatted "</TD>" skip.

    put unformatted "<TD align=""center"">" skip. /* текущие таблицы ключей */
    for each  otktd no-lock where otktd.id_usr = usr.id and otktd.state = 1 use-index idx_own by otktd.tnum:
        put unformatted otktd.tnum "&nbsp;&nbsp;" skip.
    end.
    put unformatted "</TD>" skip.

    put unformatted "<TD align=""center"">" skip. /* неиспользованные таблицы ключей */
    for each  otktd no-lock where otktd.id_usr = usr.id and otktd.state = 2 use-index idx_own by otktd.tnum:
        put unformatted otktd.tnum "&nbsp;&nbsp;" skip.
    end.
    put unformatted "</TD>" skip.

    put unformatted "<TD align=""center"">" string (usr.otk_index - 1) "</TD>" skip.                    /* тек.ключ */

    put unformatted "</TR>" skip.

end. /* usr */

/* end. --- cif */

put unformatted "</TABLE>" skip.

{html-end.i}
output close.
unix silent value("cptwin reprts.htm excel").
pause 0.

