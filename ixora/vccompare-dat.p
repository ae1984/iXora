/* vccompare-dat.p
 * MODULE
        Название модуля - Валютный контроль.
 * DESCRIPTION
        Описание - Сверка оборотов по счету клиента и платежей Валютного Контроля.
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
        16.01.2012 aigul
 * BASES
        BANK COMM TXB
 * CHANGES
        17.01.2012 aigul - добавила and txb.remtrz.fcrc = vcdocs.pcrc and txb.remtrz.amt = vcdocs.sum
        30.01.2012 aigul - добавила проверку joudoc
        07.03.2012 aigul - добавила сравнение платежей рмз с филиала
        19.04.2012 aigul - исправила проверку банка
        20.04.2012 aigul - исключила удаленные проводки
        29.01.2013 damir - Полностью переделал. Оптимизация кода. Внедрено Техническое Задание.
*/
{vccomparevar.i}

def var v-bank as char.
def var v-rmz as char.
def var v-ourbnk as char.
def var v-SendRec as char.
def var v-KOd as char.
def var v-KBe as char.
def var v-KNP as char.
def var v-Storn as logi.

def buffer b-jh for txb.jh.
def buffer b-jl for txb.jl.
def buffer b1-jl for txb.jl.
def buffer b2-jl for txb.jl.

find first txb.sysc where txb.sysc.sysc eq "ourbnk" no-lock no-error.
if avail txb.sysc then v-ourbnk = trim(txb.sysc.chval).
find txb.cmp no-lock no-error.
if avail txb.cmp then v-bank = trim(txb.cmp.name).

