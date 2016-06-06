/* stnextp_c.i
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

/* stnextp_c.i */

Procedure nextp:

find next stmshi where stmshi.cif = in_cif and stmshi.aaa = in_account no-lock no-error.
 if available stmshi then do: 
    ch_date   = stmshi.pstart.
    ch_period = stmshi.period.
 end.
 else do: ch_date = ?. ch_period = ?. end. 
End.
