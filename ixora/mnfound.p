/* mnfound.p
 * MODULE
        Мониторинг заемщика
 * DESCRIPTION
        Учредители клиента
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11- Учредит
 * AUTHOR
        01.03.05 marinav
 * CHANGES
*/


{global.i}
{kd.i}
{kdsysc1.f}

{kdfound.i kdaffilh kdcifhis "kdaffilh.nom = s-nom" "kdcifhis.nom = s-nom" kdsysc1}

