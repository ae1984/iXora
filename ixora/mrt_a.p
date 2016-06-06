/* mrt_a.p
 * MODULE
        Монитор
 * DESCRIPTION
        Автоматический расчет МРТ
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
        07/04/06 tsoy
 * CHANGES
	19/10/06 u00121 добавил no-undo, no-lock  в поиски по таблицам, убрал global.i вместо явно прописал необходимые глобальные переменные.
			и вообще, массовое использование глобальных переменных введет к нецелесообразному использованию памяти, в global.i иx "тучи", здесь используется одна,
			а память выделяется под все. ДОЛОЙ global.i!!!

*/



define shared var g-ofc    like ofc.ofc.

def shared var vasof as date no-undo.

define shared variable dcCash as decimal format "z,zzz,zzz,zz9.99-" no-undo.
define shared variable dcLiab as decimal format "z,zzz,zzz,zz9.99-" no-undo. 

define variable hday as logical no-undo.
define variable bdate as date no-undo.
define variable wstart as integer no-undo.
define variable wend as integer no-undo.
define variable icnt as integer no-undo.

define buffer b-mrt for mrt.


dcCash = round(dcCash,2).
dcLiab = round(dcLiab,2).

if dcLiab = 0 then 
   do:
      find last mrt where mrt.whn < vasof no-lock no-error.
      dcLiab = mrt.liab.
   end.

find hol where hol.hol = vasof no-lock no-error.
hday = avail hol.

find last sysc where sysc.sysc = 'WKSTRT' no-lock no-error.
if avail sysc then 
     wstart = sysc.inval.  
else 
     wstart = 2.

find last sysc where sysc.sysc = 'WKEND' no-lock no-error.
if avail sysc then 
     wend = sysc.inval.  
else 
     wend = 6.

if (weekday(vasof) >= wstart) and (weekday(vasof) <= wend) and not(hday) then
do:
  
  find mrt where mrt.whn = vasof no-lock no-error.
  if available mrt 
     then 
       do:
          if (mrt.cash <> dcCash) or (mrt.liab <> dcLiab) then 
          do:
                   find current mrt exclusive-lock.
                   assign
	                   mrt.cash = dcCash
	                   mrt.liab = dcLiab
	                   mrt.who = g-ofc.
                   find current mrt no-lock.
          end.
       end.
     else
       do:
          create mrt.
          assign
          mrt.cash = dcCash
          mrt.liab = dcLiab
          mrt.who = g-ofc
          mrt.whn = vasof.
       end.
  find last sysc where sysc.sysc = 'MRTBDT' no-lock no-error.
  if avail sysc then 
                  do:
                     bdate = sysc.daval.
                     icnt = 0.
                     for each b-mrt where b-mrt.whn >=bdate no-lock:  
                         icnt = icnt + 1. 
                     end.
                     if icnt <= 13 
                        then
                          do:
                             if icnt = 13 
                                then 
                                  do: 
                                     find current sysc exclusive-lock.
                                     sysc.daval = sysc.daval + 14. 
                                     find current sysc no-lock.
                                  end.
                             for each b-mrt where (b-mrt.whn >= bdate) and (b-mrt.whn < vasof) no-lock:
                                 accumulate b-mrt.liab (TOTAL COUNT).
                             end.
                             find current mrt exclusive-lock.
                             mrt.mrt = (((ACCUM TOTAL b-mrt.liab) / (ACCUM COUNT b-mrt.liab)) / 100) * 6.
                             find current mrt no-lock.
                          end.
                  end.
  pause.
end.
