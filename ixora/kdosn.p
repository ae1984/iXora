/* kdosn.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Электронное кредитное досье
        Расшифровка основных средств
 * RUN
 * CALLER
 * SCRIPT
 * INHERIT
 * MENU
        4-11-2 ФинРез - Осн ср-ва 
 * AUTHOR
        04.12.03 marinav
 * CHANGES
        26.01.2004 marinav  - Сверка с балансом
        30/04/2004 madiar - Просмотр клиентов филиалов в ГБ
        14/05/2004 madiar - Поставил no-lock в for each bal_cif
        01.03.2005 marinav - перенос программы в kdosn.i
*/



{global.i}
{kd.i}


{kdosn.i kdaffil kdcif true true pksysc}
