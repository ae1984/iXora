/* vc101gtd.f
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

/* vc101gtd.f Валютный контроль
   Импорт МТ-101
   Форма к списку ГТД

   15.02.2003 nadejda создан
*/

form
   t-oldgtd.dndate format "99/99/99" 
   t-oldgtd.dnnum format "x(25)"
   t-oldgtd.sum 
   t-oldgtd.pcrc label "ВАЛ" format ">>9" 
   t-oldgtd.payret label "ВЗВ" 
   with width 70 row 11 centered scroll 1 7 down overlay frame f-chgtd.
