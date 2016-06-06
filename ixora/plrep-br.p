/* plrep-br.p
 * MODULE
          Платежная система
 * DESCRIPTION
          Отчет по платежам на очереди F V2 8А для филиалов
 * RUN
          Способ вызова программы, описание параметров, примеры вызова
 * CALLER
          Список процедур, вызывающих этот файл 
 * SCRIPT
          Список скриптов, вызывающих этот файл
 * INHERIT
          rmzmonr1.p
 * MENU
          8-3-14
 * AUTHOR
          01.06.06 ten
 * CHANGES
*/

{global.i}
define variable v-type as integer no-undo.
define variable v-date as date no-undo.
def var mesgdt as char no-undo.
define button brnew.
define button bprit.
define button bexit.
define button brems.
define button bmail.
def var v-fname as character format "x(16)" no-undo.
define frame totf with no-labels centered row 19 overlay.
define frame ctrlf 
brnew label "Обновить"
bprit label "Печать"
brems label "Платежи"
bexit label "Выход"
bmail label "         Почта"
with no-box centered row 22 overlay.

define variable name as character extent 4 initial ["Обычные                ",
                                                    "Пенсионные             ",
                                                    "Интернет               ",
                                                    "Инкассовые             "] .
def var v-amt as dec format ">>>,>>>,>>>.99" no-undo.
def var v-cnt as dec no-undo.
def var v-amt1 as dec format ">>>,>>>,>>>.99" no-undo.
def var v-cnt1 as dec no-undo.
def var v-amt2 as dec format ">>>,>>>,>>>.99" no-undo.
def var v-cnt2 as dec no-undo.
def var v-name as char init "ИТОГО:" no-undo.

define var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

define new shared temp-table clrrep no-undo 
  field cdep as char format "x(25)"
  field depnamelong as char format "x(25)" label "Подразделение"
  field depnameshort as char format "x(14)".

define temp-table t-rep  no-undo
        field type  as integer /* 1-обычные, 2-пенсионки, 3-интернет, 4-инкассовые */ 
        field cover as integer 
        field bank   like remtrz.sbank
        field cnt   as integer initial 0  format ">>>" 
        field cnt1   as integer initial 0  format ">>>" 
        field amt   as decimal format ">>>,>>>,>>>,>>>.99" 
        field amt1   as decimal format ">>>,>>>,>>>,>>>.99" .

def buffer btrep for t-rep.

v-fname = "rpt.htm".
run sel ("Выберите тип отчета", "1. Текущая дата валюлирования|" +
                                "2. Будущая дата валютирования").

case return-value:
   when "1" then v-date = today .
   when "2" then v-date = today + 1.
end.

on choose of brnew in frame ctrlf do:

for each t-rep :
  cnt = 0.
  amt = 0.
  cnt1 = 0. 
  amt1 = 0.
end.
v-amt = 0.
v-amt1 = 0.
v-amt2 = 0.
v-cnt = 0.
v-cnt1 = 0.
v-cnt2 = 0.
if v-date = today then do:
for each que where que.pid = "F" or que.pid = "8A" no-lock .
   find remtrz of que no-lock no-error .
   if available remtrz then do:
      if remtrz.valdt2 <> v-date then next.
      if remtrz.rcbank = "TXB00" and remtrz.cover <= 2 then do:
         case remtrz.source:
              when "PNJ" then v-type = 2.
              when "IBH" then v-type = 3.
              when "INK" then v-type = 4.
              otherwise v-type = 1.
         end case.
         find t-rep where t-rep.type = v-type no-lock no-error .
         if not available t-rep then create t-rep .
         assign t-rep.type  = v-type
                t-rep.cover = remtrz.cover
                t-rep.bank = remtrz.sbank.
         if remtrz.cover = 1 then do: t-rep.amt   = t-rep.amt + remtrz.amt.  t-rep.cnt   = t-rep.cnt + 1. end.
                             else do: t-rep.amt1 = t-rep.amt1 + remtrz.amt.  t-rep.cnt1   = t-rep.cnt1 + 1. end.
      end.
   end.
end.
end.
else do:
for each que where que.pid = "V2" or que.pid = "8A" no-lock .
   find remtrz of que no-lock no-error .
   if available remtrz then do:
      if remtrz.valdt2 <> v-date then next.
      if remtrz.rcbank = "TXB00" and remtrz.cover <= 2 then do:
         case remtrz.source:
              when "PNJ" then v-type = 2.
              when "IBH" then v-type = 3.
              when "INK" then v-type = 4.
              otherwise v-type = 1.
         end case.
         find t-rep where t-rep.type = v-type no-lock no-error .
         if not available t-rep then create t-rep .
         assign t-rep.type  = v-type
                t-rep.cover = remtrz.cover
                t-rep.bank = remtrz.sbank.
         if remtrz.cover = 1 then do: t-rep.amt   = t-rep.amt + remtrz.amt.  t-rep.cnt   = t-rep.cnt + 1. end.
                             else do: t-rep.amt1 = t-rep.amt1 + remtrz.amt.  t-rep.cnt1   = t-rep.cnt1 + 1. end.
      end.
   end.
