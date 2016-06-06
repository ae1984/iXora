/* binchk.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Проверка БИН/ИИН
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        cif-joi.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        24/06/2008 alex
 * BASES
        BANK
 * CHANGES
*/

def var dtchk as char.
def var binchk as char.
def var axchk as char.
  
find first sub-cod where sub-cod.acc eq cif.cif no-lock no-error.
if avail(sub-cod) then do:

    if (cif.type eq ""B"") and (cif.cgr eq 403) then do:
        dtchk = substr(replace(string(cif.expdt, ""99.99.99""), ""."", """"), 5, 2) + substr(replace(string(cif.expdt, ""99.99.99""), ""."", """"), 3, 2).
        if cif.geo = ""021"" then axchk = ""4"".
        else axchk = ""5"".
        binchk = substr(cif.bin, 1, 5).
        if binchk ne dtchk + axchk then message ""Неправильно введён БИН"" view-as alert-box.
        else leave.
    end.
    
    else do:
    
        dtchk = substr(replace(string(cif.expdt, ""99.99.99""), ""."", """"), 5, 2) + substr(replace(string(cif.expdt, ""99.99.99""), ""."", """"), 3, 2) +  substr(replace(string(cif.expdt, ""99.99.99""), ""."", """"), 1, 2).
        find first sub-cod where (sub-cod.acc eq cif.cif) and (sub-cod.d-cod eq ""clnsex"") no-lock no-error.
        if avail(sub-cod) then do:
        
            if (sub-cod.ccode eq ""01"") then do:            
                if (year(cif.expdt) le 1900) then axchk = ""1"".
                if (year(cif.expdt) ge 1899) and (year(cif.expdt) le 2000) then axchk = ""3"".
                if (year(cif.expdt) ge 1999) and (year(cif.expdt) le 2100) then axchk = ""5"".
            end.
            else
                if (sub-cod.ccode eq ""02"") then do:                
                    if (year(cif.expdt) le 1900) then axchk = ""2"".
                    if (year(cif.expdt) ge 1899) and (year(cif.expdt) le 2000) then axchk = ""4"".
                    if (year(cif.expdt) ge 1999) and (year(cif.expdt) le 2100) then axchk = ""6"".
                end.
                
        else message ""Проставьте признаки клиента в справочнике"" view-as alert-box.
        
        binchk = substr(cif.bin, 1, 7).
        
        if binchk ne dtchk + axchk then message ""Неправильно введён ИИН"" view-as alert-box.
        else leave.
    end.
    else message ""Проставьте признаки клиента в справочнике"" view-as alert-box.
end.                

end.