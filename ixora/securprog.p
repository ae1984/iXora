/* securprog.p
 * MODULE
        Название модуля
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
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        11.11.2011 damir - перекомпиляция
*/

{global.i}

{securprog.i

&head        = cifdss
&headkey     = uninum
&post        = "sec"
&option      = "CIF"
&delete      = " delete cifdss. "
&predisplay  = " run predispl. "
&display     = " display
                 v-rnnokpo v-namecomp1 v-namecomp2 v-namecomp3 v-dtnumreg1 v-dtnumreg2 v-whoreg1 v-whoreg2 v-whoreg3 v-address1
                 v-address2 v-address3 v-fiomain1 v-fiomain2 v-fiomain3 v-tel v-busstype1 v-busstype2 v-busstype3 v-wherefil1
                 v-wherefil2 v-dtbegend1 v-dtbegend2 v-dtbegend3 v-summreq1 v-summreq2 v-summreq3 v-criter1 v-criter2 v-criter3
                 v-criter4 v-criter5 v-criter6 v-moreinfo1 v-moreinfo2 v-moreinfo3 v-moreinfo4 v-moreinfo5 v-moreinfo6 v-moreinfo7
                 v-moreinfo8 v-moreinfo9 v-moreinfo10 v-result1 v-result2 v-result3 with frame sec. "
&update      = " run updating. "
&postupdate  = " run postupdate. "
}

procedure updating:
    update v-rnnokpo v-namecomp1 v-namecomp2 v-namecomp3 v-dtnumreg1 v-dtnumreg2 v-whoreg1 v-whoreg2 v-whoreg3 v-address1 v-address2
    v-address3 v-fiomain1 v-fiomain2 v-fiomain3 v-tel v-busstype1 v-busstype2 v-busstype3 v-wherefil1 v-wherefil2 v-dtbegend1
    v-dtbegend2 v-dtbegend3 v-summreq1 v-summreq2 v-summreq3 v-criter1 v-criter2 v-criter3 v-criter4 v-criter5 v-criter6 v-moreinfo1
    v-moreinfo2 v-moreinfo3 v-moreinfo4 v-moreinfo5 v-moreinfo6 v-moreinfo7 v-moreinfo8 v-moreinfo9 v-moreinfo10 v-result1 v-result2
    v-result3 with frame sec.
end.

procedure postupdate:
    assign
    cifdss.rnnokpo  = trim(v-rnnokpo)
    cifdss.namecomp = trim(v-namecomp1) + " " + trim(v-namecomp2) + " " + trim(v-namecomp3)
    cifdss.dtnumreg = trim(v-dtnumreg1) + " " + trim(v-dtnumreg2)
    cifdss.whoreg   = trim(v-whoreg1) + " " + trim(v-whoreg2) + " " + trim(v-whoreg3)
    cifdss.address  = trim(v-address1) + " " + trim(v-address2) + " " + trim(v-address3)
    cifdss.fiomain  = trim(v-fiomain1) + " " + trim(v-fiomain2) + " " + trim(v-fiomain3)
    cifdss.tel      = trim(v-tel)
    cifdss.busstype = trim(v-busstype1) + " " + trim(v-busstype2) + " " + trim(v-busstype3)
    cifdss.wherefil = trim(v-wherefil1) + " " + trim(v-wherefil2)
    cifdss.dtbegend = trim(v-dtbegend1) + " " + trim(v-dtbegend2) + " " + trim(v-dtbegend3)
    cifdss.summreq  = trim(v-summreq1) + " " + trim(v-summreq2) + " " + trim(v-summreq3)
    cifdss.criter   = trim(v-criter1) + " " + trim(v-criter2) + " " + trim(v-criter3) + " " + trim(v-criter4) + " " +
    trim(v-criter5) + " " + trim(v-criter6)
    cifdss.moreinfo = trim(v-moreinfo1) + " " + trim(v-moreinfo2) + " " + trim(v-moreinfo3) + " " + trim(v-moreinfo4) + " " +
    trim(v-moreinfo5) + " " + trim(v-moreinfo6) + " " + trim(v-moreinfo7) + " " + trim(v-moreinfo8) + " " + trim(v-moreinfo9) + " " +
    " " + trim(v-moreinfo10)
    cifdss.result   = trim(v-result1) + " " + trim(v-result2) + " " + trim(v-result3).
end.

procedure predispl:
    if avail cifdss then do:
        assign
        v-rnnokpo    = substr(cifdss.rnnokpo, 1, 20)
        v-namecomp1  = substr(cifdss.namecomp, 1, 64)
        v-namecomp2  = substr(cifdss.namecomp, 65, 106)
        v-namecomp3  = substr(cifdss.namecomp, 172, 106)
        v-dtnumreg1  = substr(cifdss.dtnumreg, 1, 64)
        v-dtnumreg2  = substr(cifdss.dtnumreg, 65, 106)
        v-whoreg1    = substr(cifdss.whoreg, 1, 64)
        v-whoreg2    = substr(cifdss.whoreg, 65, 106)
        v-whoreg3    = substr(cifdss.whoreg, 172, 106)
        v-address1   = substr(cifdss.address, 1 , 64)
        v-address2   = substr(cifdss.address, 65, 106)
        v-address2   = substr(cifdss.address, 172, 106)
        v-fiomain1   = substr(cifdss.fiomain, 1, 64)
        v-fiomain2   = substr(cifdss.fiomain, 65, 106)
        v-tel        = substr(cifdss.tel, 1, 64)
        v-busstype1  = substr(cifdss.busstype, 1, 64)
        v-busstype2  = substr(cifdss.busstype, 65, 106)
        v-busstype3  = substr(cifdss.busstype, 172, 106)
        v-wherefil1  = substr(cifdss.wherefil, 1, 64)
        v-wherefil2  = substr(cifdss.wherefil, 65, 106)
        v-dtbegend1  = substr(cifdss.dtbegend, 1, 64)
        v-dtbegend2  = substr(cifdss.dtbegend, 65, 106)
        v-dtbegend3  = substr(cifdss.dtbegend, 172, 106)
        v-summreq1   = substr(cifdss.summreq, 1, 64)
        v-summreq2   = substr(cifdss.summreq, 65, 106)
        v-summreq3   = substr(cifdss.summreq, 172, 106)
        v-criter1    = substr(cifdss.criter, 1, 64)
        v-criter2    = substr(cifdss.criter, 65, 106)
        v-criter3    = substr(cifdss.criter, 172, 106)
        v-criter4    = substr(cifdss.criter, 279, 106)
        v-criter5    = substr(cifdss.criter, 386, 106)
        v-criter6    = substr(cifdss.criter, 493, 106)
        v-moreinfo1  = substr(cifdss.moreinfo, 1, 64)
        v-moreinfo2  = substr(cifdss.moreinfo, 65, 106)
        v-moreinfo3  = substr(cifdss.moreinfo, 172, 106)
        v-moreinfo4  = substr(cifdss.moreinfo, 279, 106)
        v-moreinfo5  = substr(cifdss.moreinfo, 386, 106)
        v-moreinfo6  = substr(cifdss.moreinfo, 493, 106)
        v-moreinfo7  = substr(cifdss.moreinfo, 600, 106)
        v-moreinfo8  = substr(cifdss.moreinfo, 707, 106)
        v-moreinfo9  = substr(cifdss.moreinfo, 814, 106)
        v-moreinfo10 = substr(cifdss.moreinfo, 921, 79)
        v-result1    = substr(cifdss.result, 1, 64)
        v-result2    = substr(cifdss.result, 65, 106)
        v-result3    = substr(cifdss.result, 172, 106).
    end.
end.