/* offdate.p
 * MODULE
        Контролер
 * DESCRIPTION
        Список офицеров, работающих за указанный день
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        7.9
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        05.11.03 sasco - переделал поиск проводок офицеров
	05.01.04 valery - помимо выбора даты добавлена возможность выбора офиса ТЗ ї573
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        03.08.2005 marinav - в центральном офисе только менеджеры ОД
*/

{comm-txb.i}
{mainhead.i}

define variable dday as date.
define variable npp as integer initial 1.
define temp-table offtmp
    field o-who like ofc.who.



{a-off.f} /*****Внесены изменения valery 05/01/2004 ************/ 

{image1.i rpt.img}
{image2.i}

{report1.i 59}

if comm-cod () = 2 then do:
   output close.
   output to value(vimgfname) page-size 0 append.
end.


for each jh no-lock where jh.jdt eq dday use-index jdt:
  if jh.depart = vdep then /*****valery 05/01/2004 **проверяем,принадлежит ли офицер выбранному офису***********/ 
  do:
  	  if can-find (first jl where jl.jh = jh.jh no-lock) then 
	  do:
           if vdep = 1 then do:
              find last ofcprofit where ofcprofit.ofc = jh.who and ofcprofit.regdt <= dday no-lock no-error.
              if avail ofcprofit and ofcprofit.profitcn = '103' then do:
              	 create offtmp.
        	 offtmp.o-who = jh.who.
              end.	
           end.
           else do:
        	create offtmp.
        	offtmp.o-who = jh.who.
           end.	
    	  end.	
  end.
end.

{t-off.f} /*****Внесены изменения valery 05/01/2004 ************/ 

for each offtmp break by offtmp.o-who:
    if first-of (offtmp.o-who) then do:
        find ofc where ofc.ofc = offtmp.o-who.
        put "| "npp format "99" ". "offtmp.o-who "| "
        ofc.name format "x(30)" "|" skip "\r".
        npp = npp + 1.
    end.
end.

put "+---------------------------------------------+" .

output close.

{image3.i}
                           
/*************************************************************************************/



