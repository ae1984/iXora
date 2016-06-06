/* psrecv.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Назначение программы, описание процедур и функций
        Передача сфифта из филиала
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        03.11.01 KOVAL Изменил передачу свифт платежа из филиала, т.к. база будет общая
        17.03.03 nadejda - изменен поиск РНН - надо брать из cmp.addr[2], а не sysc!
        24.05.03 nadejda - изменено копирование файла пенсионки с ftp на cp
        19.03.04 isaev   - добавлено копирование справочника(sub-cod) ATTACH при передаче Remtrz с филиала
        18.12.2005 tsoy     - добавил время создания платежа.
        18.11.2005 ten - добавил sub-cod.urgency
        01.09.2006 u00121 - изменено копирование файла пенсионки с cp на scp
        		  - формат : scp -qp <host от куда>:<имя файла с полным path> <имя файла куда копировать на текущем сервере>
        19.03.2009 galina - добавила копирование справочников iso3166, zdcavail, zsgavail
        28.05.2009 galina - добавила копирование поля vcact
        01.10.2012 evseev - логирование
        03.01.2013 evseev - тз-625
        01.11.2013 evseev tz626
*/




{get-host.i}

define            variable oldvaldt    as date.
define            variable exitcod     as cha.
define            variable r-new       like shtbnk.remtrz.remtrz.
define            variable r-old       like shtbnk.remtrz.sqn.
define            variable v-sqn       as cha.
define            variable buf         as cha     extent 100.
define            variable i           as integer.
define            variable ksm         as cha.
define shared     variable v-weekbeg   as integer.
define shared     variable v-weekend   as integer.
define new shared variable srm-remtrz  like bank.remtrz.remtrz.
define shared     variable s-remtrz    like shtbnk.remtrz.remtrz.
define shared     variable sold-remtrz like shtbnk.remtrz.remtrz.
define stream send.
define shared variable g-today  as date.
define        variable acode    as cha.
define        variable v-reterr as integer.
{lgps.i}

