/* vcvstran.f
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
 * BASES
        COMM BANK
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        12.04.2011 damir - убрал  параметры временной таблицы, поставил codfr.code codfr.name[1]
*/

form
    codfr.code  label "КОД" format "x(10)"
    codfr.name[1]  label "НАЗВАНИЕ СТРАНЫ" format "x(67)"
with 11 down title codific-name overlay centered row 6 frame uni_help1.
