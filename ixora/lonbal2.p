/* lonbal2.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Расчет остатков по клиентским счетам на задаваемых уровнях. Только для SUBLEDGER: "CIF" 
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
        23/11/2004 saltanat
 * CHANGES
*/
def shared var g-today as date.

define input  parameter p-sub like trxbal.subled.
define input  parameter p-acc as char.
define input  parameter p-dt like jl.jdt.
define input  parameter p-lvls as char.
define input  parameter p-includetoday as logi.
define output parameter res as decimal.

def var i as integer.

res = 0.

if p-dt > g-today then p-dt = g-today. /*return.*/

if p-includetoday then do: /* за дату */
  if p-dt = g-today then do:
     for each trxbal where trxbal.subled = p-sub and trxbal.acc = p-acc no-lock:
         if lookup(string(trxbal.level), p-lvls) > 0 then do:

            find aaa where aaa.aaa = p-acc no-lock no-error.
            if not avail aaa then return.

	    find trxlevgl where trxlevgl.gl     eq aaa.gl 
                            and trxlevgl.subled eq p-sub
                            and lookup(string(trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail trxlevgl then return.

	    find gl where gl.gl eq trxlevgl.glr no-lock no-error.    
	    if not avail gl then return.

	    if gl.type eq "A" or gl.type eq "E" then res = res + trxbal.dam - trxbal.cam.
	    else res = res + trxbal.cam - trxbal.dam.

	    find sub-cod where sub-cod.sub eq "gld" and sub-cod.d-cod eq "gldic"
	                   and sub-cod.acc eq string(trxlevgl.glr) no-lock no-error.
	    if available sub-cod and sub-cod.ccode eq "01" then res = - res.

	    /* ------------------------------------------------------------ */
	    for each jl where jl.acc = p-acc 
                          and jl.jdt >= p-dt 
                          and jl.lev = 1 no-lock:
	    if gl.type eq "A" or gl.type eq "E" then res = res - jl.dam + jl.cam.
            else res = res + jl.dam - jl.cam.
            end.

         end.
     end.
  end.
  else do:
     do i = 1 to num-entries(p-lvls):
        find last histrxbal where histrxbal.subled = p-sub 
                              and histrxbal.acc = p-acc 
                              and histrxbal.level = integer(entry(i, p-lvls))
                              and histrxbal.dt <= p-dt no-lock no-error.
        if avail histrxbal then do:
            find aaa where aaa.aaa = p-acc no-lock no-error.
            if not avail aaa then return.

	    find trxlevgl where trxlevgl.gl     eq aaa.gl 
                            and trxlevgl.subled eq p-sub
                            and lookup(string(trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail trxlevgl then return.

	    find gl where gl.gl eq trxlevgl.glr no-lock no-error.    
	    if not avail gl then return.

	    if gl.type eq "A" or gl.type eq "E" then res = res + histrxbal.dam - histrxbal.cam.
	    else res = res + histrxbal.cam - histrxbal.dam.

	    find sub-cod where sub-cod.sub eq "gld" and sub-cod.d-cod eq "gldic"
	                   and sub-cod.acc eq string(trxlevgl.glr) no-lock no-error.
	    if available sub-cod and sub-cod.ccode eq "01" then res = - res.

        end.
     end.
  end.
end. /* if p-includetoday */
else do: /* на дату */
   do i = 1 to num-entries(p-lvls):
       find last histrxbal where histrxbal.subled = p-sub and histrxbal.acc = p-acc and histrxbal.level = integer(entry(i, p-lvls))
                                 and histrxbal.dt < p-dt no-lock no-error.
       if avail histrxbal then do:
            find aaa where aaa.aaa = p-acc no-lock no-error.
            if not avail aaa then return.

	    find trxlevgl where trxlevgl.gl     eq aaa.gl 
                            and trxlevgl.subled eq p-sub
                            and lookup(string(trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail trxlevgl then return.

	    find gl where gl.gl eq trxlevgl.glr no-lock no-error.    
	    if not avail gl then return.

	    if gl.type eq "A" or gl.type eq "E" then res = res + histrxbal.dam - histrxbal.cam.
	    else res = res + histrxbal.cam - histrxbal.dam.

	    find sub-cod where sub-cod.sub eq "gld" and sub-cod.d-cod eq "gldic"
	                   and sub-cod.acc eq string(trxlevgl.glr) no-lock no-error.
	    if available sub-cod and sub-cod.ccode eq "01" then res = - res.

       end.
   end.
end.

