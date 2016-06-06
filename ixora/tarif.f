/* tarif.f
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
        27.10.2011 damir - увеличил формат ввода поля tarif.pakalp.
        13.12.2011 damir - расширил фрейм.
*/


form
    tarif.num    format "x(3)"
    tarif.nr     label "Nr." format 'zzz'
    tarif.pakalp format "x(95)" column-label "Услуга "
with overlay   column 1 row 3 15 down title 'Справочник комиссий за услуги,F4 -выход' width 105 frame tarif.
message 'F4-выход,RETURN - выбор           '.
