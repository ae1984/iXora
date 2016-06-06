/* dlncard0.p
 * MODULE

 * DESCRIPTION

 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * AUTHOR
        02.08.2004 dpuchkov
 * CHANGES
*/

{mainhead.i}
{dln.i "new"}
def var v-select as integer.
repeat:
  v-select = 0.
  run sel2 (" ХРАНИЛИЩЕ ЮР.ДЕЛ КЛИЕНТОВ ", 
            " 1. Список юр.дел| 2. Импорт новых дел| 3. Настройки|    ВЫХОД ", 
            output v-select).
  if v-select = 0 or v-select = 4 then return.
  case v-select:
    when 1 then run dlnlistr.      /*просмотр*/
    when 2 then run dlnimp ("").   /* импорт всех файлов из каталога */
    when 3 then run dlnsysc.       /*настройки*/
  end case.
end.

