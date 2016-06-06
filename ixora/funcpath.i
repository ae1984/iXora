/* funcpath.p
 * MODULE
        Поиск наименования функции по пути к ней.
 * DESCRIPTION
        Показывает наименование функции.
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
        17.09.04 - suchkov
 * CHANGES

*/

function get-fname returns character (v-funcpath as char).
    define variable i     as integer .
    define variable point as character .
    define variable vfn   as character initial "MENU".
    
    do i = 1 to num-entries (v-funcpath, "."):
        point = ENTRY (i, v-funcpath, ".").
        find nmenu where nmenu.father = vfn and nmenu.ln = integer (point) no-lock no-error .
        if not available nmenu then do:
            display "Ошибка в пути!!!".
            return "ERROR".
        end.
        vfn = nmenu.fname .
    end.
    return vfn.
end.
