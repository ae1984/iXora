/* lchist
* MODULE
        Trade Finance
 * DESCRIPTION
        Описание формы
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
        19/01/2012 id00810
 * BASES
        BANK COMM
 * CHANGES
*/

form
    s-namef    label 'Filial             ' format "x(30)" skip
    v-cif      label 'Applicant code     ' validate(can-find(cif where cif.cif = v-cif no-lock) or (v-find and v-cif = ''),'Enter applicant code!') format "x(6)" ' ' v-cifname no-label format "x(35)"
    s-lc       label 'Reference Number   ' format "x(15)" validate(can-find(LC where LC.LC = s-LC and lc.bank = s-ourbank no-lock) or v-find,'Enter credit number!') skip
    v-lcsumorg label 'L/C Original Amount' format ">,>>>,>>>,>>>,>>9.99"  v-lccrc1 no-label format "x(3)" skip
    v-lcsumcur label 'L/C Current Amount ' format ">,>>>,>>>,>>>,>>9.99"  v-lccrc2 no-label format "x(3)" skip
    v-lcdtexp  label 'Expiry Date        ' format "99/99/9999" skip
    v-lcsts    label 'Credit status      ' format "x(5)" skip
    v-lcerrdes no-label format "x(60)"
    with width 70 side-label overlay centered row 3 frame frlc title s-ftitle.

on help of s-LC in frame frlc do:
    if not v-find or v-cif <> '' then do:
       {itemlist.i
         &file    = "LC"
         &frame   = "row 6 centered scroll 1 10 down width 70 overlay "
         &where   = " LC.cif = v-cif and lookup(lc.lcsts,'FIN,CLS,CNL') > 0 "
         &flddisp = " LC.LC label 'Reference Number ' format 'x(15)' LC.LCsts label 'Credit status' format 'x(15)' "
         &chkey   = "LC"
         &index   = "LC"
         &end     = "if keyfunction(lastkey) = 'end-error' then return."
         }
     end.
     if v-find and v-cif = '' then do:
        {itemlist.i
         &file    = "LC"
         &set     = "2"
         &frame   = "row 6 centered scroll 1 10 down width 70 overlay "
         &where   = "LC.bank = s-ourbank and lookup(lc.lcsts,'FIN,CLS,CNL') > 0 "
         &flddisp = " LC.LC label 'Reference Number' format 'x(15)' LC.LCsts label 'Credit status' format 'x(5)' LC.cif label 'Aplicant Code' format 'x(6)'"
         &chkey   = "LC"
         &index   = "LC"
         &end     = "if keyfunction(lastkey) = 'end-error' then return."
         }
     end.
     s-lc = LC.LC.
     displ s-LC with frame frlc.
end.
