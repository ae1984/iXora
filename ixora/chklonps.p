/* chklonps.p
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

def output parameter rcod  as logi init true.
define shared variable g-today as date.

  find  remtrz where  remtrz.remtrz = rmz no-lock no-error.
  
  if not avail remtrz then  do:
   rcod = false. 
   message 'Not available remtrz.'. 
   pause.
   hide message.
   end.
  else do:
    find que of remtrz no-lock no-error.
    if que.pid ne '2L' then do:
     rcod = false. 
     message " pid not equal '2l'". pause . hide message.
     end.

    if remtrz.rsub ne 'lon' then do:
    rcod = false.
    message " Rsub  not equal 'LON' ".
    pause.
    hide message.
    end.
    else do: 
    
    if remtrz.jh1 eq ? or remtrz.jh1 eq 0 then do:
     rcod = false.
     message '1 TRx not exists .'.
     pause.
     hide message.
     end.   
    else do:
      if not(remtrz.jh2 eq ? or remtrz.jh2 eq 0 ) then do:
      rcod = false.
      message ' 2 TRx exists. ' .
      pause.
      hide message.
      end.
      else do:
           for each jh use-index jdt where jh.jdt = g-today and
               jh.jh <> remtrz.jh1 and index(jh.party,remtrz.remtrz) > 0
               no-lock:                
               find first jl where jl.jh = jh.jh no-lock no-error.
               if available jl
               then do:
                    rcod = false.
                    message ' 2 TRx exists. '.
                    pause.
                    hide message.
                    leave.
               end.
           end.
      end.
      end.
    end.
  end.
