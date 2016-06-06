/* vcpartna.p
 * MODULE
        Валютный контроль 
 * DESCRIPTION
        Акцепт данных об инопартнере
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        15-6-4, 15-7-1
 * AUTHOR
        18.10.2002 nadejda
 * CHANGES
*/

{vc.i}

{global.i}
{nlvar.i}

def shared var s-partner like vcpartners.partner.
def var v-ans as logical init no.

find vcpartners where vcpartners.partner = s-partner no-error.
if avail vcpartners then do:
  if vcpartners.cdt = ? then do:
    message " Утвердить данные инопартнера? " update v-ans.
    if v-ans eq false then do:
      bell.
      leave.
    end.
    else do:
      vcpartners.cdt = g-today.
      vcpartners.cwho = g-ofc.
      s-noedt = true.
      s-nodel = true.
      s-page = 1.
      run nlmenu.
    end.
  end.
  else do:
    message " Снять отметку об утверждении данных? " update v-ans.
    if v-ans eq false then do:
      bell.
      leave.
    end.
    else do:
      vcpartners.cdt = ?.
      vcpartners.cwho = ''.
      s-noedt = false.
      s-nodel = false.
      s-page = 1.
      run nlmenu.
    end.
  end.
end.


