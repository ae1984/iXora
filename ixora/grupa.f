/* grupa.f
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


form "Продолжать (П) или снова (С) ?" vappend
format "Продолжать/Снова"
skip
     "Печатать ? " vprint format "Да/Нет"
     skip
     "Команда печати " dest format "x(40)" skip
     with row 4 no-box no-label centered frame image1.

