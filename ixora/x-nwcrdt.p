/* x-nwcrdt.p
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

/* x-nwcrdt.p
new credit card creation
*/
{global.i}
def shared var s-crdt like crdt.crdt.
def shared var vcrdt like crcard.crcard.
def var vcr like crdt.crdt.
def var vans as log.
def buffer bcrdt for crdt.

find crdt where crdt.crdt eq s-crdt.
find crcard where crcard.crcard = vcrdt.
find crdtstn where crdtstn.crdtstn = crcard.crdtstn.

if crdtstn.ncard = false then do:
   {mesg.i 9201}.
   undo,retry.
end.

do on error undo,retry:
   {mesg.i 0943} update vans.
   if not vans then undo,retry.
   else do:
   {mesg.i 7804} update  vcr.
   find crcard where crcard.crcard = vcr no-error.
   if available crcard then do:
      bell.
      {mesg.i 0731}.
      undo,retry.
   end.
   if vcr eq ""  then undo,retry. end.
end.

do transaction:
  crdt.ocrdt = s-crdt.
  crdt.expdt = crdt.expdt + 365.
  crcard.active = false.

  create crcard.
  crcard.crdt   = s-crdt.
  crcard.crcard = vcr.
  crcard.who    = g-ofc.
  crcard.whn    = g-today.
  crcard.tim    = time.
  crcard.crdtstn    = 1.
end.

disp       crdt.crdt   skip
	   crdt.crcdtyp  crdt.expdt   skip
	   crdt.lname         skip
	   crdt.fname       crdt.mname  skip
	   crdt.street[1] label "ADDRESS" skip
	   crdt.street[2] label ""   skip
	   crdt.street[3] label ""   skip
	   crdt.birthday    crdt.ssn   skip
	   crdt.htel                     skip
	   crdt.employer   skip
	   crdt.positn     skip
	   crdt.btel                skip
	   crdt.limit crdt.climit skip
	   crdt.pint  crdt.cint   skip
	   crdt.chdate               skip
     with frame crdt row 1 col 1 2 col side-label width 66
	  title " NEW CREDIT CARD REGISTRATION".

update     crdt.expdt
	   crdt.chdate               skip
     with frame crdt .
    crcard.expdt = crdt.expdt.
    {mesg.i 0716}.
    pause 0.
    next.
