/* tlprompt.f
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


form "Команда печати    :" dest format "x(40)" skip
     "Пользователь      :" v-ofc skip
     "Дата              :" tek-dat skip
     "Кол-во экземпляров:" v-copy format "zzzz"
        with row 4 no-box no-label centered frame image1.
