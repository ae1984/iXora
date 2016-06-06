/* pssend.p
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
        19.03.04 isaev   - добавлено копирование справочника(sub-cod) ATTACH при передаче Remtrz на филиал
        19.07.04 saltanat - добавлена возможность "Зачисления в Тенге" на полочку Валютного Контроля.
        29.07.04 saltanat - добавлено проставление значения справочника *** RMZVAL ***  отношения к валютному контролю
        09.08.04 suchkov  - исправлена ошибка (убран no-lock из update sub-cod)
        18.12.2005 tsoy     - добавил время создания платежа.
        28.06.2005 tsoy     - добавлено копирование справочника(sub-cod) urgency при передаче Remtrz на филиал
        06.05.2009 galina - добавила копирование справочников iso3166, zdcavail, zsgavail и поля vcact
        07.06.2012 evseev - отструктурировал код, логирование
        06/03/2013 Luiza - ТЗ 1741 для карточных счетов remtrz.rsub = "arp"
        20/06/2013 Luiza - ТЗ 1917
        23.10.2013 evseev - tz926

 */

def var oldvaldt as date .
def var exitcod as cha .
def var r-new like bank.remtrz.remtrz .
def var r-old like bank.remtrz.sqn .
def var v-sqn as cha .
def var buf as cha extent 100 .
def var i as int .
def var ksm as cha .
def shared var v-weekbeg as int.
def shared var v-weekend as int.
def new shared var srm-remtrz like shtbnk.remtrz.remtrz .
def shared var s-remtrz like bank.remtrz.remtrz .
def stream send .
def shared var g-today as date .
def shared var lbnstr as cha .
def var acode as cha .
def var v-reterr as int .
{lgps.i}


