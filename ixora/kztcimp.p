/* kztcimp.p
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
        08/09/04 sasco Имя файла теперь запрашивается
*/

define var v-dbfile as char.
def var i as int init 0 no-undo.
def var j as int init 0.

define stream imp.

update v-dbfile label "Файл (с путем если надо)" format "x(70)" 
                with row 2 centered overlay title "Импорт Алматытелеком" frame ffile.
hide frame ffile.

run savelog( "kaztel", 'Начало импорта.').
file-info:file-name = v-dbfile.
if file-info:file-type = ? then do:
    run savelog( "kaztel", 'Не найден файл загрузки ' + v-dbfile).
    run mail("municipaltxb00", "AlmatyTelecom Importer", "Ошибка", 
    "Не найден файл загрузки" + v-dbfile, "", "", ""). 
    run savelog( "kaztel", 'Окончание импорта.').
return.    
end.

def var v-dbpath as char.
find sysc where sysc.sysc = "rkbdir" no-lock no-error.
v-dbpath = sysc.chval.
if substr (v-dbpath, length(v-dbpath), 1) <> "/" then v-dbpath = v-dbpath + "/".

unix silent value("rm -f " + v-dbpath + "import/kaztel/kaztel.*").

UNIX SILENT value( "dbf 1 1 " + v-dbfile + " " + v-dbpath + "import/kaztel/kaztel.err > " + v-dbpath + "import/kaztel/kaztel.d").

delete from kaztelsp.

INPUT stream imp FROM value(v-dbpath + "import/kaztel/kaztel.d").
REPEAT:
    i = i + 1.
    CREATE kaztelsp.
    IMPORT stream imp kaztelsp NO-ERROR. 

    IF ERROR-STATUS:ERROR then do: 
        run savelog("kaztel", 'Строка ' + string(i) + '. Ошибка импорта.').
        DO j = 1 to ERROR-STATUS:NUM-MESSAGES:         
             run savelog( "kaztel", chr(9) + ERROR-STATUS:GET-MESSAGE(j)).
        END.
        undo.
    end.
END.
INPUT stream imp CLOSE.

run savelog("kaztel", 'Окончание импорта.').

unix silent value ("rm " + v-dbfile).