nextJL:
for each txb.jl where txb.jl.jdt ge v-dt1 and txb.jl.jdt le v-dt2 and txb.jl.who ne "" no-lock:
    find first txb.jh where txb.jh.jh eq txb.jl.jh no-lock no-error.
    find first txb.aaa where txb.aaa.aaa eq txb.jl.acc no-lock no-error.
    if (not avail txb.jh) or (txb.jl.sts ne 6) or (not avail txb.aaa) then next nextJL.
    find first txb.cif where txb.cif.cif eq txb.aaa.cif no-lock no-error.
    if not avail txb.cif then next nextJL.

    v-SendRec = "". v-KOd = "". v-KBe = "". v-KNP = "". v-Storn = false.

    v-Storn = txb.jl.rem[1] matches "*storn*" or txb.jl.rem[2] matches "*storn*" or txb.jl.rem[3] matches "*storn*" or
              txb.jl.rem[4] matches "*storn*" or txb.jl.rem[5] matches "*storn*".

    if substr(trim(txb.jh.party),1,10) begins "rmz" then do:
        find first txb.remtrz where txb.remtrz.remtrz eq substr(trim(txb.jh.party),1,10) no-lock no-error.
        if avail txb.remtrz then do:
            if txb.remtrz.dracc eq txb.aaa.aaa then v-SendRec = "S".
            if txb.remtrz.cracc eq txb.aaa.aaa then v-SendRec = "R".
        end.
        if lookup(v-SendRec,"S,R") gt 0 then do:
            run Get_EKNP("rmz",txb.remtrz.remtrz,"eknp",output v-KOd,output v-KBe,output v-KNP).

            create wrk1.
            wrk1.txb = v-ourbnk.
            wrk1.bank = v-bank.
            wrk1.sub = "rmz".
            wrk1.rmz_jou = txb.remtrz.remtrz.
            wrk1.SendRec = v-SendRec.
            wrk1.jh = txb.jl.jh.
            find first b1-jl where b1-jl.jh eq txb.remtrz.jh1 no-lock no-error.
            find last b2-jl where b2-jl.jh eq txb.remtrz.jh2 no-lock no-error.
            if avail b1-jl and avail b2-jl then do:
                wrk1.drgl = b1-jl.gl.
                wrk1.crgl = b2-jl.gl.
            end.
            else do:
                wrk1.drgl = txb.remtrz.drgl.
                wrk1.crgl = txb.remtrz.crgl.
            end.
            if v-SendRec eq "S" then wrk1.crc = txb.remtrz.fcrc.
            if v-SendRec eq "R" then wrk1.crc = txb.remtrz.tcrc.
            wrk1.cif = txb.cif.cif.
            wrk1.cifname = trim(txb.cif.prefix) + " " + trim(txb.cif.name).
            wrk1.type = txb.cif.type.
            wrk1.rdt = txb.remtrz.rdt.
            wrk1.jdt = txb.jl.jdt.
            if txb.jl.dc eq "D" then wrk1.amt = txb.jl.dam.
            else wrk1.amt = txb.jl.cam.
            wrk1.note = trim(txb.remtrz.detpay[1]) + " " + trim(txb.remtrz.detpay[2]) + " " + trim(txb.remtrz.detpay[3]) + " " + trim(txb.remtrz.detpay[4]).
            wrk1.KOd = v-KOd.
            wrk1.KBe = v-KBe.
            wrk1.KNP = v-KNP.
            if txb.cif.type eq "B" then do:
                find first comm.vccontrs where comm.vccontrs.cif eq txb.cif.cif no-lock no-error.
                if avail comm.vccontrs then wrk1.AtrContract = "present".
                else wrk1.AtrContract = "none".
            end.
        end.
    end.
    else if substr(trim(txb.jh.party),1,10) begins "jou" then do:
        find first txb.joudoc where txb.joudoc.docnum eq substr(trim(txb.jh.party),1,10) no-lock no-error.
        if avail txb.joudoc then do:
            if not (txb.joudoc.dracctype eq "4" and txb.joudoc.cracctype eq "2") then next nextJL.

            find first txb.arp where txb.arp.arp eq txb.joudoc.dracc no-lock no-error.
            if not (avail txb.arp and string(txb.arp.gl) begins "2237" and txb.joudoc.cracc eq txb.aaa.aaa) then next nextJL.

            run Get_EKNP("jou",txb.joudoc.docnum,"eknp",output v-KOd,output v-KBe,output v-KNP).
            if v-KOd + v-KBe + v-KNP eq "" then
            run GetCods_txb(v-Storn,txb.jl.jh,txb.jl.dc,txb.jl.cam,txb.jl.acc,output v-KOd,output v-KBe,output v-KNP).

            create wrk1.
            wrk1.txb = v-ourbnk.
            wrk1.bank = v-bank.
            wrk1.sub = "jou".
            wrk1.rmz_jou = joudoc.docnum.
            wrk1.SendRec = "R".
            wrk1.drgl = txb.arp.gl.
            wrk1.crgl = txb.aaa.gl.
            wrk1.jh = txb.jl.jh.
            wrk1.acc = txb.joudoc.cracc.
            wrk1.cif = txb.cif.cif.
            wrk1.type = txb.cif.type.
            if txb.jl.dc eq "D" then wrk1.amt = txb.jl.dam.
            else wrk1.amt = txb.jl.cam.
            wrk1.crc = txb.joudoc.crcur.
            wrk1.rdt = txb.joudoc.whn.
            wrk1.jdt = txb.jl.jdt.
            wrk1.cifname = trim(txb.cif.prefix) + " " + trim(txb.cif.name).
            wrk1.KOd = v-KOd.
            wrk1.KBe = v-KBe.
            wrk1.KNP = v-KNP.
            wrk1.note = txb.joudoc.remark[1] + " " + txb.joudoc.remark[2].
            if txb.cif.type eq "B" then do:
                find first comm.vccontrs where comm.vccontrs.cif eq txb.cif.cif no-lock no-error.
                if avail comm.vccontrs then wrk1.AtrContract = "present".
                else wrk1.AtrContract = "none".
            end.
        end.
    end.
    else do:
        if txb.jl.dc eq "D" then do:
            find first b-jl where b-jl.jh eq txb.jl.jh and b-jl.crc eq txb.jl.crc and b-jl.dc eq "C" and b-jl.cam eq txb.jl.dam and
            b-jl.ln ne txb.jl.ln no-lock no-error.
            if avail b-jl then do:
                run GetCods_txb(v-Storn,txb.jl.jh,txb.jl.dc,txb.jl.dam,txb.jl.acc,output v-KOd,output v-KBe,output v-KNP).

                create wrk1.
                wrk1.txb = v-ourbnk.
                wrk1.bank = v-bank.
                wrk1.sub = "other".
                wrk1.SendRec = "S".
                wrk1.jh = txb.jl.jh.
                wrk1.drgl = txb.jl.gl.
                wrk1.crgl = b-jl.gl.
                wrk1.acc = txb.jl.acc.
                wrk1.cif = txb.cif.cif.
                wrk1.type = txb.cif.type.
                wrk1.amt = txb.jl.dam.
                wrk1.crc = txb.jl.crc.
                wrk1.rdt = txb.jl.whn.
                wrk1.jdt = txb.jl.jdt.
                wrk1.cifname = trim(txb.cif.prefix) + " " + trim(txb.cif.name).
                wrk1.KOd = v-KOd.
                wrk1.KBe = v-KBe.
                wrk1.KNP = v-KNP.
                wrk1.note = txb.jl.rem[1] + " " + txb.jl.rem[2] + " " + txb.jl.rem[3] + " " + txb.jl.rem[4] + " " + txb.jl.rem[5].

                if txb.cif.type eq "B" then do:
                    find first comm.vccontrs where comm.vccontrs.cif eq txb.cif.cif no-lock no-error.
                    if avail comm.vccontrs then wrk1.AtrContract = "present".
                    else wrk1.AtrContract = "none".
                end.
            end.
        end.
        if txb.jl.dc eq "C" then do:
            find first b-jl where b-jl.jh eq txb.jl.jh and b-jl.crc eq txb.jl.crc and b-jl.dc eq "D" and b-jl.dam eq txb.jl.cam and
            b-jl.ln ne txb.jl.ln no-lock no-error.
            if avail b-jl then do:
                run GetCods_txb(v-Storn,txb.jl.jh,txb.jl.dc,txb.jl.cam,txb.jl.acc,output v-KOd,output v-KBe,output v-KNP).

                create wrk1.
                wrk1.txb = v-ourbnk.
                wrk1.bank = v-bank.
                wrk1.sub = "other".
                wrk1.SendRec = "R".
                wrk1.jh = txb.jl.jh.
                wrk1.drgl = b-jl.gl.
                wrk1.crgl = txb.jl.gl.
                wrk1.acc = txb.jl.acc.
                wrk1.cif = txb.cif.cif.
                wrk1.type = txb.cif.type.
                wrk1.amt = txb.jl.cam.
                wrk1.crc = txb.jl.crc.
                wrk1.rdt = txb.jl.whn.
                wrk1.jdt = txb.jl.jdt.
                wrk1.cifname = trim(txb.cif.prefix) + " " + trim(txb.cif.name).
                wrk1.KOd = v-KOd.
                wrk1.KBe = v-KBe.
                wrk1.KNP = v-KNP.
                wrk1.note = txb.jl.rem[1] + " " + txb.jl.rem[2] + " " + txb.jl.rem[3] + " " + txb.jl.rem[4] + " " + txb.jl.rem[5].

                if txb.cif.type eq "B" then do:
                    find first comm.vccontrs where comm.vccontrs.cif eq txb.cif.cif no-lock no-error.
                    if avail comm.vccontrs then wrk1.AtrContract = "present".
                    else wrk1.AtrContract = "none".
                end.
            end.
        end.
    end.
    hide message no-pause.
    message "Base-" v-ourbnk " Journal Ledger-" txb.jl.jh.
