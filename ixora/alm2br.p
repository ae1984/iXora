/* alm2br.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Копирование шаблона с базы Алматы на базы филиалов
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
        08/12/2004 madiyar
 * CHANGES
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        28/02/2008 madiyar - разбранчевка с учетом банк-мко
        25/04/2012 evseev  - rebranding. разбранчевка с учетом банк-мко.
        27/04/2012 evseev  - повтор
*/

def var v-templ as char.
def var ja as logi init yes.

find bank.sysc where bank.sysc.sysc = "ourbnk" no-lock no-error.
if not avail bank.sysc or bank.sysc.chval = "" then do:
     message " There is no record OURBNK in bank.sysc file !!".
     pause. return.
end.
if trim(bank.sysc.chval) <> "TXB00" then do:
  message " Запуск только в Головном Банке! ".
  pause. return.
end.

find first bank.cmp no-lock no-error.
if not avail bank.cmp then do:
    message " Не найдена запись cmp " view-as alert-box error.
    return.
end.

def var v-path as char no-undo.

if bank.cmp.name matches ("*МКО*") then v-path = '/data/'.
else v-path = '/data/b'.

update skip(1)
       v-templ label " Шаблон для копирования     " skip
       ja label " Копировать на все филиалы? " skip
       skip(1)
       with side-label centered row 7 frame fr.

hide frame fr.

for each comm.txb where comm.txb.consolid and comm.txb.is_branch no-lock:
    if keyfunction(lastkey) = "end-error" then do:
      if connected ("txb") then disconnect "txb".
      return.
    end.
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run alm2br2(v-templ,ja).
end.
if connected ("txb") then disconnect "txb".

if ja then hide message no-pause.




