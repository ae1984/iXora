/* lcbo2ext.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        External Charges - акцепт второго менеджера бэк-офиса + проводки + MT-сообщения
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
        29/03/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
    08/04/2011 id00810 - заполнение поля bank в lceventres
    18/04/2011 id00810 - перекомпиляция
    14/06/2011 id00810 - назначение платежа
    28/06/2011 id00810 - использование функции chk-f
    22/07/2011 id00810 - добавлены новые виды оплат комиссий
    13/09/2011 id00810 - обработка ошибки копирования в SWIFT
    11/11/2011 id00810 - убрала отладочные сообщения
    18/11/2011 id00810 - ошибка в параметрах uni0206
    06.12.2012 Lyubov  - убрала лишний параметр для шаблона vnb0015
*/
{global.i}
{chk-f.i}
def shared var s-lc     like lc.lc.
def shared var s-event  like lcevent.event.
def shared var s-number like lcevent.number.
def shared var s-sts    like lcevent.sts.
def new shared var v-lcerrdes as char.

def var v-sum     as deci no-undo extent 3.
def var v-crc     as int  no-undo.
def var v-type    as char no-undo.
def var v-spgl    as char no-undo.
def var v-pair    as char no-undo.
def var v-acc     as char no-undo.
def var v-dacc    as char no-undo.
def var v-cacc    as char no-undo.
def var v-gl      as int  no-undo.
def var v-gldes   as char no-undo.
def var v-dgl     as int  no-undo.
def var v-cgl     as int  no-undo.
def var v-dgldes  as char no-undo.
def var v-cgldes  as char no-undo.
def var v-num     as char no-undo extent 3.
def var i         as int  no-undo.
def var l         as int  no-undo.
def var v-param   as char no-undo.
def var v-trx     as char no-undo.
def var vdel      as char no-undo initial "^".
def var rcode     as int  no-undo.
def var rdes      as char no-undo.
def var v-benacc  as char no-undo.
def var v-benbank as char no-undo.
def var v-benname as char no-undo.
def var v-benrnn  as char no-undo.
def var v-clname  as char no-undo.
def var v-filrnn  as char no-undo.
def var v-filname as char no-undo.
def var v-sum1    as deci no-undo.
def var v-yes     as logi no-undo init yes.
def var v-knp     as char no-undo.
def var v-kod     as char no-undo.
def var v-kbe     as char no-undo.
def var v-nazn    as char no-undo.
def var v-nazn1   as char no-undo.
def var v-logsno  as char init "no,n,нет,н,1".
def var v-rmz     like remtrz.remtrz no-undo.
def new shared var s-jh like jh.jh.

{LC.i}
pause 0.
if lookup(s-sts,'BO1,ERR') = 0 then do:
    message "Event status should be BO1 or Err!" view-as alert-box error.
    return.
end.

message 'Do you want to change event status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
if not v-yes then return.

find first lcevent where lcevent.bank = s-ourbank and lcevent.lc = s-lc and lcevent.event = s-event and lcevent.number = s-number no-lock no-error.
if not avail lcevent then return.

find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'ComPtype' no-lock no-error.
if avail lceventh and lceventh.value1 <> '' then v-type = lceventh.value1.

find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'CurCode' no-lock no-error.
if avail lceventh and lceventh.value1 <> '' then v-crc = int(lceventh.value1).

find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'ComAmt' no-lock no-error.
if avail lceventh and lceventh.value1 <> '' then v-sum[1] = deci(lceventh.value1).

find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'AmtTax' no-lock no-error.
if avail lceventh and lceventh.value1 <> '' then v-sum[2] = deci(lceventh.value1).

find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'PAmt' no-lock no-error.
if avail lceventh and lceventh.value1 <> '' then v-sum[3] = deci(lceventh.value1). else v-sum[3] = v-sum[1] - v-sum[2].

find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'KOD' no-lock no-error.
if avail lceventh and lceventh.value1 <> '' then v-kod = lceventh.value1.

find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'KBE' no-lock no-error.
if avail lceventh and lceventh.value1 <> '' then v-kbe = lceventh.value1.

find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'KNP' no-lock no-error.
if avail lceventh and lceventh.value1 <> '' then v-knp = lceventh.value1.

find first pksysc where pksysc.sysc = 'extch_trx' + v-type + (if v-crc = 1 then string(v-crc) else '') no-lock no-error.
if not avail pksysc then do:
    message "There is no record extch_trx" + v-type + (if v-crc = 1 then string(v-crc) else "") + " in pksysc file!" view-as alert-box error.
    return.
end.
assign v-spgl   = pksysc.chval
       v-num[1] = '1-st'
       v-num[2] = '2-nd'
       v-num[3] = '3-rd'
       v-nazn   = 'Оплата комиссии инобанка ' + s-lc
       v-nazn1  = 'Корпоративный подоходный налог у источника выплаты с доходов нерезидента ' + s-lc.

