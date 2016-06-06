/* rmzmonf.i
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

procedure rptfile.
   unix silent('rm -f rpt.*').
   output to value(v-fname).
   put unformatted 
   "<HTML><HEAD><TITLE>" + mesgdt + "</TITLE>" skip
   "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
   "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
   "<STYLE TYPE=""text/css"" ID=""default""> " 
   "table \{font:Arial Cyr,sans\;font-size:x-small\;border-collapse:collapse\;align:left\;empty-cells:show\;valign:top}" skip
   "</STYLE></HEAD><BODY>" skip
   "<P align=left><FONT size=3 face='Arial cyr, sans'>" skip  mesgdt "<br><br>"skip
   skip "Исполнитель: <b>" + userid + " </b></p>" skip
   "<Table width=450 border=1><tr><th>Подразделение</th><th><nobr>LB, сумма/к-во</nobr></th>" skip
   "<th><nobr>LBG, сумма/к-во</nobr></th><th><nobr>ВСЕГО, сумма/к-во</nobr></th></tr>" skip.

   for each rep where (lb-cnt > 0 or lbg-cnt > 0):
       accumulate lb-sum (total).
       accumulate lb-cnt (total).
       accumulate lbg-sum (total).
       accumulate lbg-cnt (total).
       accumulate lb-sum + lbg-sum (total).
       accumulate lb-cnt + lbg-cnt (total).
      
       put "<tr><td align=left>"
       depnamelong format "x(30)" "</td><td align=right><nobr>"
       trim(string(lb-sum, ">,>>>,>>>,>>9.99")) + '/<b>' + string(lb-cnt) + '</b>'
       format "x(30)" "</nobr></td><td align=right><nobr>"
       trim(string(lbg-sum, ">,>>>,>>>,>>9.99")) + '/<b>' + string(lbg-cnt) + '</b>'
       format "x(30)" "</nobr></td><td align=right><nobr>"
       trim(string(lb-sum + lbg-sum, ">,>>>,>>>,>>9.99")) + '/<b>' + string(lb-cnt + lbg-cnt) + '</b>'
       format "x(30)" "</nobr></td></tr>"skip.
   end.
   
   put unformatted skip 
   "<tr><td>Итого</td><td align=right><b><nobr>" 
   trim(string(accum total lb-sum,">,>>>,>>>,>>9.99")) + ' / ' + string(accum total lb-cnt) format "x(30)" 
   "</b></nobr></td><td align=right><b><nobr>"
   trim(string(accum total lbg-sum,">,>>>,>>>,>>9.99")) + ' / ' + string(accum total lbg-cnt) format "x(30)" 
   "</b></nobr></td><td align=right><b><nobr>"
   trim(string(accum total lb-sum + lbg-sum,">,>>>,>>>,>>9.99")) + ' / ' + string(accum total lb-cnt + lbg-cnt) format "x(30)"
   "</nobr></b></td></tr></table><br></body></html>"
   skip.
   
   output close.

  /* Может пригодиться для текстового файла 
  output to rpt.img.
  put unformatted 
  mesgdt skip
  today skip
  string(time, "HH:MM:SS") skip "Исполнитель: " userid skip(1).
  put unformatted  fill("-", 93) skip
  "|     Подразделение       |     LB    сумма/к-во|    LBG    сумма/к-во|    ВСЕГО  сумма/к-во|" skip fill("-", 93) skip.

  for each rep where (lb-cnt > 0 or lbg-cnt > 0):
    accumulate lb-sum (total).
    accumulate lb-cnt (total).
    accumulate lbg-sum (total).
    accumulate lbg-cnt (total).
    accumulate lb-sum + lbg-sum (total).
    accumulate lb-cnt + lbg-cnt (total).

    put "|"
      depnamelong format "x(25)" "|"
      string(lb-sum, ">,>>>,>>>,>>9.99") + '/' + string(lb-cnt)
      format "x(21)" "|"
      string(lbg-sum, ">,>>>,>>>,>>9.99") + '/' + string(lbg-cnt)
      format "x(21)" "|"
      string(lb-sum + lbg-sum, ">,>>>,>>>,>>9.99") + '/' + string(lb-cnt + lbg-cnt)
      format "x(21)" "|"skip.
  end.

  put unformatted fill("-", 93) skip "|" "Итого" format "x(25)" "|"
    string(accum total lb-sum, ">,>>>,>>>,>>9.99") + '/' + string(accum total lb-cnt)
    format "x(24)" "|"
    string(accum total lbg-sum, ">,>>>,>>>,>>9.99") + '/' + string(accum total lbg-cnt)
    format "x(24)" "|"
    string(accum total lb-sum + lbg-sum, ">,>>>,>>>,>>9.99") + '/' +
    string(accum total lb-cnt + lbg-cnt)
    format "x(24)" "|" skip fill("-", 93).
  output close.
*/
end.
