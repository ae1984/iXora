/* longoF.p
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

def input parameter rmz  like remtrz.remtrz.
def input parameter sub  like remtrz.rsub.
def input parameter v-jh like remtrz.jh2.
 
def output parameter rcod1  as logi init false.

{lgps.i "new"}
{global.i}

   do transaction  on error undo,retry:
   find  remtrz where  remtrz.remtrz = rmz exclusive-lock no-error.
   
   if not (v-jh eq 0 or v-jh eq ?) then do:  
   remtrz.jh2 = v-jh.
   find first que where que.remtrz = rmz exclusive-lock no-error.
   if avail que and que.pid <> "F" then do :
   que.rcod = "0" .
   v-text =  'manual 2 TRx ' + string(v-jh) 
   +  ' for ' +
   remtrz.remtrz + "rcod = " + que.rcod .
   
   que.con = "F".
   que.dp = today.
   que.tp = time.
   release que .
   run lgps.
   rcod1 = true.
   end.
  
  
  end.
  else do :
  message '2 TRx not exists.'.
  pause.
  hide message.
  end.

  end.
