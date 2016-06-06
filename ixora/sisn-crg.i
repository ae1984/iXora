/* sisn-crg.i
 * MODULE
        PRAGMA
 * DESCRIPTION
        ОБщая для вывода кнопок через верхнее меню
        Специально для пункта 1.2
        Копия из sisn.i
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK COMM
 * AUTHOR
        06.11.2003 sasco
 * CHANGES
        07.11.2003 sasco - разрешено открывать счета без проверки на {&checkpermission}
        22.06.2004 nadejda - разрешено выполнять различные пункты верхнего меню, если они не редактируют данные клиента
                             настройка на разрешение запуска пункта - в настройке пунктов верхнего меню
        12.01.2009 galina - добавила проверку наличия пункта верхнего меню перед вызовом процедуры
        22.01.2009 galina - явно указала ширину фрейма menu
        12/03/09 marinav - проверка клиента на специнструкции
        30.10.2013 evseev tz-1890
*/

/* sisn.i
*/

define shared variable s-{&headkey} like {&head}.{&headkey}.
define shared variable s-newrec as logical.
define shared frame {&pre}{&head}{&post}.

define variable v-ans as logical.
define variable v-procro as char.
define variable v-max as integer init 15.
def buffer b-cif for cif.

function isAcceptCif returns logical.
   find first b-cif where b-cif.cif = g-cif no-lock no-error.
   if avail cif then do:
      find last crg where crg.crg = b-cif.crg and crg.stn = 1 use-index crg no-lock no-error.
      if avail crg then return yes. else return no.
   end. else return no.
end function.

/*


*/


{opt-prmt.i}

find {&head} where {&head}.{&headkey} eq s-{&headkey}.

{nlvar.i new
"s-main = ""SUB"". s-opt = ""{&option}"". s-page = 1."}

if "{&noedt}" eq "true" then s-noedt = true.
if "{&nodel}" eq "true" then s-nodel = true.

{&variable}

s-page = 1.
run nlmenu.

form s-sign[1] s-menu s-sign[2] with frame menu width 110 col 1 row 1 no-box no-label.

{{&pre}{&head}{&post}.f}
{&frame}

{&start}
main:
repeat:
  hide message.
  {&predisplay}
  {&display}
  {&postdisplay}
  view frame {&pre}{&head}{&post}.
  {&viewframe}

  choose:
  repeat:
    display s-sign s-menu with no-box no-label frame menu.
    if s-newrec eq true then leave choose.
    choose field s-menu no-error with frame menu.
    if keyfunction(lastkey) eq "CURSOR-RIGHT" and frame-index eq v-max
    then do:
      if s-sign[2] ne ">" then do:
        bell.
      end.
      else do:
        s-page = s-page + 1.
        run nlmenu.
      end.
    end.
    else
    if keyfunction(lastkey) eq "CURSOR-LEFT" and frame-index eq 1
    then do:
      if s-sign[1] ne "<" then do:
        bell.
      end.
      else do:
        s-page = s-page - 1.
        run nlmenu.
      end.
    end.
    else
    if keyfunction(lastkey) eq "RETURN" or
       keyfunction(lastkey) eq "GO" then leave choose.
    else do:
      bell.
    end.
  end. /* choose */

  if keyfunction(lastkey) eq "END-ERROR" then leave main.

  if s-page eq 1 and (frame-index eq 1 or frame-index eq 2) or s-newrec eq true then do:
    do transaction on error undo, retry:
    if isAcceptCif() then do:
       bell.
       message 'Для редактирования необходимо снять акцепт карточки клиента в п.м. 1.1.4 «Контроль признаков клиента»' view-as alert-box.
    end. else do:
        if s-newrec eq true or frame-index eq 1 and s-menu[1] ne " " then do:
          if {&checkpermission} then do:
             {&no-update}
             {&preupdate}
                  {&update}
                  {&postupdate}
             s-newrec = false.
          end.
          else do:
             if isAcceptCif() = no then do:
               {&nopermission}
             end. else message 'Для редактирования необходимо снять акцепт карточки клиента в п.м. 1.1.4 «Контроль признаков клиента»' view-as alert-box.
          end.
        end.
        else
        if frame-index eq 2 and s-menu[2] ne " " then do:
          if {&checkpermission} then do:
             bell.
             {mesg.i 0824} update v-ans.
             if v-ans eq false then do:
               bell.
               undo, next main.
             end.
             {&no-delete}
                {&predelete}
                {&delete}
                {&postdelete}
             clear frame {&pre}{&head}{&post}.
             {&clearframe}
             leave main.
          end.
          else do:
             if isAcceptCif() = no then do:
                {&nopermission}
             end. else message 'Для редактирования необходимо снять акцепт карточки клиента в п.м. 1.1.4 «Контроль признаков клиента»' view-as alert-box.
          end.
        end. end.
    end.
  end.
  else  do:
    find optitem where optitem.optmenu eq s-opt and optitem.ln eq (s-page - 1) * v-max + frame-index - 2 no-lock no-error.
    if avail optitem then do:
        run savelog("sisn-crg", optitem.proc + " " + g-cif ).
        if isAcceptCif() and lookup(optitem.proc, "cif-joi,cif-jol,subcif,cif-cmp,cif-chk,cif-ref,pipl,founder,cif-ost,cif-dep") > 0 then do:
           bell.
           message 'Для редактирования необходимо снять акцепт карточки клиента в п.м. 1.1.4 «Контроль признаков клиента»' view-as alert-box.
        end. else do:
            if chkrights(optitem.proc) then do:
              if search(optitem.proc + ".r") <> ? then do:
                if {&checkpermission} or
                   chkavail_run(s-opt, optitem.proc) = "yes" or
                   (chkavail_run(s-opt, optitem.proc) <> "yes" and chkproc-ro(s-opt, optitem.proc) <> "") then do:
                  if not ({&checkpermission}) and (chkavail_run(s-opt, optitem.proc) <> "yes" and chkproc-ro(s-opt, optitem.proc) <> "") then do:
                    run value(chkproc-ro(s-opt, optitem.proc)).
                  end. else
                    run value(optitem.proc).
                  pause 0.
                end.
                else do transaction on error undo, retry:
                  if isAcceptCif() = no then do:
                     {&nopermission}
                  end. else message 'Для редактирования необходимо снять акцепт карточки клиента в п.м. 1.1.4 «Контроль признаков клиента»' view-as alert-box.
                end.
              end.
              else do:
                {mesg.i 0210}.
              end.
            end.
            else do:
              v-procro = chkproc-ro(s-opt, optitem.proc).
              if v-procro = "" or v-procro = "?" then do:
                bell.
                message "   У вас нет прав для выполнения процедуры " + optitem.proc + " !"
                    view-as alert-box button ok title "".
              end.
              else do:
                if search(v-procro + ".r") <> ? then do:
                  run value(v-procro).
                  pause 0.
                end.
                else do:
                  {mesg.i 0210}.
                end.
              end.
            end.
        end.
    end.
  end.
end. /* main */
{&end}

