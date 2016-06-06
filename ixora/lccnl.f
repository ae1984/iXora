/* lccnl.f
 * MODULE
        Cancel - аннулирование
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
        10.07.2012 Lyubov
 * BASES
        BANK COMM
 * CHANGES
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
    v-rcacc   label 'Risk commission account       ' format "x(1)" validate(can-find (codfr where codfr.codfr = 'lcrcacc' and codfr.code = v-rcacc no-lock),'Enter the Risk commission account!') help "F2-help" v-rcaname no-label format "x(45)" skip
    with width 70 side-label overlay centered row 3 frame frcnl title s-ftitle.

on help of s-LC in frame frcnl do:
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
     displ s-LC with frame frcnl.
end.
on help of v-rcacc in frame frcnl do:
    {itemlist.i
     &file    = "codfr"
     &frame   = "row 6 centered scroll 1 20 down width 91 overlay "
     &where   = " codfr.codfr = 'lcrcacc' and codfr.code <> 'msc' "
     &flddisp = " codfr.code label 'Code' format 'x(8)' codfr.name[1] label 'value' format 'x(80)' "
     &chkey   = "code"
     &index   = "cdco_idx"
     &end     = "if keyfunction(lastkey) = 'end-error' then return."
    }
    assign v-rcacc     = codfr.code
           v-rcaname   = codfr.name[1].
    display v-rcacc v-rcaname with frame frcnl.
end.