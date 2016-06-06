/* checkGW.p
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
        5-3-6 5-2-1 5-9-1
 * AUTHOR
        09.09.2004 tsoy
 * CHANGES
        13.09.2004 tsoy v-is-go = false в начале цикла
        04.10.2004 tsoy убрал exclusive-lock.
        07.10.2004 tsoy проверка на банк каждого найденного совпадения по референсу.
*/

{vm-lib.i}
{global.i}
def input  parameter p-remtrz as char.
def output parameter p-is-go  as logical.

def var v-clsday  as date.
def var v-is-go   as logical.
def var v-is-go2  as logical.

find last cls no-lock.
if avail cls then 
    v-clsday =  cls.whn - 3. 
 else
    v-clsday =  g-today - 3. 

for each remtrz where remtrz.remtrz = p-remtrz no-lock.
            v-is-go  = false .    
            v-is-go2 = false .
            p-is-go = false.   
            
            for each swdt where swdt.rdt >= v-clsday  no-lock.
                if index(AllSpaceDelete(remtrz.sqn), AllSpaceDelete (swdt.ref)) > 0 then do:
                        
                        v-is-go = true.

                        if v-is-go then do:
                                   find first swhd where swhd.swid    = swdt.swid no-lock no-error.
                                   find first dfb where dfb.nostroacc = swhd.acc  no-lock no-error.
                                   if avail dfb then do:
                                      find first bankt where bankt.acc = dfb.dfb 
                                              and bankt.aut = true no-lock no-error.
                                         if avail bankt then do:                 
                                         if remtrz.sbank = bankt.cbank then do:
                                             v-is-go2 = true.
                                         end.
                                      end.
                                    end.
                        end.

                        if v-is-go and v-is-go2 and remtrz.amt = swdt.amt then  do:
                           p-is-go = true.
                           leave.
                        end.

                end.

                if index(AllSpaceDelete(remtrz.sqn), AllSpaceDelete(swdt.ref2)) > 0 then do:

                        v-is-go = true.

                        if v-is-go then do:
                                   find first swhd where swhd.swid    = swdt.swid no-lock no-error.
                                   find first dfb where dfb.nostroacc = swhd.acc  no-lock no-error.
                                   if avail dfb then do:
                                      find first bankt where bankt.acc = dfb.dfb 
                                              and bankt.aut = true no-lock no-error.
                                         if avail bankt then do:                 
                                         if remtrz.sbank = bankt.cbank then do:
                                             v-is-go2 = true.
                                         end.
                                      end.
                                    end.
                        end.

                        if v-is-go and v-is-go2 and remtrz.amt = swdt.amt then do:
                           p-is-go = true.
                           leave.
                        end.

                end.
            end.

end.
                 

