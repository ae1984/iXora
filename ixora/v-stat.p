/* v-stat.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       29/08/06 u00121 заменил nawk на awk
*/

def temp-table scan field  scan as cha extent 2 .
def var dd as int . 
def var v-nwt as int  .
def var tpause as int . 
def var del as log .
def var leav as log .
def var i as int .
def var rold like dproc.pid . 
def var ttt as int . 
 {mainhead.i "PSMAN " "NEW GLOBAL" }  
 {ps-prmt.i}        
def var rsts like que.pid . 
def var nnn as cha .
def var vv as cha format "x(1)" .
def var v-pause as int .
def new shared var s-remtrz like que.remtrz.
def var s-remtrzR like que.remtrz.
def var s-quepid like fproc.pid .
def var s-quetyp like ptyp.ptype .
def var tmp as cha.
def new shared frame pid.
def var v-pid like que.pid.

def new shared var v-log as cha .
def var v-copy as integer.
{lgps.i "new" }
m_pid = "PS_".
u_pid = "v-stat".

def temp-table sts field pid like que.pid
  field nw as int initial ? field np as int field nf as int
  field nwt as int field npt as int field nft as int
  field nwtn as int field nptn as int field nftn as int.
def var cikl as int.
def new shared var idle as cha .
def var ifi as int.
def var swt as cha .
def var spt as cha .
def var sft as cha .
def new shared var h as int .
def var s-date as date .
def var s-time as int .
def var hp as int .
def var l-leave as log .
s-date = today .
s-time = time .
vv = "-" .
h  = 13 .
hp = 13 .


find sysc where sysc.sysc = "ps-cls" no-lock no-error .
if not avail sysc or string(sysc.daval) = ? then do:
 message " There isn't record PS-CLS in sysc file !!".
 bell. bell.
 pause .   return .
end.
find last cls .
if not ( cls.cls eq sysc.daval) then do:
 display " WARNING !!! Last PS CLOSED day is : " +
   string(sysc.daval) format "x(46)" skip(0)
 " and it doesn't match with PLATON closed day !! " with centered
   row 10  frame warn . bell . bell .
   pause .
   hide frame warn .
 end .

tpause = 100  . 

form
 " " sts.pid  column-label "Que"
 sts.nw label " Wait " format "zzz9" dd format "zz9" 
 label "W_D" swt label "W_Time"
 sts.nf label "Finish" format "zzz9"  " " 
 with  column 3 overlay no-hide hp down frame sts1.

display " W A I T ... " with centered frame bbb . pause 0.
for each dproc where dproc.u_pid = 0 exclusive-lock .
 delete dproc .
end .

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 message " This isn't record OURBNK in sysc file !!".
 pause .
end.

m_hst = trim(sysc.chval).

find first dproc no-lock no-error .
if avail dproc then do:
input through value("ps_ls_pid " + trim(m_hst)) .

 repeat:
  create scan.
  import scan.
 end.
 input close.

for each dproc exclusive-lock .
del = true .
for each scan .
 if scan[2] begins
    trim(m_hst) + "_" +  trim(dproc.pid) + "_" + string(dproc.copy,"99")
    then do :
     if scan[1] = string(dproc.u_pid) then del = false .
     delete scan . leave .
    end.
end.
 if del then  delete dproc .
end .
release dproc .
for each scan . delete scan . end .
end.
hide frame bbb.
form " " dproc.pid column-label "Process"
 dproc.copy label "Cp" dproc.tout label "Pause"  dproc.u_pid idle
 label "  Idle " " "   with column 40 h down title m_hst overlay frame pid.
/*
view frame pid.
*/
pause 0.

rold = "" .   
rsts = "" . 

cikl = 0.
repeat :
display
  "F1 - PS MANAGER HELP , F2 - PLATON HELP "
    with row 21 column 5 no-box centered frame mm.
 pause 0 .
/*  
 display
 "H - log , J - quest , P/T - search by pid/type , F8/F9 - proc.start/stop."
    with row 20 column 5 no-box frame mm1.
 display
 "HOME - all proc. stop , END - exit , ^t - MONITOR STEP , F2 - help ."
    with row 21 column 5 no-box frame mm2.
   */

