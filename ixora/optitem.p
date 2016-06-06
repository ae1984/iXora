/* optitem.p
 * MODULE
        Главное меню
 * DESCRIPTION
        Редактирование списка пунктов верхнего меню с настройками и выдачей прав доступа
 * RUN
        
 * CALLER
        optmenu.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        9-1-4-2
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        22.06.2004 nadejda - добавлена настройка на разрешение запуска пункта, если там проверяется запрет на редактирование
                             настройка пишется вторым параметром в optitem.des
*/

def shared var s-optmenu like optitsec.optmenu .
def new shared var s-optproc like optitsec.proc .
def var v-menu like optlang.menu.
def var v-des like optlang.des.
def var v-ro like optitem.des.
def var v-rec as recid.
def var v-ln like optitem.ln.
def var v-avail_run as char.

{global.i}
{opt-prmt.i}

{jabrw.i   
&start = " "
&head = " optitem"
&headkey = "optmenu "
&index = " optitem "
&formname = " optitem"
&framename = " optitem "
&where = " optitem.optmenu = s-optmenu "
&addcon = " true "
&deletecon = " true "
&prechoose = " message 'F4-Выход, INS-вставка, F10-удаление, Пробел-права доступа'. "
&predisplay = " if avail optitem then do: find optlang where optlang.lang eq g-lang and 
                 optlang.ln eq optitem.ln and optlang.optmenu eq s-optmenu no-lock no-error. 
                 if avail optlang then do: v-menu = optlang.menu. v-des = optlang.des. end. 
                 else do: v-menu = ''. v-des = ''. end. 
                 v-ro = chkproc-ro(optitem.optmenu, optitem.proc). 
                 v-avail_run = chkavail_run(optitem.optmenu, optitem.proc).
               end. 
               else do: v-menu = ''. v-des = ''. v-ro = ''. v-avail_run = ''. end.  "
&display = " optitem.ln optitem.proc v-menu v-des v-ro v-avail_run "
&postcreate = " run postcrp. "
&preupdate = " find optlang where optlang.lang eq g-lang and
                 optlang.ln eq optitem.ln and optlang.optmenu eq s-optmenu no-error. 
               if not avail optlang then do: 
                 create optlang. 
                 optlang.optmenu = s-optmenu. 
                 optlang.lang = g-lang. 
                 optlang.ln = optitem.ln. 
               end.
               v-menu = optlang.menu. v-des = optlang.des. 
               v-ro = chkproc-ro(optitem.optmenu, optitem.proc). 
               v-avail_run = chkavail_run(optitem.optmenu, optitem.proc).
"
&update = " optitem.ln optitem.proc v-menu v-des v-ro v-avail_run "
&postupdate = " optlang.ln = optitem.ln. optlang.menu = v-menu. optlang.des = v-des. 
                optitem.des = trim(v-ro). v-avail_run = trim(v-avail_run). 
                if v-avail_run <> '' then optitem.des = optitem.des + ',' + trim(v-avail_run).
"
&prevdelete = " run predeletep. "
&highlight = " optitem.ln "
&end = " hide frame optitem. "
&postkey  = " if keyfunction(lastkey) = ' ' then do: 
                s-optproc = optitem.proc. 
                run ofcsel_opt. 
                next inner. 
              end. "
}


procedure predeletep.
  find optlang where optlang.lang = g-lang and optlang.ln eq optitem.ln and 
     optlang.optmenu eq optitem.optmenu no-error.
  if avail optlang then delete optlang. 
  find optitsec where optitsec.optmenu = optitem.optmenu and optitsec.proc = optitem.proc no-error. 
  if avail optitsec then delete optitsec.
end procedure.

procedure postcrp.
  v-rec = recid(optitem). 
  find last optitem where optitem.optmenu = s-optmenu use-index optitem no-error. 
  if available optitem then v-ln = optitem.ln + 1. else v-ln = 1. 
  find optitem where recid(optitem) = v-rec. 
  optitem.optmenu = s-optmenu. 
  optitem.ln = v-ln. 
end procedure.
