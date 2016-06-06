/* r-brfilial.i
 * MODULE
        Программы общего назначения
 * DESCRIPTION
        Запуск отчетов по текущему филиалу или в ЦО - выбор консолидированный/филиалы
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        01.04.2004 nadejda
 * CHANGES
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        13/12/2007 madiyar - определение базы (МКО или Банк)
        06/01/08 marinav - исправлен путь к базам с /data/9/ на  /data/
        15/03/2012 id00810 - название банка из sysc
        19/03/2012 id00810 - добавила указание на базу bank
        25/04/2012 evseev  - rebranding. разбранчевка с учетом банк-мко.
        27/04/2012 evseev  - повтор
        04/02/2013 zhasulan - ТЗ 1459 (передаем logname для столбца "Филиал")
        25.09.2013 damir - Внедрено Т.З. № 1869. Убрал logname.
*/

find first bank.cmp no-lock no-error.
if not avail bank.cmp then do:
    message " Не найдена запись cmp " view-as alert-box error.
    return.
end.

def var v-path as char no-undo.

/*find first bank.sysc where bank.sysc.sysc = 'bankname' no-lock no-error.
if avail bank.sysc and bank.cmp.name matches ("*" + bank.sysc.chval + "*")  then v-path = '/data/b'.
else v-path = '/data/'.*/

/*if bank.cmp.name matches "*ForteBank*" then v-path = '/data/b'.
else v-path = '/data/'.*/

if bank.cmp.name matches ("*МКО*") then v-path = '/data/'.
else v-path = '/data/b'.

find bank.sysc where bank.sysc.sysc = "ourbnk" no-lock no-error.
find comm.txb where comm.txb.consolid and comm.txb.bank = bank.sysc.chval no-lock no-error.

if not comm.txb.is_branch then do:
  {sel-filial.i}
end.
else do:
  v-select = comm.txb.txb + 2.
end.


for each comm.txb where comm.txb.consolid and
         (if v-select = 1 then true else comm.txb.txb = v-select - 2) no-lock:
    if connected ("txb") then disconnect "txb".
    if bank.cmp.name matches ("*МКО*") and (comm.txb.txb=0 or comm.txb.txb=3 or comm.txb.txb=5 or comm.txb.txb=7 or comm.txb.txb=8 or comm.txb.txb=9 or comm.txb.txb=10 or comm.txb.txb=11 or comm.txb.txb=12 or comm.txb.txb=13 or comm.txb.txb=14 or comm.txb.txb=15) then next.
    connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run {&proc}.
end.

if connected ("txb")  then disconnect "txb".


def var v-bankname as char.

if v-select = 1 then do:
  find first bank.cmp no-lock no-error.
  v-bankname = bank.cmp.name + "<br>Консолидированный отчет".
end.
else do:
  find comm.txb where comm.txb.consolid and comm.txb.txb = v-select - 2 no-lock no-error.
  v-bankname = comm.txb.name.
end.



