/* s-rimamd.p
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

/* s-rimamd.p
*/

{global.i}

def shared var s-bank like rim.bank.
def shared var s-lcno like rim.lcno.

def var vln as int.
def var ans as log.

find rim where rim.bank eq s-bank
	  and  rim.lcno eq s-lcno.

repeat:
  vln = 0.
  form ramd.ln ramd.orgamt ramd.chgamt ramd.newamt
    with row 5 centered title " AMEND FILE " overlay top-only
    down frame ramd.
  for each ramd where ramd.lcno eq rim.lcno and ramd.bank eq rim.bank:
    display ramd.ln ramd.orgamt ramd.chgamt ramd.newamt
      with frame ramd.
    down 1 with frame ramd.
    vln = ramd.ln.
  end.
  vln = vln + 1.
  {mesg.i 1808} update ans.
  if ans eq false then leave.
  create ramd.
  ramd.bank = rim.bank.
  ramd.lcno = rim.lcno.
  ramd.ln = vln.
  ramd.crc = rim.crc.
  ramd.orgamt = rim.amt[1] - rim.amt[2].
  ramd.newamt = ramd.orgamt.
  display ramd.ln ramd.orgamt with frame ramd.
  update ramd.chgamt with frame ramd.
  ramd.newamt = ramd.orgamt + ramd.chgamt.
  display ramd.newamt with frame ramd.
  bell.
  {mesg.i 0928} update ans.
  if ans eq false then undo, retry.
  rim.amt[2] = rim.amt[2] - ramd.chgamt.
  leave.
end.
hide frame ramd.
