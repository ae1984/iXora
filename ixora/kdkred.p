/* kdkred.p
 * MODULE
        Электронное Кредитное Досье
 * DESCRIPTION
        Кредиторы в КД
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
        04.12.2003 marinav
 * CHANGES
        30/04/2004 madiar - Просмотр клиентов филиалов в ГБ
        14/05/2004 madiar - Поставил no-lock в for each bal_cif
        01.03.2005 marinav - перенос программы в kdkred.i
*/


{global.i}
{kd.i}

{kdkred.i kdaffil kdcif true true pksysc}

