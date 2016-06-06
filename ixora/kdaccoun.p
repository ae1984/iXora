/* kdaccoun.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Электронное кредитное досье
        Счета (kdaffil.code = 09)- информация об оборотах на текущих счетах клиента (info[1]) и об
              остатках на срочных счетах (info[2]) в ТКБ и других банках
                     
 * RUN
 * CALLER
 * SCRIPT
 * INHERIT
 * MENU
        4-11-4 Верхнее меню "Счета"
 * AUTHOR
        02/09/03 marinav
 * CHANGES
        30/04/2004 madiar - Просмотр досье филиалов в ГБ
        12/05/2004 madiar - Добавил расчет полного среднемесячного оборота по счетам в Texakabank
        20/05/2004 madiar - В find kdlon добавил еще проверку на kdcif - иначе находилось несколько записей в kdlon с одинаковыми номерами досье
                            Поиск записей в kdaffil - не только по коду досье, но и по коду клиента
        01.03.2005 marinav - перенос программы в kdaccoun.i
*/

{global.i}
{kd.i}


{kdaccoun.i kdaffil kdcif "kdaffil.kdlon = s-kdlon" true kdsysc}
