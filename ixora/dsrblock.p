/* dsrblock.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Блокирование досье
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
{dsr.i new}

def var v-cif as char.
def var v-cifname as char.
def var ja as log format "да/нет" init no.

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

  ja = no.

  find first dsr where dsr.cif = v-cif  no-lock no-error .
  if not avail dsr then do:
      message skip    " В базе нет досье на этого клиента ! "
              skip(1) view-as alert-box button ok 
              title " ВНИМАНИЕ ! ".

     return.
  end.

  find first dsr where dsr.cif = v-cif and dsr.bdt ne ? no-error.
  if avail dsr then do:
      message skip    " Досье блокировано!!!~n Разблокировать ? "
              skip(1)  
              view-as alert-box button yes-no title " ВНИМАНИЕ ! " update ja.
      if ja then do: 
         for each dsr where dsr.cif = v-cif:
            assign dsr.bdt = ? dsr.bwho = ''.
         end.
      end.
  end.

  else do:
      message skip    " Блокировать досье? "
              skip(1)  
              view-as alert-box button yes-no title " ВНИМАНИЕ ! " update ja.
      if ja then do: 
         for each dsr where dsr.cif = v-cif:
            assign dsr.bdt = today dsr.bwho = g-ofc.
         end.
      end.
  end.
end.

