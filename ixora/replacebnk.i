/* .p
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
        07/05/2012 evseev
 * BASES
        BANK
 * CHANGES
*/



function del_city returns char (input parm1 as char).
    def var s as char.
    def var s1 as char.
    def var i as int.
    if not(parm1 matches '*филиал*') then do:
        if parm1 matches '*АО *' then do:
            s1 = ''.
            do i = 1 to num-entries (parm1, ' '):
               s = entry (i,parm1, ' ').
               if  s matches '*г~~.*' then next.
               if s1 <> "" then s1 = s1 + " ".
               s1 = s1 + s.
            end.
        end. else s1 = parm1.
    end. else s1 = parm1.
    return s1.
end function.


function replace_bnamebik returns char (input parm1 as char, input dt as date).
    def var s as char.
    def var s1 as char.
    s1 = parm1.
    s1 = replace(s1,'ForteBank','ForteBank').
    if dt < 05/07/2012 then do:
       s1 = replace(s1,'ForteBank','МЕТРОКОМБАНК').
       s1 = replace(s1,'FOBAKZKA','MEOKKZKA').
    end. else do:
       if not(parm1 matches '*филиал*') then do:
          s1 = replace(s1,'МЕТРОКОМБАНК','ForteBank').
       end.
       s1 = replace(s1,'MEOKKZKA','FOBAKZKA').
    end.
    /*message parm1 s1 . pause.*/
    return s1.
end function.