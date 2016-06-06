/* dlncif.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Просмотр юридических дел клиентов
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * AUTHOR
        29.02.2004 dpuchkov
 * CHANGES
*/

{mainhead.i}
{dln.i new}

def var v-cif as char.
def var v-cifname as char.

v-cif = "".
v-cifname = "".

def frame f-client 
  v-cif label "КЛИЕНТ " format "x(6)" colon 10 help " Введите код клиента (F2 - поиск)"
    validate (can-find(first cif where cif.cif = v-cif no-lock), " Клиент с таким кодом не найден!")
  v-cifname no-label format "x(45)" colon 18
  with side-label row 5 no-box.

repeat on endkey undo, return:
  update v-cif with frame f-client.

  find first cif where cif.cif = v-cif no-lock no-error.
  v-cifname = trim((cif.prefix) + " " + trim(cif.name)).

  displ v-cifname with frame f-client.
  run dlnview (v-cif, yes).
end.


