/* kfm_fm1Chk.p
 * MODULE
        Финансовый мониторинг
 * DESCRIPTION
        Проверка формы ФМ-1
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
        30/03/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
        14/04/2010 madiyar - проверка ОКПО
        20/04/2010 madiyar - проверка заполнения поля "Вид участника"
        10/08/2010 madiyar - проверка заполнения поля "Код вида операции"
        16/08/2010 madiyar - убрал проверку ОКПО
        09/08/2011 madiyar - проверка заполнения поля "Код вида операции", исправил dataName -> dataCode
*/

{global.i}
{kfm.i}

def input parameter p-bank as char no-undo.
def input parameter p-operId as integer no-undo.
def output parameter p-chkErr as logi no-undo.
def output parameter p-chkMess as char no-undo.

p-chkErr = no.
p-chkMess = "".

def buffer bt-kfmprt for t-kfmprt.

/* проверим заполнение от имени/по поручению */
for each t-kfmprt where t-kfmprt.bank = p-bank and t-kfmprt.operId = p-operId no-lock:
    find first t-kfmprth where t-kfmprth.bank = p-bank and t-kfmprth.operId = p-operId and t-kfmprth.partId = t-kfmprt.partId and t-kfmprth.dataCode = "prtWhat" no-lock no-error.
    if avail t-kfmprth and (t-kfmprth.dataValue = "02" or t-kfmprth.dataValue = "03") then do:
        find first t-kfmprth where t-kfmprth.bank = p-bank and t-kfmprth.operId = p-operId and t-kfmprth.partId = t-kfmprt.partId and t-kfmprth.dataCode = "prtFrom" no-lock no-error.
        if (not avail t-kfmprth) or (trim(t-kfmprth.dataValue) = '') then p-chkMess = "Не заполнен критерий 'Наим/ФИО уч. (от имени/по поруч)' по участнику " + t-kfmprt.partName.
        else do:
            find first bt-kfmprt where bt-kfmprt.bank = p-bank and bt-kfmprt.operId = p-operId and bt-kfmprt.partName = t-kfmprth.dataValue no-lock no-error.
            if not avail bt-kfmprt then p-chkMess = "Не введены данные по участнику (от имени или по поручению)~n" + t-kfmprth.dataValue.
        end.
    end.
    if p-chkMess <> "" then do: p-chkErr = yes. leave. end.
end.

if not p-chkErr then do:
    /* проверим заполнение поля "Вид участника" */
    for each t-kfmprt where t-kfmprt.bank = p-bank and t-kfmprt.operId = p-operId no-lock:
        find first t-kfmprth where t-kfmprth.bank = p-bank and t-kfmprth.operId = p-operId and t-kfmprth.partId = t-kfmprt.partId and t-kfmprth.dataCode = "prtWhat2" no-lock no-error.
        if avail t-kfmprth and trim(t-kfmprth.dataValue) = '' then do:
            assign p-chkErr = yes p-chkMess = "Не заполнен критерий 'Вид участника' по " + t-kfmprt.partName.
            leave.
        end.
    end.
end.

if not p-chkErr then do:
    /* проверим заполнение поля "Код вида операции" по подозрительным операциям */
    if s-operType = 'su' then do:
        find first t-kfmoperh where t-kfmoperh.bank = p-bank and t-kfmoperh.operId = p-operId and t-kfmoperh.dataCode = "opType" no-lock no-error.
        if not(avail t-kfmoperh and trim(t-kfmoperh.dataValue) <> '') then do:
            p-chkErr = yes.
            p-chkMess = "Не заполнен критерий 'Код вида операции'".
        end.
    end.
end.
