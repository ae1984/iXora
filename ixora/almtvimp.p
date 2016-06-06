/* almtvimp.p
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
        16.01.2004 nadejda - получатель письма по эл.почте изменен на общий адрес it@elexnet.kz
        05.02.2004 sasco   - переделал так, чтобы имя файла запрашивалось с экрана
        03/05/06   marinav - теперь файл приходит к нам в кодировке Koi8
*/

/* KOVAL настройка для филиалов */

define var v-dbfile as char.
def var i as int init 0 no-undo.
def var j as int init 0.

define stream imp.

define temp-table atvtmp 
    field tmp   as char format "x(15)"
    field summ  as decimal
    field address   as char
    field house     as integer
    field flat  as char
    field f     as char
    field io    as char
    field accnt as char
    field dt    as char.

run savelog( "almatv", 'Начало импорта.').
/* v-dbfile = session:parameter. */

update v-dbfile label "Файл (с путем если надо)" format "x(70)" 
                with row 2 centered overlay title "Импорт Alma TV" frame ffile.
hide frame ffile.

file-info:file-name = v-dbfile.
if file-info:file-type = ? then do:
    run savelog( "almatv", 'Не найден файл загрузки ' + v-dbfile).
    run mail("it@elexnet.kz", "Alma-TV Importer", "Ошибка", 
    "Не найден файл загрузки" + v-dbfile, "", "", ""). 
    run savelog( "almatv", 'Окончание импорта.').
return.    
end.

unix silent value("rm -f " + trim(OS-GETENV("DBDIR")) + "/import/a-tv/base.*").
unix silent value("rm -f " + trim(OS-GETENV("DBDIR")) + "/import/a-tv/atv.*").

UNIX SILENT value( "dbf 1 1 " + v-dbfile + " " + trim(OS-GETENV("DBDIR")) + "/import/a-tv/atv.err > " + trim(OS-GETENV("DBDIR")) + "/import/a-tv/atv.d").
/*
unix silent 
    cat value(trim(OS-GETENV("DBDIR")) + "/import/a-tv/atv.d | win2koi > " + trim(OS-GETENV("DBDIR")) + "/import/a-tv/base.d").
*/

for each almatv where dtfk = ?:
    delete almatv.
end.

INPUT stream imp FROM value(trim(OS-GETENV("DBDIR")) + "/import/a-tv/atv.d").
REPEAT:
    i = i + 1.
    CREATE atvtmp.
    IMPORT stream imp atvtmp NO-ERROR. 

    IF ERROR-STATUS:ERROR then do: 
        run savelog("almatv", 'Строка ' + string(i) + '. Ошибка импорта.').
        DO j = 1 to ERROR-STATUS:NUM-MESSAGES:         
             run savelog( "almatv", chr(9) + ERROR-STATUS:GET-MESSAGE(j)).
        END.
        undo.
    end.
    else do:
        run savelog( "almatv", 'Строка ' + string(i) + '. Контракт No ' + atvtmp.tmp + '...........Ok.').
    end.
END.
INPUT stream imp CLOSE.

run savelog("almatv", 'Окончание импорта.').

for each atvtmp:
        create almatv no-error.
        run cpatv.
    end.

procedure cpatv.
update
 almatv.ndoc = decimal(substring(trim(atvtmp.tmp),7,8))
 almatv.summ = atvtmp.summ
 almatv.address = trim(atvtmp.address)
 almatv.house   = string(atvtmp.house)
 almatv.flat    = trim(atvtmp.flat)
 almatv.f       = trim(atvtmp.f)
 almatv.io      = trim(atvtmp.io)
 almatv.accnt   = integer(atvtmp.accnt)
 almatv.dt      = date(
                   substring(atvtmp.dt,1,2) + "/" + 
                   substring(atvtmp.dt,3,2) + "/" + 
                   substring(atvtmp.dt,5,4) 
                  ).
end.

