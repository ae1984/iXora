/* r-disconusr.p
 * MODULE
        Для использования в скриптах администраторов БД
 * DESCRIPTION
        Отключение пользоватлей от БД через proshut
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        suki <PID>
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        20.09.2012 id00700
 * BASES
        BANK TXB
 * CHANGES
*/

def shared var db-path as char.
def shared var pts as integer.

db-path = replace(db-path,".db","").

find first txb._connect where txb._connect._Connect-pid = pts no-lock no-error.
if avail txb._connect then do:
unix silent value ("proshut " + db-path + " -C disconnect " + string(txb._connect._Connect-Usr)).
unix silent value ("sudo kill " + string(pts)).
end.
