/* findtxbcif.p
 * MODULE
        Фин. мониторинг - Взаимодействие с AML
 * DESCRIPTION
        Возвращает id клиента по счету или номеру документа RMZ
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
        29/06/2010 galina
 * BASES
        BANK COMM AST
 * CHANGES
        22/07/2010 galina - добавила параметр regwho
*/

find first ast.sysc where ast.sysc.sysc = "ourbnk" no-lock no-error.
if not avail ast.sysc or ast.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.


def input parameter p-aaa as char.
def input parameter p-rmz as char.
def output parameter p-type as char.
def output parameter p-cif as char.
def output parameter p-regwho as char.

if p-aaa <> '' then do:
    find first ast.aaa where ast.aaa.aaa = p-aaa no-lock no-error.
    if avail ast.aaa then do:
        find first ast.cif where ast.cif.cif = ast.aaa.cif no-lock no-error.
        if avail ast.cif then assign p-type = "cif" p-cif = ast.cif.cif.
    end.
    else do:
        find first ast.arp where ast.arp.arp = p-aaa no-lock no-error.
        if avail ast.arp then do:
            if ast.arp.gl = 287032 or ast.arp.gl = 100200 then do:
                p-type = "cif". p-cif = "".
                find first ast.remtrz where ast.remtrz.remtrz = p-rmz no-lock no-error.
                if avail ast.remtrz then do:
                    if ast.remtrz.kfmcif <> '' then do:
                        p-cif = ast.remtrz.kfmcif.
                        if p-cif begins 'cm' then p-type = "cifm".
                    end.
                end.
            end.
            else assign p-type = "bank" p-cif = ast.sysc.chval.
        end.
    end.
end.
else do:
    p-type = "cif". p-cif = "".
    find first ast.remtrz where ast.remtrz.remtrz = p-rmz no-lock no-error.
    if avail ast.remtrz then do:
        if ast.remtrz.kfmcif <> '' then do:
            p-cif = ast.remtrz.kfmcif.
            if p-cif begins 'cm' then p-type = "cifm".
        end.
    end.
end.
if p-rmz <> '' then do:
    find first ast.remtrz where ast.remtrz.remtrz = p-rmz no-lock no-error.
    if avail ast.remtrz then do:
        if ast.remtrz.rwho <> '' and caps(ast.remtrz.rwho) <> 'SUPERMAN' then p-regwho = ast.remtrz.rwho.
        else do:
            if ast.remtrz.sbank = ast.sysc.chval then find first ast.jh where ast.jh.jh = ast.remtrz.jh1 no-lock no-error.
            /*if ast.remtrz.rbank = ast.sysc.chval then find first ast.jh where ast.jh.jh = ast.remtrz.jh2 no-lock no-error.*/
            if avail ast.jh then p-regwho = ast.jh.who.

        end.
    end.
end.


