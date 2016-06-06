/* pcstload1.p
 * MODULE
        Платежные карты
 * DESCRIPTION
        Staff: Первоначальная загрузка данных
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        16-1-1
 * AUTHOR
        25/05/2012 id00810
 * BASES
        BANK
 * CHANGES
        23/08/2012 id00810 - добавлен выбор продукта
*/
def new shared var s-pcprod as char  no-undo.
def var v-sel as int  no-undo.
repeat:
    run sel2 (" Выберите продукт: ", " 1. STAFF | 2. SALARY | 3. Выход ", output v-sel).
    if keyfunction (lastkey) = "end-error" or v-sel = 3 then return.
    case v-sel:
        when 1 then s-pcprod = 'staff'.
        when 2 then s-pcprod = 'salary'.
    end.
    run pcstload.
end.
