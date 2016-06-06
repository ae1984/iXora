/* jlupd-liz.p
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

/*
*  jlupd-liz.p
*
*  p-action = "+"
*
*  1. Add record in lonliz file if it does not exist
*     or update existing record.
*  2. Add new record to the lonlizjl file
*  
*      OR
*  p-action = "-"
*
*  1. Find record in lonliz file and decrease sum on dam & cam. 
*  2. Delete record from lonlizjl file.
*/
define input parameter p-action as   char.
define input parameter p-lon    as   char.
define input parameter p-level  as   integer.
define input parameter p-subled like gl.subled.
define input parameter p-jh     like jl.jh.
define input parameter p-gl     like jl.gl.
define input parameter p-dc     like jl.dc.
define input parameter p-cam    like jl.cam.
define input parameter p-dam    like jl.dam.
define input parameter p-who    like jl.who.
define input parameter p-jdt    like jl.jdt.
define input parameter p-crc    like jl.crc.
define input parameter p-acc    like jl.acc.
define input parameter p-ln     like jl.ln.

define shared variable g-today as date.
define shared variable g-ofc   as char.
define new shared variable s-longl as integer extent 20.
define variable gl-arp like jl.gl.
define variable ok as logical.
define variable i as integer.

if p-lon = "" then return.

find lon where lon.lon = p-lon no-lock no-error.
if not available lon then return.

/* obrabotka dlja lizinga */
if lon.gua = "LK" or lon.gua = "FK"
then do:
   if p-subled = "arp" then do:
      find arp where arp.arp = "44" + string(lon.crc) + "liz" no-lock no-error.
      if not available arp
      then do:
         bell.
         message "Несуществующая АРП карточка" "44" + string(lon.crc) + "ЛИЗ".
         pause.
         return.
      end.
      gl-arp = arp.gl.
   end.
   else do:
      run f-longl(lon.gl,"pvn_debet,pvn_kredit,gl-noform,gl-atalg,gl-depo",output ok).
      if not ok
      then do:
         bell.
         message "Счет " lon.gl "не оформлен в справочнике longl".
         pause.
         return.
      end.
   end.

   if p-action = "+" and p-level > 0 then do:
      run IncreaseLevel(p-level,p-gl).
      return.
   end.
   else if p-action = "+" and p-level = 0 then return.
      
   /* vibor urovnja */   
   case p-gl:
      when gl-arp then do:
           if p-action = "+"  then run IncreaseLevel(1,gl-arp).
           else                    run DecreaseLevel.
        end.
      when s-longl[1] then do:
           if p-action = "+"  then run IncreaseLevel(2,s-longl[1]).
           else                    run DecreaseLevel.
        end.
      when s-longl[2] then do:
           if p-action = "+"  then run IncreaseLevel(2,s-longl[2]).
           else                    run DecreaseLevel.
        end.
      when s-longl[3] then do:
           if p-action = "+"  then run IncreaseLevel(3,s-longl[3]).
           else                    run DecreaseLevel.
        end.
      when s-longl[4] then do:
           if p-action = "+"  then run IncreaseLevel(4,s-longl[4]).
           else                    run DecreaseLevel.
        end.
   end case.
end.

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
PROCEDURE IncreaseLevel:
define input parameter p-level1 as integer.
define input parameter p1-gl   like gl.gl.

find first lon where lon.lon = p-lon no-lock.
find first lonliz where lonliz.lon = lon.lon no-error.
if not available lonliz then do:
   create lonliz.
   lonliz.lon = lon.lon.
   lonliz.crc = lon.crc.
   lonliz.rdt = g-today.
   lonliz.who = g-ofc.
   lonliz.whn = today.
end.

if p-dc = "C" then
   lonliz.cam[p-level1] = lonliz.cam[p-level1] + p-cam.
else
   lonliz.dam[p-level1] = lonliz.dam[p-level1] + p-dam.

do on error undo,leave:
   create lonlizjl.
   lonlizjl.jh  = p-jh.
   lonlizjl.gl  = p1-gl.
   lonlizjl.who = p-who.
   lonlizjl.whn = today.
   lonlizjl.jdt = p-jdt.
   lonlizjl.dc  = p-dc.
   lonlizjl.tim = time.
   lonlizjl.crc = p-crc.
   lonlizjl.lon = lon.lon.
   lonlizjl.acc = p-acc.
   lonlizjl.ln  = p-ln.
   if p-dc = "D" then
      lonlizjl.amt = p-dam.
   else
      lonlizjl.amt = p-cam.
   lonlizjl.level = p-level1.
   release lonlizjl.
end.

END PROCEDURE.
/*-----------------------------------------------------*/

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
PROCEDURE DecreaseLevel:
find first lon where lon.lon = p-lon no-lock.
find first lonlizjl where lonlizjl.jh = p-jh and lonlizjl.ln = p-ln 
use-index jhln no-error.

if available lonlizjl then do:
   find first lonliz where lonliz.lon = lon.lon no-error.
   if available lonliz then do:
      if lonlizjl.dc = "D" then
         lonliz.dam[lonlizjl.level] = lonliz.dam[lonlizjl.level] - p-dam.
      else
         lonliz.cam[lonlizjl.level] = lonliz.cam[lonlizjl.level] - p-cam.
   end.
   delete lonlizjl.
end.
END PROCEDURE.
/*-----------------------------------------------------*/
