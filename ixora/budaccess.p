/* budaccess.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        доступ для корректировки данных по ПБ
* CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        14/07/2012 Luiza
 * BASES
	BANK COMM

 * CHANGES
*/

{global.i}
    def var rez as log.
    def var v-year   as int.
    def var v-access as int.

    define temp-table t-year no-undo
    field year as int
    index ind2 is primary  year.

    define temp-table t-dep no-undo
    field depname as char
    field gl as int
    index ind2 is primary  depname.
    empty temp-table t-year.

    find first budget /*use-index budyear*/  no-lock no-error.
    if available budget then do:
        v-year = budget.year.
        create t-year.
        t-year.year = v-year.
        for each budget no-lock.
            if budget.year <> v-year then do:
                v-year = budget.year.
                create t-year.
                t-year.year = v-year.
            end.
        end.
    end.
    else do:
        message "Данные для бюджетных позиций не сформированы!".
        return.
    end.

   DEFINE QUERY q-year FOR t-year.

    DEFINE BROWSE b-year QUERY q-year
        DISPLAY t-year.year no-label format "9999" WITH  5 DOWN.
    DEFINE FRAME f-year b-year  WITH overlay row 5 COLUMN 25 width 15 title "Выберите год".
/***********************************************************************************************************/
    OPEN QUERY  q-year FOR EACH t-year no-lock.
    ENABLE ALL WITH FRAME f-year.
    wait-for return of frame f-year
    FOCUS b-year IN FRAME f-year.
    v-year = t-year.year.
    hide frame f-year.
    find first budget use-index budyear where budget.year =  v-year no-lock no-error.
    if available budget then v-access = budget.access.
    else return.

    rez = false.
    if v-access = 0 then do:
        run yn("","Открыть доступ для редактирования?","","", output rez).
        if rez then do:
            message "Ждите идет обработка записей ".
            for each budget use-index budyear where budget.year = v-year exclusive-lock.
                budget.access = 1.
            end.
            hide message no-pause.
        end.
    end.
    else do:
        run yn("","Закрыть доступ для редактирования?","","", output rez).
        if rez then do:
            message "Ждите идет обработка записей ".
            for each budget use-index budyear where budget.year = v-year exclusive-lock.
                budget.access = 0.
            end.
            hide message no-pause.
        end.
    end.