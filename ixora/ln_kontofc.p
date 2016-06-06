/* ln_kontofc.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Поиск текущего офицера в списке контролеров
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-1-11
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        09.09.2003 nadejda - ужесточила контроль штамповки - теперь только по списку контролеров (4-3-7)
        20.07.2004 tsoy    - добавил департамент авторизации
*/

{global.i}

def input parameter p-jhofc like ofc.ofc. /* офицер, сделавший проводку, которую надо проконтролировать - ищется его департамент */
def input parameter p-msg as logical. /* выдавать или нет предупреждающие сообщения */
def output parameter p-ans as logical. /* возврат ДА - можно контролировать */

def var v-dep as char.

p-ans = yes.

find sysc where sysc.sysc = "loncon" no-lock no-error.
if avail sysc and sysc.chval <> "" then do:
  if lookup (g-ofc, sysc.chval) = 0 then do:
    if p-msg then message skip " Вы не являетесь контролером проводок по ссудным счетам !" skip(1) view-as alert-box button ok title "".
    p-ans = no.
  end.
  else do:
    if entry (lookup (g-ofc, sysc.chval) + 1, sysc.chval) <> "0" then do:
      find ofc where ofc.ofc = g-ofc no-lock no-error.
      v-dep = ofc.titcd.
      find ofc where ofc.ofc = p-jhofc no-lock no-error.
      if v-dep <> ofc.titcd and v-dep <> "523" then do:
        if p-msg then message skip " Вы не являетесь контролером по департаменту офицера" p-jhofc "!" skip(1) view-as alert-box button ok title "".
        p-ans = no.
      end.
    end.
  end.
end.

