/* trxsublv.f
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

form trxsublv.level validate(trxsublv.level > 0,'') label " Урвн" 
     trxsublv.des format "x(32)" Label " Описание "
     with column 41 row 3 30 down title "  Уровни  " frame trxsublv.
