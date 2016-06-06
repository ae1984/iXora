/* chk-holiday.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Пересчет графика - перенос платежей с выходных и праздничных дней
 * RUN
        lnscd.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        11.01.2012 aigul
 * BASES
        BANK COMM
 * CHANGES
*/
def input parameter dt1 as date.
def output parameter dt2 as date.
def var v-dt as date.
def var v-dt1 as date.
def var i as int.
def buffer b-holiday for holiday.
v-dt1 = ?.
i = 0.
for each holiday where holiday.hmonth = month(dt1) no-lock:
    i = i + 1.
end.
for each holiday where holiday.hday = day(dt1) and holiday.hmonth = month(dt1) no-lock:
    v-dt = dt1 + 1.
    if i > 3 then do:
        for each b-holiday where b-holiday.hmonth = month(v-dt) no-lock:
            if b-holiday.hday = day(v-dt) then do:
                v-dt1 = v-dt + 1.
            end.
            if b-holiday.hday <> day(v-dt1)  then do:
                v-dt1 = v-dt1.
            end.
            else do:
            if b-holiday.hday = day(v-dt1) then v-dt1 = v-dt1 + 1.
            end.
            if v-dt1 = ? and v-dt <> ? then v-dt1 = v-dt.
        end.
    end.
    else do:
        for each b-holiday:
            if b-holiday.hday = day(v-dt) and b-holiday.hmonth = month(v-dt) then do:
                v-dt1 = v-dt + 1.
                if b-holiday.hday <> day(v-dt1) and b-holiday.hmonth = month(v-dt1) then do:
                    v-dt1 = v-dt1.
                end.
                else do:
                    if b-holiday.hday = day(v-dt1) and b-holiday.hmonth = month(v-dt1) then v-dt1 = v-dt1 + 1.
                end.
            end.
            if v-dt1 = ? and v-dt <> ? then v-dt1 = v-dt.
        end.
    end.
end.
if weekday(v-dt1) = 1 then v-dt1 = v-dt1 + 1.
if weekday(v-dt1) = 7 then v-dt1 = v-dt1 + 2.
dt2 = v-dt1.