/* 2l_ps.p
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
	06.04.2005 u00121 - Добавлена автоматическая выдача прав доступа на полочки соответсвующие РКО, к которому привязан офицер - изменена ps-prmts.i
	24.06.2006 tsoy   - перекомпиляция
*/

/* last change : 8/12/2001 by sasco  
             - вызов процедуры изменен с s-remtrz на s-remtrzp
             - новая версия - от отметки "NEW-VERSION:"
               старая версия - от отметки "OLD-VERSION:"
*/                 
                                          
/* NEW-VERSION: */
{get-dep.i}

def var acode like crc.code.              
def var bcode like crc.code.
def buffer tgl for gl.
def new shared var s-remtrz like remtrz.remtrz.
def var t-pay like remtrz.amt.    
def new shared var v-option as cha.
def new shared var v-rsub like remtrz.rsub . 
define new shared variable s-title as character.
define new shared variable s-newrec as logical format "Да/Нет".
def var s-rmzsub like remtrz.remtrz .
{lgps.i "new"}

def temp-table gll field gllist like remtrz.remtrz.
def temp-table gllt field gllist like remtrz.remtrz 
                  field payment like remtrz.payment.
def var i as integer.
def new shared var q_pid like m_pid.
def new shared var s-rcode as integer.
def var s-valcon like s-rmzsub.

define frame aaa s-valcon label "Платеж" with side-label centered.
define frame aav s-valcon label "Платеж" with side-label centered.
define new shared var eremzed like remtrz.remtrz.

on help of s-valcon in frame aaa do:
run h-rmzzzz.
s-valcon = eremzed. 
displ s-valcon with frame aaa.
end.
                          
on help of s-valcon in frame aav do:
run h-rmzzzv.
s-valcon = eremzed.
displ s-valcon with frame aav.
end.

repeat:
{mainhead.i INWR2L}  
 m_pid = "2l".
 u_pid = "2l_ps" .
 v-option = "2lon".

 pause 0.
 run s-rsub .
 if keyfunction(lastkey) eq "end-error" then leave .
 pause 0 .  

 {ps-prmts.i} 

 s-remtrz = "". 
 s-rmzsub = "" .
 if v-rsub = 'valcon' then
 do:
    update s-valcon with frame aaa.
    s-rmzsub = s-valcon.
 end.                        
 else if v-rsub = 'vcon' then
 do:
    update s-valcon with frame aav.
    s-rmzsub = s-valcon.
 end.
 else update s-rmzsub label "Платеж" with side-labels centered frame aab.
 find first remtrz where s-rmzsub = remtrz.remtrz no-lock no-error . 
 find first que where s-rmzsub = que.remtrz no-lock no-error .           

 m_pid = que.pid.
 q_pid = m_pid.
                    
  i = 0.
    for each que where que.pid = m_pid and que.con = "W" no-lock:
    find first remtrz where remtrz.remtrz = que.remtrz and remtrz.rsub = v-rsub
    no-lock no-error. 
     if avail remtrz then do:
        create gllt.
        gllt.gllist = remtrz.remtrz.
        gllt.payment = remtrz.payment.
        i = i + 1.
     end.
    end . 

  for each gll: delete gll. end.
  for each gllt by gllt.payment: create gll. gll.gllist = gllt.gllist. end.
  for each gllt: delete gllt. end.
  find first gll where gll.gllist = s-rmzsub.

   repeat :
    s-remtrz = gll.gllist.
    run s-remtrzp.
    find first que where que.remtrz = s-remtrz no-lock no-error.
    if not avail que or (que.pid ne m_pid and que.con ne "F") then do:    
      find first gll where gll.gllist = s-remtrz no-error.
    end.
    if keyfunction(lastkey) eq "END-ERROR" then do:
         hide all. bell. 
         find first gll where gll.gllist = s-remtrz no-error.              
         if keyfunction(lastkey) eq "END-ERROR" then do : 
          hide all . leave. end.
    end.
      if keyfunction(lastkey) eq "Cursor-up" then
        find prev gll no-lock no-error. 
      if keyfunction(lastkey) eq "Cursor-down" then                         
           find next gll no-lock no-error.
      if not available gll then do:
            hide all. bell. 
          find first gll where gll.gllist = s-remtrz  no-error.
          if not avail gll then find first gll no-error.
          if keyfunction(lastkey) eq "END-ERROR" then do:
              hide all . leave.  end.
      end.       
   end.
   hide all.

end . 

for each gll. delete gll. end.

/*  OLD-VERSION:  - полный текст исходной программы */
/*
def var acode like crc.code.
def var bcode like crc.code.
def buffer tgl for gl.
def new shared var s-remtrz like remtrz.remtrz.
def var t-pay like remtrz.amt.
def new shared var v-option as cha.
def new shared var v-rsub like remtrz.rsub . 
define new shared variable s-title as character.
define new shared variable s-newrec as logical format "Да/Нет".
def var s-rmzsub like remtrz.remtrz .

 {mainhead.i INWR2L}
 {lgps.i "new"}
 m_pid = "2l".                   
 u_pid = "2l_ps" .
 v-option = "2lon".
 
repeat: 
 run s-rsub .
 if keyfunction(lastkey) eq "end-error" then leave .
  pause 0 .  
 {ps-prmts.i}                   
 s-remtrz = "". 
 s-rmzsub = "" .
 update s-rmzsub label "Платеж" with side-label centered frame aaa . 
 find first remtrz where s-rmzsub = remtrz.remtrz no-lock no-error . 
 find first que where s-rmzsub = que.remtrz no-lock no-error .
 if avail que and avail remtrz and remtrz.rsub =  v-rsub 
  and que.pid = m_pid and 
  keyfunction(lastkey) ne "end-error" and s-rmzsub  ne "" 
  then  do : s-remtrz = s-rmzsub . run s-remtrz . end . 
end . 

*/
