/* analbal.p
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

/* analbal.p
   Balance Analysis
*/

{mainhead.i }  /*  ANALYSIS ACCOUNT BALANCE  */

define temp-table tmp field aaa like aal.aaa
		    field regdt like aal.regdt
		    field aax   like aal.aax
		    field amt   like aal.amt.

define var vgross as decimal format "z,zzz,zzz,zzz,zzz.99CR" label "GROSS BAL".
define var vavail as decimal format "z,zzz,zzz,zzz,zzz.99CR" label "AVAIL BAL".
define var vcnt as int.
def var v-weekbeg as int.
def var v-weekend as int.

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.

repeat:
  prompt-for aaa.aaa.
  find aaa using aaa.aaa.
  display aaa.aaa aaa.dr[1] - aaa.cr[1] format "z,zzz,zzz,zzz,zzz.99CR"
     with side-label frame aaa.
  vgross = 0.
  vavail = 0.

  for each aal of aaa where aal.sta ne "RJ"
  break by aal.regdt by aal.aah:
    find aax where aax.lgr eq aaa.lgr and aax.ln eq aal.aax.
    vgross = vgross + aal.amt * aax.drcr.
    display aal.aax aal.amt aal.fday.
    if last-of(aal.regdt)
    then display aal.regdt vgross.
    create tmp.
    tmp.aaa = aal.aaa.
    tmp.regdt = aal.regdt.
    if aal.fday gt 0
    then do:
      repeat vcnt = 1 to aal.fday:
	tmp.regdt = tmp.regdt + 1.
	repeat:
	  find hol where hol.hol eq tmp.regdt no-error.
	  if not available hol and
	     weekday(tmp.regdt) ge v-weekbeg and
	     weekday(tmp.regdt) le v-weekend
	    then leave.
	    else tmp.regdt = tmp.regdt + 1.
	end.
      end.
    end.
    tmp.aax = aal.aax.
    tmp.amt = aal.amt.
  end.
  for each tmp break by tmp.regdt:
    find aax where aax.lgr eq aaa.lgr and aax.ln eq tmp.aax.
    vavail = vavail + tmp.amt * aax.drcr.
    if last-of(tmp.regdt)
    then display tmp.regdt label "AVAIL-DATE" vavail.
  end.
  for each tmp:
    delete tmp.
  end.
end.
