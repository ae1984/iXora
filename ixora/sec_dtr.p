/* sec_dtr.p
 * MODULE
        Администрирование АБПК
 * DESCRIPTION
	Ведение истории лишения прав доступа на пункты меню в nmenu
 * RUN
	Тригер
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        20.03.2005 u00121
 * CHANGES
*/

TRIGGER PROCEDURE FOR Delete OF sec.
{global.i}
find last hissta where hissta.rem = sec.ofc and 
                       hissta.ref = sec.fname no-error.
if not avail hissta then
do:
        create hissta.
                hissta.rem = sec.ofc. /*кому выдали*/
                hissta.ref = sec.fname. /*имя функции пункта меню на который выдали права*/
                hissta.sta = "sec". /*вид прав - sec = пункты меню nmenu*/
end.

hissta.fwhn = today. /*когда забрали права*/
hissta.ftim = time. /*во сколько*/
hissta.fwho = g-ofc. /*кто забрал*/