run n-remtrz.
run savelog("psrecv","60. remtrz.remtrz=" + s-remtrz ) no-error.
do transaction:
    find first shtbnk.que where shtbnk.que.remtrz = sold-remtrz exclusive-lock no-wait no-error.
    if not available que then return.
    if available shtbnk.que then do:
        run savelog("psrecv","66. remtrz.remtrz=" + sold-remtrz ) no-error.
        shtbnk.que.dw = today.
        shtbnk.que.tw = time.
        find first shtbnk.remtrz where shtbnk.remtrz.remtrz = sold-remtrz exclusive-lock. /* Beginning of main program body */
        find first shtbnk.bankl where bankl.bank = shtbnk.remtrz.rcbank no-lock no-error.
        if available bankl then find first shtbnk.bankt where bankt.cbank = shtbnk.bankl.cbank and bankt.crc = shtbnk.remtrz.tcrc and bankt.racc = "1" no-lock no-error.
        if not available shtbnk.bankt then do:
            run savelog("psrecv","78. remtrz.remtrz=" + sold-remtrz ) no-error.
            v-text = " Банк-получатель " + remtrz.rcbank + " не найден ! " + remtrz.remtrz.
            run lgps-r.
            run lgps.
            shtbnk.que.dp = today.
            shtbnk.que.tp = time.
            shtbnk.que.con = "F".
            shtbnk.que.rcod = "1".
            return.
        end.

        find first bank.bankl where bank.bankl.bank = shtbnk.remtrz.sbank no-lock no-error.
        if available bank.bankl then
           find first bank.bankt where bank.bankt.cbank = bank.bankl.cbank and bank.bankt.crc   = shtbnk.remtrz.tcrc and bank.bankt.racc  = "1" no-lock no-error.
        if not available bank.bankt then do:
            run savelog("psrecv","97. remtrz.remtrz=" + sold-remtrz ) no-error.
            v-text = " REMOTE Банк-отправитель " + shtbnk.remtrz.sbank + " не найден ! " +  shtbnk.remtrz.remtrz.
            run lgps-r.
            run lgps.
            shtbnk.que.dp = today.
            shtbnk.que.tp = time.
            shtbnk.que.con = "F".
            shtbnk.que.rcod = "1".
            return.
        end.

        find first bank.remtrz where bank.remtrz.sbank = shtbnk.remtrz.sbank and bank.remtrz.sqn begins substr(shtbnk.remtrz.sqn,1,5) + "." + substr(shtbnk.remtrz.remtrz,1,10) no-lock no-error.
        if available bank.remtrz then do:
            run savelog("psrecv","114. remtrz.remtrz=" + sold-remtrz + " " + bank.remtrz.remtrz + " " + shtbnk.remtrz.remtrz ) no-error.
            v-text = " Платеж " + shtbnk.remtrz.sbank + " " + shtbnk.remtrz.sqn + " уже зарегистрирован : " + bank.remtrz.remtrz.
            run lgps.
            run lgps-r.
            shtbnk.que.dp = today.
            shtbnk.que.tp = time.
            shtbnk.que.con = "F".
            shtbnk.que.rcod = "1".
            return.
        end .

        oldvaldt = shtbnk.remtrz.valdt2.

        if shtbnk.remtrz.valdt2 < g-today then shtbnk.remtrz.valdt2 = g-today.
        if shtbnk.bankt.vtime < time and shtbnk.remtrz.valdt2 = g-today then do:
            shtbnk.remtrz.valdt2 = shtbnk.remtrz.valdt2 + 1.
            repeat:
                find shtbnk.hol where hol.hol eq shtbnk.remtrz.valdt2 no-lock no-error.
                if not available hol and weekday(shtbnk.remtrz.valdt2) ge v-weekbeg and weekday(shtbnk.remtrz.valdt2) le v-weekend then leave.
                else shtbnk.remtrz.valdt2  = shtbnk.remtrz.valdt2 + 1.
            end.
        end.
        if shtbnk.remtrz.valdt2 ne oldvaldt then do:
            v-text =  "2 дата валютирования изменена : " + string(oldvaldt) + " -> " + string(shtbnk.remtrz.valdt2) + " " + shtbnk.remtrz.remtrz.
            run lgps-r .
        end.

        create bank.remtrz.
        bank.remtrz.rtim = time.
        bank.remtrz.remtrz = s-remtrz.
        bank.remtrz.cover  = shtbnk.remtrz.cover.
        bank.remtrz.source = "AN".
        bank.remtrz.rdt    = g-today.
        bank.remtrz.valdt1 = shtbnk.remtrz.valdt2.
        bank.remtrz.amt    = shtbnk.remtrz.payment.
        bank.remtrz.payment = shtbnk.remtrz.payment.
        bank.remtrz.rsub   = shtbnk.remtrz.rsub.
        bank.remtrz.racc   = shtbnk.remtrz.racc.
        bank.remtrz.sbank  = shtbnk.remtrz.sbank.
        bank.remtrz.rbank  = shtbnk.remtrz.rbank.
        bank.remtrz.sqn    = substr(shtbnk.remtrz.sqn,1,5) + "." + substr(shtbnk.remtrz.remtrz,1,10) + ".." + substr(shtbnk.remtrz.sqn,19) + "..." + trim(shtbnk.remtrz.source).
        bank.remtrz.sndcoract = shtbnk.remtrz.sndcoract.
        bank.remtrz.sndcor[1] = shtbnk.remtrz.sndcor[1].
        bank.remtrz.sndcor[2] = shtbnk.remtrz.sndcor[2].
        bank.remtrz.sndcor[3] = shtbnk.remtrz.sndcor[3].
        bank.remtrz.sndcor[4] = shtbnk.remtrz.sndcor[4].
        bank.remtrz.fcrc = shtbnk.remtrz.tcrc.
        bank.remtrz.tcrc = shtbnk.remtrz.tcrc.
        bank.remtrz.rdt  = today.
        bank.remtrz.sacc = shtbnk.remtrz.sacc.
        bank.remtrz.racc = shtbnk.remtrz.racc.
        bank.remtrz.ord  = shtbnk.remtrz.ord.
        bank.remtrz.ref  = shtbnk.remtrz.ref.
        bank.remtrz.vcact = shtbnk.remtrz.vcact.

        if index(bank.remtrz.ord, "/RNN/") = 0 then do:
            find first shtbnk.cmp no-lock no-error.
            find shtbnk.sysc where shtbnk.sysc.sysc = "bnkbin" no-lock no-error.
            bank.remtrz.ord = bank.remtrz.ord + " /RNN/" + trim(/*shtbnk.cmp.addr[2]*/ shtbnk.sysc.chval).
        end.
        if bank.remtrz.ord = ? then do:
          run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "psrecv.p 169", "1", "", "").
        end.
        bank.remtrz.bb[1] = shtbnk.remtrz.bb[1].
        bank.remtrz.bb[2] = shtbnk.remtrz.bb[2].
        bank.remtrz.bb[3] = shtbnk.remtrz.bb[3].
        bank.remtrz.info[3] = shtbnk.remtrz.info[3].
        bank.remtrz.info[7] = shtbnk.remtrz.info[7]. /* KOVAL VAL Control */
        bank.remtrz.info[9] = shtbnk.remtrz.info[9].
        bank.remtrz.intmed = shtbnk.remtrz.intmed.
        bank.remtrz.intmedact = shtbnk.remtrz.intmedact.
        do i = 1 to 4:
            bank.remtrz.actins[i] = shtbnk.remtrz.actins[i].
        end.
        do i = 1 to 3:
            bank.remtrz.bn[i] = shtbnk.remtrz.bn[i].
        end.
        do i = 1 to 6:
            bank.remtrz.rcvinfo[i] = shtbnk.remtrz.rcvinfo[i].
        end.
        do i = 1 to 4:
            bank.remtrz.detpay[i] = shtbnk.remtrz.detpay[i].
        end.
        do i = 1 to 4:
            bank.remtrz.ordins[i] = shtbnk.remtrz.ordins[i].
        end.
        bank.remtrz.ba = shtbnk.remtrz.ba.
        bank.remtrz.bi = shtbnk.remtrz.bi.

        ksm = bank.remtrz.remtrz + bank.remtrz.source +
              string(bank.remtrz.rdt) +
              string(bank.remtrz.valdt1) +
              string(bank.remtrz.amt) +
              string(bank.remtrz.payment) +
              string(bank.remtrz.rsub) +
              string(bank.remtrz.racc) +
              string(bank.remtrz.sbank) +
              string(bank.remtrz.rbank) +
              string(bank.remtrz.sqn) +
              string(bank.remtrz.fcrc) +
              string(bank.remtrz.tcrc) +
              string(bank.remtrz.rdt) +
              string(bank.remtrz.sacc) +
              string(bank.remtrz.racc) +
              string(bank.remtrz.ord) +
              string(bank.remtrz.ref) +
              string(bank.remtrz.bb[1]) +
              string(bank.remtrz.bb[2]) +
              string(bank.remtrz.bb[3]) +
              string(bank.remtrz.info[3]) +
              string(bank.remtrz.info[9]) +
              string(bank.remtrz.intmed) +
              string(bank.remtrz.intmedact).

        do i = 1 to 4:
            ksm = ksm + bank.remtrz.actins[i].
        end.
        do i = 1 to 3:
            ksm = ksm + bank.remtrz.bn[i].
        end.
        do i = 1 to 6:
            ksm = ksm + bank.remtrz.rcvinfo[i].
        end.
        do i = 1 to 4:
            ksm = ksm + bank.remtrz.detpay[i].
        end.
        do i = 1 to 4:
            ksm = ksm + bank.remtrz.ordins[i].
        end.
        ksm = ksm + bank.remtrz.ba + bank.remtrz.bi.

        find first shtbnk.sysc where shtbnk.sysc.sysc = "ourbnk" no-lock no-error.
        if available shtbnk.sysc then ksm = ksm + trim(shtbnk.sysc.stc).
        bank.remtrz.info[1] = encode(ksm) .

        /*----- Pension payments processing (added by alex) ------*/
        if index(shtbnk.remtrz.rcvinfo[1],"/PSJ/") <> 0 then do:
            find shtbnk.sysc where shtbnk.sysc.sysc = "PSJIN" no-lock no-error.
            if not available shtbnk.sysc or shtbnk.sysc.chval = "" then do:
                run savelog("psrecv","238. remtrz.remtrz=" + sold-remtrz ) no-error.
                v-text = " ERROR!!! There isn't record PSJIN in sysc file on branch!!!".
                run lgps.
                run lgps-r.
                shtbnk.que.dp = today.
                shtbnk.que.tp = time.
                shtbnk.que.con = "F".
                shtbnk.que.rcod = "1".
                delete bank.remtrz.
                return .
            end.
            find bank.sysc where bank.sysc.sysc = "PSJIN" no-lock no-error.
            if not available bank.sysc or bank.sysc.chval = "" then do:
                run savelog("psrecv","251. remtrz.remtrz=" + sold-remtrz ) no-error.
                v-text = " ERROR!!! There isn't record PSJIN in sysc file on Head office!!!".
                run lgps.
                run lgps-r.
                shtbnk.que.dp = today.
                shtbnk.que.tp = time.
                shtbnk.que.con = "F".
                shtbnk.que.rcod = "1".
                delete bank.remtrz.
                return.
            end.
            v-text = "".
            input through value ("cp -f " + trim(shtbnk.sysc.chval) + shtbnk.remtrz.remtrz + " " + trim(bank.sysc.chval) + bank.remtrz.remtrz) no-echo.
            repeat:
                import unformatted v-text.
            end.
            input close.

            if search(trim(bank.sysc.chval) + bank.remtrz.remtrz) = ? or v-text ne "" then do:
                run savelog("psrecv","270. remtrz.remtrz=" + sold-remtrz ) no-error.
                v-text = shtbnk.remtrz.remtrz + " ERROR!!! Cannot transfer Pension payment file!!! " + v-text.
                run lgps-r.
                run lgps.
                shtbnk.que.dp = today.
                shtbnk.que.tp = time.
                shtbnk.que.con = "F".
                shtbnk.que.rcod = "1".
                delete bank.remtrz.
                return.
            end. else do:
                v-text = shtbnk.remtrz.remtrz + " Ttransfer Pension payment file successfull." + v-text.
                run lgps-r.
                run lgps.
            end.
        end.
        bank.remtrz.t_sqn = s-remtrz.
        /*--------------------------------------------------------*/

        /*----- Copying sub-cod records (added by alex) ------*/
        for each shtbnk.sub-cod where shtbnk.sub-cod.acc = shtbnk.remtrz.remtrz
            and shtbnk.sub-cod.sub = "rmz"
            and (shtbnk.sub-cod.d-cod = "eknp" or shtbnk.sub-cod.d-cod = "zattach" or
            shtbnk.sub-cod.d-cod = "urgency" or  shtbnk.sub-cod.d-cod = "zdcavail" or
            shtbnk.sub-cod.d-cod ="iso3166" or shtbnk.sub-cod.d-cod = "zsgavail") no-lock:
            create bank.sub-cod.
            assign
                bank.sub-cod.acc   = bank.remtrz.remtrz
                bank.sub-cod.sub   = shtbnk.sub-cod.sub
                bank.sub-cod.d-cod = shtbnk.sub-cod.d-cod
                bank.sub-cod.rcode = shtbnk.sub-cod.rcode
                bank.sub-cod.ccode = shtbnk.sub-cod.ccode
                bank.sub-cod.sub   = shtbnk.sub-cod.sub.
        end.
        /*----------------------------------------------------*/

        /*** KOVAL Copy of swbody (tables of the Swift MT-content) ***/
        if bank.remtrz.tcrc <> 1 then
        do:
            v-text = " (передача swift) " + shtbnk.remtrz.remtrz + " -> " + bank.remtrz.remtrz.
            run lgps .
            find first comm.swout where comm.swout.rmz=shtbnk.remtrz.remtrz no-error.
            if available comm.swout then
            do:
                v-text = " (передача swift) Запись в comm.swout.rmz.".
                run lgps.
                find first shtbnk.sysc where shtbnk.sysc.sysc = "ourbnk" no-lock no-error.
                assign
                    comm.swout.branch    = trim(shtbnk.sysc.chval)     /* Пишем код филиала */
                    comm.swout.rmz       = bank.remtrz.remtrz             /* Пишем новый rmz */
                    comm.swout.rmzparent = shtbnk.remtrz.remtrz.    /* Пишем филиальский rmz */
                /* перенос данных на новый RMZ */
                for each comm.swbody where comm.swbody.rmz = shtbnk.remtrz.remtrz exclusive-lock.
                    comm.swbody.rmz = bank.remtrz.remtrz.
                end.
            end.
        end.
        /*** KOVAL end Copy                                        ***/

        define variable v-chief  as character init "НЕ ПРЕДУСМОТРЕНО".
        define variable v-mainbk as character init "НЕ ПРЕДУСМОТРЕНО".

        find first shtbnk.aaa where shtbnk.aaa.aaa = shtbnk.remtrz.sacc no-lock no-error.
        if available shtbnk.aaa then  do:
            find first shtbnk.sub-cod where shtbnk.sub-cod.sub = "cln" and shtbnk.sub-cod.acc = shtbnk.aaa.cif and shtbnk.sub-cod.d-cod = "clnchf" no-lock no-error.
            if available shtbnk.sub-cod and shtbnk.sub-cod.ccode ne "msc" then v-chief = trim(sub-cod.rcode).
            find first shtbnk.sub-cod where shtbnk.sub-cod.sub = "cln" and shtbnk.sub-cod.acc = shtbnk.aaa.cif and shtbnk.sub-cod.d-cod = "clnbk" no-lock no-error.
            if available shtbnk.sub-cod and sub-cod.ccode ne "msc" then v-mainbk = trim(sub-cod.rcode).
        end. else  do:
            find shtbnk.lon where lon.lon = shtbnk.remtrz.sacc no-lock no-error.
            if available lon then do:
                find first shtbnk.sub-cod where shtbnk.sub-cod.sub = "cln" and shtbnk.sub-cod.acc = shtbnk.lon.cif and shtbnk.sub-cod.d-cod = "clnchf" no-lock no-error.
                if available shtbnk.sub-cod and shtbnk.sub-cod.ccode ne "msc" then v-chief = trim(shtbnk.sub-cod.rcode).
                find first sub-cod where shtbnk.sub-cod.sub = "cln" and shtbnk.sub-cod.acc = lon.cif and shtbnk.sub-cod.d-cod = "clnbk" no-lock no-error.
                if available shtbnk.sub-cod and shtbnk.sub-cod.ccode ne "msc" then v-mainbk = trim(shtbnk.sub-cod.rcode).
            end.  else do :   /*  our CHIEF  MAINBK   */
                find first shtbnk.sysc where shtbnk.sysc.sysc = "CHIEF" no-lock no-error.
                if available shtbnk.sysc then v-chief = trim(shtbnk.sysc.chval).
                find first shtbnk.sysc where shtbnk.sysc.sysc = "MAINBK" no-lock no-error.
                if available shtbnk.sysc then v-mainbk = trim(shtbnk.sysc.chval).
            end.
        end.

        create bank.sub-cod.
        assign
            bank.sub-cod.acc   = bank.remtrz.remtrz
            bank.sub-cod.sub   = "rmz"
            bank.sub-cod.d-cod = "clnchf"
            bank.sub-cod.rcode = v-chief
            bank.sub-cod.ccode = "chief".
        create bank.sub-cod.
        assign
            bank.sub-cod.acc   = bank.remtrz.remtrz
            bank.sub-cod.sub   = "rmz"
            bank.sub-cod.d-cod = "clnbk"
            bank.sub-cod.rcode = v-mainbk
            bank.sub-cod.ccode = "mainbk".
        create bank.que.
        assign
            bank.que.remtrz   = s-remtrz
            bank.que.pid      = "AN"
            bank.que.rcid     = recid(bank.remtrz)
            bank.remtrz.ptype = "N"
            bank.que.ptype    = bank.remtrz.ptype.
        if v-reterr = 0 then bank.que.rcod = "0".
        else do:
            run savelog("psrecv","423. remtrz.remtrz=" + sold-remtrz ) no-error.
            bank.que.rcod = "1".
            bank.que.pvar = string(v-reterr).
        end.

        bank.que.con = "W".
        bank.que.dp = today.
        bank.que.df = today.
        bank.que.tf = time.
        bank.que.tp = time.
        bank.que.dw = today.
        bank.que.tw = time.
        bank.que.pri = 29999.
        m_hst = shtbnk.remtrz.scbank.

        v-text = "Платеж  " + bank.remtrz.remtrz +
            " <- " + shtbnk.remtrz.sbank + " " + shtbnk.remtrz.remtrz +
            " зарегистрирован , код завершения = " + bank.que.rcod.
        run lgps.
        v-text = "Отправка прямым доступом " + shtbnk.remtrz.sqn + " " +
            shtbnk.remtrz.remtrz + " -> " + shtbnk.remtrz.rcbank +
            " -> " + bank.remtrz.remtrz + " сумма " + string(shtbnk.remtrz.payment) + " Вал=" +
            string(shtbnk.remtrz.fcrc) + " Тип= " + shtbnk.remtrz.ptype.
        run lgps-r.
        /*  End of program body */
        shtbnk.que.dp = today.
        shtbnk.que.tp = time.
        shtbnk.que.con = "F".
        shtbnk.que.rcod = "0".
    end.
end.

