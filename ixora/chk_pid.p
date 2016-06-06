/* chk_pid.p
 * MODULE
        монитор процессов ПС
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        15.06.2012 evseev
 * BASES
        BANK COMM
 * CHANGES
*/

def new shared var s-errpid as char no-undo.
def var i as int no-undo.
def var v-maillist as char no-undo.
def var v-param as char no-undo.


find sysc where sysc.sysc = "pid_param" no-lock no-error.
if avail sysc then do:
   v-param = sysc.chval.
end. else do transact:
   create sysc.
   sysc.sysc = "pid_param".
   sysc.chval = "".
end.

{r-branch.i &proc = "chk_pid-txb(v-param)"}

if s-errpid <> "" then do:
    s-errpid = " 1        2         3         4              5                          6" +
               "~n---------------------------------------------------------------------------------------------~n" + s-errpid.
    do i = 1 to 5:
       find sysc where sysc.sysc = "pid_mail" + string(i) no-lock no-error.
       if avail sysc then do:
          v-maillist = sysc.chval.
          run mail(v-maillist, "PID <errpid@metrocombank.kz>", "Проблема с процессами ПС!!!", s-errpid, "1", "", "").
       end. else if i = 1 then do transact:
          create sysc.
          sysc.sysc = "pid_mail" + string(i).
          sysc.chval = "id00787@metrocombank.kz".
       end.
    end.
end.