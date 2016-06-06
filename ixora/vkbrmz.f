/* vkbrmz.f
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


def var v-priory as cha format "x(8)" .
def var pakal like tarif2.pakalp.
def var v-psbank like remtrz.sbank.
def var v-cor as  cha format "x(11)".

form remtrz.remtrz label "Платеж"
     " <-- " remtrz.sqn label "Nr." format "X(26)" " "  
     remtrz.rdt label "Рег.дата" skip
     remtrz.ptype  label "Тип   "
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
     v-cor label "NOR.CENTRA S/KONTS "    skip
       remtrz.bn     skip
     remtrz.detpay[1]   skip
     remtrz.detpay[2]  skip
     remtrz.detpay[3]    skip
     remtrz.detpay[4]
     with frame vkbrmz  side-label row 3  centered  no-box.
