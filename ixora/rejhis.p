/* rejhis.p
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
	29/08/06 u00121 заменил nawk на awk
*/


 def shared var v-ref as cha .
 def var v-hst as cha.
 def var v-log as cha.
 find sysc where sysc.sysc = "ourbnk" no-lock no-error .
 if not avail sysc or sysc.chval = "" then do:
  display " This isn't record OURBNK in sysc file !!".
  pause .
  undo .
  return .
 end.

v-hst = trim(sysc.chval).
 find sysc where sysc.sysc = "PS_LOG" no-lock no-error .
 if not avail sysc or sysc.chval = "" then do:
  display " This isn't record PS_LOG in sysc file !!".
  pause .
  undo .
  return .
 end.
 find first reject where reject.ref = v-ref no-lock no-error .

 v-log = trim(sysc.chval).
  display "W A I T " with centered frame www . pause 0 .
  unix silent value("awk 'index($0,""" + v-ref + """) != 0 \{print
  $0\}' "    + v-log + trim(v-hst) + "_logfile.lg." + 
  string(reject.whn,"99.99.9999") + " >  tmp_rps.img " ).    /*29/08/06 u00121 заменил nawk на awk*/
  hide frame www.

  hide frame www.
  unix ps_less tmp_rps.img.

