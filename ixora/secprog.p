/* secprog.p
 * MODULE
        Название модуля - Внутрибанковские операции
 * DESCRIPTION
        Описание - Ведение клиентской базы Департамента Службы Безопасности
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню - 8.13.1
 * AUTHOR
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        11.11.2011 damir - перекомпиляция
*/

{vc.i}

{mainhead.i}

def var v-bank as char init "".

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if avail sysc then v-bank = trim(sysc.chval).

{   sec.i
    &head       = cifdss
    &headkey    = uninum
    &formname   = "sec"
    &option     = "CIF"
    &numsys     = "auto"
    &keytype    = "string"
    &nmbrcode   = "CIF"
    &update     = " run update. "
    &postupdate = " run postupdate.
                    message 'Зарегистрирован новый клиент !!!' view-as alert-box buttons ok. "
    &nmbrcode   = " "
}

procedure update:
    update v-rnnokpo v-namecomp1 v-namecomp2 v-namecomp3 v-dtnumreg1 v-dtnumreg2 v-whoreg1 v-whoreg2 v-whoreg3 v-address1 v-address2
    v-address3 v-fiomain1 v-fiomain2 v-fiomain3 v-tel v-busstype1 v-busstype2 v-busstype3 v-wherefil1 v-wherefil2 v-dtbegend1
    v-dtbegend2 v-dtbegend3 v-summreq1 v-summreq2 v-summreq3 v-criter1 v-criter2 v-criter3 v-criter4 v-criter5 v-criter6 v-moreinfo1
    v-moreinfo2 v-moreinfo3 v-moreinfo4 v-moreinfo5 v-moreinfo6 v-moreinfo7 v-moreinfo8 v-moreinfo9 v-moreinfo10 v-result1 v-result2
    v-result3 with frame sec.
end.

procedure postupdate:
    assign
    cifdss.rnnokpo  = v-rnnokpo
    cifdss.namecomp = trim(v-namecomp1) + " " + trim(v-namecomp2) + " " + trim(v-namecomp3)
    cifdss.dtnumreg = trim(v-dtnumreg1) + " " + trim(v-dtnumreg2)
    cifdss.whoreg   = trim(v-whoreg1) + " " + trim(v-whoreg2) + " " + trim(v-whoreg3)
    cifdss.address  = trim(v-address1) + " " + trim(v-address2) + " " + trim(v-address3)
    cifdss.fiomain  = trim(v-fiomain1) + " " + trim(v-fiomain2) + " " + trim(v-fiomain3)
    cifdss.tel      = trim(v-tel)
    cifdss.busstype = trim(v-busstype1) + " " + trim(v-busstype2) + " " + trim(v-busstype3)
    cifdss.dtbegend = trim(v-dtbegend1) + " " + trim(v-dtbegend2) + " " + trim(v-dtbegend3)
    cifdss.summreq  = trim(v-summreq1) + " " + trim(v-summreq2) + " " + trim(v-summreq3)
    cifdss.criter   = trim(v-criter1) + " " + trim(v-criter2) + " " + trim(v-criter3) + " " + trim(v-criter4) + " " +
    trim(v-criter5) + " " + trim(v-criter6)
    cifdss.moreinfo = trim(v-moreinfo1) + " " + trim(v-moreinfo2) + " " + trim(v-moreinfo3) + " " + trim(v-moreinfo4) + " " +
    trim(v-moreinfo5) + " " + trim(v-moreinfo6) + " " + trim(v-moreinfo7) + " " + trim(v-moreinfo8) + " " + trim(v-moreinfo9) + " " +
    " " + trim(v-moreinfo10)
    cifdss.result   = trim(v-result1) + " " + trim(v-result2) + " " + trim(v-result3)
    cifdss.wherefil = trim(v-wherefil1) + " " + trim(v-wherefil2)
    cifdss.whn      = g-today
    cifdss.who      = g-ofc
    cifdss.bank     = v-bank.
end.