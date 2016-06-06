/* dsrcard0.i
 * MODULE
        Клиентская база
 * DESCRIPTION
    -------------    Копия 1-13 Хранилище карточек подписей -----------------------------
        Управление хранилищем досье - импорт, замена, списки файлов
        
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-13-6
 * AUTHOR
        07.02.2005 marinav
 * CHANGES
*/

{mainhead.i}

{dsr.i "new"}

def var v-select as integer.

repeat:
  v-select = 0.
  run sel2 (" ХРАНИЛИЩЕ ДОСЬЕ КЛИЕНТОВ ", 
            " 1. Список документов| 2. Добавление / Изменение  документов| 3. Удаление документов | 4. Настройки|    ВЫХОД ", 
            output v-select).

  if v-select = 0 or v-select = 5 then return.

  case v-select:
    when 1 then run dsrlist (1).
    when 2 then run dsrimp ("").   /* импорт всех файлов из каталога */
    when 3 then run dsrdel.
    when 4 then run dsrsysc.
  end case.
end.

