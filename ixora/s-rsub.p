/* s-rsub.p
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
*/

/* s-rsub.p */
{global.i}

{lgps.i}
def temp-table gll field gllist as char format "x(6)" field num as 
 int format "zzzz" .
def shared var v-rsub like remtrz.rsub . 
def var i as int.
def var tt as cha.
def var h as int .
h = 0 .

find sysc where sysc.sysc = "PS_SUB" no-lock no-error.
tt = sysc.chval .
repeat :
 h = h + 1 .
 create gll .
 if index(tt,",") = 0 
  then do: gll.gllist = trim(tt) . 
   leave . 
  end .
  else 
   do: gll.gllist = substr(tt,1,index(tt,",") - 1 ).
    for each que where que.pid = m_pid and que.con = "W" no-lock  . 
      find first remtrz where remtrz.remtrz = que.remtrz no-lock . 
      if remtrz.rsub = gll.gllist then  gll.num = gll.num + 1 . 
    end.
   end . 
   tt = substr(tt,index(tt,",") + 1,length(sysc.chval)).
   if tt = "" then do: 
         h = h + 1 .  
         create gll .
         gll.gllist = "----" .  
       for each que where que.pid = m_pid and que.con = "W" no-lock  .
         find first remtrz where remtrz.remtrz = que.remtrz no-lock .
         if remtrz.rsub = "" then  gll.num = gll.num + 1 .
       end.
      leave . 
   end .  
end.

  if h  > 25 then h = 25  .
  do:
       {browpnp.i
        &h = "h"
        &where = " true "
        &frame-phrase = "row 5 centered 
           scroll 1 h down overlay no-label  "
        &seldisp = "gll.gllist"
        &predisp = " "
        &file = "gll"
        &disp = " gll.gllist gll.num "
        &addupd = " gll.gllist "
        &upd    = " gll.gllist "
        &postupd = " "
        &addcon = "false"
        &updcon = "false"
        &delcon = "false"
        &retcon = "true"
        &befret = " v-rsub  = gll.gllist . 
        for each gll . 
          delete gll.
        end. 
        color display message gll.gllist gll.num with frame frm . pause 0 . 
        if v-rsub  = '----' then v-rsub = ''. "
       }
end.
