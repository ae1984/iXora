/* InsSwiftSts.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        05.10.2012 evseev
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def input parameter i-swift_id as int no-undo.
def input parameter i-val      as char no-undo.
def input parameter i-sts      as char no-undo.


function GetSwiftStsId returns integer.
    do transaction:
        find first pksysc where pksysc.sysc = "swift_sts_id" exclusive-lock no-error.
        if avail pksysc then
           pksysc.chval = string(int(pksysc.chval) + 1).
        else do:
           create pksysc.
           pksysc.sysc = "swift_sts_id".
           pksysc.chval = "1".
        end.
        find first pksysc where pksysc.sysc = "swift_sts_id" no-lock no-error.
    end.
    return int(pksysc.chval).
end function.

do transaction:
   create swift_sts.
   assign
      swift_sts.swift_id = i-swift_id
      swift_sts.swift_sts_id = GetSwiftStsId()
      swift_sts.dt = today
      swift_sts.tm = time
      swift_sts.sts = i-sts
      swift_sts.usr = g-ofc
      swift_sts.val = i-val.
end.
