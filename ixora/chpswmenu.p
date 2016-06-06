/* chpswmenu.p
 * MODULE
        Администрирование ИКСОРЫ
 * DESCRIPTION
        При входе в ПРАГМУ - проверка даты последней смены пароля, если больше 30 дней, то запросить смену пароля
 * RUN
        
 * CALLER
        nmenu.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        вход в ПРАГМУ
 * AUTHOR
        09.12.2003 nadejda
 * CHANGES
*/

{global.i}

def var v-newpswd as logical init no.
def var v-daypswd as integer init 30.

find ofc where ofc.ofc = g-ofc no-lock no-error.

/* первый вход юзера - записать дату первого входа и отсчитывать смену пароля от нее */
if ofc.visadt = ? then do:
  find current ofc exclusive-lock.
  ofc.visadt = today.   
  find current ofc no-lock.
end.
else do:
  /* для суперюзеров и ДИТ смену пароля не запрашиваем! */
  find sysc where sysc.sysc = "SUPUSR" no-lock no-error.
/*  if lookup(g-ofc, sysc.chval) = 0 and ofc.titcd <> "508" then do: */ /*id00024 - 14-Jun-2010 */
  if lookup(g-ofc, sysc.chval) = 0 then do:
    find sysc where sysc.sysc = "SYSPWD" no-lock no-error.
    if avail sysc then v-daypswd = sysc.inval.

    /* если прошло больше 30 дней, то запросить смену пароля */
    if today - ofc.visadt > v-daypswd then do:
      run chpsw0 (no, output v-newpswd).
      /* если отказался вводить новый пароль - выскакиваем из ПРАГМЫ */
      if not v-newpswd then quit.
    end.
  end.
end.

