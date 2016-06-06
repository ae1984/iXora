/* rnn-is-client.p
 * MODULE
         Общий
 * DESCRIPTION
        Проверка по РНН является ли владелец клиентом бака
 * RUN

 * CALLER
     pkcash.p
     pkdebr1.p
     pkkritlib.p
     pkmonall.p
     pkrepgr.p
 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        02.05.2004 tsoy
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        04/03/2008 madiyar - подправил разбранчевку (МКО-Банк)
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
        27/04/2012 evseev  - повтор
*/


def input parameter v-rnn as char.
def input-output parameter v-ans as logical.

def var v-is-client as logical.
v-ans = no.

def var v-path as char no-undo.

find first bank.cmp no-lock no-error.
if not avail bank.cmp then do:
    message " Не найдена запись cmp " view-as alert-box error.
    return.
end.

if bank.cmp.name matches "*МКО*" then v-path = '/data/'.
else v-path = '/data/b'.

for each comm.txb where comm.txb.consolid = true no-lock:
  if connected ("txb") then disconnect "txb".
  connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
         run rnn-is-client2 (v-rnn, input-output v-is-client).
         if v-is-client then do:
                v-ans = yes.
                leave.
         end.
end.

if connected ("txb") then disconnect "txb".



