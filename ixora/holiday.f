/* holiday.f
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
        29.12.2011 aigul
 * BASES
        BANK COMM
 * CHANGES
*/
form holiday.hday LABEL "День" format "99"
     holiday.hmonth LABEL "Месяц" format "99"
     with  centered row  3 down frame holiday.

/*
def var v-day as int.
def var v-month as int.

update v-day label ' Укажите день' format '99'
                  validate (v-day < 32, "День должен быть меньше 32 числа") skip with side-label row 5 centered frame dat.
update v-month label ' Укажите месяц' format '99'
                  validate (v-month < 13, "Месяц должен быть меньше 13 числа") skip with side-label row 5 centered frame dat.

if v-day <> 0 and v-month <> 0 then do:
    create holiday.
    holiday.who = g-ofc.
    holiday.whn = g-today.
    holiday.hday = v-day.
    holiday.hmonth = v-month.
    message "ПРаздничный день успешно добавлен!" view-as alert-box.
end.*/