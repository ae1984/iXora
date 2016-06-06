/* jlupd-flon.p
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
define input parameter p-lon like lon.lon.
define shared variable g-today as date.
define new shared variable s-longl as integer extent 20.
define variable ok as logical.
define variable i as integer.

find lon where lon.lon = p-lon no-lock no-error.
if not available lon
then return.
if lon.gua = "LK" or lon.gua = "FK"
then do:
     for each fagra where fagra.lon = lon.lon and fagra.jh = p-jh and
         fagra.ln = p-ln  exclusive-lock:
         fagra.jh = 0.
         fagra.ln = 0.
         find falon where falon.falon = fagra.falon exclusive-lock.
         find gl where gl.gl = fagra.gl1 no-lock.
         if gl.subled = "LON"
         then do:
              if fagra.dc = "D"
              then falon.dam[gl.level] = falon.dam[gl.level] - fagra.amt.
              else falon.cam[gl.level] = falon.cam[gl.level] - fagra.amt.
         end.
     end.
end.
else do:
     find first fagra where fagra.falon = lon.lon and fagra.jh = p-jh and
         fagra.ln = p-ln  exclusive-lock no-error.
     if available fagra
     then do:
          fagra.jh = 0.
          fagra.ln = 0.
          
          run f-longl(lon.gl,"lon%gl,glsoda%,lon%gl,lon%gl,lon%gl",output ok).
          if not ok
          then do:
               bell.
               message "Счет " lon.gl "не оформлен в справочнике longl".
               pause.
          end.
          find falon where falon.falon = p-lon exclusive-lock no-error.
          if not available falon
          then ok = no.
          if ok
          then do:
               do i = 1 to 5:
                  if p-gl = s-longl[i]
                  then do:
                       if fagra.dc = "D"
                       then falon.dam[i] = falon.dam[i] - fagra.amt.
                       else falon.cam[i] = falon.cam[i] - fagra.amt.
                       leave.
                  end.
               end.
          end.
     end.
end.
