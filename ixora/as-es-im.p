/* as-es-im.p
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
        05/02/04 sasco переделал на ввод имени файла с экрана
        14/09/05 kanat - исправил формирование кривых лицевых счетов
*/

def var v-file as char.
def var typeb as char format "x(1)".
def var tmpd as char.
def var i as int init 0 no-undo.
def var j as int init 0.
define temp-table tmpls like as-es-ls.

update v-file label "Файл (с путем если надо)" format "x(70)" 
                with row 2 centered overlay title "Импорт баз данных АстанаЭнерго" frame ffile.
hide frame ffile.

tmpd = string(day(today),"99") + string(month(today),"99") + substring(string(today,"999999"),5,2) .

file-info:file-name = v-file.
if file-info:file-type = ? then do:
    run savelog( "as_energ", 'Не найден файл загрузки ' + v-file).
    run mail("municipaltxb01@elexnet.kz", "Astana Energo Service Importer", "Ошибка", 
    "Не найден файл загрузки" + v-file, "", "", ""). 
    run savelog( "as_energ", 'Окончание импорта.').
return.    
end.

/*output to terminal NO-MAP.*/

if caps(v-file) <> "LIC_ABON.DBF" and caps(v-file) <> "LIC_CHET.DBF" then do:
        run savelog( "as_energ", "Не найдены файлы LIC_ABON.DBF или LIC_CHET.DBF").
        disp "Проблема - Не найдены файлы LIC_ABON.DBF или LIC_CHET.DBF " .
        return.
end.

/*output close.*/

if caps(v-file) = "LIC_CHET.DBF" then typeb = "C".
if caps(v-file) = "LIC_ABON.DBF" then typeb = "A".

delete from as-es-ls where as-es-ls.type = typeb.

def var v-dbpath as char.
find sysc where sysc.sysc = "rkbdir" no-lock no-error.
v-dbpath = sysc.chval.
if substr (v-dbpath, length(v-dbpath), 1) <> "/" then v-dbpath = v-dbpath + "/".

run savelog( "as_energ", 'Начало ипорта базы as-es-ls: ' + v-file).

UNIX SILENT value( "dbf 1 1 " + v-file + " " + v-dbpath + "import/aes/es" + tmpd + ".err > " + v-dbpath + "import/aes/es.d").

UNIX SILENT value("dos-un " + v-dbpath + "import/aes/es.d " + v-dbpath + "import/aes/es" + tmpd + ".d").

INPUT FROM value(v-dbpath + "import/aes/es" + tmpd + ".d").

REPEAT on error undo, leave:
    CREATE tmpls.
    IMPORT tmpls except type dateimp NO-ERROR.

    IF ERROR-STATUS:ERROR then do: 
        run savelog("as_energ", 'Строка ' + string(i) + '. Ошибка импорта.').
        DO j = 1 to ERROR-STATUS:NUM-MESSAGES:         
             run savelog( "as_energ", chr(9) + ERROR-STATUS:GET-MESSAGE(j) + tmpls.type + tmpls.accnt + tmpls.fio ).
        END.
        undo.
    end.
END.

INPUT CLOSE.
    
for each tmpls:
    FIND FIRST as-es-ls WHERE as-es-ls.type  = typeb  and 
                              as-es-ls.accnt = tmpls.accnt
                              use-index typeacc no-error.
    if available as-es-ls then
        run cpls.
    else do:
        create as-es-ls no-error.
        run cpls.
    end.
    delete tmpls no-error.
end.


for each as-es-ls where as-es-ls.accnt matches "*.00000*" exclusive-lock.
update as-es-ls.accnt = replace(as-es-ls.accnt,".00000","").
end.
release as-es-ls.


procedure cpls.
 update
 as-es-ls.type     = typeb
 as-es-ls.accnt    = tmpls.accnt
 as-es-ls.fio      = tmpls.fio
 as-es-ls.address  = tmpls.address
 as-es-ls.dateimp  = today.
end.

run savelog( "as_energ", 'Завершение ипорта базы as-es-ls: ' + v-file).

