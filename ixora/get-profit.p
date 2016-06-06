
/* get-profit.p
 * MODULE
        Автоматизация проставления кода дох-расходов        
 * DESCRIPTION
        Определение профит-центра для  кода дох-расходов        
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        30/03/2006 marinav
 * CHANGES
*/

def input  param v-ofc 	as char	no-undo. 
def input  param v-dep 	as char	no-undo. 
def output param v-depd as char no-undo. /* профит центр для кодов доходов-расходов*/


if v-dep = '1' then do:
      find ofc where ofc.ofc = v-ofc no-lock no-error.
      if avail ofc then do:
         find codfr where codfr.codfr = "sproftcn" and codfr.code = ofc.titcd no-lock no-error.
         if avail codfr then v-depd = codfr.name[4].
      end.
      else do:
        v-depd = ''. 
      end.
end.
else do:
      find first sysc where sysc.sysc = 'PCRKO' no-lock.
      if avail sysc then do:
            find codfr where codfr.codfr = "sproftcn" and codfr.code = trim(sysc.chval) + fill('0', 2 - length(trim(string(v-dep)))) + trim(string(v-dep)) no-lock no-error.
            if avail codfr then v-depd = codfr.name[4].
                           else v-depd = ''. 
      end.
end.