end.

nextVCCONTRS:
for each comm.vccontrs where comm.vccontrs.bank eq v-ourbnk no-lock:
    find txb.cif where txb.cif.cif eq comm.vccontrs.cif no-lock no-error.
    if not avail txb.cif then next nextVCCONTRS.
    for each comm.vcdocs where comm.vcdocs.contract eq comm.vccontrs.contract and comm.vcdocs.dndate ge v-dt1 and
    comm.vcdocs.dndate le v-dt2 and (comm.vcdocs.dntype eq "02" or comm.vcdocs.dntype eq "03") and (comm.vcdocs.payret or
    not comm.vcdocs.payret) no-lock:
        create wrk2.
        wrk2.txb = v-ourbnk.
        wrk2.bank = v-bank.
        wrk2.cif = comm.vccontrs.cif.
        wrk2.cifname = trim(txb.cif.prefix) + " " + trim(txb.cif.name).
        wrk2.type = txb.cif.type.
        wrk2.contract = trim(comm.vccontrs.ctnum) + " от " + string(comm.vccontrs.ctdate, "99/99/9999").
        wrk2.cttype = comm.vccontrs.cttype.
        wrk2.rdt = comm.vcdocs.rdt.
        wrk2.jdt = comm.vcdocs.dndate.
        wrk2.KNP = comm.vcdocs.knp.
        wrk2.note = comm.vcdocs.info[1].
        wrk2.amt = comm.vcdocs.sum.
        wrk2.crc = comm.vcdocs.pcrc.
        if comm.vcdocs.dntype eq "02" then wrk2.dntype = "извещение".
        if comm.vcdocs.dntype eq "03" then wrk2.dntype = "поручение".
        find first vcps where vcps.contract eq comm.vccontrs.contract and vcps.dntype eq "01" no-lock no-error.
        if avail vcps then wrk2.ps = vcps.dnnum + string(vcps.num).
    end.
    hide message no-pause.
    message "Base-" v-ourbnk " Contract-" comm.vccontrs.contract.
end.

procedure Get_EKNP:
    def input parameter p-sub as char.
    def input parameter p-acc as char.
    def input parameter p-d-cod as char.
    def output parameter p-KOd as char.
    def output parameter p-KBe as char.
    def output parameter p-KNP as char.

    p-KOd = "". p-KBe = "". p-KNP = "".
    find first txb.sub-cod where txb.sub-cod.sub eq p-sub and txb.sub-cod.acc eq p-acc and txb.sub-cod.d-cod eq p-d-cod and txb.sub-cod.ccode ne "msc" no-lock no-error.
    if avail txb.sub-cod then do:
        p-KOd = substr(trim(txb.sub-cod.rcode),1,2).
        p-KBe = substr(trim(txb.sub-cod.rcode),4,2).
        p-KNP = substr(trim(txb.sub-cod.rcode),7,3).
    end.
end procedure.


