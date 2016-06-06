/* mnreput.p 

 * MODULE
        Мониторинг заемщика
 * DESCRIPTION
        Кредитная репутация заемщика
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-2 Репутация 
 * AUTHOR
        01.03.05 marinav
 * CHANGES
*/



{global.i}
{kd.i}

{kdreput.i kdaffilh kdcifhis "kdaffilh.nom = s-nom" "kdcifhis.nom = s-nom"}