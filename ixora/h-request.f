/* h-request.f
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Вывод найденных документов
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
        20.01.2011 aigul
 * CHANGES
*/

form
   codfr.name[2] format "x(6)" LABEL "ТИП"
   vcdocs.dnnum format "x(26)" label "НОМЕР ЗАПРОСА"
   vcdocs.dndate format "99/99/99" label "ДАТА ЗАПРОСА"
   with width 80 row 4 centered scroll 1 12 down overlay frame h-request.



