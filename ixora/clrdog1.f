/* clrdog1.f
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

form clrdog.rem  label "Док.Nr." 
    /* clrdoc.facc label "Maks–taja rё±" */
     clrdog.tacc label "Счет получ." 
     clrdog.amt  label "Сумма            " format "zz,zzz,zzz,zzz.99"
with no-label column 36 overlay row 6 11 down 
     title trim(bankhead) frame clrdog1.
