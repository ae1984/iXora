/* q-trx.p
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

/* q-trx.p
*/

define var tottrx  as int format ">,>>9".
define var cashin  as dec decimals 2 format ">>>,>>>,>>9.99-".
define var cashout as dec decimals 2 format ">>>,>>>,>>9.99-".
define var cashbal as dec decimals 2 format ">>>,>>>,>>9.99-".
define var totamt  as dec decimals 2 format ">>>,>>>,>>9.99-".

{mainhead.i TLQRY}

for each aal where aal.regdt eq g-today and aal.who eq g-ofc
  break by aal.aah descending by aal.ln descending:
  if first-of(aal.aah) then tottrx = tottrx + 1.
  find aax where aax.lgr eq aal.lgr and aax.ln eq aal.aax.
  display string(aal.tim,"HH:MM:SS") label "TIME"
    aal.aah format 'zzzzzzz9' aal.ln aal.aax aax.des format "x(16)"
    aal.aaa aal.amt with down frame aal1.

       if aax.cash eq true then cashin = cashin + aal.amt.
  else if aax.cash eq false then cashout = cashout + aal.amt.

  if last(aal.aah)
  then do:
	 cashbal = cashin - cashout.
	 {aalaah.f}
       end.
end.
pause 5.
/* page. */

{aaldisp.f}

tottrx = 0.
totamt = 0.

for each aal where aal.regdt eq g-today and aal.who eq g-ofc
	      and  aal.chk   ne 0
  break by aal.aah by aal.ln:
  if first-of(aal.aah) then tottrx = tottrx + 1.
  find aax where aax.lgr eq aal.lgr and aax.ln eq aal.aax.
  display string(aal.tim,"HH:MM:SS") label "TIME"
    aal.aah format 'zzzzzzz9' aal.ln aal.aax aax.des format "x(16)"
    aal.aaa aal.amt with down frame aal2.

       /*
       if aax.cash eq true then cashin = cashin + aal.amt.
  else if aax.cash eq false then cashout = cashout + aal.amt.
       */
       totamt = totamt + aal.amt.
  if last(aal.aah)
  then do:
	 cashbal = cashin - cashout.
	 {aalaah2.f}
       end.
end.
pause 5.
/* page. */

{aaldisp2.f}
tottrx = 0.
totamt = 0.

for each aal where aal.regdt eq g-today and aal.who eq g-ofc
	      and  aal.aax   eq 52
  break by aal.aah by aal.ln:
  if first-of(aal.aah) then tottrx = tottrx + 1.
  find aax where aax.lgr eq aal.lgr and aax.ln eq aal.aax.
  display string(aal.tim,"HH:MM:SS") label "TIME"
    aal.aah format 'zzzzzzz9' aal.ln aal.aax aax.des format "x(16)"
    aal.aaa aal.amt with down frame aal3.

  totamt = totamt + aal.amt.

  if last(aal.aah)
  then do:
	 cashbal = cashin - cashout.
	 {aalaah3.f}
       end.
end.
pause 5.
