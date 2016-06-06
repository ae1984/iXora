/* bankt_w_tr.p
 * MODULE
	СПРАВОЧНИКИ
 * DESCRIPTION
	Тригер на запись в таблицу bankt
	при изменении любой записи прописывается кто, когда и восколько изменял
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
	
 * AUTHOR
        05.05.05 u00121
 * CHANGES
*/

TRIGGER PROCEDURE FOR Write OF bankt.
bankt.who = userid("bank").
bankt.whn = today.
bankt.vtime = time.
return.