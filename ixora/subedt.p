/* subedt.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Меню "Справоч" в пункте 3.2.1.3 (Операции с кредитом)
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
        04/08/2009 galina
 * BASES
        BANK COMM
 * CHANGES
*/



def var v-sel as integer no-undo. 
def var v-sel1 as integer no-undo. 
def var v-chsel as char no-undo.
/*def shared var s-lon as char.*/
{global.i}
{pk.i}
    find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
    find first lon where lon.lon = pkanketa.lon no-lock no-error.
    if not avail lon then next. 
    s-lon = pkanketa.lon.
    find first cif where cif.cif = pkanketa.cif no-lock no-error.
    if not avail cif then next.

ggg:
repeat:
    
    run sel2 ("ВЫБЕРИТЕ СПРАВОЧНИК", ' 1. Признаки кредита | 2. Признаки клиента | 3. Выход ', output v-sel).
    case v-sel:
      when 1 or when 2 then do:
         if v-sel = 1 then v-chsel = ' 1. Реструктуризация | 2. Цель кредита '.
         else v-chsel = ' 1. Наемный работник| 2. Не стандартный | 3. ИП '.
         gg:
         repeat:
             v-sel1 = 0.
             run sel2 ("ВЫБЕРИТЕ ПРИЗНАК", v-chsel, output v-sel1).
             if v-sel = 1 then do:
                if v-sel1 = 1 then run sub-pklon(s-lon,'LON', 'pkrst').
                if v-sel1 = 2 then run sub-pklon(s-lon,'LON', 'pkpur').
                if v-sel1 > 0 and keyfunction(lastkey) = "END-ERROR" then next gg.
                
             end.
             if v-sel = 2 then do:
                if v-sel1 = 1 then run sub-pklon(cif.cif,'CLN', 'hwoker').
                if v-sel1 = 2 then run sub-pklon(cif.cif,'CLN', 'nonstn').
                if v-sel1 = 3 then run sub-pklon(cif.cif,'CLN', 'indbus').
                if v-sel1 > 0 and keyfunction(lastkey) = "END-ERROR" then next gg.
                
             end.
             if v-sel > 0 and keyfunction(lastkey) = "END-ERROR" then next ggg.
         end.
      end.  
      otherwise return.
    end.  
end.