repeat:

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 message " This isn't record OURBNK in sysc file !!".
 pause .
end.

m_hst = trim(sysc.chval).

find sysc where sysc.sysc = "PS_LOG" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 message " This isn't record PS_LOG in sysc file !!".
 pause .
end.

v-log = trim(sysc.chval).
display "Start time =" s-date string(s-time,"hh:mm:ss")
 with no-box no-label overlay row 1 frame stime.
pause 0 .
display "Current time =" today string(time,"hh:mm:ss")
  with no-box no-label no-hide row 1 column 40 overlay frame ttt .
pause 0.
  g-fname = "PSMAN ".
  g-mdes = "    Payment System MANAGER ".

display
  g-fname g-mdes g-ofc  g-today
  with color message frame mainhead.
if rsts ne "" then find first que where que.pid > rsts 
 use-index fprc no-lock no-error .
if not avail que then do: rsts = "" . 
find first que  
 /* where que.pid ne "ARC" */
 use-index fprc no-lock no-error .
end.
ttt = time .
ifi = 0 . 
if  avail que  then do: 
 display " W A I T ..."  format "x(20)"  with row 21 no-box frame www  .
 cikl = cikl + 1.
repeat : 
 if que.pid = "ARC" then
  do:
    find last  que where que.pid = "ARC"  use-index fprc no-lock .
    find next que  use-index fprc no-lock no-error.
    if not avail que then leave .
  end .
 if que.pid = "ARC" then
   do:
      find last  que where que.pid = "ARC"  use-index fprc no-lock .
      find next que  use-index fprc no-lock no-error.
      if not avail que then leave .
  end .

  if que.pid = "F" then
    do:
        find last  que where que.pid = "F"  use-index fprc no-lock .
        find next que  use-index fprc no-lock no-error.
        if not avail que then leave .
    end .
  
 find first sts where que.pid eq sts.pid no-error.
 if not avail sts then do:
  create sts.
  sts.pid = que.pid .
  ifi = ifi + 1 .
  if ifi > hp then leave .
  sts.nw = 0 . sts.np = 0. sts.nf = 0.
  sts.nwt = 0 . sts.npt = 0. sts.nft = 0.
  sts.nwtn = 0 . sts.nptn = 0. sts.nftn = 0.
 end.
 if que.con = "W" then
   do : sts.nw = sts.nw + 1.
        sts.nwtn = sts.nwtn + 1 .
        sts.nwt = ttt - que.tf + sts.nwt + (today - que.df) * 86400 .
   end.
 else        /*
 if que.con = "P" then
   do : sts.np = sts.np + 1.
        sts.nptn = sts.nptn + 1.
        sts.npt = time - que.tw + sts.npt .
   end.
 else          */
 if que.con = "F" then
   do : sts.nf = sts.nf + 1.
        sts.nftn = sts.nftn + 1.
   end.
 find next que  use-index fprc no-lock no-error .
 if not avail que then leave .
end.
find first sts no-lock no-error . 
if avail sts then do: 
/*
clear frame  sts1 all .  */

ifi = 0.

for each sts where sts.pid >= rsts exclusive-lock break by sts.pid  .
 if sts.nw eq 0 and sts.np eq 0 and sts.nf eq 0 then delete sts . else
 do:
  dd = 0 . 
  v-nwt =  time - ttt + sts.nwt  / (sts.nw + sts.nf ) .
 repeat:
   if v-nwt < 86400 then leave .
   dd = dd + 1 .
   v-nwt = v-nwt - 86400  .
 end.
 if sts.nw ne 0 then swt = string(v-nwt ,"hh:mm:ss").
                else swt = "  ----  ".
 /*
 if sts.np ne 0 then spt = string(int(sts.npt / sts.np ),"hh:mm:ss").
                else spt = "  ----  ".
 */

 if sts.nf ne 0 then sft = string(int(sts.nft / sts.nf ),"hh:mm:ss").
                else sft = "  ----  ".
 display sts.pid sts.nw dd swt /* sts.np  spt */ sts.nf  with frame sts1.
 down with frame sts1.
 ifi = ifi + 1.
 rsts = "".
 if ifi = hp then do:
 if not last(sts.pid) then do:
   /*
   pause  3 .
ifi = i - 1 .
do i = 1 to ifi :
 up 1 with frame sts1.
end .
  ifi = 0 .      */
  rsts = sts.pid . 
  leave . 
  end .
 end.
 pause 0.
