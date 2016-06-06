/* fingers.p
 * MODULE
        БИОМЕТРИЯЧЕСКИЙ АНАЛИЗ
 * DESCRIPTION
        Назначение программы, описание процедур и функций
	Формирование базы отпечатков пальцев
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
	subcod.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        19/09/05 u00121
 * CHANGES
        02/02/06 u00121 - изменил принцип формирования ответов от сканера
        06/01/08 marinav - исправлен путь к базам с /data/9/ на  /data/
        27/03/2008 madiyar - новые сканеры
        05/05/2010 galina - перекомпиляция
*/

def input param i-cif as char.
def input param i-upl as char.

DEFINE BUTTON button-scan LABEL "Сканировать".
DEFINE BUTTON button-compare LABEL "Забрать файлы".

FORM button-scan button-compare WITH FRAME but-frame ROW 7 overlay.

ON CHOOSE OF button-scan do:
    unix silent value("touch run.bin").
    unix silent value("scp -q run.bin Administrator@`askhost`:c:\\\\bio\\\\in").
end.

ON CHOOSE OF button-compare DO:
    unix silent value ("if [ ! -d //data//import//fingers//" + i-cif + "// ]; then mkdir //data//import//fingers//" + i-cif + "// ; chmod 0777 //data//import//fingers//" + i-cif + "//; fi").
    unix silent value ("if [ ! -d //data//import//fingers//" + i-cif + "//" + string(i-upl) + "// ]; then mkdir //data//import//fingers//" + i-cif + "//" + string(i-upl) + "// ;  chmod 0777 //data//import//fingers//" + i-cif + "//" + string(i-upl) + "//; fi").

    unix silent value("scp -q Administrator@`askhost`:c://bio//out//hXTemplate1 /data/import/fingers/" + i-cif + "/" + string(i-upl) + "/").
    unix silent chmod 0777 value ("/data/import/fingers/" + i-cif + "/" + string(i-upl) + "/" + "*").

	find last upl where upl.uplid = int(i-upl) no-error.
	if avail upl then do:
		upl.finger = true. /*устанавливаем его признак*/
	end.
	else do:
	    /*если это не доверенное лицо, то это или директор или главный бухгалтер, следовательно второй входной параметр это код из sub-cod.d-cod равный mainbk или chief
		наличие этой записи будет означать что у директора/гл.буха данного клиента отпечатки уже сняли*/
		create uplfnghst.
		        uplfnghst.cif = i-cif. /*код клиента*/
		        uplfnghst.ofc = user('bank'). /*логин пользователя*/
		        uplfnghst.dt = today. /*дата изменения*/
		        uplfnghst.tm = time. /*время изменения*/
		        uplfnghst.upl = i-upl. /*код доверенного лица*/
		        uplfnghst.sts = true. /*признак изменения*/
	end.

    unix silent value("ssh Administrator@`askhost` erase /Q c:\\\\bio\\\\out\\\\*").
	message "Сканирование отпечатков пальцев успешно завершено." view-as alert-box.

end.

ENABLE all WITH FRAME but-frame.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW or CHOOSE OF button-compare.

