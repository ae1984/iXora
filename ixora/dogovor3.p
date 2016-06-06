/* dogovor3.p
 * MODULE
        Депозиты
 * DESCRIPTION

 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK COMM
 * AUTHOR
        02.07.2013 evseev - tz-1909
 * CHANGES
*/


def var s-aaa like aaa.aaa.

update s-aaa label "Номер счета" with centered overlay color message row 5 frame f-aaa.
hide frame f-aaa.

run dogovorEx(s-aaa,'1').