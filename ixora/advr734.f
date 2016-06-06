/* advr734.f
 * MODULE
        Advice of Refusal
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
        17/03/2011 evseev
 * BASES
        BANK COMM
 * CHANGES
        17/01/2012 id00810 - добавлена переменная - наименование филиала, изменен индекс для LC
*/

form
    s-namef    label 'Filial             ' format "x(30)" skip
    v-cif      label 'Applicant code     ' validate(can-find(cif where cif.cif = v-cif no-lock) or (v-find and v-cif = ''),'Enter applicant code!') format "x(6)" ' ' v-cifname no-label format "x(35)"
    s-lc       label 'Reference Number   ' format "x(15)" validate(can-find(LC where LC.LC = s-LC and lc.bank = s-ourbank and LC.lcsts = 'FIN' no-lock) or v-find,'Enter credit number!') skip
    v-lcsumorg label 'L/C Original Amount' format ">,>>>,>>>,>>>,>>9.99" v-lccrc1 no-label format "x(3)" skip
    v-lcsumcur label 'L/C Current Amount ' format ">,>>>,>>>,>>>,>>9.99" v-lccrc2 no-label format "x(3)" skip
    v-lcdtexp  label 'Expiry Date        ' format "99/99/9999" skip
    v-lcsts    label 'Credit status      ' format "x(5)" skip(1)
    s-number   label 'Number of Event    ' validate(can-find(LCevent where LCevent.LC = s-LC and Lcevent.event = s-event and LCevent.number = s-number no-lock),'Enter the Number of Advice of Refusal!') format ">9" help "F2 - help" skip
    s-sts      label 'Event status       ' format "x(5)" skip
    v-lcerrdes no-label format "x(60)" skip
    with width 70 side-label overlay centered row 3 frame frcor title ' ADVICE OF REFUSAL '.

on help of s-LC in frame frcor do:
    if not v-find or v-cif <> '' then do:
       {itemlist.i
         &file    = "LC"
         &frame   = "row 6 centered scroll 1 10 down width 70 overlay "
         &where   = " LC.cif = v-cif and lc.lcsts = 'FIN' "
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
         &where   = "LC.bank = s-ourbank and lc.lcsts = 'FIN' "
         &flddisp = " LC.LC label 'Reference Number' format 'x(15)' LC.LCsts label 'Credit status' format 'x(5)' LC.cif label 'Aplicant Code' format 'x(6)'"
         &chkey   = "LC"
         &index   = "lcrwhn"
         &end     = "if keyfunction(lastkey) = 'end-error' then return."
         }
     end.
     s-lc = LC.LC.
     displ s-LC with frame frcor.
end.

on help of s-number in frame frcor do:
    {itemlist.i
     &file    = "LCevent"
     &frame   = "row 6 centered scroll 1 20 down width 91 overlay "
     &where   = " LCevent.LC = s-lc and LCevent.event = s-event and LCevent.number > 0"
     &chtype  = "integer"
     &flddisp = "LCevent.number label 'Number' format '>9' LCevent.sts label 'Status' format 'x(6)' LCevent.rwhn label 'Date' "
     &chkey   = "number"
     &index   = "bank"
     &end     = "if keyfunction(lastkey) = 'end-error' then return."
     }
     s-number = LCevent.number.
     display s-number with frame frcor.
end.