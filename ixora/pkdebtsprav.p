/* pkdebtsprav.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Справочники по работе с задолжниками
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-14-6
 * AUTHOR
        13.02.2004 suchkov
 * CHANGES
        24.02.2006 Natalya D. - добавила справочник причин.
*/

define variable v-select as integer no-undo.
define variable v-bookcod as character no-undo. 
def var hbookcod as handle.
run bookcod persistent set hbookcod.

repeat:
    v-select = 0.
    run sel2 (" РЕДАКТИРОВАНИЕ СПРАВОЧНИКОВ ", " 1. Справочник действий | 2. Справочник результатов | 3. Статусы | 4. Причины |    ВЫХОД ", output v-select).
    if v-select = 0 then return.
    
    case v-select:
        when 1 then do:
            v-bookcod = "pkdbtact".
            find bookref where bookref.bookcod = v-bookcod no-lock .
            run bookank in hbookcod (bookref.bookcod, '*', yes).
        end.
        when 2 then do:
            v-bookcod = "pkdbtres".
            find bookref where bookref.bookcod = v-bookcod no-lock .
            run bookself in hbookcod (bookref.bookcod, '*', yes).
        end.
        when 3 then do:
            v-bookcod = "pkdbtsts".
            find bookref where bookref.bookcod = v-bookcod no-lock .
            run bookself in hbookcod (bookref.bookcod, '*', yes).
        end.
        when 4 then do:
            v-bookcod = "pkdbtinf".
            find bookref where bookref.bookcod = v-bookcod no-lock .
            run bookself in hbookcod (bookref.bookcod, '*', yes).
        end.
        when 5 then return.
    end.
end.
