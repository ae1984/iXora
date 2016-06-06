/* findstr.i
 * MODULE
        Фин.мониторинг
 * DESCRIPTION
        Поиск по ключевым словам для Фин.мониторинга
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        30/05/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        19/04/2010 galina - убрала функцию checkkey
*/

function checkString returns logical (input sourceString as char, input targetString as char).
    def var res as logi no-undo.
    def var bb as logi no-undo.
    def var i as integer no-undo.
    def var j as integer no-undo.
    def var chars as char no-undo init "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЫЪЭЮЯ".
    if sourceString <> '' and targetString <> '' then do:
        res = no.
        j = 1.
        repeat:
            i = index(sourceString,targetString,j).
            if i = 0 then leave.
            else do:
                j = i + 1.
                bb = yes.
                if i <> 1 then if index(chars,caps(substring(sourceString,i - 1,1))) > 0 then bb = no.
                if i + length(targetString) - 1 < length(sourceString) then if index(chars,caps(substring(sourceString,i + length(targetString),1))) > 0 then bb = no.
                if bb then do:
                    res = yes.
                    leave.
                end.
            end.
        end.
    end.
    return res.
end function.

function checkkey2 returns logical (input instr as char, input v-pkysysc as char).
    def var res as logi no-undo.
    def var i as integer no-undo.
    res = false.
    find first pksysc where pksysc.sysc = v-pkysysc no-lock no-error.
    do i = 1 to num-entries(pksysc.chval):
      if checkString (instr, entry(i,pksysc.chval)) = true then do:
        res = true.
        leave.
      end.
    end.
    return res.
end function.
