/* trx-mobdel.i
 * MODULE
        Генератор транзакций
 * DESCRIPTION
        Удаление записей в mobtemp при удалении проводок
  ! ! ! Для вызова - обязательно иметь номер проводки в vjh ! ! !
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        trxdel.p, trxstor.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        19/09/03 sasco
 * CHANGES

*/


if vjh <> ? and vjh <> 0 then
do:

    /* 1. Пополнения пласт. карточек */
    find mobtemp where mobtemp.phone = string (vjh) and mobtemp.state >= 300 exclusive-lock no-error.
    if available mobtemp then do:
       run savelog ("trxdel", "Удаление проводки " + mobtemp.phone + " пополнения пласт. карт. # " + mobtemp.ref).
       delete mobtemp.
    end.
    release mobtemp.

    /* 2. KMobile */

    find mobtemp where mobtemp.state < 3 and mobtemp.ref = string(vjh) exclusive-lock no-error.
    if available mobtemp then do:
       run savelog ("trxdel", "Удаление проводки " + mobtemp.ref + " на KMobile (" + mobtemp.phone + " " + mobtemp.npl + ")" ).
       delete mobtemp.
    end.
    release mobtemp.

    /* 3. KCell */
    /* mobtemp.joudoc = joudoc = remtrz */
    for each mobtemp where mobtemp.state > 2 and mobtemp.state < 300:
        /* joudoc */
        find joudoc where joudoc.docnum = mobtemp.joudoc no-lock no-error.
        if available joudoc then do:
           if joudoc.jh = vjh then do:
              run savelog ("trxdel", "Удаление проводки " + string (vjh) + " / " + mobtemp.joudoc + " на KCell (" + mobtemp.phone + " " + mobtemp.npl + ")" ).
              delete mobtemp.
           end.
        end.
        /* remtrz */
        find remtrz where remtrz.remtrz = mobtemp.joudoc no-lock no-error.
        if available remtrz then do:
           if remtrz.jh1 = vjh or remtrz.jh2 = vjh then do:
              run savelog ("trxdel", "Удаление проводки " + string (vjh) + " / " + mobtemp.joudoc + " на KCell (" + mobtemp.phone + " " + mobtemp.npl + ")" ).
              delete mobtemp.
           end.
        end.
    end.


end.