end.
end.

/*
if ifi > 0 then do:
  */
do i = ifi + 1  to hp :
 clear frame sts1 .
 down with frame sts1.
end.
ifi = i - 1 .

do i = 1 to ifi :
 up 1 with frame sts1.
end .
           /*        end.      */

/*
 else
 clear frame  sts1 all .
*/

 for each sts exclusive-lock .
  sts.nw = 0  . sts.np = 0  . sts.nf = 0.
  sts.nwt = 0 . sts.npt = 0 . sts.nft = 0.
 end.
 end.
 else  do :
    hide frame sts1.
       message " QUE is empty ..."  . pause 1 . v-pause = 1 .
 end .
 end.
 else 
 do :
   hide frame sts1. 
   message " QUE is empty ..."  . pause 1 . v-pause = 1 .
 end .


find first dproc no-lock no-error . 
if avail dproc then do:
ifi = 0.
for each dproc no-lock where dproc.pid ge rold  
                       break by dproc.pid by copy .  
 if dproc.l_time ne 0 then
   idle = string(time - dproc.l_time,"hh:mm:ss").
 else idle = "--:--:--".
 display dproc.pid dproc.copy dproc.tout dproc.u_pid idle with frame pid.
 ifi = ifi + 1.
 down with frame pid .
 v-pause = 0.
 rold = "" . 
 if ifi = h then do:
  if not last(copy) then do:
   rold = dproc.pid . 
   leave .
   /*
    pause 3 .
    ifi = i - 1 .
    do i = 1 to ifi :
     up 1 with frame pid.
    end .
    ifi = 0 .
   */
  end .
 end.
 pause 0 .
 release dproc .
 end.
 do i = ifi + 1  to h :
  clear frame pid .
  down with frame pid.
 end.

ifi = i - 1 .
do i = 1 to ifi :
 up 1 with frame pid.
end .

end . 
else hide frame pid .

if vv = "/" then vv = "\\" .
else
if vv = "\\" then vv = "-" .
else
if vv = "-" then vv = "/" .
hide frame www . 
display    tpause vv with overlay no-box no-label row 21 
frame vvv . pause 0 .

 s-remtrz = "".
 l-leave = false .
 if tpause = 0 then tpause = 1 . 
  display
    "F1 - PS MANAGER HELP , F2 - PLATON HELP "
        with row 21 column 5 no-box centered frame mm.
         pause 0 .

 readkey pause tpause  .
 hide frame mm . 
 hide frame vvv . 
