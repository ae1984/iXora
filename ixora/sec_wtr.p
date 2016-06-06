/* sec_wtr.p
 * MODULE
        Администрирование АБПК
 * DESCRIPTION
	Ведение истории выдачи прав доступа на пункты меню в nmenu
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
TRIGGER PROCEDURE FOR Write OF sec.
{global.i}
create hissta.
	hissta.rem = sec.ofc. /*кому выдали*/
	hissta.sta = "sec". /*вид прав - sec = пункты меню nmenu*/
	hissta.ref =  sec.fname. /*имя функции пункта меню на который выдали права*/
	hissta.swho = g-ofc. /*кто выдал*/
	hissta.swhn = today. /*дата выдачи*/
	hissta.stim = time. /*время выдачи*/

