/* 4Nrmt.p
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

{lgps.i}
def new shared var sold-remtrz like shtbnk.remtrz.remtrz . 
def new shared var s-remtrz like shtbnk.remtrz.remtrz .
def shared var rhost as cha.
def shared var v-weekbeg as int.
def shared var v-weekend as int.
def shared var g-today as date .

if connected("shtbnk") then
    for each shtbnk.que where shtbnk.que.pid = "4N"
                        and shtbnk.que.con = "W"
                        use-index fprc no-lock.
        find first shtbnk.remtrz of shtbnk.que no-lock.
        if shtbnk.remtrz.sbank = rhost then do:
            sold-remtrz = shtbnk.remtrz.remtrz . 
            run psrecv.
        end.
    end. 
 
if connected("shtbnk") then
    for each shtbnk.que where shtbnk.que.pid = "8"
                        and shtbnk.que.con = "W" use-index fprc no-lock.
        find first shtbnk.remtrz of shtbnk.que no-lock.
        if shtbnk.remtrz.sbank = rhost then do:
            s-remtrz = shtbnk.remtrz.remtrz . 
            run psrconf.
        end. 
    end. 

if connected("shtbnk") then
    for each shtbnk.que where shtbnk.que.pid = "8A"
                        and shtbnk.que.con = "W" use-index fprc no-lock.
        find first shtbnk.remtrz of shtbnk.que no-lock.
        if shtbnk.remtrz.sbank = rhost then do:
            s-remtrz = shtbnk.remtrz.remtrz .
            run psrconf1.
        end.
    end.