do i = 1 to num-entries(v-spgl,';'):
    if v-crc > 1  then do:
        if v-type = '1' and v-sum[i] = 0 then next.
        if v-type = '2' then v-sum[i] = v-sum[1].
        if v-type = '3' and i < 3 then v-sum[i] = v-sum[i + 1].
        if v-type = '4' and i = 1 then v-sum[1] = v-sum[3].
    end.
    else v-sum[i] = v-sum[1].
    v-pair = entry(i,v-spgl,';').

    do l = 1 to 2:
        find first gl where gl.gl = int(entry(l,v-pair)) no-lock no-error.
        if not avail gl then return.
        assign v-gl =  gl.gl v-gldes = gl.des.
        if gl.subled = '' then v-acc = string(gl.gl).
        else if gl.subled = 'arp' then do:
            if v-gl <> 285110 then do:
                find first pksysc where pksysc.sysc = 'ILCARP' no-lock no-error.
                if avail pksysc then do:
                    if num-entries(pksysc.chval) >= v-crc then v-acc = entry(v-crc,pksysc.chval).
                    else do:
                        message "The value ILCARP in pksysc is empty!" view-as alert-box error.
                        return.
                    end.
                end.
            end.
            else do:
                find first sysc where sysc.sysc = 'nlg022' no-lock no-error.
                if not avail sysc then do:
                    message "There is no record nlg022 in bank.sysc file!" view-as alert-box error.
                    return.
                end.
                v-acc = sysc.chval.
            end.
            find first arp where arp.arp = v-acc no-lock no-error.
            if not avail arp then return.
        end.
        else if gl.subled = 'fun' then do:
            find first lch where lch.lc = s-lc and lch.kritcode = 'AccPay' no-lock no-error.
            if not avail lch or lch.value1 = '' then do:
                message 'There is no deal for ' + s-lc + '!' view-as alert-box error.
                return.
            end.
            v-acc = lch.value1.
            find first fun where fun.fun = v-acc no-lock no-error.
            if not avail fun then return.
        end.
        else if gl.subled = 'dfb' then do:
            if v-crc > 1 then do:
                find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'SCor202' no-lock no-error.
                if avail lceventh and lceventh.value1 <> '' then do:
                    find first LCswtacc where LCswtacc.accout = lceventh.value1 and LCswtacc.crc = v-crc no-lock no-error.
                    if avail LCswtacc then v-acc = LCswtacc.acc.
                    else return.
                end.
                else return.
            end.
            else do:
                find first LCswtacc where LCswtacc.crc = v-crc no-lock no-error.
                if avail LCswtacc then v-acc = LCswtacc.acc.
                else return.
            end.
            find first dfb where dfb.dfb = v-acc no-lock no-error.
            if not avail dfb then return.
            v-gl = dfb.gl.
        end.
        if l = 1 then assign v-dacc   = v-acc
                             v-dgl    = v-gl
                             v-dgldes = v-gldes.
                else assign v-cacc   = v-acc
                             v-cgl    = v-gl
                             v-cgldes = v-gldes.
    end.

    find first lceventres where lceventh.bank = lcevent.bank and lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.dacc = v-dacc and lceventres.cacc = v-cacc no-lock no-error.
    if avail lceventres then do:
            message "Attention! The " + v-num[i] + " posting was done earlier!" view-as alert-box info.
    end.
    else do:
            v-trx = ''.
            if v-crc > 1 then do:
                if v-type = '1' then do:
                    if i = 1 then assign v-trx   = 'uni0206'
                                         v-sum1  = v-sum[1]
                                         v-param = v-dacc + vdel + v-nazn + vdel +  string(v-sum1) + vdel + string(v-crc) + vdel + v-cacc.
                    if i = 2 then assign v-trx   = 'vnb0015'
                                         v-sum1  = v-sum[2]
                                         v-param = string(v-sum1) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-nazn1 + vdel + '1' + vdel + v-cacc.
                    if i = 3 then assign v-trx   = 'uni0012'
                                         v-sum1  = v-sum[3]
                                         v-param = string(v-sum1) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn + vdel + substr(v-kbe,1,1) + vdel + substr(v-kbe,2,1) + vdel + v-knp.
                end.
                if v-type = '2' then do:
                    if i = 1 then assign v-trx   = 'uni0012'
                                         v-sum1  = v-sum[1]
                                         v-param = string(v-sum1) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn  + vdel + substr(v-kbe,1,1) + vdel + substr(v-kbe,2,1) + vdel + v-knp.
                    if i = 2 then assign v-trx   = 'uni0206'
                                         v-sum1  = v-sum[1]
                                         v-param = v-dacc + vdel + v-nazn + vdel +  string(v-sum1) + vdel + string(v-crc) + vdel + v-cacc.
                end.
                if v-type = '3' then do:
                    if i = 1 then assign v-trx = 'uni0210'
                                         v-sum1  = v-sum[2]
                                         v-param = string(v-sum1) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-nazn1 + vdel + '1' + vdel + v-cacc + vdel + v-nazn1.
                    if i = 2 then assign v-trx   = 'uni0012'
                                         v-sum1  = v-sum[3]
                                         v-param = string(v-sum1) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn + vdel + substr(v-kbe,1,1) + vdel + substr(v-kbe,2,1) + vdel + v-knp.
                    if i = 3 then assign v-trx   = 'uni0209'
                                         v-sum1  = v-sum[3]
                                         v-param = string(v-sum1) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn.
                end.
                if v-type = '4' then do:
                    if i = 1 then assign v-trx   = 'uni0012'
                                         v-sum1  = v-sum[3]
                                         v-param = string(v-sum1) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn + vdel + substr(v-kbe,1,1) + vdel + substr(v-kbe,2,1) + vdel + v-knp.
                    if i = 2 then assign v-trx   = 'uni0210'
                                         v-sum1  = v-sum[2]
                                         v-param = string(v-sum1) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-nazn1 + vdel + '1' + vdel + v-cacc + vdel + v-nazn1.
                    if i = 3 then assign v-trx   = 'uni0209'
                                         v-sum1  = v-sum[3]
                                         v-param = string(v-sum1) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn.
                end.
               /* if v-type = '5' then
                 assign v-trx   = 'uni0022'
                        v-sum1  = v-sum[1]
                        v-param = string(v-sum1) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-nazn1 + vdel + substr(v-kod,1,1) + vdel + substr(v-kbe,1,1) + vdel + substr(v-kod,2,1) + vdel + substr(v-kbe,2,1) + vdel + v-knp + vdel + '1' + vdel + v-cacc /*+ vdel + v-nazn1*/.*/

            end.
            if v-crc = 1 then do:
                if v-type = '1' then do:
                    if i = 1 then assign v-trx   = 'uni0144'
                                         v-sum1  = v-sum[1]
                                         v-param = string(v-sum1) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn.
                    if i = 2 then assign v-trx   = 'uni0004'
                                         v-sum1  = v-sum[1]
                                         v-param = string(v-sum1) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn + vdel + substr(v-kbe,1,1) + vdel + substr(v-kbe,2,1) + vdel + v-knp.
                end.
                if v-type = '3' then do:
                    if i = 1 then assign v-trx   = 'uni0004'
                                         v-sum1  = v-sum[1]
                                         v-param = string(v-sum1) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn + vdel + substr(v-kbe,1,1) + vdel + substr(v-kbe,2,1) + vdel + v-knp.
                    if i = 3 then assign v-trx   = 'uni0209'
                                         v-sum1  = v-sum[1]
                                         v-param = string(v-sum1) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn.
                end.
            end.
            if v-trx ne '' then do:
                s-jh = 0.
                run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).

                if rcode ne 0 then do:
                    message rdes.
                    pause.
                    message "The " + v-num[i] + " posting was not done!" view-as alert-box error.
                    find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ErrDes' no-lock no-error.
                    if avail lceventh then find current lceventh exclusive-lock.
                    if not avail lceventh then create lceventh.
                    assign  lceventh.lc       = s-lc
                            lceventh.event    = s-event
                            lceventh.number   = s-number
                            lceventh.bank     = s-ourbank
                            lceventh.kritcode = 'ErrDes'
                            lceventh.value1   = string(rcode) + ' ' + rdes.
                    run lcstse(s-sts,'Err').
                    return.
                end.
                message "The " + v-num[i] + " posting was done!" view-as alert-box info.

            end.
            else if v-crc = 1 and ((v-type = '1' and i = 3) or (v-type = '3' and i = 2)) then do:

                find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'BenAcc' no-lock no-error.
                if avail lceventh and lceventh.value1 <> '' then v-benacc = lceventh.value1.

                find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'BenIns' no-lock no-error.
                if avail lceventh and lceventh.value1 <> '' then v-benbank = lceventh.value1.

                find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'BenPay' no-lock no-error.
                if avail lceventh and lceventh.value1 <> '' then v-benname = lceventh.value1.

                find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'BenRNN' no-lock no-error.
                if avail lceventh and lceventh.value1 <> '' then v-benrnn = lceventh.value1.

                find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'Client' no-lock no-error.
                if avail lceventh and lceventh.value1 <> '' then v-clname = lceventh.value1.

                find first cmp no-lock no-error.
                if avail cmp then assign v-filrnn = cmp.addr[2] v-filname = cmp.name.
                v-nazn = 'Оплата комиссии инобанка ' + s-lc + '. Аппликант ' + v-clname.

                run rmzcre (s-number,
                v-sum[1],
                v-dacc,
                v-filrnn,
                v-filname,
                v-benbank,
                v-benacc,
                v-benname,
                v-benrnn,
                '0',
                no,
                v-knp,
                '14',
                v-kbe,
                v-nazn,
                '1P',
                0,
                2,
                g-today) .
                v-rmz = return-value.

                if v-rmz = '' then do:
                    message "The " + v-num[i] + " posting (rmz) was not done!" view-as alert-box error.
                    find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ErrDes' no-lock no-error.
                    if avail lceventh then find current lceventh exclusive-lock.
                    if not avail lceventh then create lceventh.
                    assign  lceventh.lc       = s-lc
                            lceventh.event    = s-event
                            lceventh.number   = s-number
                            lceventh.bank     = s-ourbank
                            lceventh.kritcode = 'ErrDes'
                            lceventh.value1   = 'RMZ error!!!'.
                    run lcstse(s-sts,'Err').
                    return.
                end.
                message "The " + v-num[i] + " posting (rmz) was done!" view-as alert-box info.
            end.
            else do:
                message "The unknown transaction!" view-as alert-box error.
                return.
            end.
            create  lceventres.
            assign  lceventres.lc      = s-lc
                    lceventres.event   = s-event
                    lceventres.number  = s-number
                    lceventres.dacc    = v-dacc
                    lceventres.cacc    = v-cacc
                    lceventres.amt     = v-sum1
                    lceventres.crc     = v-crc
                    lceventres.com     = no
                    lceventres.comcode = ''
                    lceventres.rwho    = g-ofc
                    lceventres.rwhn    = g-today
                    lceventres.jh      = s-jh
                    lceventres.jdt     = g-today
                    lceventres.trx     = v-trx
                    lceventres.levC    = 1
                    lceventres.levD    = 1
                    lceventres.rem     = v-nazn
                    lceventres.bank    = s-ourbank
                    lceventres.info[1] = v-rmz.
            if v-rmz ne '' then do:
                find first remtrz where remtrz.remtrz = v-rmz no-lock no-error.

                assign  lceventres.jh  = remtrz.jh1
                        lceventres.rem = lceventres.rem + ' (перевод  ' + v-rmz + ')'.
            end.
    end.
