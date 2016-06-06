/* compay_init.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл - compay5.p
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK
 * CHANGES
        07.11.2012 damir - Внедрено Т.З. № 1365,1481,1538.
        14.11.2012 damir - Оптимизация кода. Изменения связанные с изменениями 07.11.2012.
*/

def temp-table t-Type no-undo
    field code    as char
    field name    as char
    field choise  as char
    field ap_code as inte
    field i       as inte
    index idx is primary i ascending.

def buffer b-t-Type for t-Type.

DEF VAR QH2 AS HANDLE.
CREATE QUERY QH2.
QH2:SET-BUFFERS('b-t-Type').

def var v-cnt     as inte.
def var v-errmess as char.
def var v-str as char.

empty temp-table t-Type.

if num-entries(Doc:codereg,';') > 0 then do:
    repeat v-cnt = 1 to num-entries(Doc:codereg,';'):
        v-str = ''.
        v-str = trim(entry(v-cnt,Doc:codereg,';')).

        create t-Type.
        t-Type.code   = trim(entry(1,v-str,'|')).
        t-Type.name   = trim(entry(2,v-str,'|')).
        t-Type.i      = v-cnt.
        t-Type.choise = "REG".
    end.
end.

if num-entries(Doc:typepay,';') > 0 then do:
    repeat v-cnt = 1 to num-entries(Doc:typepay,';'):
        v-str = ''.
        v-str = trim(entry(v-cnt,Doc:typepay,';')).

        create t-Type.
        t-Type.code    = trim(entry(1,v-str,'|')).
        t-Type.name    = trim(entry(2,v-str,'|')).
        t-Type.i       = v-cnt.
        t-Type.ap_code = Doc:ap_code.
        t-Type.choise  = "TYP".
    end.
end.

function Chk_Prov returns logical(input p-input1 as char,input p-input2 as char).
    QH2:QUERY-CLOSE().
    QH2:QUERY-PREPARE("for each b-t-Type where b-t-Type.choise = '" + p-input1 + "' and b-t-Type.code = '" + p-input2 + "'").
    QH2:QUERY-OPEN().
    QH2:GET-FIRST().

    if avail b-t-Type then return true.
    else do:
        v-errmess = "Не найдены записи в таблице t-Type!!!".
        return false.
    end.
    QH2:QUERY-CLOSE().
end function.

function Find_First returns logical(input p-input1 as char,input p-input2 as char).
    if Chk_Prov(p-input1,p-input2) then return true.
    else do:
        v-errmess = "Не найден введенный вами параметр,нажмите <F2> для выбора!!!".
        return false.
    end.
end.


