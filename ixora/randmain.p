/* randmain.p 
 * MODULE
        Программы общего назначения
 * DESCRIPTION
        Розыгрыш
 * BASES
        BANK COMM TXB
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        randfilial
 * SCRIPT
        
 * INHERIT
        rand.i randloto
 * MENU
         
 * AUTHOR
        07/04/2008 Alex
 * CHANGES
*/

{rand.i "new"}

def var dt1 as date no-undo.
def var dt2 as date no-undo.
def var k as int no-undo.

def var v-lcnt as char no-undo.
def var v-name as char no-undo.

def frame dat.

dt2 = today - 1.
dt1 = date(month(dt2),1,year(dt2)).

update dt1 label ' Укажите период с ' format '99/99/9999' dt2 label ' по ' format '99/99/9999' skip
       with side-label row 5 centered frame dat.
hide frame dat.

for each txb.lon where txb.lon.rdt ge dt1 and txb.lon.rdt le dt2 and txb.lon.opnamt gt 0 and txb.lon.opnamt le 500000 no-lock:
    k = k + 1.
    create dt-table.
    dt-table.code = txb.lon.lon.
    dt-table.id = k.
end.

/*for each dt-table:
    display dt-table.
end.*/

run randloto.

find first txb.lon where g-winr eq txb.lon.lon no-lock no-error.
if avail txb.lon then do:
    
    v-lcnt = ''. v-name = ''.
    find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    if avail txb.cif then v-name = txb.cif.name.
    find first txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
    if avail txb.loncon then v-lcnt = txb.loncon.lcnt.
    
    display txb.loncon.lcnt format "x(15)" label 'Договор' skip
            txb.lon.rdt format "99/99/9999" label "От" skip
            txb.cif.name label 'Имя' format "x(50)" skip
            txb.lon.opnamt label 'Сумма кредита' format ">>>,>>>,>>9.99" skip
            with side-labels centered frame f1 title 'Победитель акции "Беспроцентный кредит"'.
     
end.