end.

if v-crc > 1 and (v-type = '1' or v-type = '3') then do:
    if chk-f("$HOME/.ssh/id_swift") ne '0' then do:
            message "There is no file $HOME/.ssh/id_swift!" view-as alert-box error.
            find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ErrDes' no-lock no-error.
            if avail lceventh then find current lceventh exclusive-lock no-error.
            else create lceventh.
            assign lceventh.value1   = "There is no file $HOME/.ssh/id_swift!"
                   lceventh.lc       = s-lc
                   lceventh.event    = s-event
                   lceventh.number   = s-number
                   lceventh.kritcode = 'ErrDes'
                   lceventh.bank     = s-ourbank.
            find current lceventh no-lock no-error.
            run lcstse(s-sts,'Err').
            return.
    end.
    run lcmtext ('202',yes) no-error.
    if error-status:error then do:
        find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ErrDes' no-lock no-error.
            if avail lceventh then find current lceventh exclusive-lock no-error.
            else create lceventh.
            assign lceventh.value1   = "File MT202 wasn't copied to SWIFT Alliance!"
                   lceventh.lc       = s-lc
                   lceventh.event    = s-event
                   lceventh.number   = s-number
                   lceventh.kritcode = 'ErrDes'
                   lceventh.bank     = s-ourbank.
            find current lceventh no-lock no-error.
            run lcstse(s-sts,'Err').
            return.
    end.
    find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'MT756' no-lock no-error.
    if avail lceventh and lookup(lceventh.value1,v-logsno) = 0 then do:
        run lcmtext ('756',yes) no-error.
        if error-status:error then do:
            find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ErrDes' no-lock no-error.
            if avail lceventh then find current lceventh exclusive-lock no-error.
            else create lceventh.
            assign lceventh.value1   = "File MT756 wasn't copied to SWIFT Alliance!"
                   lceventh.lc       = s-lc
                   lceventh.event    = s-event
                   lceventh.number   = s-number
                   lceventh.kritcode = 'ErrDes'
                   lceventh.bank     = s-ourbank.
            find current lceventh no-lock no-error.
            run lcstse(s-sts,'Err').
            return.
        end.
    end.
end.
run lcstse(s-sts,'FIN').
if s-sts = 'ERR' then do:
    find first lceventh where lceventh.bank = lcevent.bank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ErrDes' no-lock no-error.
    if avail lceventh then do:
        find current lceventh exclusive-lock.
        lceventh.value1 = ''.
        find current lceventh no-lock no-error.
    end.
end.
