/* mnaffil.p   Мониторинг
 * MODULE
        Мониторинг заемщика
 * DESCRIPTION
       ИНФОРМАЦИЯ ОБ АФФИЛИИРОВАННОЙ КОМПАНИИ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11 Аффилир
 * AUTHOR
        01.03.05 mairnav
*/
   



{global.i}
{kd.i}
{kdsysc1.f}

{kdaffil.i kdaffilh kdcifhis "kdaffilh.nom = s-nom" "kdcifhis.nom = s-nom" kdsysc1}

