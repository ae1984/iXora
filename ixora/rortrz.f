/* rortrz.f
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
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

form remtrz.remtrz   remtrz.cover  skip
     remtrz.rdt   remtrz.jh1    skip
     remtrz.fcrc   label "PAYMENT-CRC"
     acode label "" remtrz.amt label "PAYMENT"  skip
     remtrz.tcrc label "REMIT-CRC"
     ccode label "" remtrz.payment label "REMIT-AMOUNT" skip
     "”””””””””””””””””””””””””” Customer Remittance Payment By ””””””””””””””””””””"
     skip
     v-outcode label "PAY-TYPE" skip
     v-pnp label "SUB-LED" skip
     "”””””””””””””””””””””””””” Service Charge Payment By ”””””””””””””””””””””””””"
     skip
     remtrz.svcrc label "CURRENCY" bcode label ""
     remtrz.svca label "SVC-CHG"  skip
     v-chg label "CHG-TYPE" remtrz.svcaaa  label "ACCOUNT" skip
     remtrz.svccgl label "CHG-GL" skip
     remtrz.ord label "ORDER-BY" skip
     "””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””"
     remtrz.detpay[1] label "PIEZ§MES"
     remtrz.detpay[2] label "" skip
     "””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””"
     v-priory label "PRIORITY"
     with frame rortrz 4 col row 3 centered .
