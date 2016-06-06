/* aaatoday.f
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

def var vappend as log format "Продолжать/Снова".
def var v-mess as char initial "Обработка КИФ ... " format "x(21)".
form "Продолжать (П) или Снова (С) ?" vappend
format "Продолжать/Снова"
skip
     "Команда печати " dest format "x(40)" skip
     with row 4 no-box no-label centered frame image1.
