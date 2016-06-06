/* bkrent.f
 * MODULE
        Кредиты
 * DESCRIPTION
        ВВод расходов по БД
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        
 * AUTHOR
        03.03.2004 marinav
 * CHANGES
*/

form
     bkrentspr.name format "x(45)" label "Код "
     bkrent.val[1] format "->>>,>>>,>>9.99" label " Данные "
     with row 5 centered scroll 1 down title " РАСХОДЫ ПО ПРОГРАММЕ БЫСТРЫЕ ДЕНЬГИ "
     frame bkrent.


