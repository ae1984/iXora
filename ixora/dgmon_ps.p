/* dgmon_ps.p
 * MODULE
        Мониторинг договоров - платежная система
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
        23/10/2007 madiyar
 * BASES
        bank comm
 * CHANGES
*/

{global.i}

def var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

def buffer b-dgmon for dgmon.
def var dt_srok as date no-undo.
def var v-deadline_day as integer no-undo.
def var mon_days as integer no-undo.
def var v-month as integer no-undo.
def var v-year as integer no-undo.
def var v-maillist as char no-undo.
def var v-who as char no-undo.
def var i as integer no-undo.

for each dgmon where dgmon.bank = s-ourbank and dgmon.sts = 'A' no-lock:
    
    if dgmon.reminder_sent = today then next.
    
    dt_srok = ?.
    if dgmon.deadline_dt <> ? then dt_srok = dgmon.deadline_dt.
    else do:
        v-deadline_day = dgmon.deadline_day.
        if v-deadline_day > 0 then do:
            run mondays(month(today),year(today),output mon_days).
            if mon_days < v-deadline_day then v-deadline_day = mon_days.
            if v-deadline_day >= day(today) then dt_srok = date(month(today),v-deadline_day,year(today)).
            else do:
                v-deadline_day = dgmon.deadline_day.
                v-month = month(today) + 1.
                v-year = year(today).
                if v-month = 13 then do: v-month = 1. v-year = v-year + 1. end.
                run mondays(v-month,v-year,output mon_days).
                if mon_days < v-deadline_day then v-deadline_day = mon_days.
                dt_srok = date(v-month,v-deadline_day,v-year).
            end.
        end.
    end.
    
    if dt_srok = ? then next.
    
    if dt_srok - today = dgmon.reminder then do:
        v-maillist = dgmon.resp_person + "@metrobank.kz".
        do i = 1 to num-entries(dgmon.mailing_list):
            if v-maillist <> '' then v-maillist = v-maillist + ','.
            v-maillist = v-maillist + entry(i,dgmon.mailing_list) + "@metrobank.kz".
        end.
        find first ofc where ofc.ofc = dgmon.resp_person no-lock no-error.
        if avail ofc then v-who = ofc.name. else v-who = dgmon.resp_person.
        run mail(
                v-maillist,
                "METROBANK <abpk@metrobank.kz>",
                "Мониторинг договоров - напоминание",
                "Предмет договора: " + dgmon.subject + "\nКонтрагент: " + dgmon.contractor + "\nДата договора: " + string(dgmon.dt,"99/99/9999") + "\nСрок исполнения: " + string(dt_srok,"99/99/9999") + ", до исполнения осталось " + string(dgmon.reminder) + " дн.\nОтветственный: " + v-who,
                "1", "", "").
        find first b-dgmon where b-dgmon.id = dgmon.id exclusive-lock no-error.
        b-dgmon.reminder_sent = today.
    end.
    
end.