end.
end.
/*output to rep.img .*/
for each t-rep no-lock break by t-rep.type .
   displ 
      name[t-rep.type] format "x(14)" label "Подразделение"
      string(t-rep.amt, ">,>>>,>>>,>>9.99") + "/" + string(t-rep.cnt)
      format "x(21)" label "      LB   сумма/к-во" at 16
      string(t-rep.amt1, ">,>>>,>>>,>>9.99") + "/" + string(t-rep.cnt1)
      format "x(21)" label "     LBG   сумма/к-во"at 37
      string(t-rep.amt + t-rep.amt1, ">,>>>,>>>,>>9.99") + "/" + string(t-rep.cnt + t-rep.cnt1)
      format "x(21)" label "   ВСЕГО   сумма/к-во" at 58 with 14 down frame repf.
      v-amt1 = v-amt1 + t-rep.amt.
      v-amt2 = v-amt2 + t-rep.amt1.
      v-cnt1 = v-cnt1 + t-rep.cnt.
      v-cnt2 = v-cnt2 + t-rep.cnt1.
      v-amt = v-amt + t-rep.amt + t-rep.amt1.
      v-cnt = v-cnt + t-rep.cnt + t-rep.cnt1.
end.
     displ "Итого" format "x(14)"
     string(v-amt1, ">,>>>,>>>,>>9.99") + "/" + string(v-cnt1) 
     format "x(21)" at 16
     string(v-amt2, ">,>>>,>>>,>>9.99") + "/" + string(v-cnt2)
     format "x(21)" at 37
     string(v-amt, ">,>>>,>>>,>>9.99") + "/" + 
     string(v-cnt)
     format "x(21)" at 58
     with frame totf.
     pause 0.
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
 run mail(trim(sysc.chval), "TEXAKABANK <" + g-ofc + "@elexnet.kz>", mesgdt, mesgdt , "1", "", "rpt.html").
end.

on choose of brems in frame ctrlf do:
   for each clrrep: delete clrrep. end.
   for each t-rep where (cnt > 0 or cnt1 > 0):
      create clrrep.
             clrrep.cdep = string(t-rep.type).
             clrrep.depnamelong = name[t-rep.type].
             clrrep.depnameshort = name[t-rep.type].
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
      if v-date = today then do:
         run rmzmonr1.p (clrrep.cdep, v-date) "remtrz.payment" "que" "pid = ""F"" or pid = ""8A"" "  "que.remtrz" " " "1".
         run rmzmonr1.p (clrrep.cdep, v-date) "remtrz.payment" "que" "pid = ""F"" or pid = ""8A"" " "que.remtrz" "append" "2".
      end.
      else do:
         run rmzmonr1.p (clrrep.cdep, v-date) "remtrz.payment" "que" "pid = ""V2"" or pid = ""8A"" "  "que.remtrz" " " "1".
         run rmzmonr1.p (clrrep.cdep, v-date) "remtrz.payment" "que" "pid = ""V2"" or pid = ""8A"" " "que.remtrz" "append" "2".
      end.
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

procedure rptfile.
v-amt = 0.
v-amt1 = 0.
v-amt2 = 0.
v-cnt = 0.
v-cnt1 = 0.
v-cnt2 = 0.

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

for each t-rep where (t-rep.amt > 0 or t-rep.amt1 > 0):
      v-amt1 = v-amt1 + t-rep.amt.
      v-amt2 = v-amt2 + t-rep.amt1.
      v-cnt1 = v-cnt1 + t-rep.cnt.
      v-cnt2 = v-cnt2 + t-rep.cnt1.
      v-amt = v-amt + t-rep.amt + t-rep.amt1.
      v-cnt = v-cnt + t-rep.cnt + t-rep.cnt1.


 put "<tr><td align=left>"
 name[t-rep.type] format "x(30)" "</td><td align=right><nobr>"
 trim(string(t-rep.amt, ">,>>>,>>>,>>9.99")) + "/<b>" + string(t-rep.cnt) + "</b>"
 format "x(30)" "</nobr></td><td align=right><nobr>"
 trim(string(t-rep.amt1, ">,>>>,>>>,>>9.99")) + "/<b>" + string(t-rep.cnt1) + "</b>"
 format "x(30)" "</nobr></td><td align=right><nobr>"
 trim(string(t-rep.amt + t-rep.amt1, ">,>>>,>>>,>>9.99")) + "/<b>" + string(t-rep.cnt + t-rep.cnt1) + "</b>"
 format "x(30)" "</nobr></td></tr>"skip.
end.

put unformatted skip 
 "<tr><td>Итого</td><td align=right><b><nobr>" 
 trim(string(v-amt1 ,">,>>>,>>>,>>9.99")) + " / " + string(v-cnt1) format "x(30)" 
 "</b></nobr></td><td align=right><b><nobr>"
 trim(string(v-amt2,">,>>>,>>>,>>9.99")) + " / " + string(v-cnt2) format "x(30)" 
 "</b></nobr></td><td align=right><b><nobr>"
 trim(string(v-amt,">,>>>,>>>,>>9.99")) + " / " + string(v-cnt) format "x(30)"
 "</nobr></b></td></tr></table><br></body></html>"
 skip.

output close.

end.

enable all with frame ctrlf.
apply "choose" to brnew.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
