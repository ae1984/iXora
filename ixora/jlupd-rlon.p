/* jlupd-rlon.p
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

define input parameter p-jh like jl.jh.
define input parameter p-ln like jl.ln.
define input parameter p-gl like jl.gl.
define input parameter p-acc like jl.acc.
define input parameter p-dc like jl.dc.
define input parameter p-lon as character.
define shared variable g-today as date.
define new shared variable s-longl as integer extent 20.
define variable ok as logical.
define variable i as integer.

find lon where lon.lon = p-lon no-lock no-error.
if not available lon
then return.

if lon.gua = "LK" or lon.gua = "FK"
then do:
     for each fagra where fagra.lon = lon.lon and fagra.gl = lon.gl and 
         fagra.gl1 = p-gl and fagra.pf = "F" and fagra.dc = p-dc and 
         fagra.acc = p-acc and fagra.whn = g-today and fagra.jh = 0 and 
         fagra.who = userid("bank") exclusive-lock:
         fagra.jh = p-jh.
         fagra.ln = p-ln.
         find gl where gl.gl = fagra.gl1 no-lock.
         if gl.subled = "LON"
         then do:
              find falon where falon.falon = fagra.falon exclusive-lock.
              if fagra.dc = "D"
              then falon.dam[gl.level] = falon.dam[gl.level] + fagra.amt.
              else falon.cam[gl.level] = falon.cam[gl.level] + fagra.amt.
         end.
     end.
end.
else do:
     find first fagra where fagra.falon = p-lon and fagra.gl = lon.gl and
          fagra.gl1 = p-gl and fagra.pf = "F" and fagra.dc = p-dc and
          fagra.acc = p-acc and fagra.whn = g-today and fagra.jh = 0 and
          fagra.who = userid("bank") exclusive-lock no-error.
     if available fagra
     then do:
          run f-longl(lon.gl,"lon%gl,glsoda%,lon%gl,lon%gl,lon%gl",output ok).
          if not ok
          then do:
               bell.
               message "Konts " lon.gl "не оформлен в справочнике longl".
               pause.
          end.
          find falon where falon.falon = p-lon exclusive-lock no-error.
          if not available falon
          then do:
               create falon.
               falon.falon = lon.lon.
               falon.lon = "".
               falon.facif = "".
               falon.cif = "".
               falon.gl = lon.gl.
               falon.who = userid("bank").
               falon.whn = g-today.
          end.
          if ok
          then do:
               do i = 1 to 5:
                  if p-gl = s-longl[i]
                  then do:
                       if p-dc = "D"
                       then falon.dam[i] = falon.dam[i] + fagra.amt.
                       else falon.cam[i] = falon.cam[i] + fagra.amt.
                       leave.
                  end.
               end.
          end.
          fagra.jh = p-jh.
          fagra.ln = p-ln.
     end.
end.
