/* bookcred.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Редактирование справочника видов кредитов
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-6-3
 * AUTHOR
        22.01.2003 nadejda
 * CHANGES
        28.11.2003 nadejda  - убрала перевод кода в цифры, сортировка просто по коду

*/


{mainhead.i}

def var v-title as char.
def var v-cod as char init "credtype".
def var v-ans as logical.

find bookref where bookref.bookcod = v-cod no-lock no-error.
v-title = bookref.bookname.

displ "<ENTER> - редактир.,  <INS> - вставка,  <Ctrl-D> - удаление"
  with centered row 21 no-box frame footer.


{jabrw.i 

&start     = " "
&head      = "bookcod"
&headkey   = "bookcod"
&index     = "main"
&formname  = "bookcred"
&framename = "bookcod"
&where     = " bookcod.bookcod = v-cod "
&addcon    = " true "
&deletecon = " true "
&predelete = " " 
&precreate = " "
&postcreate = " assign bookcod.bookcod = v-cod
                       bookcod.regdt = g-today
                       bookcod.regwho = g-ofc 
                       bookcod.upddt = g-today 
                       bookcod.updwho = g-ofc. 
                       bookcod.treenode = v-cod. "
&update    = " bookcod.code bookcod.name bookcod.info[1] " 
&postupdate = " bookcod.treenode = v-cod + bookcod.code. 
                run checkmenu. " 
&prechoose = " "
&predisplay = "  "
&display   = " bookcod.code bookcod.name bookcod.regdt bookcod.regwho bookcod.info[1] "
&highlight = " bookcod.code bookcod.name bookcod.regdt bookcod.regwho bookcod.info[1] "
&postkey   = " "
&end       = " hide frame bookcod. hide frame footer. "
}

def temp-table t-nmenu like nmenu.
def temp-table t-nmdes like nmdes.
def buffer b-bookcod for bookcod.
def buffer b-sysc for sysc.
def var v-father as char.

procedure checkmenu.
  def var v-cred1 as char.
  find first b-bookcod where b-bookcod.bookcod = v-cod use-index main no-lock no-error.
  v-cred1 = caps(b-bookcod.info[1]).

  /* копирование пунктов меню */
  find first nmenu where caps(nmenu.fname) = caps(bookcod.info[1]) + "LON" no-lock no-error.
  if not avail nmenu then do:
    v-ans = yes.
    message skip(1) " Пункт главного меню для данного вида кредитов не найден !"
            skip(1) " Добавить недостающие пункты меню ?" skip(1) 
            view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-ans.
    if v-ans then do:
      for each t-nmenu. delete t-nmenu. end.
      for each t-nmdes. delete t-nmdes. end.
      
      run cp-menu(v-cred1 + "LON").

      find nmenu where caps(nmenu.fname) = caps(b-bookcod.info[1]) + "LON" no-lock no-error.

      v-father = nmenu.father.
      find last nmenu where nmenu.father = v-father use-index nmenu no-lock no-error.

      find t-nmenu where t-nmenu.father = v-father.
      t-nmenu.ln = nmenu.ln + 1.

      find t-nmdes where t-nmdes.fname = t-nmenu.fname.
      t-nmdes.des = replace(replace(bookcod.name, "'", ""), '"', "") + " ФЛ".

      for each t-nmenu:
        substr(t-nmenu.fname, 1, 2) = caps(bookcod.info[1]).
        if t-nmenu.father <> v-father then substr(t-nmenu.father, 1, 2) = caps(bookcod.info[1]).
        find nmenu where nmenu.fname = t-nmenu.fname no-lock no-error.
        if not avail nmenu then do:
          create nmenu.
          buffer-copy t-nmenu to nmenu.
        end.
      end.

      for each t-nmdes:
        substr(t-nmdes.fname, 1, 2) = caps(bookcod.info[1]).
        find nmdes where nmdes.fname = t-nmdes.fname no-lock no-error.
        if not avail nmdes then do:
          create nmdes.
          buffer-copy t-nmdes to nmdes.
        end.
      end.
    end.
  end.

  /* копирование параметров в sysc */
  for each b-sysc where b-sysc.sysc begins v-cred1 no-lock:
    find first sysc where sysc.sysc = caps(bookcod.info[1] + substr(b-sysc.sysc, 3)) no-lock no-error.
    if not avail sysc then do:
      create sysc.
      assign sysc.sysc = caps(bookcod.info[1] + substr(b-sysc.sysc, 3))
             sysc.des = b-sysc.des
             sysc.inval = b-sysc.inval
             sysc.chval = b-sysc.chval
             sysc.loval = b-sysc.loval
             sysc.deval = b-sysc.deval
             sysc.daval = b-sysc.daval
             sysc.sts = b-sysc.sts
             sysc.stc = b-sysc.stc.
    end.
  end.

end procedure.

procedure cp-menu.
  def input parameter p-fname as char.

  find nmenu where caps(nmenu.fname) = p-fname no-lock no-error.
  create t-nmenu.
  buffer-copy nmenu to t-nmenu.

  for each nmdes where nmdes.fname = p-fname no-lock:
    create t-nmdes.
    buffer-copy nmdes to t-nmdes.
  end.

  for each nmenu where caps(nmenu.father) = p-fname no-lock:
    run cp-menu (nmenu.fname).
  end.
end.
