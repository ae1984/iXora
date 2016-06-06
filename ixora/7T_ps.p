/* 7T_ps.p
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
        28.09.2002 - sasco - отправка реестров для KMobile
        19.03.2004 isaev - автом. пополнение карт.счетов с филиалов
	    24.06.2006 tsoy     - перекомпиляция
	    06.04.2009 galina - проверка соответствия валют при зачислении на arp или на cif счет
        24/11/2010 galina - записываем номер платежа в ЦО в талицу lcpayres для платежей ао аккредитивам
        10.01.2011 Luiza   - добавила передачу пустого параметра ("") при вызове trxsim.p
        19/07/2011 id00810 - записываем номер платежа в ЦО в талицу lceventres для платежей по аккредитивам
        08/09/2011 madiyar - убрал пробелы между detpay в примечании к проводке
        07.06.2012 evseev - отструктурировал код
        10.08.2012 id00810 - заполнение таблицы pcpay для платежей по пополнению счетов по ПК
        28.11.2012 evseev - ТЗ-1374
*/


/* 2-я проводка */

{global.i}
{lgps.i}
{convgl.i "bank"}

{comm-txb.i}
def var seltown as char.
seltown = comm-txb().

def var chkbal like jl.dam.
def new shared var s-sta as char.
def new shared var s-ref as char.
def new shared var s-rem like rem.rem.
def buffer bgl for gl.
def buffer bjl for jl.
/* for trxgen start */

def var s-jh like jh.jh .
def var vdel as cha initial "^" .
def var rdes   as cha .
def var rcode   as int initial 0 .
def var rdes1  as cha .
def var rcode1  as int .
def var vparam as cha .
def var vparam1 as cha .
def var vsum as cha .
def var shcode as cha .
def var shcode1 as cha .
def var v-weekbeg as int.
def var v-weekend as int.
def var ro-gl as char.
def var ro-gl1 as char.
def var ri-gl as char.
def var ri-gl1 as char.

find sysc where sysc.sysc eq "PSPYGL" no-lock .
ro-gl = string(sysc.inval) .
ro-gl1 = trim(sysc.chval).

find sysc where sysc.sysc eq "PSINGL" no-lock .
ri-gl = string(sysc.inval) .
ri-gl1 = trim(sysc.chval).

find first que where que.pid = m_pid and que.con = "W" use-index fprc no-lock no-error.
if not avail que then return.

