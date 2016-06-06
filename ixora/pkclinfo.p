/* pkcifnew.p
 * MODULE
        Потребительские кредиты
 * DESCRIPTION
        Создать нового клиента 
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        
 * MENU
        4-x-4-
 * AUTHOR
        01.02.2004 nadejda
 * CHANGES
*/

{mainhead.i}

def new shared var s-cif like cif.cif.

update skip(1) 
  s-cif label " КОД КЛИЕНТА" 
    validate (can-find(cif where cif.cif = s-cif and cif.type = "P" no-lock), " Клиент не найден или не является физлицом!")
  " " skip(1)
  with centered row 6 side-labels title "[ ВЫБЕРИТЕ КЛИЕНТА ]" frame f-cif.


run cif-infe.

