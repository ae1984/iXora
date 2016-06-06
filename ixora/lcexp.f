/* lcexp.f
 * MODULE
        Expire - закрытие
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
        24/02/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        15/04/2011 id00810 - заголовок формы
        24/06/2011 id00810 - переставила v-lcerrdes, поменяла услвие выбора по статусу
        17/01/2012 id00810 - добавлена переменная - наименование филиала, изменен индекс для LC
*/

form
    s-namef   label 'Filial                        ' format "x(30)" skip
    v-cif     label 'Applicant code                ' format "x(6)"  validate(can-find(cif where cif.cif = v-cif no-lock) or (v-find and v-cif = ''),'Enter applicant code!') ' ' v-cifname no-label format "x(24)"
    s-lc      label 'Reference Number              ' format "x(15)" validate(can-find(LC where LC.LC = s-LC and lc.bank = s-ourbank and lookup(lc.lcsts,'FIN,CLS,CNL') > 0 no-lock) or v-find,'Enter credit number!') skip
    v-lcsum1  label 'Outstanding Collateral Balance' format ">,>>>,>>>,>>>,>>9.99"  v-lccrc1 no-label format "x(3)" skip
    v-lcsum2  label 'Claims/Obligations            ' format ">,>>>,>>>,>>>,>>9.99"  v-lccrc2 no-label format "x(3)" skip
    v-lcdtexp label 'Expiry Date                   ' format "99/99/9999" skip
    v-lcsts   label 'Credit status                 ' format "x(5)"       skip(1)
    s-sts     label 'Status of Event               ' format "x(5)"       skip
    v-lcerrdes no-label                              format "x(60)"      skip
    with width 70 side-label overlay centered row 3 frame frexp title s-ftitle.

on help of s-LC in frame frexp do:
    if not v-find or v-cif <> '' then do:
       {itemlist.i
         &file    = "LC"
         &frame   = "row 6 centered scroll 1 10 down width 70 overlay "
         &where   = " LC.cif = v-cif and lookup(lc.lcsts,'FIN,CLS,CNL') > 0 and lc.lc begins s-lcprod "
         &flddisp = " LC.LC label 'Reference Number ' format 'x(15)' LC.LCsts label 'Credit status' format 'x(15)' "
         &chkey   = "LC"
         &index   = "lcrwhn"
         &end     = "if keyfunction(lastkey) = 'end-error' then return."
         }
     end.
     if v-find and v-cif = '' then do:
        {itemlist.i
         &file    = "LC"
         &set     = "2"
         &frame   = "row 6 centered scroll 1 10 down width 70 overlay "
         &where   = "LC.bank = s-ourbank and lookup(lc.lcsts,'FIN,CLS,CNL') > 0 and lc.lc begins s-lcprod "
         &flddisp = " LC.LC label 'Reference Number' format 'x(15)' LC.LCsts label 'Credit status' format 'x(5)' LC.cif label 'Aplicant Code' format 'x(6)'"
         &chkey   = "LC"
         &index   = "lcrwhn"
         &end     = "if keyfunction(lastkey) = 'end-error' then return."
         }
     end.
     s-lc = LC.LC.
     displ s-LC with frame frexp.
end.
