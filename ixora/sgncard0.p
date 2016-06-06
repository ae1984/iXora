/* sgncard0.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Управление хранилищем карточек - импорт, замена, списки файлов
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-13-3
 * AUTHOR
        29.02.2004 nadejda
 * CHANGES
*/

{mainhead.i}

{sgn.i "new"}

def var v-select as integer.

repeat:
  v-select = 0.
  run sel2 (" ХРАНИЛИЩЕ КАРТОЧЕК КЛИЕНТОВ ", 
            " 1. Список карточек| 2. Импорт новых карточек| 3. Настройки|    ВЫХОД ", 
            output v-select).

  if v-select = 0 or v-select = 4 then return.

  case v-select:
    when 1 then run sgnlist.
    when 2 then run sgnimp ("").   /* импорт всех файлов из каталога */
    when 3 then run sgnsysc.
  end case.
end.

