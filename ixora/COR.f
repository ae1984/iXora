/* COR.f
 * MODULE
        корреспонденция
 * DESCRIPTION
        Описание
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
        18.10.2012 Lyubov
 * BASES
        BANK COMM
 * CHANGES

*/

form
    s-namef    label 'Filial             ' format "x(30)" skip
    s-lc       label 'Reference Number   ' format "x(15)" validate(can-find(LC where LC.LC = s-LC and lc.bank = s-ourbank no-lock) or v-find,'Enter credit number!') skip
    v-lcsts    label 'Credit status      ' format "x(5)" skip
    v-lcerrdes no-label format "x(60)"
    with width 70 side-label overlay centered row 3 frame frlc title s-ftitle.

on help of s-LC in frame frlc do:
    if not v-find then do:
       {itemlist.i
         &file    = "LC"
         &frame   = "row 6 centered scroll 1 10 down width 70 overlay "
         &where   = " lc.lc begins s-lcprod "
         &flddisp = " LC.LC label 'Reference Number ' format 'x(15)' LC.LCsts label 'Credit status' format 'x(15)' "
         &chkey   = "LC"
         &index   = "lcrwhn"
         &end = "if keyfunction(lastkey) = 'end-error' then return."
         }
     end.

     s-lc = LC.LC.
     displ s-LC with frame frlc.

end.
