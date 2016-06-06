/* comm-bik.i
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

/* 
   Функция возвращает БИК банка
*/

function comm-bik returns char.
 find first bank.sysc where bank.sysc.sysc = "CLECOD" no-lock no-error.
 return trim(bank.sysc.chval).
end.
