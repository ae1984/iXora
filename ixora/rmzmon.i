/* rmzmon.i
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
                   koval    - Объединил программки lbmon, stmon, v1v2mon, st2mon в этот геморройный файл 
        10.10.2003 nadejda  - изменила создание списка департаментов для интернет-платежей - теперь берется из codfr
        15.10.2003 nadejda  - убрала отсюда создание списка департаментов в rmzmont.i и сделала его вызов в rmzmon1.p
        05.01.2005 tsoy     - добавил печать 31 и Е
        29.03.2005 kanat    - добавил отчеты по очереди выгружаемых платежей DRLB и DRPR
        07.04.2005 kanat    - добавил отчеты по очереди выгружаемых платежей DRSTW
        19.04.2005 kanat    - добавил отчеты по очереди выгружаемых платежей DRLBG
*/

define button brnew.
define button bprit.
define button bexit.
define button brems.
define button bmail.
define frame totf with no-labels centered row 19 overlay.
define frame ctrlf 
brnew label "Обновить"
bprit label "Печать"
brems label "Платежи"
bexit label "Выход"
bmail label "         Почта"
with no-box centered row 22 overlay.

on choose of brnew in frame ctrlf do:

for each rep :
  lb-cnt = 0.
  lb-sum = 0.

  lbg-cnt = 0. 
  lbg-sum = 0.
end.

case QQ:
 when "LB,LBG" then do:
  for each que no-lock where que.pid = "LB" or que.pid begins "LB-" or que.pid begins "LBG" :
    s-remtrz = que.remtrz.
    {rmzmonc.i 
        &lb  = " que.pid = 'LB' or que.pid begins 'LB-' "
        &lbg = " que.pid begins 'LBG' "
    }
  end.
 end.
 when "V1,V2"  then do:
  for each que no-lock where que.pid = "v2" or  que.pid = "v1" :
    s-remtrz = que.remtrz.
    {rmzmonc.i 
        &lb  = " remtrz.cover = 1 "
        &lbg = " remtrz.cover = 2 "
    }
  end.
 end.
 when "STW"   then do:
  for each que no-lock where pid="STW" and (que.npar matches "*Last PID = LB" or que.npar matches "*Last PID = LB-*" or can-find(first remtrz where remtrz = que.remtrz and cover = 1 no-lock)  or que.npar matches "*Last PID = LBG*" or can-find(first remtrz where remtrz = que.remtrz and cover = 2 no-lock)) :
    s-remtrz = que.remtrz.
    {rmzmonc.i 
        &lb  = "que.npar matches '*Last PID = LB' or que.npar matches '*Last PID = LB-*' or can-find(first remtrz where remtrz = que.remtrz and cover = 1 no-lock) "
        &lbg = "que.npar matches '*Last PID = LBG*' or can-find(first remtrz where remtrz = que.remtrz and cover = 2 no-lock) "
    }
  end.
 end.
 when "ST2"   then do:
  for each que no-lock where pid="ST2" and (que.npar matches "*Last PID = LB" or que.npar matches "*Last PID = LB-*" or can-find(first remtrz where remtrz = que.remtrz and cover = 1 no-lock)  or que.npar matches "*Last PID = LBG*" or can-find(first remtrz where remtrz = que.remtrz and cover = 2 no-lock)) :
    s-remtrz = que.remtrz.
    {rmzmonc.i 
        &lb  = "que.npar matches '*Last PID = LB' or que.npar matches '*Last PID = LB-*' or can-find(first remtrz where remtrz = que.remtrz and cover = 1 no-lock) "
        &lbg = "que.npar matches '*Last PID = LBG*' or can-find(first remtrz where remtrz = que.remtrz and cover = 2 no-lock) "
    }
  end.
  end.
 
  when "31"  then do:
   for each que no-lock where que.pid = "31":
     s-remtrz = que.remtrz.
     find remtrz where remtrz.remtrz = s-remtrz and lookup(remtrz.ptype,  "2,6,N") > 0 no-lock no-error.
     if avail remtrz then do:
         {rmzmonc.i 
             &lb  = " remtrz.cover = 1 "
             &lbg = " remtrz.cover = 2 "
         }
     end.

   end.
  end.

 when "E"  then do:
  for each que no-lock where que.pid = "E":
    s-remtrz = que.remtrz.
     find remtrz where remtrz.remtrz = s-remtrz and lookup(remtrz.ptype,  "2,6,N") > 0 no-lock no-error.
     if avail remtrz then  do:
         {rmzmonc.i 
             &lb  = " remtrz.cover = 1 "
             &lbg = " remtrz.cover = 2 "
         }
      end.
  end.
 end.

 when "DRLB"  then do:
  for each que no-lock where que.pid = "DRLB":
    s-remtrz = que.remtrz.
     find remtrz where remtrz.remtrz = s-remtrz and lookup(remtrz.ptype,  "2,6") > 0 no-lock no-error.
     if avail remtrz then  do:
         {rmzmonc.i 
             &lb  = " remtrz.cover = 1 "
             &lbg = " remtrz.cover = 2 "
         }
      end.
  end.
 end.

 when "DRPR"  then do:
  for each que no-lock where que.pid = "DRPR":
    s-remtrz = que.remtrz.
     find remtrz where remtrz.remtrz = s-remtrz and lookup(remtrz.ptype,  "2,6") > 0 no-lock no-error.
     if avail remtrz then  do:
         {rmzmonc.i 
             &lb  = " remtrz.cover = 1 "
             &lbg = " remtrz.cover = 2 "
         }
      end.
  end.
 end.

 when "DRLBG" then do:
  for each que no-lock where que.pid = "DRLBG":
    s-remtrz = que.remtrz.
     find remtrz where remtrz.remtrz = s-remtrz and lookup(remtrz.ptype,  "2,6") > 0 no-lock no-error.
     if avail remtrz then do:
         {rmzmonc.i 
             &lb  = " remtrz.cover = 1 "
             &lbg = " remtrz.cover = 2 "
         }
     end.
  end.
 end.

 when "DRSTW"  then do:
  for each que no-lock where que.pid = "DRSTW":
    s-remtrz = que.remtrz.
     find remtrz where remtrz.remtrz = s-remtrz and lookup(remtrz.ptype,  "2,6") > 0 no-lock no-error.
     if avail remtrz then  do:
         {rmzmonc.i 
             &lb  = " remtrz.cover = 1 "
             &lbg = " remtrz.cover = 2 "
         }
      end.
  end.
 end.

 when "ST5"   then do:
      run stpjou.
      apply "window-close" to CURRENT-WINDOW.
 end.
