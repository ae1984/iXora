/* tswprn.p
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

/* KOVAL ПЕЧАТЬ SWIFT МАКЕТА 
   
   06.11.02 добавил rmzparent
   suchkov 05.11.2003 - Добавил i-шку с паролем для supermana
*/

{global.i}
{comm-txb.i}
{passval.i}

def var ourcode as integer.
ourcode=comm-cod().

def new shared var s-remtrz like remtrz.remtrz label "Платеж" . 

form skip s-remtrz with frame rmzor side-label row 3 centered.
{lgps.i new}

def var l as logical init false.

update s-remtrz 
/*validate (can-find (swout where swout.rmz = s-remtrz no-lock),"Платеж не найден!" )*/
with frame rmzor.

find first swout no-lock where swout.rmz=s-remtrz use-index rmz no-error.
if not avail swout then do:
    find first swout where swout.rmzparent = s-remtrz use-index rmzchild no-lock no-error.
    if avail swout then assign s-remtrz = swout.rmz l=true no-error.
    else do:
        message "Платеж не найден!".
        leave.
    end.
end.
else l=true.

if l then if ourcode=0 then run swmt-cre(s-remtrz,g-today,"view",swout.mt,"","").
                       else do:
                             disconnect comm.
                             unix silent value("export passw=" + vpass + "; runproTXB00 swmt-cref " + trim(s-remtrz) + "," + string(g-today,"99.99.99") + ",file," + trim(swout.mt) + ",,").
                             run menu-prt('rpt.txt').
                       end.
