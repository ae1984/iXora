/* trxsub.p
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
        03/07/08 marinav - изменение форм  
*/

def shared var g-lang as char.
{trxsublv.f}

{jabro.i
&start     = "view frame trxsub.
              view frame trxsublv."
&head      = "trxsub"
&headkey   = "subled"
&index     = "subled"
&formname  = "trxsub"
&framename = "trxsub"
&where     = "true"
&addcon    = "true"
&deletecon = "true"
&predelete = " " 
&precreate = " "
&postadd    = "update trxsub.subled trxsub.des with frame trxsub." 
&prechoose = 
 "message 'F4-выход,INS-доб, L-уровень S-Справочники T-Статусы F10-удаление'. 
              clear frame trxsublv all.
              for each trxsublv where trxsublv.subled = trxsub.subled no-lock:
                  disp trxsublv.level trxsublv.des with frame trxsublv.
                  down with frame trxsublv.
              end."
&predisplay = " "
&display   = " trxsub.subled trxsub.des"
&highlight = " trxsub.subled trxsub.des"
&postkey   = "else if keyfunction(lastkey) = 'RETURN' then do transaction
                                             on endkey undo, next inner:
              find trxsub where recid(trxsub) = crec exclusive-lock.
                update trxsub.des with frame trxsub.
              end.
              else if keyfunction(lastkey) = 'L' then do:
                run trxsublv.
              end.
              else if keyfunction(lastkey) = 'S' then do:
                run subdic(trxsub.subled).
              end.
              else if keyfunction(lastkey) = 'T' then do:
                run stsset(trxsub.subled).
              end.
              "
&end = "hide frame trxsub.
        hide frame trxsublv."
}
hide message.

PROCEDURE trxsublv.
{jabro.i
&start     = "view frame trxsublv."
&head      = "trxsublv"
&headkey   = "subled"
&index     = "subledlv"
&formname  = "trxsublv"
&framename = "trxsublv"
&where     = "trxsublv.subled = trxsub.subled"
&addcon    = "true"
&deletecon = "true"
&predelete = " " 
&postcreate = "trxsublv.subled = trxsub.subled."
&postadd = "   update trxsublv.level /*validate(trxsublv.level > 0,'')*/ 
                                  with frame trxsublv.
               update trxsublv.des with frame trxsublv." 
&prechoose = "message 'F4-выход,INS-доб, F10-удаление'".
&predisplay = " "
&display   = "trxsublv.level trxsublv.des"
&highlight = "trxsublv.level trxsublv.des"
&postkey   = "else if keyfunction(lastkey) = 'RETURN' then do transaction
                                             on endkey undo, next inner:
                 find trxsublv where recid(trxsublv) = crec exclusive-lock.
                 update trxsublv.des with frame trxsublv.
              end."
&end = "hide frame trxsublv."
}
END procedure.

