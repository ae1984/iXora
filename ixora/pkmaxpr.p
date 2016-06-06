/* pkmaxpr.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Процедура для определения количества и длительности просрочек
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
        22/07/2008 madiyar - скопировал из pkdiscount.p с изменениями
 * BASES
        BANK
 * CHANGES
        05/09/2008 madiyar - подправил на случай наличия текущей просрочки
*/

def shared var g-today as date.

define input parameter v-cif as char no-undo.
define input parameter v-lon as char no-undo.

define output parameter p-err as char no-undo. /* описание ошибки, если без ошибок = "" */
define output parameter p-coun as integer no-undo init 0. /* количество просрочек */
define output parameter p-maxpr as integer no-undo init 0. /* дней максимальная просрочка */

def var v-bal7 as deci no-undo init 0.
def var v-coun as integer no-undo.
def var v-maxpr as integer no-undo.
def var fdt as date no-undo.
def var dayc1 as integer no-undo.

v-coun = 0. v-maxpr = 0.

v-cif = trim(v-cif).
v-lon = trim(v-lon).
if v-cif <> "" then do:
    find first cif where cif.cif = v-cif no-lock no-error.
    if not avail cif then do:
        p-err = "Клиент с кодом " + v-cif + " не найден".
        return.
    end.
    find first lon where lon.cif = v-cif and lon.opnamt > 0 no-lock no-error.
    if not avail lon then do:
        p-err = "Нет кредитов".
        return.
    end.
end.
if v-lon <> "" then do:
    find first lon where lon.lon = v-lon no-lock no-error.
    if not avail lon then do:
        p-err = "Кредит " + v-lon + " не найден".
        return.
    end.
    if v-cif <> "" then do:
        if v-cif <> lon.cif then do:
            p-err = "Код клиента не совпадает".
            return.
        end.
    end.
    else v-cif = lon.cif.
end.
else do:
    if v-cif = "" then do:
        p-err = "Не указан ни код клиента, ни номер ссудного счета".
        return.
    end.
end.

for each lon where lon.cif = v-cif no-lock:
  
    if (v-lon <> "") and (lon.lon <> v-lon) then next.
    if lon.opnamt <= 0 then next.
    
    fdt = ?. v-bal7 = 0.
    for each lonres where lonres.lon = lon.lon no-lock use-index jdt:
        if lonres.lev <> 7 then next.
        if lonres.dc = 'd' then do:
            if v-bal7 = 0 and lonres.amt > 0 then do:
                v-coun = v-coun + 1.
                fdt = lonres.jdt.
            end.
            v-bal7 = v-bal7 + lonres.amt.
        end.
        else do:
            v-bal7 = v-bal7 - lonres.amt.
            if v-bal7 <= 0 then do:
                v-bal7 = 0.
                dayc1 = lonres.jdt - fdt.
                if v-maxpr < dayc1 then v-maxpr = dayc1.
            end.
        end.
    end. /* for each lonres */
    
    /* если есть текущая просрочка */
    if v-bal7 > 0 and fdt <> ? then do:
        dayc1 = g-today - fdt.
        if v-maxpr < dayc1 then v-maxpr = dayc1.
    end.
    
end. /* for each lon */

assign p-coun = v-coun p-maxpr = v-maxpr.

