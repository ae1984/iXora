/* trg_subled_gl.p
 * MODULE
	Администрирование
 * DESCRIPTION
        Назначение программы, описание процедур и функций
	ведение истории изменения типов сабледжеров у счетов главной книги
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
        27/01/06 u00121
 * CHANGES
*/


TRIGGER PROCEDURE FOR Assign OF gl.subled OLD VALUE oldsub.
if gl.subled <> oldsub then /*если новое значение не равно предыдущему значению*/
do:
	create hisglsub. /*то создаем запись в истории*/
	assign
		hisglsub.gl      = gl.gl  /*счет главной книги*/
		hisglsub.sub_old = oldsub /*предыдущее значение сабледжера*/
		hisglsub.sub_new = gl.subled /*новое значение сабледжера*/
		hisglsub.who     = user('bank') /*логин внесшего изменения человека*/
		hisglsub.whn     = today /*дата изменения*/
		hisglsub.tm      = time. /*время изменения*/
end.