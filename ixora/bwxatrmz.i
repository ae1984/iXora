/* bwxatrmz.i
 * MODULE
        Загрузка bwx файла на ntmain
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
        15/03/04 isaev
 * CHANGES
        05/04/04 isaev - проверка на значение ccode <> 'msc'
        26.04.2005 marinav - if avail sysc заменен на if avail bookcod  
 
 */

def stream t.

function unix_s returns char (cmd as char).
    def var st as char init ''.
    input stream t through value(cmd).
    import stream t unformatted st.
    input stream t close.
    return st.
end.


if comm-txb() = "TXB00" then do:    
    
    def var rcd as char.
    def var bwxdir as char.
    def var bwxfile as char.
    find first sub-cod where sub-cod.acc = remtrz.remtrz
                       and sub-cod.sub = 'RMZ'
                       and sub-cod.d-cod = 'zattach'

                       no-lock no-error.
    if avail sub-cod and sub-cod.ccode <> 'msc' then do:
        find current sub-cod exclusive-lock.

        bwxdir = "NTMAIN:L:\\Users\\Private\\Departments\\Bwx\\Salary\\".
        find first bookcod where bookcod = 'cardaccs' and bookcod.code = 'bwxdir' no-lock no-error.
        
        bwxfile = substring(sub-cod.rcode, r-index(sub-cod.rcode, "/") + 1).

/*26.04.2005 marinav        if avail sysc then bwxdir = trim(bookcod.name).*/
        if avail bookcod then bwxdir = trim(bookcod.name).
        rcd = unix_s("rcp " + sub-cod.rcode + " " + bwxdir).
        if rcd = "" then do:
            v-text = remtrz.remtrz + ": BWX файл " + bwxfile + " скопирован в директорию " + bwxdir.
        end. else
            v-text = remtrz.remtrz + ": Ошибка копирования BWX файла " + bwxfile + "\n" + rcd.
        run lgps.
    end.
end.
