/* lnx-jls.p
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

/* x-jls.p
*/
/*
    01.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/

def shared var s-jh  like jh.jh.
def new shared var s-consol like jh.consol initial false.
def var i as int.

{mainhead.i}  /* GENERAL ENTRY - SINGLE */

def var vbal like jl.bal.
def var vdam like jl.dam.
def var vcam like jl.cam.
def var oldround as log.
{jhjl.f new}

  {x-jlcf.i} /* clearing frame */
  {x-jlvf.i} /* view frame */

          find jh where jh.jh = s-jh no-lock.
          display jh.jh jh.jdt jh.who
            with frame jh.

  find jh using jh.jh no-lock no-error.
  if not available jh
    then do:
      bell.
      {mesg.i 9204}.
      undo, retry.
    end. /* if not available jh */
    else do:
        s-jh = jh.jh.
        {mesg.i 0946}.
        display jh.jh jh.jdt jh.who with frame jh.
        display jh.cif jh.party jh.crc with frame party.
        if jh.cif ne ""
          then do:
            find cif where cif.cif eq jh.cif no-lock.
            display trim(trim(cif.prefix) + " " + trim(cif.name)) @ jh.party with frame party.
          end.
    end.
         pause 0.

/* vbal, vcam, vdam evaluation and displaying for current jh*/
vdam = 0.
vcam = 0.
vbal = 0.
for each jl of jh no-lock:
vdam = vdam + jl.dam.
vcam = vcam + jl.cam.
vbal = vdam - vcam.
end.
display vbal with frame bal.
display vdam vcam with frame tot.
/* finished */
         run lns-jls.
hide frame rem. hide frame jl. hide frame tot. hide frame bal.
hide frame party. hide frame jh.