end case.

mesgdt = "Отчет о состоянии исходящих платежей (" + QQ + ") на " + string(today, "99/99/99") + " " + string(time, "HH:MM:SS").

for each rep where (lb-cnt > 0 or lbg-cnt > 0) :
  accumulate lb-sum (total).
  accumulate lb-cnt (total).
  accumulate lbg-sum (total).
  accumulate lbg-cnt (total).
  accumulate lb-sum + lbg-sum (total).
  accumulate lb-cnt + lbg-cnt (total).

  displ 
    rep.depnameshort  format "x(14)" label "Подразделение"
    string(lb-sum, ">,>>>,>>>,>>9.99") + "/" + string(lb-cnt)
    format "x(21)" label "      LB   сумма/к-во" at 16
    string(lbg-sum, ">,>>>,>>>,>>9.99") + "/" + string(lbg-cnt)
    format "x(21)" label "     LBG   сумма/к-во"at 37
    string(lb-sum + lbg-sum, ">,>>>,>>>,>>9.99") + "/" + string(lb-cnt + lbg-cnt)
    format "x(21)" label "   ВСЕГО   сумма/к-во" at 58 with 14 down frame repf.
end.
pause 0.

if  QQ <> "ST5" then do:
     displ "Итого" format "x(14)"
     string(accum total lb-sum, ">,>>>,>>>,>>9.99") + "/" + string(accum total lb-cnt) 
     format "x(21)" at 16
     string(accum total lbg-sum, ">,>>>,>>>,>>9.99") + "/" + string(accum total lbg-cnt)
     format "x(21)" at 37
     string(accum total lb-sum + lbg-sum, ">,>>>,>>>,>>9.99") + "/" + 
     string(accum total lb-cnt + lbg-cnt)
     format "x(21)" at 58
     with frame totf.
     pause 0.
end.
end.

on choose of brems in frame ctrlf do:
   for each clrrep: delete clrrep. end.
   for each rep where (lb-cnt > 0 or lbg-cnt > 0):
     create clrrep.
     clrrep.cdep = rep.cdep.
     clrrep.depnamelong = rep.depnamelong.
     clrrep.depnameshort = rep.depnameshort.
   end.

   def query q1 for clrrep.
   
   def browse b1 
       query q1 no-lock
       display 
           clrrep.depnamelong no-label
           with 14 down title "Выберите департамент".

   def frame fr1 
       b1
       with no-labels centered overlay view-as dialog-box.

   on return of b1 in frame fr1 do:
       case QQ:
            when "LB,LBG" then do:
                run rmzmonr.p (clrrep.cdep,QQ) "remtrz.payment" "que" "pid = ""lb"" "  "que.remtrz".
                run rmzmonr.p (clrrep.cdep,QQ) "remtrz.payment" "que" "pid = ""lbg"" " "que.remtrz" "append".
            end.
            when "STW" then do:
                run rmzmonr.p (clrrep.cdep,QQ) "clrdoc.amt" "clrdoc" "rdt=dt" "clrdoc.rem" "" "tdate = clrdoc.rdt.".
                run rmzmonr.p (clrrep.cdep,QQ) "clrdog.amt" "clrdog" "rdt=dt" "clrdog.rem" "append" "tdate = clrdog.rdt.".
            end.
            when "ST2" then do:
                run rmzmonr.p (clrrep.cdep,QQ) "remtrz.payment" "que" "pid=""ST2"" " "que.remtrz".
            end.
            when "V1,V2" then do:
                run rmzmonr.p (clrrep.cdep,QQ) "remtrz.payment" "que" "pid=""v1"" " "que.remtrz".
                run rmzmonr.p (clrrep.cdep,QQ) "remtrz.payment" "que" "pid=""v2"" " "que.remtrz" "append".
            end.
            when "31" then do:
                run rmz31e (clrrep.cdep,QQ).
            end.
            when "E" then do:
                message "E" view-as alert-box title "Внимание".
                run rmz31e (clrrep.cdep,QQ).
            end.
            when "DRLB" then do:
                run rmz31e (clrrep.cdep,QQ).
            end.
            when "DRPR" then do:
                run rmz31e (clrrep.cdep,QQ).
            end.
            when "DRLBG" then do:
                run rmz31e (clrrep.cdep,QQ).
            end.
            when "DRSTW" then do:
                run rmz31e (clrrep.cdep,QQ).
            end.

       end case.    

       hide frame fr1 no-pause.
       run menu-prt("rpt.txt").
       
       open query q1 for each clrrep.
       enable all with frame fr1. 
   end.

   open query q1 for each clrrep.
   ENABLE all with frame fr1.
   apply "value-changed" to b1 in frame fr1.
   WAIT-FOR endkey of frame fr1.
   hide frame fr1 no-pause.
