/* cif-lgot.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Редактирование льготной группы клиента
 * RUN
        верхнее меню редактирования клиента "Льгота"
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1.2
 * AUTHOR
        29.01.2004 nadejda
 * CHANGES
*/

{global.i}

define shared variable s-cif like cif.cif.
def var v-pres as char.
def var v-ans as logical.
def shared frame cif. 

{cif.f}

find cif where cif.cif = s-cif no-lock no-error.
if not available cif then return.

do transaction on error undo, retry:
  find current cif exclusive-lock.

  v-pres = cif.pres. 
  update cif.pres with frame cif. 
  
  if cif.pres <> "" then 
    update cif.legal with frame cif.

  run defexcl.
end.
release cif.


/* обработка вида льготного обслуживания */
procedure defexcl.
  def var p-ans as logical.

  /* установка льготных тарифов, если выбран вид льготного обслуживания или очистить, если льгота отменена */
  if cif.pres <> v-pres then do:
    v-ans = yes.
    message skip " Установить/снять ЛЬГОТНЫЕ тарифы для данного клиента?"
            skip(1) view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-ans.
    if v-ans then do:
      /* очистить старые льготы */
      if v-pres <> "" then run value("clnlgot-" + v-pres) (cif.cif, "", no).
      /* установить новые льготы */
      if cif.pres = "" then do:
        cif.legal = "".
        displ cif.legal with frame cif.
        pause 0.
      end.
      else run value("clnlgot-" + cif.pres) (cif.cif, "", yes). 

      run clntarifex (cif.cif).
    end.
    else cif.pres = v-pres.
  end.
end procedure.

