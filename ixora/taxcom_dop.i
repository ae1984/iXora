/* taxcom_dop.i
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
 * CHANGES
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        11.02.2005 kanat - изменил группу выбираемых тарифов
*/

function taxcom_dop returns decimal ( sum as decimal, code as char).  
define var trid as rowid.
define var comchar as char.

    /*
    if sm <= 50 then return 5.0.
    if sm <= 1700 then return 15.0.
    return round((sm / 1000) * 9, 2).
    
    if lcomu then do:
        if sm <= 1501 then return 15.0.
        return round((sm / 100), 2).
    end.
    */
    
    find first tarif2 where num = "6" and kod = code and tarif2.stat = 'r' no-lock no-error.
    comchar = tarif2.pakalp.
    trid = rowid(tarif2).
    if can-find(first tarif2 where num = "6" and pakalp = comchar and 
                rowid(tarif2) <> trid and tarif2.stat = 'r')
    then do:
        l1: for each tarif2 where num = "6" and pakalp = comchar and tarif2.stat = 'r':
            if sum >= tarif2.min and
            (sum <= tarif2.max or tarif2.max = 0)
            then leave l1.
        end.
    end.

    if tarif2.ost <> 0 then return tarif2.ost.
    return sum * tarif2.proc * 0.01.
end.
