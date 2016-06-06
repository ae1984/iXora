/* bxcif_clr.p
 * MODULE
        Операционный модуль
 * DESCRIPTION
        Удаление задолжности по комиссии
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
        11.08.2011 id00700
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}


def var d as char format 'x(20)'.
def var v-chk as logical initial no.
def button btn-cls   label  "Списать".
def button btn-exit  label  "Выход".

def frame frame2
skip(1) btn-cls btn-exit
with centered title "Обнуление задолжности" row 10.

on choose of btn-cls do:
update d LABEL "Введите счёт" format 'x(20)' WITH CENTERED frame qq.
hide frame qq.
disp d.
if d <> '' then do:
    find first aaa where aaa.aaa = d no-lock no-error.
        if not avail aaa then do:
        message "Данного счёта нет в вашем филиале!" view-as alert-box.
        return.
end.
find first bxcif where bxcif.aaa = d no-lock no-error.
    if avail bxcif then v-chk = yes.
    if v-chk then do:
        for each bxcif where bxcif.aaa = d exclusive-lock:
        run savelog("delcombxcif",'Удалена комиссия по счёту ' + bxcif.aaa + ', на сумму ' + string (bxcif.amount)).
        delete bxcif.
    end.
    for each bxcif where bxcif.aaa = d no-lock.
end.
message "Все задолжности по счёту удалены." view-as alert-box.
end.
if v-chk = no then do:
message "По указанному счёту задолжности не найдены." view-as alert-box.
end.
end.
end.
on choose of btn-exit pause 0 no-message.
enable all with frame frame2.
wait-for choose of btn-exit.
