/* x-jlol.i
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

/* x-jlol.i
   Find OLD jh record...

   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
*/

getjh:
do on error undo, retry:
  /*
  {x-jlvf.i} /* view */
  */
  {mesg.i 1811}.

  prompt jh.jh with frame jh.

  if input jh.jh eq ?
    then do:
      run x-jhlst.
      undo, retry.
    end. /* jh.jh eq ? */

  find jh using jh.jh no-error.
  if not available jh
    then do:
      bell.
      {mesg.i 9204}.
      undo, retry.
    end. /* if not available jh */
    else do:
      /*
      if g-ofc ne "root" and jh.who ne g-ofc
       then do:
         bell.
         {mesg.i 0602}.
         undo, retry.
       end.
       */
      /*
      else if jh.post eq true
        then do:
          bell.
          {mesg.i 0224}.
          undo, retry.
        end.
      */
      /*
      else if jh.consol ne s-consol
        then do:
          bell.
          {mesg.i 0001}.
          undo, retry.
        end.
      */
      /* else do: */
        s-jh = jh.jh.
        {mesg.i 0946}.
        display jh.jh jh.jdt jh.who with frame jh.
        display jh.cif jh.party jh.crc with frame party.
        if jh.cif ne ""
          then do:
            find cif where cif.cif eq jh.cif.
            display trim(trim(cif.prefix) + " " + trim(cif.name)) @ jh.party with frame party.
          end.
      /* end. */
    end.
end. /* getold */
