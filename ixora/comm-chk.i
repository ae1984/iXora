/* comm-chk.i
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
*/

/* нужно заранее определить переменную seltxb */

function comm-chk returns logical (ref as char, dat as date ).

  def var test as logical init false.
  def var v-users as char init "". 

  find first commonpl where txb = seltxb and deluid = ? and date = dat and
                            joudoc = ? and commonpl.arp = ref no-lock no-error.

  if available commonpl then do:

          test = true.
   
          for each commonpl no-lock where commonpl.txb = seltxb and
                                          commonpl.deluid = ? and
                                          commonpl.date = dat and
                                          commonpl.joudoc = ? and
                                          commonpl.arp = ref
                                          break by commonpl.uid:
           if first-of(uid) then v-users = "~n" + commonpl.uid + v-users.
          end.

          MESSAGE "Есть платежи, не зачисленные на транз. счета" +
          "~nКассиры: " + v-users VIEW-AS ALERT-BOX TITLE "Внимание".

  end.

  return test.

end.
