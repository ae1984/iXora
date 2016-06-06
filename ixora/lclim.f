/* lclim.f
 * MODULE
        Trade Finance
 * DESCRIPTION
        Limits - Описание фрейма
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14.7.1.1
 * AUTHOR
        16/09/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        17/01/2012 id00810 - добавлена переменная - наименование филиала
*/

form
    s-namef     label 'Filial         ' format "x(30)" skip
    s-cif       label 'Applicant code ' validate(can-find(cif where cif.cif = s-cif no-lock) or (v-find and s-cif = ''),'Enter applicant code!') format "x(6)" ' ' v-cifname no-label format "x(40)"
    s-number    label 'Number of Limit' validate(can-find(lclimit where lclimit.bank = s-ourbank and lclimit.number = s-number no-lock) or v-find,'Enter the Number of Limit!') format ">9" help "F2 - help" skip
    v-limsumorg label 'Original Amount' format ">,>>>,>>>,>>>,>>9.99" v-limcrc1 no-label format "x(3)" skip
    v-limsumcur label 'Current Amount ' format ">,>>>,>>>,>>>,>>9.99" v-limcrc2 no-label format "x(3)" skip
    v-limdtexp  label 'Expiry Date    ' format "99/99/9999" skip
    v-limsts    label 'Status         ' format "x(5)" skip
    v-limerrdes no-label format "x(60)"
    with width 70 side-label overlay centered row 3 frame frlclimit title s-ftitle.

on help of s-number in frame frlclimit do:
    if not v-find or s-cif <> '' then do:
        {itemlist.i
        &file    = "lclimit"
        &set     = "1"
        &frame   = "row 6 centered scroll 1 20 down width 91 overlay "
        &where   = " lclimit.bank = s-ourbank and lclimit.cif = s-cif "
        &chtype  = "integer"
        &flddisp = "lclimit.cif label 'Client#' format 'x(06)' lclimit.number label 'Number of Limit' format '>9' lclimit.sts label 'Limit Status' format 'x(6)' "
        &chkey   = "number"
        &index   = "bcn"
        &end     = "if keyfunction(lastkey) = 'end-error' then return."
        }
     end.
     else do:
        {itemlist.i
        &file    = "lclimit"
        &set     = "2"
        &frame   = "row 6 centered scroll 1 20 down width 91 overlay "
        &where   = " lclimit.bank = s-ourbank "
        &chtype  = "integer"
        &flddisp = "lclimit.cif label 'Client#' format 'x(06)' lclimit.number label 'Number of Limit' format '>9' lclimit.sts label 'Limit Status' format 'x(6)' "
        &chkey   = "number"
        &index   = "bcn"
        &end     = "if keyfunction(lastkey) = 'end-error' then return."
        }
        s-cif = lclimit.cif.
     end.
     s-number = lclimit.number.
     display s-number with frame frlclimit.
end.