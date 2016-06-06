/* checks.f
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

/*checks.f
07.07.95*/


/*
form checks.nono
checks.lidzno checks.regdt
            checks.who checks.prizn checks.undt checks.whu
    with centered row 3 down frame checks.
*/
form checks.nono label  "С НОМЕРА" format "9999999"
     checks.lidzno label  "ПО НОМЕР" format "9999999"
     checks.regdt label "ДАТА РЕГ."
     checks.who label   "ВЫДАЛ"
     checks.prizn label "ПРИЗНАК"
     checks.undt label  "ДАТА ЗАКР."
     checks.whu label   "ЗАКРЫЛ"
     checks.celon label "ПРИЧИНА"
     with centered row 3 down overlay top-only frame checks.
