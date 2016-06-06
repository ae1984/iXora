/* h-rslc.f
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

/* h-rslc.f Валютный контроль
   Форма к списку рег. свид-в/лицензий

   18.10.2002 nadejda создан
*/

form " "
   vcrslc.dndate " "
   vcrslc.dnnum format "x(25)" " "
   codfr.name[2] format "x(10)" LABEL "ТИП"  " "
   vcrslc.lastdate  " "
   with row 4 centered scroll 1 12 down overlay frame h-rslc.



