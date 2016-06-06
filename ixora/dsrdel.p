/* dsrdel.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Удаление досье
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-13-6
 * AUTHOR
        15.02.2005 marinav
 * CHANGES
*/

{mainhead.i}
{dsr.i}

def var v-cif as char.
def var v-cifname as char.
def var ja as log format "да/нет" init no.
def var v-cod as char.
def var v-name as char.
def var v-num as inte.
def var i as inte.
def buffer b-ofc for ofc.

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


  /***** Проверка на профит-центр - кто обслуживает клиента, тот и изменяет *********/
    find first cif where cif.cif = v-cif no-lock no-error.
    find first ofc where ofc.ofc = g-ofc no-lock no-error.
    find first b-ofc where b-ofc.ofc = cif.fname no-lock no-error.
    if avail ofc and avail b-ofc then do:
           if ofc.titcd ne b-ofc.titcd then do:
               message " Ваше подразделение не имеет право на изменение/удаление досье клиента - " + v-cif . 
               pause 100.
               return.
           end.
      end.
      else do:
            message " Не найден менеджер, обслуживающий клиента - " + v-cif + "  " + cif.fname. 
            pause 100.
            return.
      end.
    

  find first dsr where dsr.cif = v-cif no-lock no-error.
  if not avail dsr then do:
      message skip    " В базе нет досье на этого клиента ! "
              skip(1) view-as alert-box button ok 
              title " ВНИМАНИЕ ! ".

     return.
  end.

  find first dsr where dsr.cif = v-cif and dsr.bdt ne ? no-lock no-error.
  if avail dsr then do:
      message skip    " Досье клиента заблокировано!~n Удаление невозможно! "
              skip(1) view-as alert-box button ok 
              title " ВНИМАНИЕ ! ".

     return.
  end.
   
  ja = no.
  pause 0.
  run uni_book ("sgndoc", "*", output v-cod).
  v-num = num-entries(v-cod).

    
  message skip    " Удалить докукменты ? "
              skip(1)  
              view-as alert-box button yes-no title " ВНИМАНИЕ ! " update ja.
      if ja then do: 
         do i = 1 to v-num:
            find first dsr where dsr.cif = v-cif and dsr.docs = entry(i, v-cod) no-error.
            if avail dsr then do:
               assign dsr.sts = 'D' dsr.adt = ? dsr.awho = '' dsr.udt = today  dsr.uwho = g-ofc.
               create dsrhis.
               buffer-copy dsr to dsrhis.
               assign dsrhis.rdt = today
               dsrhis.rtim = time
               dsrhis.rwho = g-ofc
               dsrhis.action = "DEL" .              
            end.
         end.
         message skip    " Докукменты удалены!~n Требуется акцепт контролера! "
              skip(1)  
              view-as alert-box button ok title " ВНИМАНИЕ ! " update ja.
      end.

end.

