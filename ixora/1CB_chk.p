/* 1CB_chk.p
 * MODULE
        экспресс кредиты по ПК
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
        11/11/2013 Luiza ТЗ 1932
 * BASES
        BANK
 * CHANGES
*/

{global.i}


def input parameter fcb_id as int no-undo.

def var xml_id as int no-undo.
def var v-date as date.

find first fcb where fcb.fcb_id = fcb_id no-lock no-error.
if not avail fcb then return.
xml_id = fcb.xml_id.

find first xml_det where xml_det.xml_id = xml_id  no-lock no-error.
if not avail xml_det then do:
    message "Отчет ПКБ не найден, повторите запрос в ПКБ!" view-as alert-box title 'ВНИМАНИЕ'.
    return.
end.

find first xml_det where xml_det.xml_id = xml_id and xml_det.par matches "*CigResultError Errmessage" no-lock no-error.
if avail xml_det then do:
    return.
end.

find first xml_det where xml_det.xml_id = xml_id and xml_det.par matches "*Root ExistingContracts" no-lock no-error.
if not avail xml_det then do:
    return.
end.

find first xml_det where xml_det.xml_id = xml_id and xml_det.par matches "*Contract LastUpdate value" no-lock no-error.
if avail xml_det then do:
    v-date = date(trim(xml_det.val)).
    for each xml_det where xml_det.xml_id = xml_id and xml_det.par matches "*Contract LastUpdate value" no-lock:
       if v-date > date(trim(xml_det.val)) then v-date = date(trim(xml_det.val)).
    end.

    find first xml_det where xml_det.xml_id = xml_id and xml_det.par matches "*Footer DateOfIssue value" no-lock no-error.
    if date(trim(xml_det.val)) - v-date > 30 then do:
       message "Дата последнего обновления Отчет КБ не соответствует заданному параметру" view-as alert-box question buttons ok.
    end.
end.