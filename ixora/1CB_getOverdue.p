/* 1CB_getOverdue.p
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
        06.05.2013 evseev tz-1810
 * BASES
        BANK
 * CHANGES
*/

{global.i}


def input parameter fcb_id as int no-undo.
def output parameter p-day as int no-undo.
def output parameter p-count as int no-undo.

def var xml_id as int no-undo.
def var v-day as int.
def var i as int.
def var cont_num as int.

def var v-maxcontracts as int init 30.
def var v-start as int extent 30.
def var v-end as int extent 30.
def var v-contractcount as int.
def temp-table t-xml_det like xml_det.

cont_num = 0.
p-day = 0.

find first fcb where fcb.fcb_id = fcb_id no-lock no-error.
if not avail fcb then return.
xml_id = fcb.xml_id.

find first xml_det where xml_det.xml_id = xml_id and xml_det.par matches "*CigResultError Errmessage" no-lock no-error.
if avail xml_det then do:
    return.
end.

find first xml_det where xml_det.xml_id = xml_id and xml_det.par matches "*Root ExistingContracts" no-lock no-error.
if not avail xml_det then do:
    return.
end.


/*Contract NumberOfOverdueInstalments value*/
i = 0.
for each xml_det where xml_det.xml_id = xml_id and xml_det.par matches "*Contract NumberOfOverdueInstalments value*" no-lock:
    i = i + 1.
    v-day = int(xml_det.val) no-error.
      if error-status:error then do:
         run savelog("1CB_getOverdue", "48. " + string(xml_id) +  "Ошибка конвертации Contract NumberOfOverdueInstalments value = " + xml_det.val).
         next.
      end.
    if p-day <= v-day then do:
       p-day = v-day.
       cont_num = i.
    end.
end.

do i = 1 to v-maxcontracts:
   v-start[i] = 0.
   v-end[i] = 0.
end.

v-contractcount = 0.
for each xml_det where xml_det.xml_id = xml_id and xml_det.par matches "*Contract ContractTypeCode*" no-lock:
   v-contractcount = v-contractcount + 1.
   if v-contractcount > 1 then v-end[v-contractcount - 1] = xml_det.line - 1.
   v-start[v-contractcount] = xml_det.line.
end.

find last xml_det where xml_det.xml_id = xml_id  no-lock no-error.
v-end[v-contractcount] = xml_det.line.

empty temp-table t-xml_det.
if  v-contractcount >= 1 then do:
    for each xml_det where xml_det.xml_id = xml_id and xml_det.line >= v-start[cont_num] and xml_det.line <= v-end[cont_num] no-lock.
         create t-xml_det.
         buffer-copy xml_det to t-xml_det.
    end.
end.

p-count = 0.
for each t-xml_det where t-xml_det.par matches "*PaymentsCalendar Payment value":
   i = 0.
   i = int(trim(t-xml_det.val)) no-error.
   if i > 0 then p-count = p-count + 1.
end.

i = 0.
find first t-xml_det where t-xml_det.par matches "*Contract ProlongationCount value".
if avail t-xml_det then i = int(trim(t-xml_det.val)) no-error.

if p-count < i then p-count = i.




