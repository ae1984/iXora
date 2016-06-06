/* taxoutdet.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Формирование детальных реестров налоговых платежей
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
        31/10/03 sasco добавил  taxoutdet00.p для Алматы
        17/11/03 sasco для Алматы добавил выбор детального или сводного реестора
        23/01/04 sasco добавил вывод детального реестра (только просмотр) - без проставления пачек
        29/04/04 kanat Астана и остальные филиалы будут пачковаться как Уральск.
*/

/* sasco - run for taxtrgen0 (TXB00, 02)  nad taxtrgen1 (TXB01) */
{comm-txb.i}
def input parameter v-dat as date.
define variable reptype as integer initial 1.

def var seltxb as int.
seltxb = comm-cod().

                   
if seltxb = 0 then do: 
        message "1) Реестр c Excel 2) Детальный с пачками 3) Детальный только просмотр" update reptype.
        if reptype = 1 then run taxoutdet00 (v-dat). /* АЛМАТЫ */
        else
        if reptype = 2 then run taxoutdet0 (v-dat).
        else
        if reptype = 3 then run taxoutdet0rp (v-dat).
        else message "Ошибка выбора!".
   end.
   else
run taxoutdet0 (v-dat). /* ОСТАЛЬНЫЕ ФИЛИАЛЫ */

