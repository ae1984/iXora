/* elcedt.f
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

/* elcedt.f
*/


form rim.lcno colon 11
     rim.ref colon 50 skip
     rim.bank colon 11 label "IZLD.BANKA"
     bank.name no-label skip
     rim.grp colon 11
     rim.crc colon 11 label "AKR SUMMA " rim.amt[1] no-label
     rim.tol colon 50 skip
     vcrc colon 11 label "ATLIKUM" vbal no-label skip
     rim.rdt colon 11 skip
     rim.idt colon 11 rim.expdt colon 50 skip
     rim.tennor colon 11 help "1.UZR…DOT  2.PЁC UZR…D.  3.KONOSAMN"
     rim.trm colon 50  skip
     rim.fee colon 11 label "BANK.MAKS"
     rim.intpay colon 50 label "PROCENTU TIPS" help "1.PIESKT. 2.ATLAIDE " skip
     rim.cif colon 11 LABEL "IZDEV" rim.party no-label skip
     rim.acc colon 11 skip
     rim.rem colon 11 skip
     rim.amt[4] colon 11 label "INF MKS" vcnt colon 50 skip
     with width 80 row 3 side-label centered
     overlay frame rim.
     /*
     rim.lcno rim.ref rim.bank rim.grp rim.ref rim.crc rim.amt[1] rim.tol
     vcrc vbal rim.rdt rim.idt rim.expdt rim.tennor  rim.trm rim.fee
     rim.intpay  rim.cif rim.party rim.acc rim.rem rim.amt[4] vcnt
     */

form cmd
     with centered no-box no-label row 21 frame slct.
