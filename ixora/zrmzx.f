/* zrmzx.f
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

/* zrmzx.f */

define variable v-priory as character format "x(8)" .
define variable v-psbank like remtrz.sbank.

form z_remtrz " <-- " remtrz.sqn format "X(26)" " "  remtrz.rdt  skip
     remtrz.ptype  label "TYPE  "
     "     " ptyp.des no-label "   " remtrz.cover  skip
     v-psbank label "SBANK " "->" remtrz.scbank label "SCOR"
     "->" remtrz.rcbank label "RCOR" "->" remtrz.rbank  skip
     remtrz.drgl   label "DRGL  " format "zzzzz9" gl.sub format  "x(8)"
     no-label "             "
     remtrz.crgl label "CRGL    " format "zzzzz9"
      tgl.sub no-label format "x(6)"  rsub label "RSUB " skip
     remtrz.dracc label "DRACC " remtrz.fcrc   label "  F_CRC"
     acode no-label "  "
     remtrz.cracc label "CRACC   " remtrz.tcrc label "   T_CRC"
     bcode  no-label  skip
     remtrz.valdt1 label "V-DT1 " "  "
     remtrz.jh1  label " 1-TRX"
     remtrz.valdt2 label " V-DT2   " "    "
     remtrz.jh2     skip
     remtrz.sacc label "SACC  " "        "
     remtrz.racc   label "RACC    " skip
     remtrz.amt   "       " remtrz.payment label "PAYMENT " skip
     remtrz.svcrc label "SVC_CRC " remtrz.svccgr label "TARIF"
     " -  " pakal no-label format "x(35)" skip
     remtrz.svca remtrz.svcaaa remtrz.svccgl skip
     remtrz.ord    skip
     remtrz.bb label "BENEF-BANK "  skip
     remtrz.ba label "BENEF-ACCOUNT "    skip
     remtrz.bn     skip
     remtrz.bi format "x(20)" v-priory label "PRIORITY"
     with frame remtrz  side-label row 3 centered  no-box.
