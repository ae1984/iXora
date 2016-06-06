/* lcevent.f
 * MODULE
        Trade Finance
 * DESCRIPTION
        Событие - описание формы
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
        14/03/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        27/05/2011 id00810 - переставила v-lcerrdes - описание ошибки относится к статусу события, а не аккредитива
        28/06/2011 id00810 - поменяла условие выбора по статусу
        10/08/2011 id00810 - при выборе номера события необходимо учитывать банк
        17/01/2012 id00810 - добавлена переменная - наименование филиала, изменен индекс для LC
*/

form
    s-namef    label 'Filial             ' format "x(30)" skip
    v-cif      label 'Applicant code     ' validate(can-find(cif where cif.cif = v-cif no-lock) or (v-find and v-cif = ''),'Enter applicant code!') format "x(6)" ' ' v-cifname no-label format "x(35)"
    s-lc       label 'Reference Number   ' format "x(15)" validate(can-find(LC where LC.LC = s-LC and lc.bank = s-ourbank and lookup(lc.lcsts,'FIN,CLS,CNL') > 0 no-lock) or v-find,'Enter credit number!') skip
    v-lcsumorg label 'L/C Original Amount' format ">,>>>,>>>,>>>,>>9.99" v-lccrc1 no-label format "x(3)" skip
    v-lcsumcur label 'L/C Current Amount ' format ">,>>>,>>>,>>>,>>9.99" v-lccrc2 no-label format "x(3)" skip
    v-lcdtexp  label 'Expiry Date        ' format "99/99/9999" skip
    v-lcsts    label 'Credit status      ' format "x(5)" skip(1)
    s-number   label 'Number of Event    ' validate(can-find(lcevent where lcevent.bank = s-ourbank and lcevent.lc = s-lc and lcevent.event = s-event and lcevent.number = s-number no-lock),'Enter the Number of Event!') format ">9" help "F1 - help" skip
    s-sts      label 'Event status       ' format "x(5)" skip
    v-lcerrdes no-label                    format "x(60)" skip
    with width 70 side-label overlay centered row 3 frame frevent title s-ftitle.

on help of s-lc in frame frevent do:
    if not v-find or v-cif <> '' then do:
       {itemlist.i
         &file = "LC"
         &frame = "row 6 centered scroll 1 10 down width 70 overlay "
         &where = " LC.cif = v-cif and lookup(lc.lcsts,'FIN,CLS,CNL') > 0 and lc.lc begins s-lcprod "
         &flddisp = " LC.LC label 'Reference Number ' format 'x(15)' LC.LCsts label 'Credit status' format 'x(15)' "
         &chkey = "LC"
         &index  = "lcrwhn"
         &end = "if keyfunction(lastkey) = 'end-error' then return."
         }
     end.
     if v-find and v-cif = '' then do:
        {itemlist.i
         &file = "LC"
         &set = "2"
         &frame = "row 6 centered scroll 1 10 down width 70 overlay "
         &where = "lookup(lc.lcsts,'FIN,CLS,CNL') > 0 and lc.lc begins s-lcprod and can-do(if s-event ne 'extch' then s-ourbank else '*',lc.bank) "
         &flddisp = " LC.LC label 'Reference Number' format 'x(15)' LC.LCsts label 'Credit status' format 'x(5)' LC.cif label 'Aplicant Code' format 'x(6)'"
         &chkey = "LC"
         &index  = "lcrwhn"
         &end = "if keyfunction(lastkey) = 'end-error' then return."
         }
     end.
     s-lc = lc.lc.
     displ s-lc with frame frevent.

end.

on help of s-number in frame frevent do:
    {itemlist.i
     &file = "lcevent"
     &frame = "row 6 centered scroll 1 20 down width 91 overlay "
     &where = " lcevent.lc = s-lc and lcevent.event = s-event "
     &chtype = "integer"
     &flddisp = "lcevent.number label 'Number of Event' format '>9' lcevent.sts label 'Event Status' format 'x(6)' lcevent.bank format 'x(05)' "
     &chkey = "number"
     &index = "bank"
     &end = "if keyfunction(lastkey) = 'end-error' then return."
     }
     s-number = lcevent.number.
     display s-number with frame frevent.
end.