run nrm-remtrz.
do transaction:
    find first bank.que where bank.que.remtrz = s-remtrz exclusive-lock no-wait no-error.
    if not avail que then do:
       run savelog("pssend","54. remtrz.remtrz=" + s-remtrz).
       return.
    end.
    if avail bank.que then do:
        run savelog("pssend","58. remtrz.remtrz=" + s-remtrz + "que.rcod=" + bank.que.rcod ).
        bank.que.dw = today.
        bank.que.tw = time.
        find first bank.remtrz where bank.remtrz.remtrz = s-remtrz exclusive-lock.
        /* Beginning of main program body */
        find first bank.bankl where bankl.bank = bank.remtrz.rcbank no-lock no-error.
        if avail bankl then
           find first bank.bankt where bankt.cbank = bank.bankl.cbank and bankt.crc = bank.remtrz.tcrc and bankt.racc = "1" no-lock no-error.
        if not avail bank.bankt then do:
            v-text = " Банк-получатель " + remtrz.rcbank + " не найден в справочнике " + remtrz.remtrz.
            run lgps.
            bank.que.dp = today.
            bank.que.tp = time.
            bank.que.con = "F".
            bank.que.rcod = "1".
            run savelog("pssend","73. remtrz.remtrz=" + s-remtrz + "que.rcod=" + bank.que.rcod ).
            return.
        end.

        find first shtbnk.bankl where shtbnk.bankl.bank = bank.remtrz.sbank no-lock no-error.
        if avail shtbnk.bankl then
           find first shtbnk.bankt where shtbnk.bankt.cbank = shtbnk.bankl.cbank and shtbnk.bankt.crc = bank.remtrz.tcrc and shtbnk.bankt.racc = "1" no-lock no-error.
        if not avail shtbnk.bankt then do:
            v-text = " Банк-получатель " + bank.remtrz.sbank + " не найден в справочнике филиала " +  bank.remtrz.remtrz.
            run lgps.
            bank.que.dp = today.
            bank.que.tp = time.
            bank.que.con = "F".
            bank.que.rcod = "1".
            run savelog("pssend","73. remtrz.remtrz=" + s-remtrz + "que.rcod=" + bank.que.rcod ).
            return.
        end.

        find first shtbnk.remtrz where shtbnk.remtrz.sbank = bank.remtrz.sbank and shtbnk.remtrz.sqn begins substr(bank.remtrz.sqn,1,5) + "." +
                                       substr(bank.remtrz.remtrz,1,10) no-lock no-error.
        if avail shtbnk.remtrz then do:
            v-text = " Платеж " + bank.remtrz.sbank + " " + bank.remtrz.sqn + " уже зарегистрирован в базе филиала " + shtbnk.remtrz.remtrz.
            run lgps.
            bank.que.dp = today.
            bank.que.tp = time.
            bank.que.con = "F".
            bank.que.rcod = "1".
            run savelog("pssend","73. remtrz.remtrz=" + s-remtrz + "que.rcod=" + bank.que.rcod ).
            return.
        end .

        oldvaldt = bank.remtrz.valdt2.

        if bank.remtrz.valdt2 < g-today then bank.remtrz.valdt2 = g-today.
        if bank.bankt.vtime < time and bank.remtrz.valdt2 = g-today then do:
            bank.remtrz.valdt2 = bank.remtrz.valdt2 + 1.
            repeat:
                find bank.hol where hol.hol eq bank.remtrz.valdt2 no-lock  no-error.
                if not available hol and weekday(bank.remtrz.valdt2) ge v-weekbeg and  weekday(bank.remtrz.valdt2) le v-weekend then leave.
                else bank.remtrz.valdt2  = bank.remtrz.valdt2 + 1.
            end.
        end.
        if bank.remtrz.valdt2 ne oldvaldt then do:
            v-text = "Дата 2 валютирования изменена : " + string(oldvaldt) + " -> " + string(bank.remtrz.valdt2) + " " + bank.remtrz.remtrz.
            run lgps.
        end.

        create shtbnk.remtrz.
        shtbnk.remtrz.rtim = time.
        shtbnk.remtrz.remtrz = srm-remtrz.
        shtbnk.remtrz.source = "AN".
        shtbnk.remtrz.rdt = g-today.
        shtbnk.remtrz.valdt1 = bank.remtrz.valdt2.
        shtbnk.remtrz.amt = bank.remtrz.payment.
        shtbnk.remtrz.payment = bank.remtrz.payment.
        if substring(trim(bank.remtrz.racc),10,4) = "2860" and bank.remtrz.tcrc = 1 then shtbnk.remtrz.rsub = "arp".
        else shtbnk.remtrz.rsub = bank.remtrz.rsub.
        shtbnk.remtrz.racc = bank.remtrz.racc.
        shtbnk.remtrz.sbank = bank.remtrz.sbank.
        shtbnk.remtrz.rbank = bank.remtrz.rbank.
        shtbnk.remtrz.sqn = substr(bank.remtrz.sqn,1,5) + "." + substr(bank.remtrz.remtrz,1,10) + ".." + substr(bank.remtrz.sqn,19) + "..." + trim(bank.remtrz.source).
        shtbnk.remtrz.fcrc = bank.remtrz.tcrc.
        shtbnk.remtrz.tcrc = bank.remtrz.tcrc.
        shtbnk.remtrz.rdt = today.
        shtbnk.remtrz.sacc = bank.remtrz.sacc.
        shtbnk.remtrz.racc = bank.remtrz.racc.
        shtbnk.remtrz.ord = bank.remtrz.ord.
        if shtbnk.remtrz.ord = ? then do:
           run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "pssend.p 138", "1", "", "").
        end.
        shtbnk.remtrz.ref = bank.remtrz.ref.
        shtbnk.remtrz.bb[1] = bank.remtrz.bb[1].
        shtbnk.remtrz.bb[2] = bank.remtrz.bb[2].
        shtbnk.remtrz.bb[3] = bank.remtrz.bb[3].
        shtbnk.remtrz.info[3] = bank.remtrz.info[3].
        shtbnk.remtrz.info[7] = bank.remtrz.info[7]. /*** KOVAL ФИО того кто провел валютный контроль ***/
        shtbnk.remtrz.info[9] = bank.remtrz.info[9].
        shtbnk.remtrz.vcact = bank.remtrz.vcact.
        if bank.remtrz.dracc = lbnstr then shtbnk.remtrz.info[2] = lbnstr.
        shtbnk.remtrz.intmed = bank.remtrz.intmed.
        shtbnk.remtrz.intmedact  = bank.remtrz.intmedact.
        do i = 1 to 4: shtbnk.remtrz.actins[i]  = bank.remtrz.actins[i]. end.
        do i = 1 to 3: shtbnk.remtrz.bn[i] = bank.remtrz.bn[i] . end.
        do i = 1 to 6: shtbnk.remtrz.rcvinfo[i] = bank.remtrz.rcvinfo[i]. end.
        do i = 1 to 4: shtbnk.remtrz.detpay[i] = bank.remtrz.detpay[i]. end.
        do i = 1 to 4: shtbnk.remtrz.ordins[i] = bank.remtrz.ordins[i]. end.
        shtbnk.remtrz.ba = bank.remtrz.ba.
        shtbnk.remtrz.bi = bank.remtrz.bi.
        /*----- Copying sub-cod records (added by alex) ------*/
        for each bank.sub-cod where bank.sub-cod.acc = bank.remtrz.remtrz and bank.sub-cod.sub = "rmz" and (bank.sub-cod.d-cod = "eknp" or
            bank.sub-cod.d-cod = "zattach" or bank.sub-cod.d-cod = "rmzval" or bank.sub-cod.d-cod = "urgency" or bank.sub-cod.d-cod = 'iso3166' or
            bank.sub-cod.d-cod = 'zdcavail' or bank.sub-cod.d-cod = 'zsgavail') no-lock:
            create shtbnk.sub-cod.
            assign shtbnk.sub-cod.acc = shtbnk.remtrz.remtrz
                   shtbnk.sub-cod.sub = bank.sub-cod.sub
                   shtbnk.sub-cod.d-cod = bank.sub-cod.d-cod
                   shtbnk.sub-cod.rcode = bank.sub-cod.rcode
                   shtbnk.sub-cod.ccode = bank.sub-cod.ccode
                   shtbnk.sub-cod.sub = bank.sub-cod.sub.
        end.

        /* тенговые платежи от/на нерезидентов кидаем на полочку валютного контроля */
        find shtbnk.sub-cod where shtbnk.sub-cod.acc = shtbnk.remtrz.remtrz and shtbnk.sub-cod.sub = "rmz" and shtbnk.sub-cod.d-cod = 'eknp'
                                  and shtbnk.sub-cod.ccode = 'eknp' no-lock no-error.
        if avail shtbnk.sub-cod then if (shtbnk.remtrz.fcrc = 1 or shtbnk.remtrz.tcrc = 1) then do:
           if substr(shtbnk.sub-cod.rcod,1,1) = '2' and substr(shtbnk.sub-cod.rcod,4,1) = '1' then shtbnk.remtrz.rsub = "valcon".
           if substr(shtbnk.sub-cod.rcod,1,1) = '1' and substr(shtbnk.sub-cod.rcod,4,1) = '2' then shtbnk.remtrz.rsub = "valcon".
        end.

        /*  Проставление значения справочника *** RMZVAL ***  отношения к валютному контролю */
        if shtbnk.remtrz.rsub = "valcon" then do:
           find shtbnk.sub-cod where shtbnk.sub-cod.acc = shtbnk.remtrz.remtrz and shtbnk.sub-cod.sub = "rmz" and shtbnk.sub-cod.d-cod = "rmzval" no-error.
           if avail shtbnk.sub-cod then shtbnk.sub-cod.ccode = "valcon".
        end.

        ksm = shtbnk.remtrz.remtrz + shtbnk.remtrz.source +
              string(shtbnk.remtrz.rdt) +
              string(shtbnk.remtrz.valdt1) +
              string(shtbnk.remtrz.amt) +
              string(shtbnk.remtrz.payment) +
              string(shtbnk.remtrz.rsub) +
              string(shtbnk.remtrz.racc) +
              string(shtbnk.remtrz.sbank) +
              string(shtbnk.remtrz.rbank) +
              string(shtbnk.remtrz.sqn) +
              string(shtbnk.remtrz.fcrc) +
              string(shtbnk.remtrz.tcrc) +
              string(shtbnk.remtrz.rdt) +
              string(shtbnk.remtrz.sacc) +
              string(shtbnk.remtrz.racc) +
              string(shtbnk.remtrz.ord) +
              string(shtbnk.remtrz.ref) +
              string(shtbnk.remtrz.bb[1]) +
              string(shtbnk.remtrz.bb[2]) +
              string(shtbnk.remtrz.bb[3]) +
              string(shtbnk.remtrz.info[3]) +
              string(shtbnk.remtrz.info[9]) +
              string(shtbnk.remtrz.intmed) +
              string(shtbnk.remtrz.intmedact).
        do i = 1 to 4: ksm = ksm + shtbnk.remtrz.actins[i]. end.
        do i = 1 to 3: ksm = ksm + shtbnk.remtrz.bn[i]. end.
        do i = 1 to 6: ksm = ksm + shtbnk.remtrz.rcvinfo[i]. end.
        do i = 1 to 4: ksm = ksm + shtbnk.remtrz.detpay[i]. end.
        do i = 1 to 4: ksm = ksm + shtbnk.remtrz.ordins[i]. end.
        ksm = ksm + shtbnk.remtrz.ba + shtbnk.remtrz.bi.
        run savelog("pssend","214. remtrz.remtrz=" + s-remtrz + "que.rcod=" + bank.que.rcod ).
        find first bank.sysc where bank.sysc.sysc = "ourbnk" no-lock no-error.
        if avail bank.sysc then ksm = ksm + trim(bank.sysc.stc).
        shtbnk.remtrz.info[1] = encode(ksm).

        create shtbnk.que.
        assign shtbnk.que.remtrz = srm-remtrz
               shtbnk.que.pid = "AN"
               shtbnk.que.rcid = recid(shtbnk.remtrz)
               shtbnk.remtrz.ptype = "N"
               shtbnk.que.ptype = shtbnk.remtrz.ptype.

        if v-reterr = 0 then do:
            shtbnk.que.rcod = "0".
            run savelog("pssend","228. remtrz.remtrz=" + s-remtrz + "que.rcod=" + bank.que.rcod ).
        end. else do:
            shtbnk.que.rcod = "1".
            shtbnk.que.pvar = string(v-reterr).
            run savelog("pssend","232. remtrz.remtrz=" + s-remtrz + "que.rcod=" + bank.que.rcod ).
        end.
        run savelog("pssend","234. remtrz.remtrz=" + s-remtrz + "que.rcod=" + bank.que.rcod ).
        assign shtbnk.que.con = "W"
               shtbnk.que.dp = today
               shtbnk.que.df = today
               shtbnk.que.tf = time
               shtbnk.que.tp = time
               shtbnk.que.dw = today
               shtbnk.que.tw = time
               shtbnk.que.pri = 29999.

        m_hst = bank.remtrz.scbank.
        v-text = "Платеж " + shtbnk.remtrz.remtrz + " <- " + bank.remtrz.sbank + " " + bank.remtrz.remtrz +
                 " зарегистрирован , код завершения  = " + shtbnk.que.rcod.
        run lgps-r.
        run savelog("pssend","248. remtrz.remtrz=" + s-remtrz + "que.rcod=" + bank.que.rcod ).
        /*  End of program body */
        assign bank.que.dp = today
               bank.que.tp = time
               bank.que.con = "F"
               bank.que.rcod = "0".
        run savelog("pssend","254. remtrz.remtrz=" + s-remtrz + "que.rcod=" + bank.que.rcod ).
        v-text = "Отправка прямым доступом " + bank.remtrz.sqn + " " +    bank.remtrz.remtrz + " -> " + bank.remtrz.rcbank + " -> " + shtbnk.remtrz.remtrz +
                 " сумма = " + string(bank.remtrz.payment) + " валюта =" + string(bank.remtrz.fcrc) + " тип платежа = " + bank.remtrz.ptype +
                 " , код завершения  = " + bank.que.rcod.
        run lgps.
        run savelog("pssend","259. remtrz.remtrz=" + s-remtrz + "que.rcod=" + bank.que.rcod ).
    end.
end.