/*
 display " W A I T ..." with row 21 no-box frame www  .
  */
 if keyfunction(lastkey) = "right-end" /* or
      keylabel(lastkey) = "f4"  or
      keylabel(lastkey) = "pf4" */ then return.
 pause 0 .
 if keyfunction(lastkey) ne "" then l-leave = true .
 if keylabel(lastkey) = "ctrl-l" then 
  do: 
   update tpause  label " PAUSE (sec) ? " 
    with centered row 10 side-label overlay frame tpp .     
  end. 
 if keyfunction(lastkey) = "clear" then do:
  {ps-prmtk.i}
  update v-pid v-copy
   column-label " What process to make started ? "  with frame upd.
  v-pid = caps(v-pid).
  find fproc where fproc.pid = v-pid no-lock no-error.
   if not avail fproc then do:
     message "There isn't procedure in 'fproc' file ! " .
     pause .
    end.
    else
    do:
    if search("u_pid") ne ? then
    unix silent value("u_pid " + m_hst + " " + v-pid + " " +
      string(v-copy,"99") + " " + v-log ).
      else do:
      message " u_pid scripts wasn't found !! . " . pause . end .
    end.

   clear frame upd all.
 end.

 if keylabel(lastkey) = "ctrl-p" then do:
  {ps-prmtk.i}
 v-copy = 0.
 display " All process start ... " with centered frame www1.  pause 0 .
 for each fproc where fproc.tout ne 1000 :
  pause 2 no-message .
  v-pid = caps(fproc.pid).
  if search("u_pid") ne ? then
  unix silent value("u_pid " + m_hst + " " + v-pid + " " +
   string(v-copy,"99") + " " + v-log ).
   else do:
      message " u_pid scripts wasn't found !! . " . pause . end .
 end.
 clear frame www1 .
 end.

 if keyfunction(lastkey) = "new-line" then do transaction :
  {ps-prmtk.i}
  update v-pid v-copy
   column-label " What process to make stopped ? "  with frame updb.
  v-pid = caps(v-pid).
  find dproc where dproc.pid = v-pid and dproc.copy = v-copy
   exclusive-lock no-error.
  if avail dproc then do:
   dproc.tout = 1000.
   clear frame updb all.
  end.
  release dproc .
 end.

 if keylabel(lastkey) = "h" then do:
  input through value
  ("awk -v d=" + string(today) + " '
   (index($0,d) != 0) \{print NR;exit\} ' " +
    v-log + trim(m_hst) + "_logfile.lg." + string(today,"99.99.9999"))  . /*29/08/06 u00121 заменил nawk на awk*/
   nnn = "" .
   repeat:
    import nnn .
   end.
   input close .
  if nnn = "" then nnn = "0" .
  unix value("ps_lessh " + "+" + nnn + " " +
   v-log + trim(m_hst) + "_logfile.lg." + string(today,"99.99.9999")).
  pause 0 .
 end.

 if keylabel(lastkey) = "p" then do:
  run q-quepid. 
  if keylabel(lastkey) = "cursor-up" or  keylabel(lastkey) = "cursor-down" 
     then next.
 end.

 if keyfunction(lastkey) = "go" then do:
 hide frame mm .
 display
  " All process start .......  ^P  " skip
  " Payment system setup ....   S  " skip
  " Full Protocol view ......   H  " skip
  " Protocol request ........   J  " skip
  " REMTRZ Search by queue ..   P  " skip
  " REMTRZ Search by REMTRZ..   R  " skip
  " REMTRZ Search by type ...   T  " skip
  " Process start ...........  F8  " skip
  " Process stop ............  F9  " skip
  " Platon Help .............  F2  " skip
  " Inward investigation.....  ^U  " skip
  " Outward investigation....  ^O  " skip
  " All process Stop ........ Home " skip
  " Platon Main Menu ........ END  " skip
  " LORO,NOSTRO await monitor   N  " skip
  " Rejected Payment messages   O  " skip
  " PS Manager view timeout .  ^L  " skip
  " All pids view ...........   X  " skip
  " Exit .................. END,F4 "
    with overlay row 1 centered  title " PS MANAGER HELP " frame mm2.
    pause .
    hide frame mm2 .
    view frame mm .
    pause 0 .
 end.

 if keylabel(lastkey) = "r" then do:
  update s-remtrzR with overlay centered row 10 title "REMTRZ" frame rm.
  find first remtrz where remtrz.remtrz = s-remtrzR no-lock no-error .
  if avail remtrz then do:
  s-remtrz = caps(s-remtrzR).
  hide frame rm .
  if s-remtrz ne "" and keylabel(lastkey) ne "pf4" then do:
