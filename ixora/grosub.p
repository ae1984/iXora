/* grosub.p
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

/* grosub.p
*/

define var vcod like crc.code.
define var v-decpnt like crc.decpnt.
define var vbank like bank.name label "".
define var vamt like gro.amt.
define var vpen as log.
define var vday as int.
{mainhead.i}
def var v-weekbeg as int.
def var v-weekend as int.

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.

{sub.i
&option = "UBPSUB"
&head = "gro"
&headkey = "gro"
&framename = "gro"
&formname = "gro"
&updatecon = "true"
&deletecon = "true"
&start = " "
&display = "display  gro.gro gro.rdt gro.type gro.billno gro.amt  gro.aaa
   gro.bank  vbank gro.acct  gro.duedt gro.rem gro.sts gro.jh gro.who gro.whn
   with frame gro."
&newpreupdate = " "
&preupdate = "if gro.jh ne ? then do:
{imesg.i 0820}. bell. undo, retry. end."
&update = "gro.type gro.billno"
&postupdate =" find grotyp where grotyp.type eq gro.type.
/*/* if grotyp.chc eq true then do:
  find chc where chc.chc eq gro.billno no-error.
  if not available chc then do:
     {imesg.i 2212}
     undo,retry.
  end.
end. */*/
update gro.amt with frame gro.
if grotyp.scg eq 2  then do:
  if grotyp.camt ne 0 then vamt = grotyp.camt.
  else do:
  find crc where crc.crc eq 1.
  vamt = round(gro.amt * grotyp.crate / 100
		   * exp(10,crc.decpnt),0) / exp(10,crc.decpnt).
  end. gro.svc = vamt.
  if grotyp.pby eq 2 then gro.amt = gro.amt + vamt.
end.
disp gro.amt with frame gro.
gro.duedt = date(month(g-today),grotyp.pday,year(g-today)).
update gro.duedt with frame gro.
repeat:
find hol where hol.hol eq gro.duedt no-error.
if not available hol and weekday(gro.duedt) ge v-weekbeg and
   weekday(gro.duedt) le v-weekend then leave.
else gro.duedt = gro.duedt + 1.
end.
disp gro.duedt with frame gro.
if g-today gt gro.duedt and grotyp.pen eq true then do:
{imesg.i 0726} update vpen .
if vpen eq true then  do:
 if grotyp.pamt ne 0 then vamt = grotyp.pamt.
 else do:
  find crc where crc.crc eq 1.
  vday = g-today - gro.duedt.
  vamt = round(gro.amt * grotyp.prate / 100 * vday
	  * exp(10,crc.decpnt),0) / exp(10,crc.decpnt).
 end.
 gro.amt = gro.amt + vamt.
 disp gro.amt with frame gro.
end.
end.
update gro.aaa with frame gro.
if grotyp.trn eq 1 then do:
  find bank where bank.bank eq grotyp.acc.
  gro.bank = bank.bank.
  disp gro.bank bank.name @ vbank with frame gro.
  update gro.acct with frame gro.
end.
else do:
  find aaa where aaa.aaa eq grotyp.acc.
  gro.acc = grotyp.acc.
  disp gro.acc with frame gro.
end.
update gro.rem with frame gro."
&newpostupdate = " "
&predelete = "if gro.jh ne ? then do:
{imesg.i 0245}. bell. undo, retry. end."
&end = " "
}
