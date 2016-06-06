/* glarp.p
 * MODULE
        Pragma
 * DESCRIPTION
        Список действующих счетов ГК с детализацией АРП - ВЫБОР ФИЛИАЛА
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        glarp-txb.p
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        20/01/2005 sasco
 * CHANGES
        27/01/2005 sasco Вывод только действующих счетов ГК + последние проводки
        27/01/2005 sasco Поиск проводок по ГК в обратном порядке по датам
        31.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/

def var v-filials as char.
def var v-txb as integer.

for each txb where txb.consolid no-lock:
  if v-filials <> "" then v-filials = v-filials + "|".
  v-filials = v-filials + string(txb.txb + 1) + ". " + txb.name.
end.

v-txb = 0.

run sel2 (" ВЫБЕРИТЕ ОФИС/ФИЛИАЛ БАНКА ", v-filials, output v-txb).

if v-txb = 0 then return.
v-txb = v-txb - 1.

if connected ('txb') then disconnect 'txb'.

find first comm.txb where comm.txb.txb = v-txb and comm.txb.consolid and comm.txb.visible no-lock no-error.

connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 

run glarp-txb.p.

if connected ('txb') then disconnect 'txb'.
