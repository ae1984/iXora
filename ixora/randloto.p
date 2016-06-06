/* randloto.p 
 * MODULE
        Программы общего назначения
 * DESCRIPTION
        Розыгрыш
 * BASES
        BANK COMM
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        randmain
 * SCRIPT
        
 * INHERIT
        rand.i
 * MENU
         
 * AUTHOR
        07/04/2008 Alex
 * CHANGES
*/

{rand.i}

def button bstr label 'START'.
def var v-greet as char format 'x(10)'.
def var c like dt-table.id.
def var v-id as int.

def frame f1 
    skip(1)
    bstr
    'Номер кредита:' v-greet
    with centered row 12 no-label title 'Акция "Беспроцентный кредит"'.

for each dt-table no-lock break by dt-table.id:
    if last-of(dt-table.id) then c = dt-table.id.
end.

on choose of bstr in frame f1 do:
    if bstr:label eq 'INFO' then apply 'window-close' to frame f1.
    
    if bstr:label eq 'START' then do:
        bstr:LABEL = 'STOP'.
        repeat:
            v-id = random(1,c) no-error.
            
            for each dt-table:
                if v-id eq dt-table.id then v-greet = dt-table.code.
            end.
            
            readkey pause 0.
            display v-greet with frame f1.
            if keyfunction(lastkey) = 'RETURN' then do:
                g-winr = v-greet.
                bstr:label = 'INFO'.
                leave.
            end.
        end. 
    end.
    
end.

ENABLE bstr WITH centered FRAME f1.
WAIT-FOR window-close of current-window.