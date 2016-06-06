/* sixn.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        21/02/2008 madiyar - максимальное число пунктов верхнего меню v-max = 15
        12.01.2009 galina - добавила проверку наличия пункта верхнего меню перед вызовом процедуры
        12/03/09 marinav - проверка клиента на специнструкции
        03.05.2011 ruslan - добавил проверку для 3.2.6
        20.05.2011 ruslan - убрал проверку lon.sts
*/

 /* sixn.i
*/

define new shared variable s-{&headkey} like {&head}.{&headkey}.
define new shared variable s-newrec as logical.

define new shared frame {&pre}{&head}{&post}.
define new shared frame menu.
def buffer b{&head} for {&head}.
define variable v-procro as char.
def var v-log as logical init false.

define var v-max as int initial 15.
def var list1 as char initial "20,60,81,82,90,92".

{opt-prmt.i}

{nlvar.i new
"s-main = ""MAIN"". s-opt = ""{&option}"". s-page = 1."}

{&variable}

s-page = 1.
run nlmenu.

form s-sign[1] s-menu s-sign[2] with frame menu col 1 row 1 width 110 no-box no-label.

{{&pre}{&head}{&post}.f}
{&frame}

{&start}

main:
repeat:
  hide message no-pause.
  clear frame {&pre}{&head}{&post}.
  {&clearframe}
  view frame {&pre}{&head}{&post}.
  {&viewframe}

  choose:
  repeat:
    display s-sign s-menu with no-box no-label frame menu.
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
  end.


  if keyfunction(lastkey) eq "END-ERROR" then leave main.

  if s-page eq 1 and (frame-index eq 1 or frame-index eq 2) then do:

    if frame-index eq 1 then do:
          {&no-find}
          {&prefind}
          prompt {&head}.{&headkey}
            with frame {&pre}{&head}{&post}.
          find {&head} using input {&head}.{&headkey} no-error.
          /*проверка группы счетов 236 и 237 при запуске из 3.2.6*/
          if "{&cred}" = "yes" then do:
            for each lon where lon.cif = {&head}.{&headkey} no-lock:
                 if lookup (string(lon.grp), list1) > 0 then do:
                     if not available {&head} then do:
                     message "Данный клиент не вашего департамента" view-as alert-box.
                     return.
                    end.
                    s-{&headkey} = input {&head}.{&headkey}.
                    {&postfind}
                    display {&head}.{&headkey} with frame {&pre}{&head}{&post}.
                    pause 0.
                 end.
                 else do:
                    return.
                 end.
            end.
          end.
          else do:
              if not available {&head} then do:
                 {mesg.i 0232}.
                 bell. undo, retry.
              end.
              s-{&headkey} = input {&head}.{&headkey}.
              {&postfind}
              display {&head}.{&headkey} with frame {&pre}{&head}{&post}.
              pause 0.
          end.
    end.
    else

    if frame-index eq 2 then do:
         {&no-add}
/*         do transaction on error undo, retry:*/

           if "{&numsys}" begins "prompt" then do:
            prompt {&head}.{&headkey} with frame {&pre}{&head}{&post}.
            find {&head} using input {&head}.{&headkey} no-error.
            if available {&head} then do:
              {mesg.i 0238}.
              bell. next.
            end.
            s-{&headkey} = input {&head}.{&headkey}.
            hide message.
            {&preadd}
            do trans on error undo, retry:
               create {&head}.
               {&head}.{&headkey} = s-{&headkey}.
            end.
           end.
           else if "{&numsys}" begins "auto" then do:

                 if "{&keytype}" begins "integer" or  "{&keytype}" begins "decimal"  then do:
                   {&preadd}
                   do trans on error undo, retry:
                       create {&head}.
                       find last b{&head} no-lock no-error.
                       if available b{&head}
                         then {&head}.{&headkey} = {&keytype}(integer({&head}.{&headkey}) + 1).
                         else {&head}.{&headkey} = {&keytype}(1).
                       s-{&headkey} = {&head}.{&headkey}.
                   end.
                 end.

                 else  if "{&keytype}" begins "string" then do:
                    {&checkrnn}
                    if v-log = true then leave main.
                    do trans on error undo, retry:
                       find nmbr where nmbr.code = "{&nmbrcode}" exclusive-lock.
                       s-{&headkey} = {&keytype}(nmbr.prefix + string(nmbr.nmbr + 1) + nmbr.sufix).
                       nmbr.nmbr = nmbr.nmbr + 1.
                       release nmbr.
                       {&preadd}
                       create {&head}.
                       {&head}.{&headkey} = s-{&headkey}.
                    end.

                 end.
           end.

           else if "{&numsys}" begins "prog" then do:
               {&preadd}
               run {&numprg}.
               find {&head} where {&head}.{&headkey} = s-{&headkey}.
           end.
           do trans on error undo, retry:
              {&postadd}
           end.
           display {&head}.{&headkey} with frame {&pre}{&head}{&post}.
           pause 0.
           s-newrec = true.
/*         end. */
    end. /* add */
    run {&subprg} .
    s-newrec = false.
    s-page = 1.
    s-main = "MAIN".
    s-opt = "{&option}".
    run nlmenu.
  end.
  else do:
/*
    find optitem where optitem.optmenu eq s-opt and optitem.ln eq (s-page - 1) * v-max + frame-index - 2 no-lock no-error.
    if avail optitem then do:
        displ optitem. pause 100.
        if chkrights(optitem.proc) then do:
          if search(optitem.proc + ".r") <> ? then do:
            run value(optitem.proc).
            pause 0.
          end.
          else do:
            {mesg.i 0210}.
          end.
        end.
        else do:
          v-procro = chkproc-ro(s-opt, optitem.proc).
          if v-procro = "" then do:
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
    end.*/
  end.
end. /* main */
{&end}



