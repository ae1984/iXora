/* rmzi.f
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
        17.11.09 marinav v-pnp as cha format "x(20)" 
*/


def var v-priory as cha format "x(8)" label "Приорит." .
def var pakal like tarif2.pakalp.
def var v-psbank like remtrz.sbank.
def var vpname as cha format "x(60)" . 
def var v-ref like remtrz.sqn.
def var dtt1 as  char  format "x(70)".
def var dtt2 as  char  format "x(70)".
def var v-kind as cha label "Тип платежа" format "x(3)" .

form remtrz.remtrz label "Платеж" 
     " <-- " v-ref format "X(26)" label "Nr."  
     remtrz.rdt label "Рег.дата" skip
     remtrz.ptype label "Тип   "
     "     " ptyp.des no-label "   " 
     remtrz.cover label "Трнсп"  skip

     v-psbank label "БанкО " "->" remtrz.scbank label "КорО"
     "->" remtrz.rcbank label "КорП" "->" remtrz.rbank label "БанкП" skip
     remtrz.drgl   label "ДСГК  " format "zzzzz9" gl.sub format  "x(8)"
     no-label "             "
     remtrz.crgl label "КСГК    " format "zzzzz9"
      tgl.sub no-label format "x(6)"  rsub label "П.п. " skip
     remtrz.dracc label "Д.Сч. " format "x(20)" "        "
     remtrz.cracc label "К.Сч.   " format "x(20)" "        " skip
     remtrz.fcrc   label "Вал.Д "
     acode no-label "                      "
     remtrz.tcrc label "Вал.К   "
     bcode  no-label  skip
     remtrz.valdt1 label "1Дата " "  "
     remtrz.jh1  label " 1Пров"
     remtrz.valdt2 label " 2Дата   " "    "
     remtrz.jh2 label "2Пров"    skip
     remtrz.sacc label "Сч.О  " "        "
     remtrz.racc   label "Сч.П    " skip
     remtrz.amt label "СуммаД"
     "       " remtrz.payment label "СуммаК  " skip
     skip
     remtrz.svcrc label "Вал.Ком " remtrz.svccgr label "Тариф"
     " -  " pakal no-label format "x(35)" skip
     remtrz.svca label "СуммаКом"
     remtrz.svcaaa label "СчОКом"
     remtrz.svccgl label "СГККом" skip
     remtrz.ord label "Отпр."   skip
     remtrz.ordins[1] format "x(60)" label "Банк отпр." skip 
     remtrz.bb[1]  label "Банк получ "  skip
     vpname label "" skip 
     remtrz.bn[1] label "Получатель"    skip
     remtrz.bn[2] label "Получатель"  skip
     dtt1 label "Детали"  skip
     dtt2 label "Детали"  skip
     remtrz.bi format "x(20)" label "ИнфБанку" 
     v-priory v-kind
     with frame remtrz  side-label row 3  centered  no-box.
