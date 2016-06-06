/* chk_que.p
 * MODULE
        проверка очередей на наличие зависших платежей
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
        12.06.2012 evseev
 * BASES
        BANK COMM
 * CHANGES
*/


def new shared var s-errque as char no-undo.
def var i as int no-undo.
def var v-maillist as char no-undo.
def var v-param as char no-undo.


find sysc where sysc.sysc = "que_param" no-lock no-error.
if avail sysc then do:
   v-param = sysc.chval.
end. else do transact:
   create sysc.
   sysc.sysc = "que_param".
   sysc.chval = "".
end.

{r-branch.i &proc = "chk_que-txb(v-param)"}

if s-errque <> "" then do:
    s-errque = " 1            2     3           4              5         6                   7" +
               "~n---------------------------------------------------------------------------------------------~n" + s-errque.
    s-errque = s-errque + "~n~n1 - филиал~n2 - имя очереди~n3 - количество платежей на очереди~n4 - время простоя~n5 - время простоя в секундах~n6 - таймаут в секундах~n7 - описание очереди".
    s-errque = s-errque + "~n~n" + "Если платежи на очереди не являются зависшими, то на тех.поддержку сообщите новое время ожидания(таймаут) в минутах".
    do i = 1 to 5:
       find sysc where sysc.sysc = "que_mail" + string(i) no-lock no-error.
       if avail sysc then do:
          v-maillist = sysc.chval.
          run mail(v-maillist, "QUE <errque@metrocombank.kz>", "На очередях зависли платежи!!!", s-errque, "1", "", "").
       end. else if i = 1 then do transact:
          create sysc.
          sysc.sysc = "que_mail" + string(i).
          sysc.chval = "id00787@metrocombank.kz".
       end.
    end.
end.