do transaction:
    find first que where que.pid = m_pid and que.con = "W" use-index fprc exclusive-lock no-error.
    if avail que then do:
        que.dw = today.
        que.tw = time.
        que.con = "P".
        find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock.
        find first jl where jl.jh = remtrz.jh1 no-lock no-error.
        if not avail jl or remtrz.jh1 eq ?  then do:
            v-text = remtrz.remtrz +  " Не найдена 1 проводка !".
            run lgps.
            que.dp = today.
            que.tp = time.
            que.con = "F".
            que.pvar = "".
            que.rcod = "1".
            return .
        end.
        if remtrz.valdt2 gt g-today then do:
            v-text = remtrz.remtrz +  " 2 дата валютирования не сегодня !".
            run lgps.
            que.dp = today.
            que.tp = time.
            que.con = "F".
            que.pvar = "".
            que.rcod = "3".
            return.
        end.

        find first jl where jl.jh = remtrz.jh2 no-lock no-error.
        if not avail jl then remtrz.jh2 = ?.

        if remtrz.jh2 ne ? and remtrz.jh1 ne remtrz.jh2 then do:
            v-text = remtrz.remtrz +  " 2 проводка = " + string(remtrz.jh2) + "  уже сделана . ".
            run lgps.
            que.dp = today.
            que.tp = time.
            que.con = "F".
            que.pvar = "100".
            que.rcod = "1".
            return.
        end.

        if remtrz.info[10] = "" then do:
            for each bjl where bjl.jh = remtrz.jh1 no-lock.
                if bjl.gl = int(ro-gl) or bjl.gl = int(ro-gl1) or bjl.gl = int(ri-gl1) or bjl.gl = int(ri-gl) then do:
                    remtrz.info[10] = string(bjl.gl).
                    leave.
                end.
            end.
            if remtrz.info[10] = "" then do:
                v-text = "Ошибка ! " + remtrz.remtrz +  " info[10] пуст " .
                run lgps.
                que.dp = today.
                que.tp = time.
                que.con = "F".
                que.pvar = "100".
                que.rcod = "1".
                return.
            end.
        end.

        if remtrz.crgl eq ? or remtrz.crgl = 0 then do:
            v-text = remtrz.remtrz + " ошибка счета Г/К кредита ! . ".
            run lgps.
            que.dp = today.
            que.tp = time.
            que.con = "F".
            que.pvar = "100".
            que.rcod = "1".
            return.
        end.

        if remtrz.ptype = "7" and remtrz.svca > 0 and remtrz.svcrc ne remtrz.tcrc then do:
            v-text = "Ошибка валюты комиссии ! " + remtrz.remtrz.
            run lgps.
            que.dp = today.
            que.tp = time.
            que.con = "F".
            que.pvar = "100".
            que.rcod = "1".
            return.
        end.

        find first gl where gl.gl = remtrz.crgl no-lock.
        if gl.sub = "cif" then do:
            find first aaa where aaa.aaa = remtrz.cracc exclusive-lock no-wait no-error.
            if not avail aaa then do:
                que.pid = m_pid.
                que.df = today.
                que.tf = time.
                que.con = "W".
                return.
            end.
            if aaa.crc <> remtrz.tcrc then do:
              v-text = "Ошибка - валюта счета клиента не соответствует валюте платежа! " + remtrz.remtrz.
              run lgps.
              que.dp = today.
              que.tp = time.
              que.con = "F".
              que.pvar = "100".
              que.rcod = "1".
              return.
            end.
        end.
        if gl.sub = "arp" then do:
            find first arp where arp.arp = remtrz.cracc exclusive-lock no-wait no-error.
            if not avail arp then do:
                que.pid = m_pid.
                que.df = today.
                que.tf = time.
                que.con = "W".
                return.
            end.
            if arp.crc <> remtrz.tcrc then do:
               v-text = "Ошибка - валюта транзиного счета не соответствует валюте платежа! " + remtrz.remtrz.
               run lgps.
               que.dp = today.
               que.tp = time.
               que.con = "F".
               que.pvar = "100".
               que.rcod = "1".
               return.
            end.
        end.

        if remtrz.jh1 = remtrz.jh2 and remtrz.jh2 ne ? then do:
            que.dp = today.
            que.tp = time.
            que.con = "F".
            que.rcod = "0".
            v-text = " 2 проводка = 1 проводке " + string(remtrz.jh2) + " для " + remtrz.remtrz.
            run lgps.
            return.
        end.

        /*  Beginning of main program body */
        find first gl where gl.gl = remtrz.crgl no-lock.
        find first bgl where bgl.gl = remtrz.drgl no-lock.
        if lookup(remtrz.ptype,"N,1,2,4,5,6,8") ne 0 or (lookup(remtrz.ptype,"7") ne 0 and bgl.sub = "cif" and remtrz.bi = "our") then do:
            vparam = remtrz.remtrz + vdel + string(remtrz.payment) + vdel + remtrz.info[10] + vdel + remtrz.cracc + vdel + remtrz.remtrz + " " +
                     replace(trim(remtrz.detpay[1]) + trim(remtrz.detpay[2]) + trim(remtrz.detpay[3]) + trim(remtrz.detpay[4]) + substr(remtrz.ord,1,35) +
                     substr(remtrz.ord,36,70) + substr(remtrz.ord,71), "^", " ").
            if gl.sub = "cif" then shcode = "PSY0032".
            else if gl.sub = "dfb" then shcode = "PSY0031".
        end. else if lookup(remtrz.ptype,"3,7") ne 0 then do:
            if remtrz.fcrc = remtrz.tcrc then do:
                vparam = remtrz.remtrz + vdel + string(remtrz.payment) + vdel + (if remtrz.cracc ne "" then "" else string(remtrz.fcrc) + vdel ) +
                         remtrz.info[10] + vdel + (if remtrz.cracc ne "" then remtrz.cracc + vdel else "") + remtrz.remtrz + " " +
                         replace(trim(remtrz.detpay[1]) + trim(remtrz.detpay[2]) + trim(remtrz.detpay[3]) + trim(remtrz.detpay[4]) +
                         substr(remtrz.ord,1,35) + substr(remtrz.ord,36,70) + substr(remtrz.ord,71),"^"," ").
                shcode = if remtrz.rsub = "arp" and remtrz.cracc ne "" then "PSY0041" else (if remtrz.cracc ne "" then "PSY0033"  else "PSY0036").
            end. else do:
                vparam = remtrz.remtrz
                     + vdel + string(remtrz.amt)
                     + vdel + string(remtrz.fcrc)
                     + vdel + string(getConvGL(remtrz.fcrc,"C"))
                     + vdel + remtrz.info[10]
                     + vdel + remtrz.remtrz + " " + replace(trim(remtrz.detpay[1]) + trim(remtrz.detpay[2])
                                  + trim(remtrz.detpay[3]) + trim(remtrz.detpay[4])
                                  + substr(remtrz.ord,1,35) + substr(remtrz.ord,36,70) + substr(remtrz.ord,71),"^"," ")
                     + vdel + string(getConvGL(remtrz.tcrc,"D"))
                     + vdel + remtrz.cracc.
                shcode = "PSY0034" .
                run trxsim("", shcode, vdel, vparam, 4, output rcode, output rdes, output vsum).
                if rcode = 0 then remtrz.payment = decimal(vsum).
            end.
            if svca > 0 then do:
                vparam1 = string(remtrz.svca)    + vdel +
                          remtrz.cracc           + vdel +
                          string(remtrz.svccgl)  + vdel +
                          remtrz.remtrz + " " + replace(
                          trim(remtrz.detpay[1]) + trim(remtrz.detpay[2]) +
                          trim(remtrz.detpay[3]) + trim(remtrz.detpay[4]) +
                          substr(remtrz.ord,1,35) + substr(remtrz.ord,36,70) +
                          substr(remtrz.ord,71),"^"," ").
                shcode1 = "PSY0025".
            end.
        end.
        if rcode = 0 then do:
            run trxgen(shcode, vdel, vparam, "rmz", remtrz.remtrz, output rcode, output rdes,input-output s-jh).
            if rcode = 0 and shcode1 eq "psy0025" then do:
                run trxgen(shcode1, vdel, vparam1, "rmz", remtrz.remtrz, output rcode, output rdes, input-output s-jh).
            end.
        end.
        if rcode > 0  then do:
            v-text = " Ошибка 2 проводки rcode = " + string(rcode) + ":" + rdes + " " + remtrz.remtrz + " " + remtrz.dracc.
            run lgps.
            que.dp = today.
            que.tp = time.
            que.con = "F".
            if rcode = 28 then que.rcod = "2".
            else que.rcod = "1".
            return.
        end.

        /*  End of program body */

        v-text = string(s-jh) + " 2 проводка " + remtrz.remtrz + " тип = " + remtrz.ptype + " " + remtrz.cracc + " " + string(remtrz.payment) + " Вал = " + string(remtrz.tcrc).
        if avail rem then v-text = v-text + " RMO = " + s-rem.
        run lgps.
        que.dp = today.
        que.tp = time.
        que.con = "F".
        que.rcod = "0".
        remtrz.jh2 = s-jh.

        /*****galina***********/
        def var v-rmzf as char.
        v-rmzf = ''.
        find first arp where arp.arp = remtrz.cracc no-lock no-error.
        if avail arp then do:
            if arp.gl = 287090 then do:
                if remtrz.sbank begins 'TXB' then do:
                    v-rmzf = substr(remtrz.sqn,index(remtrz.sqn,'RMZ'),10).
                    if v-rmzf <> '' then do:
                        find first lcpayres where lcpayres.info[1] = v-rmzf no-lock no-error.
                        if avail lcpayres then do:
                            find current lcpayres exclusive-lock no-error.
                            lcpayres.info[2] = remtrz.remtrz.
                            lcpayres.rem = lcpayres.rem + '; Номер платежа в ЦО ' + remtrz.remtrz.
                            find current lcpayres no-lock no-error.
                        end. else do:
                            find first lceventres where lceventres.info[1] = v-rmzf no-lock no-error.
                            if avail lceventres then do:
                                find current lceventres exclusive-lock no-error.
                                lceventres.info[2] = remtrz.remtrz.
                                lceventres.rem = lceventres.rem + '; Номер платежа в ЦО ' + remtrz.remtrz.
                                find current lceventres no-lock no-error.
                            end.
                        end.
                    end.
                end.
            end.
            else if arp.gl = 286012 then do:
                find first pcpay where pcpay.ref = remtrz.rcvinfo[3] no-lock no-error.
                if avail pcpay then do:
                    find current pcpay exclusive-lock.
                    assign pcpay.ref = remtrz.remtrz
                           pcpay.jh  = s-jh
                           pcpay.sts = 'ready'
                           pcpay.who = g-ofc
                           pcpay.whn = g-today.
                    find current pcpay no-lock no-error.
                end.
            end.
        end.
        /**************************/
        /* isaev - for BWX attaches */
        {bwxatrmz.i}
        /* sasco - for KMobile */
        if remtrz.source <> 'IBH' then do:
            {mob333rmz.i}
        end.
        /* the same for kcell - Kanat */
        if remtrz.source <> 'IBH' then do:
            {ibcomrmz.i}
        end.

        find jh where jh.jh = s-jh exclusive-lock.
        chkbal = 0.
        for each jl of jh exclusive-lock.
            if jl.dam > 0 then chkbal = chkbal + jl.dam .
            else chkbal = chkbal - jl.cam.
            jl.sts = 6 .
        end.
        jh.sts = 6.
        release jh.
        if chkbal ne 0 then do:
            v-text = remtrz.remtrz + " Ошибка ! Несбалансированная проводка ! ".
            que.rcod = "1".
            run lgps.
        end.
    end.
end.
