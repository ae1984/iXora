/* jou_cods.f
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

form
    ja-nr        label "Nr" format "z9"
/*    w-cods.codfr label "Кодификатор" format "x(10)"*/
    w-cods.name  label "Описание " format "x(35)"
    w-cods.what  label "Для" format "x(28)"   
    w-cods.val   label "Значение" format "x(10)"
with 10 down title " Введите значения кодов " overlay centered row 5 frame jou_cods.
