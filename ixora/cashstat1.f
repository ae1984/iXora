/* cashstat1.f
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

def var vappend as logical initial false format "продолжить/создать".
form "ПРОДОЛЖИТЬ (п) ИЛИ СОЗДАТЬ НОВЫЙ (с) ?" vappend skip
     "КОМАНДА ПЕЧАТИ " dest format "x(40)" skip(2)
     with row 4 no-box no-label centered frame image1.

form "               Номер пункта" punum format "zzz9" skip
    with row 6 no-box no-label overlay centered frame im1.
