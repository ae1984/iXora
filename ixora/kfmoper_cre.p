/* kfmoper_cre.p
 * MODULE
        Финансовый мониторинг
 * DESCRIPTION
        Редактируем во временной таблице критерии операции
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
        30/03/2010 galina
 * BASES
        BANK COMM
 * CHANGES
*/

def input parameter p-operId as int.

{kfm.i}
def var choice as logi no-undo.


for each t-kfmoperh:
	t-kfmoperh.dataValueVis = getVisual(t-kfmoperh.dataCode,t-kfmoperh.dataValue).
end.

for each t-kfmprth:
	t-kfmprth.dataValueVis = getVisual(t-kfmprth.dataCode,t-kfmprth.dataValue).
end.

repeat:
    run kfmfill_operh.
    if kfmres then leave.
    else do:
        choice = no.
        message "Изменения будут отменены, продолжить?" view-as alert-box question buttons yes-no update choice.
        if choice then leave.
    end.
end.

if kfmres then do:
    repeat:
        run kfmfill_part(p-operId).
        if kfmres then leave.
        else do:
            choice = no.
            message "Изменения будут отменены, продолжить?" view-as alert-box question buttons yes-no update choice.
            if choice then leave.
        end.
    end.
end.



