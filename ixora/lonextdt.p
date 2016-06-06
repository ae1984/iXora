/* lonextdt.p
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

/* lonextdt.p
   Loan Extension
*/
/*
   01.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/

{mainhead.i CLEXT}  /*  LOAN EXTENSION  */

def new shared var s-lon like lon.lon.
def new shared var s-consol like jh.consol initial false.

def new shared var fduedt as date.
def new shared var tduedt as date.

def var ans as log.
def var vbal like jl.dam.

{lonextdt.f}

repeat:
  prompt-for lon.lon with frame lon.
  find lon using lon.lon no-error.
  if not available lon
    then do:
      bell.
      {mesg.i 0230}.
      undo, retry.
    end.
  vbal = lon.dam[1] - lon.cam[1].
  fduedt = lon.duedt.
  find gl where gl.gl eq lon.gl.
  find cif where cif.cif eq lon.cif.
  display lon.lon lon.gl gl.sname lon.grp
          lon.cif trim(trim(cif.prefix) + " " + trim(cif.name)) @ cif.name lon.lcr lon.rdt lon.duedt
          lon.base lon.prem vbal
          with frame lon.
  if lon.dam[1] - lon.cam[1] eq 0
    then do:
      bell.
      {mesg.i 9217}.
      undo, retry.
    end.
  {mesg.i 3810} update ans.
  if ans eq false then leave. /* undo, retry */
  update lon.duedt lon.base lon.prem with frame lon.
  if not lon.duedt entered
    then do:
      undo, retry.
    end.
  s-lon = lon.lon.
  tduedt = lon.duedt.
  run t-lonext.
end.
