/* rmzmx2.i
 * MODULE
        Платежная система
 * DESCRIPTION
        Вспомогательная процедура по формированию письма для отправки ведомости отправленных платежей
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
        16/05/2005 kanat
 * CHANGES
*/

procedure rptfilex.
   unix silent('rm -f rpt.*').
   output to value(v-fname).

/* клиринг или гросс по ПКО */

   put unformatted 
   "<HTML><HEAD><TITLE> Платежи системы ПКО </TITLE>" skip
   "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
   "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
   "<STYLE TYPE=""text/css"" ID=""default""> " 
   "table \{font:Arial Cyr,sans\;font-size:x-small\;border-collapse:collapse\;align:left\;empty-cells:show\;valign:top}" skip
   "</STYLE></HEAD><BODY>" skip
   "<P align=left><FONT size=3 face='Arial cyr, sans'>" skip "Платежи системы ПКО" "<br><br>"skip
   skip "Исполнитель: <b>" + userid + " </b></p>" skip
   "<Table width=450 border=1><tr><th>Подразделение</th><th><nobr>DRLB, сумма/к-во</nobr></th>" skip
   "<th><nobr>DRPR, сумма/к-во</nobr></th><th><nobr>DRLBG, сумма/кол-во</nobr></th><th><nobr>ВСЕГО, сумма/к-во</nobr></th></tr>" skip.

   for each rep where rep.drlb-cnt > 0 or rep.drpr-cnt > 0 or rep.drlbg-cnt > 0 no-lock:

       accumulate drlb-sum (total).
       accumulate drlb-cnt (total).

       accumulate drpr-sum (total).
       accumulate drpr-cnt (total).

       accumulate drlbg-sum (total).
       accumulate drlbg-cnt (total).

       accumulate drlb-sum + drpr-sum + drlbg-sum (total).
       accumulate drlb-cnt + drpr-cnt + drlbg-cnt (total).
      
       put "<tr><td align=left>"
       depnamelong format "x(30)" "</td><td align=right><nobr>"

       trim(string(drlb-sum, ">,>>>,>>>,>>9.99")) + '/<b>' + string(drlb-cnt) + '</b>'
       format "x(30)" "</nobr></td><td align=right><nobr>"

       trim(string(drpr-sum, ">,>>>,>>>,>>9.99")) + '/<b>' + string(drpr-cnt) + '</b>'
       format "x(30)" "</nobr></td><td align=right><nobr>"

       trim(string(drlbg-sum, ">,>>>,>>>,>>9.99")) + '/<b>' + string(drlbg-cnt) + '</b>'
       format "x(30)" "</nobr></td><td align=right><nobr>"

       trim(string(drlb-sum + drpr-sum + drlbg-sum, ">,>>>,>>>,>>9.99")) + '/<b>' + string(drlb-cnt + drpr-cnt + drlbg-cnt) + '</b>'
       format "x(30)" "</nobr></td></tr>"skip.
   end.
   
   put unformatted skip 
   "<tr><td>Итого</td><td align=right><b><nobr>" 

   trim(string(accum total drlb-sum,">,>>>,>>>,>>9.99")) + ' / ' + string(accum total drlb-cnt) format "x(30)" 
   "</b></nobr></td><td align=right><b><nobr>"

   trim(string(accum total drpr-sum,">,>>>,>>>,>>9.99")) + ' / ' + string(accum total drpr-cnt) format "x(30)" 
   "</b></nobr></td><td align=right><b><nobr>"

   trim(string(accum total drlbg-sum,">,>>>,>>>,>>9.99")) + ' / ' + string(accum total drlbg-cnt) format "x(30)" 
   "</b></nobr></td><td align=right><b><nobr>"

   trim(string(accum total drlb-sum + drpr-sum + drlbg-sum,">,>>>,>>>,>>9.99")) + ' / ' + string(accum total drlb-cnt + drpr-cnt + drlbg-cnt) format "x(30)"
   "</nobr></b></td></tr>" skip

   "</table><br></body></html>" skip. 
   output close.
end.
