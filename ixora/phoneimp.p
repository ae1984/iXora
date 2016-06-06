/* phoneimp.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        08/09/04 suchkov Сделал для телефонов на отнове kztcimp.p
*/

define var v-dbfile as char no-undo.

define temp-table t-phones no-undo like phones .


update v-dbfile label "Файл (с путем если надо)" format "x(70)" with row 2 centered overlay title "Импорт телефонов" frame ffile.
hide frame ffile.

file-info:file-name = v-dbfile.
if file-info:file-type = ? then do:
	message "Внимание! Не найден файл " v-dbfile view-as alert-box.
	return.    
end.

/*unix silent value("rm -f tmp-file.d").*/

UNIX SILENT value( "dbf 1 1 " + v-dbfile + " tmp-file.err > tmp-file.d && dos-un tmp-file.d tmpfile.d").

message "Обработки завершены!" view-as alert-box.

INPUT FROM tmpfile.d .
REPEAT:
    CREATE t-phones.
    IMPORT t-phones no-error . 

    IF ERROR-STATUS:ERROR then do: 
        message "Ошибка!" view-as alert-box.
        undo.
    end.
    /*display t-phones .*/
end.
INPUT CLOSE.


for each t-phones no-lock .
        find phones where phones.number = t-phones.number no-error .
        if not available phones then create phones .
	buffer-copy t-phones to phones .
end.

/*unix silent value ("rm " + v-dbfile).*/
