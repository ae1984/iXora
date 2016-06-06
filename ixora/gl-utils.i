/* gl-utils.i
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
        04.12.2012 Lyubov - увеличен формат поля num, т.к. не отображались суммы
*/

/* --------------------------- */
/* Утилиты для General Ledger  */
/* --------------------------- */

/* Converts decimal number to Excel string for numbers */
FUNCTION XLS-NUMBER returns char (num as decimal).
    if num ge 0 then return replace (string (num, "zzzzzzzzzzzzzz9.99"), ".", ",").
                else return "-" + trim (replace (string (absolute(num), "zzzzzzzzzzzzzz9.99"), ".", ",")).
END function.


/* Converts BWX dates (integer format) to Progres date */
FUNCTION TO_MY_DATE returns date (inp as character).
    return Date ( substr (inp, 7, 2) + "/" +  /* день */
                  substr (inp, 5, 2) + "/" +  /* месяц */
                  substr (inp, 1, 4) /* год */
                ).
END FUNCTION.

