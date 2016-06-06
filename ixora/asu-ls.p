/* asu-ls.p
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
        03/06/2004 kanat - Добавил ввод пути для запуска импорта с АБПК
*/

/* Нужно заранее иметь коннект к базе TEXAKA1:/data/comm/comm.db */
{comm-txb.i}

def var v-file as char.
def var tmpd as char.
def var i as int init 0 no-undo.
def var j as int init 0.
def var dbdir as char.
define temp-table tmpls like asu-ls.

update v-file label "Файл (с путем если надо)" format "x(70)" 
                with row 2 centered overlay title "Импорт баз данных Астана Су" frame ffile.
hide frame ffile.

tmpd = string(day(today),"99") + string(month(today),"99") + substring(string(today,"999999"),5,2) .

file-info:file-name = v-file.
if file-info:file-type = ? then do:
    run savelog( "ast-su", 'Не найден файл загрузки ' + v-file).
    run mail("municipal" + comm-txb() + "@elexnet.kz", "Astana Su Importer", "Ошибка", "Не найден файл загрузки" + v-file, "", "", ""). 
    run savelog( "ast-su", 'Окончание импорта.').
return.    
end.

/*output to terminal NO-MAP.*/

if caps(v-file) <> "LS_CHET.DBF" then do:
        run savelog( "ast-su", "Не найден файл LS_CHET.DBF").
        disp "Проблема - Не найдены файлы LS_CHET.DBF" .
        return.
end.

/*output close.*/


run savelog( "ast-su", 'Начало ипорта базы asu-ls: ' + v-file).

dbdir = trim(OS-GETENV("DBDIR")) + "/import/asu/".

UNIX SILENT value( "dbf 1 1 " + v-file + " " + dbdir + "asu" + tmpd + ".err > " +
dbdir + "asu.d").

UNIX SILENT value("dos-un " + dbdir + "asu.d " + dbdir + "asu" + tmpd + ".d").

/*
INPUT FROM value("/data/ast/import/asu/asu" + tmpd + ".d").
*/
INPUT FROM value(dbdir + "asu" + tmpd + ".d").


REPEAT on error undo, leave:
    CREATE tmpls.
    IMPORT tmpls.accnt tmpls.fio tmpls.street tmpls.house tmpls.flat NO-ERROR.

    IF ERROR-STATUS:ERROR then do: 
        run savelog("ast-su", 'Строка ' + string(i) + '. Ошибка импорта.').
        DO j = 1 to ERROR-STATUS:NUM-MESSAGES:         
        run savelog ("ast-su", chr(9) + ERROR-STATUS:GET-MESSAGE(j) +  string(tmpls.accnt) + tmpls.fio).
        END.
        undo.
    end.
END.

INPUT CLOSE.


/* вычистим базу перед загрузкой */
delete from asu-ls.
  
for each tmpls:
    FIND FIRST asu-ls WHERE  asu-ls.accnt = tmpls.accnt
                             use-index accnt no-error.
    if available asu-ls then
        run cpls.
    else do:
        create asu-ls no-error.
        run cpls.
    end.
    delete tmpls no-error.
end.

procedure cpls.
 update
 asu-ls.accnt    = tmpls.accnt
 asu-ls.fio      = tmpls.fio
 asu-ls.street   = tmpls.street
 asu-ls.house    = tmpls.house
 asu-ls.flat     = tmpls.flat
 asu-ls.dateimp  = today.
end.

run savelog( "ast-su", 'Завершение ипорта базы asu-ls: ' + v-file).

quit.
