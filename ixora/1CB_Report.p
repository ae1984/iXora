/* .p
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
        10.06.2013 evseev tz-1810
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def shared var s-credtype as char init '4' no-undo.
def shared var v-aaa      as char no-undo.
def shared var v-bank     as char no-undo.
def shared var v-cifcod   as char no-undo.

run savelog("1CB_Report", "30. " + v-aaa  + " | " + s-credtype + " | " + v-bank + " | " + v-cifcod).

def var v-count as int no-undo.
def var fcb_id as int init 0.

find first pkanketa where pkanketa.aaa = v-aaa and pkanketa.credtype = s-credtype no-lock no-error.
if not avail pkanketa then do:
   message "Анкета не найдена!" view-as alert-box question buttons ok.
   return.
end.
find first cif where cif.cif = pkanketa.cif no-lock no-error.
if avail cif then do:
    for each fcb where fcb.bin = trim(cif.bin) and fcb.req_method = "GetReport.200017" no-lock:
        find first xml_det where xml_det.xml_id = fcb.xml_id and xml_det.par matches "*CigResultError Errmessage" no-lock no-error.
        if avail xml_det then next.
        find first xml_det where xml_det.xml_id = fcb.xml_id no-lock no-error.
        if avail xml_det and xml_det.par = ? then next.
        fcb_id = fcb.fcb_id.
    end.

    if fcb_id = 0 then do:
       message "Отчета ПКБ нет!" view-as alert-box question buttons ok.
    end. else do:
       run credcontract(input fcb_id).
    end.
end.