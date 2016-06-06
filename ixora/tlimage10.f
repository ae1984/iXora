/* tlimage10.f
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

form skip (1) " УКАЖИТЕ ДАТУ       : " report-date format "99/99/99" skip
     skip (2) " КОМАНДА ПЕЧАТИ     : " dest format "x(10)" skip
     " КОЛ-ВО ЭКЗЕМПЛЯРОВ : " v-copy format "zzzz" skip (1)
 
      with row 8 no-label centered frame image1.
