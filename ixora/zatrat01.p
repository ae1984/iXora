/* zatrat01.p
 * MODULE
        справочник департаментов модуля ЗАРПЛАТЫ
 * DESCRIPTION
        справочник департаментов модуля ЗАРПЛАТЫ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        zatrat0.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        
 * AUTHOR
        14.06.05 nataly создан
 * CHANGES
*/

def  shared temp-table v-deps
      field dep as char
      field depname as char
        index dep is primary   dep .

for each alga.pd. 
create v-deps. 
   assign v-deps.dep = pd.pd
          v-deps.depname = pd.pdnos.
end.