/*  display s-remtrz .     */
  run rmz_ps.
  release remtrz.
  end.
  end.
 end.

 if keylabel(lastkey) = "t" then do:
  run h-quetyp.
  if s-remtrz ne "" and keylabel(lastkey) ne "pf4" then do:


  run rmz_ps.
  end.
 end.


 if keyfunction(lastkey) = "help" then do:
   if search( "pshelp.r") ne ? then
              do:
               hide  all .
               run pshelp.
              end.
              else
     do:
      message " Procedure pshelp wasn't found ".
      pause .
     end.
 end.

 if keyfunction(lastkey) = "x" then do:
   if search( "r-quer.r") ne ? then
              do:
               hide  all .
               run r-quer.
              end.
              else
     do:
      message " Procedure r-quep wasn't found ".
      pause .
     end.
 end.


 if keylabel(lastkey) = "ctrl-v" then do:
   if search( "midibb.r") ne ? then
              do:
               hide  all .
               run midibb .
              end.
              else
     do:
      message " Procedure 'midibb' wasn't found ".
      pause .
     end.
 end.
 if keylabel(lastkey) = "s" then do:
   if search( "psmain.r") ne ? then
              do:
               hide  all .
               run psmain.
              end.
              else
     do:
      message " Procedure psmain wasn't found ".
      pause .
     end.
 end.
 if keylabel(lastkey) = "j" then do:
   if search( "quest.r") ne ? then

              do:
               hide  all .
               run quest.
              end.
                               else
     do:
      message " Procedure quest wasn't found ".
      pause .
     end.
 end.
 if keylabel(lastkey) = "ctrl-t" then do:
  {ps-prmtk.i}
   if search( "M_ps.r") ne ? then

              do:
               message " MONITOR ....  " .
               run M_ps.
               message "".
              end.
                               else
     do:
      message " Procedure M_ps wasn't found ".
      pause .
     end.
 end.
 if keylabel(lastkey) = "ctrl-g" then do:
  {ps-prmtk.i}
   if search( "GN_ps.r") ne ? then

              do:
               message " TEST GEN ....  " .
               run GN_ps.
               message "".
              end.
                               else
     do:
      message " Procedure GN_ps wasn't found ".
      pause .
     end.
 end.

 if keylabel(lastkey) = "ctrl-b" then do:
  {ps-prmtk.i}
   if ( search( "H0_ps.r") ne ? ) and
    ( search( "qq10") ne ? )  then

              do:
               message " TEST HOME GEN ....  " .
               run H0_ps.
               message "".
              end.
                               else
     do:
      message " Procedure H0_ps or qq10 weren't found ".
      pause .
     end.
 end.
                     /*
 if keylabel(lastkey) = "ctrl-e" then do:
  {ps-prmtk.i}
   if search( "init.r") ne ? then

              do:
               hide  all .
               run init.
              end.
                               else
     do:
      message " Procedure init wasn't found ".
      pause .
     end.
 end.            */
                 
if keylabel(lastkey) = "ctrl-u" then do:
   {ps-prmtk.i}                 
   if search( "psarc.r") ne ? then

              do:
               hide  all .
               run psarc.
              end.
                               else
     do:
      message " Procedure psarc wasn't found ".
      pause .
     end.
 end.

if keylabel(lastkey) = "ctrl-o" then do:
   {ps-prmtk.i}                 
   if search( "psarco.r") ne ? then

              do:
               hide  all .
               run psarco.
              end.
                               else
     do:
      message " Procedure psarco wasn't found ".
      pause .
     end.
 end.
 
 if keylabel(lastkey) = "o" then do:
   if search( "q-reject.r") ne ? then

              do:
               hide  all .
               run q-reject.
              end.
                               else
     do:
      message " Procedure q-reject wasn't found ".
      pause .
     end.
 end.

 if keylabel(lastkey) = "n" then do:
   if search( "n.r") ne ? then

              do:
               hide  all .
               run n.
              end.
                               else
     do:
      message " Procedure n wasn't found ".
      pause .
     end.
 end.
      /*
 if keyfunction(lastkey) = "delete-line" then do:
  update v-pid v-copy
   column-label " What process to delete ? "  with frame updlb.
  v-pid = caps(v-pid).
   clear frame updlb all.
  find dproc where dproc.pid = v-pid and dproc.copy = v-copy
   exclusive-lock no-error.

  if avail dproc then do on error undo , leave :
   if dproc.tout ne 1000 then
   do:
    message " There is working process , stop it before ! " .
    pause .
    undo , leave .
   end.
   else
   do:
    delete dproc .
    clear frame pid all .
   end .
  end.
 end.
                   */

 if keyfunction(lastkey) = "cursor-up" then run manag.
 if keyfunction(lastkey) = "cursor-down" then run manag.

 if keyfunction(lastkey) = "home" then do transaction :
  {ps-prmtk.i}
  clear frame pid all.
  for each dproc with row 3 frame pid .
   dproc.tout = 1000.
  end.
 end.
/*
 clear frame mm all.
 clear frame mm1 all.
 clear frame mm2 all.     */

 if l-leave then   leave .
end.
end .