end.

on choose of bexit in frame ctrlf do:
    apply "window-close" to CURRENT-WINDOW.
end.

on choose of bprit in frame ctrlf do:
 apply "choose" to brnew.
 run rptfile.
 run menu-prt (v-fname).
end.

on choose of bmail in frame ctrlf do:
 run rptfile. 
 unix silent un-win value(v-fname) rpt.html.
 find sysc where sysc.sysc = "lbmail" no-lock no-error.
 run mail(trim(sysc.chval), "МЕТРОКОМБАНК <" + g-ofc + "@metrocombank.kz>", mesgdt, mesgdt , "1", "", "rpt.html").
end.

procedure rptfile.
unix silent("rm -f rpt.*").
output to value(v-fname).
   put unformatted 
   "<HTML><HEAD><TITLE>" + mesgdt + "</TITLE>" skip
   "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
   "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
   "<STYLE TYPE=""text/css"" ID=""default""> " 
   "table \{font:Arial Cyr,sans\;font-size:x-small\;border-collapse:collapse\;align:left\;empty-cells:show\;valign:top}" skip
   "</STYLE></HEAD><BODY>" skip
   "<P align=left><FONT size=3 face='Arial cyr, sans'>" skip  mesgdt "<br><br>"skip
   skip "Исполнитель: <b>" + g-ofc + " </b></p>" skip
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
 trim(string(lb-sum, ">,>>>,>>>,>>9.99")) + "/<b>" + string(lb-cnt) + "</b>"
 format "x(30)" "</nobr></td><td align=right><nobr>"
 trim(string(lbg-sum, ">,>>>,>>>,>>9.99")) + "/<b>" + string(lbg-cnt) + "</b>"
 format "x(30)" "</nobr></td><td align=right><nobr>"
 trim(string(lb-sum + lbg-sum, ">,>>>,>>>,>>9.99")) + "/<b>" + string(lb-cnt + lbg-cnt) + "</b>"
 format "x(30)" "</nobr></td></tr>"skip.
end.

put unformatted skip 
 "<tr><td>Итого</td><td align=right><b><nobr>" 
 trim(string(accum total lb-sum,">,>>>,>>>,>>9.99")) + " / " + string(accum total lb-cnt) format "x(30)" 
 "</b></nobr></td><td align=right><b><nobr>"
 trim(string(accum total lbg-sum,">,>>>,>>>,>>9.99")) + " / " + string(accum total lbg-cnt) format "x(30)" 
 "</b></nobr></td><td align=right><b><nobr>"
 trim(string(accum total lb-sum + lbg-sum,">,>>>,>>>,>>9.99")) + " / " + string(accum total lb-cnt + lbg-cnt) format "x(30)"
 "</nobr></b></td></tr></table><br></body></html>"
 skip.

output close.

/*
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
      string(lb-sum, ">,>>>,>>>,>>9.99") + "/" + string(lb-cnt)
      format "x(21)" "|"
      string(lbg-sum, ">,>>>,>>>,>>9.99") + "/" + string(lbg-cnt)
      format "x(21)" "|"
      string(lb-sum + lbg-sum, ">,>>>,>>>,>>9.99") + "/" + string(lb-cnt + lbg-cnt)
      format "x(21)" "|"skip.
  end.

  put unformatted fill("-", 93) skip "|" "Итого" format "x(25)" "|"
    string(accum total lb-sum, ">,>>>,>>>,>>9.99") + "/" + string(accum total lb-cnt)
    format "x(24)" "|"
    string(accum total lbg-sum, ">,>>>,>>>,>>9.99") + "/" + string(accum total lbg-cnt)
    format "x(24)" "|"
    string(accum total lb-sum + lbg-sum, ">,>>>,>>>,>>9.99") + "/" +
    string(accum total lb-cnt + lbg-cnt)
    format "x(24)" "|" skip fill("-", 93).
  output close.
*/
end.
if  QQ <> "ST5" then do:
   enable all with frame ctrlf.
end.
apply "choose" to brnew.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.

