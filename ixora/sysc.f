/* sysc.f
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
        23/06/2008 madiyar - изменил форматы
*/

/*def shared var paka like tarif1.pakalp.*/
form
     sysc.sysc format "x(16)"
     sysc.des format "x(51)"
     sysc.daval
     sysc.deval
     sysc.inval
     sysc.loval
     with row 3 centered scroll 1 31 down width 110
     frame sysc .
