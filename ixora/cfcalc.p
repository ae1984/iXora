/* cfcalc.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK
 * CHANGES
        21.04.2011 damir - новые переменные d2,v-ost2. добавил стр. 41 - 58 (Проверка)
*/


{mainhead.i}

def var v-cif as char.
def var v-cifname as char format "x(30)".
def var v-lon1 as char no-undo.
def var d2 as date no-undo.
def var v-ost2 as decimal no-undo.
def frame f-client.

form
    v-cif label "КЛИЕНТ " format "x(6)" colon 10 help " Введите код клиента (F2 - поиск)"
    validate (can-find(first cif where cif.cif = v-cif no-lock), " Клиент с таким кодом не найден!")
    v-cifname no-label format "x(45)" colon 18 skip
    with side-label row 4 no-box frame f-client.

d2 = g-today.

repeat: /*Дамир*/
    update v-cif with frame f-client.
    v-lon1 = ''.
    for each lon where lon.cif = v-cif no-lock:
        run lonbalcrc('lon',lon.lon,d2,"1,7,13",no,lon.crc,output v-ost2).
        if v-ost2 > 0 then do:
            if (lon.grp = 90) or (lon.grp = 92) then do:
                v-lon1 = lon.lon.
                leave.
            end.
        end.
    end.
    if v-lon1 = '' then do:
        message "Клиент не относится к данной группе ( Экспресс-кредиты физ.лицам и Долгосрочные экспресс-кред.ФЛ !!! )" view-as alert-box buttons ok.
        next.
    end.

    find first cif where cif.cif = v-cif no-lock no-error.
    if avail cif then v-cifname = trim((cif.prefix) + " " + trim(cif.name)).
    displ v-cifname with frame f-client.

    run cfcalcdtl (v-cif).
end.


