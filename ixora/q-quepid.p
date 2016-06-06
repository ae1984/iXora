/* q-quepid.p
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

/* h-quetyp.p */
{global.i}

def shared var s-remtrz like remtrz.remtrz .
def new shared var suma like remtrz.amt.
def new shared var sump like remtrz.payment.
def new shared var v-option as cha.
define new shared variable s-title as character.
define new shared variable s-newrec as logical.
def var s-pid like que.pid.
def var h as int .
def new shared var i as int.

def new shared temp-table wrem
    field remtrz like remtrz.remtrz
    field ref like remtrz.ref
    field amt like remtrz.amt
    field crc like remtr.fcrc label  "Вал".

h = 12 .

 def new shared var q_pid like que.pid .

 s-remtrz = "".
 v-option = "remps_m".
 s-pid = q_pid .
 update s-pid format 'x(5)'  
 label " Код очереди ? " with side-label overlay row 19 frame pp .
 q_pid = s-pid . 
 for each wrem :
    delete wrem.
 end.
 i = 0.
 suma = 0 . sump = 0 .
 for each que where que.pid = q_pid and que.con ne "F" no-lock use-index fprc.
   find remtrz where remtrz.remtrz = que.remtrz no-lock no-error.
   if avail remtrz then do :
     create wrem.
     wrem.remtrz = remtrz.remtrz.
     wrem.ref =  remtrz.ref.
     wrem.amt = remtrz.amt.
     wrem.crc = remtrz.fcrc.
     suma = suma + remtrz.amt.
     sump = sump + remtrz.payment.
     i = i + 1.
   end.
 end.
 run rmla.
   
     if s-remtrz = "" then do: hide all. return. end.

   find first wrem where wrem.remtrz = s-remtrz no-error.

   repeat :
    s-remtrz = wrem.remtrz.
    run s-remtrzp.
    find first que where que.remtrz = s-remtrz no-lock no-error.
    if not avail que or (que.pid ne q_pid and que.con ne "F") then do:
      find first wrem where wrem.remtrz = s-remtrz no-error.
      if avail wrem then do :
        delete wrem.
        i = i - 1.
        if i = 0 then do : hide all. return. end.
      end.
    end.
    if keyfunction(lastkey) eq "END-ERROR" then do:
         hide all. bell. run rmla .   
         find first wrem where wrem.remtrz = s-remtrz no-error. 
         if keyfunction(lastkey) eq "END-ERROR" then do : 
          hide all . return. end.
    end.
      if keyfunction(lastkey) eq "Cursor-up" then
        find prev wrem no-lock no-error. 
      if keyfunction(lastkey) eq "Cursor-down" then 
           find next wrem no-lock no-error.
      if not available wrem then do:
            hide all. bell. /* run rmla.  */
          find first wrem where wrem.remtrz = s-remtrz  no-error.
          if not avail wrem then find first wrem no-error.
          if keyfunction(lastkey) eq "END-ERROR" then do:
              hide all . return.  end.
      end.
   end.     /*  repeat   */
   hide all.
                                
