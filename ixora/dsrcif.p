/* dsrcif.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Просмтр досье
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-13-6
 * AUTHOR
        07.02.2005 marinav
 * CHANGES
        15.06.05 marinav - добавила 3 параметр в run dsrview ( 1 - надо проверять акцепт на документах) 
*/

{mainhead.i}
{dsr.i new}

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

  run dsrview (v-cif, '', 1).
end.

