 /* inkknp.i 
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Оплата инкассовых распоряжений
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        При закрытии опердня
 * AUTHOR
         dpuchkov
 * CHANGES
        17.11.2008 alex - Инкассовые распоряжения
        29.05.2009 galina - убрала сортировку по времени и счету aas и указала новый индекс aaardt
*/





/*разделение строго по КНП*/

for each aas where aas.ln <> 7777777 and (aas.sta = 4 or aas.sta = 5 or aas.sta = 8) and aas.knp = vs-knp  use-index aaardt exclusive-lock:
    /*
    find last b-blkaas where b-blkaas.aaa = aas.aaa and b-blkaas.sta = 1 no-lock no-error. 
    if avail b-blkaas then next.

    find last b-blkaas where b-blkaas.aaa = aas.aaa and lookup(string(b-blkaas.sta), "11,16") <> 0 no-lock no-error. 
    if avail b-blkaas then do:
        find last b-blkaas where b-blkaas.aaa = aas.aaa and b-blkaas.sta = 2 no-lock no-error. 
        if avail b-blkaas then do:
            next.
        end.
    end.
    */


    if aas.fsum >= decimal(aas.docprim)  then do:
        {inkclose.i}
    end.

end.

/******/
