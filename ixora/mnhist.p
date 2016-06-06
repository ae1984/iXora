/* mnhist.p
 * MODULE
        Кредитное досье Мониторинг
 * DESCRIPTION
        Кредитная история в КД
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
        01.03.2005 marinav
 * CHANGES
*/


{global.i}
{kd.i}
{kdsysc1.f}

{kdhist.i kdaffilh kdcifhis "kdaffilh.nom = s-nom" "kdcifhis.nom = s-nom" kdsysc1}
