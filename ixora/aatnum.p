/* aatnum.p
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

  /* newnum.p */
  def shared var v-aat like aat.aat.

  {proghead.i}

  do transaction:
    find sysc where sysc.sysc eq "NXTAAT".
    v-aat = sysc.inval.
    sysc.inval = sysc.inval + 1.
    create aat.
    aat.aat = v-aat.
    aat.tim = time.
    aat.who = userid('bank').
    aat.whn = g-today.
    aat.regdt = g-today.
  end.
