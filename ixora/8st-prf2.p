/* 8st-prf2.p
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
        24.05.2003 nadejda - убраны параметры -H -S из коннекта 
        21.01.2004 sasco   - раскомментировал запуск lond152
        09.09.2004 suchkov - переписал коннекты.
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/

def  shared var v-pass as char.

for each comm.txb where comm.txb.consolid = true /*and txb.txb = 0*/ no-lock:

    if connected ("txb") then disconnect "txb".
    connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
    run 8st-prf11.
    run 8st-prf22.
    run lond127.
    run lond130.
    run lond131.
    run lond140.
    run lond152.
end.
    
if connected ("txb") then disconnect "txb".
if connected ("comm") then disconnect "comm".



