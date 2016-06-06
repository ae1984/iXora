/* PCGL_ps.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Формирование проводок по платежным картам на сонове файлов GL
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню
 * AUTHOR
        29/10/2012 id00810
 * BASES
        BANK COMM
 * CHANGES
        27/11/2012 id00810 - исправила условие remtrz.jh2 = ?,
                             добавила возможность повтора в теч.часа попыток выполнить транзакцию в случае нехватки средств
        28/12/2012 id00810 - добавила проверку типа счета arp при определении нехватки средств
 */

{global.i}
def var v-bank     as char no-undo.
def var v-nazn     as char no-undo.
def var v-vnb      as logi no-undo.
def var v-dacc     as char no-undo.
def var v-cacc     as char no-undo.
def var v-trx      as char no-undo.
def var v-param    as char no-undo.
def var vdel       as char no-undo initial "^".
def var rcode      as int  no-undo.
def var rdes       as char no-undo.
def var v-time     as int  no-undo.
def var i          as int  no-undo.
def var j          as int  no-undo.
def var k          as int  no-undo.
def var v-rnnfrom  as char no-undo.
def var v-rnnto    as char no-undo.
def var v-namefrom as char no-undo.
def var v-nameto   as char no-undo.
def var v-remtrz   as char no-undo.
def var v-kod      as char no-undo.
def var v-kbe      as char no-undo.
def var v-knp      as char no-undo.
def var v-txt      as char no-undo.
def var v-err      as logi no-undo.
def var v-res      as deci no-undo.
def new shared var s-jh like jh.jh.
def buffer b-pcgl for pcgl.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    run savelog( "PCGL", " Нет параметра ourbnk sysc!").
    return.
end.
v-bank = sysc.chval.
find first pcgl where pcgl.dbnk = v-bank and pcgl.sts = 'new' no-lock no-error.
if not avail pcgl then find first pcgl where pcgl.cbnk = v-bank and pcgl.sts = 'rmz' no-lock no-error.
if not avail pcgl then return.
v-nazn = 'GL ' + 'за ' + string(pcgl.trdt).
for each pcgl where pcgl.dbnk = v-bank and pcgl.sts = 'new' no-lock break by pcgl.cbnk by pcgl.dacc by pcgl.cacc:
    i = i + 1.
    if first-of(pcgl.cbnk)
    then v-vnb = if pcgl.cbnk = pcgl.dbnk then yes else no.
    if v-vnb then do:
        s-jh = 0.
        assign v-dacc = pcgl.dacc
               v-cacc = pcgl.cacc
               v-param = string(pcgl.tramt) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn + vdel + pcgl.trdes
               v-trx   = "vnb0010".
        run trxgen (v-trx, vdel, v-param, "arp", pcgl.trnum, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            j = j + 1.
            run savelog( "PCGL", pcgl.trnum + " " + rdes).
            if pcgl.info[1] eq '' then do:
               find first b-pcgl where recid(b-pcgl) = recid(pcgl) exclusive-lock no-error.
               assign b-pcgl.who     = g-ofc
                      b-pcgl.info[1] = string(time).
               find current b-pcgl no-lock no-error.
               next.
            end.
            else do:
                v-time = int(pcgl.info[1]) no-error.
                if time - v-time >= 3600 then do:
                    k = k + 1.
                    find first b-pcgl where recid(b-pcgl) = recid(pcgl) exclusive-lock no-error.
                    assign b-pcgl.sts     = 'err'
                           b-pcgl.who     = g-ofc
                           b-pcgl.info[1] = rdes.
                    find current b-pcgl no-lock no-error.
                end.
                next.
            end.
        end.
        find first b-pcgl where recid(b-pcgl) = recid(pcgl) exclusive-lock no-error.
        assign b-pcgl.sts     = 'OK'
               b-pcgl.who     = g-ofc
               b-pcgl.jh1     = s-jh
               b-pcgl.jh2     = s-jh
               b-pcgl.info[1] = ''.
        find current b-pcgl no-lock no-error.
    end.
    else do:
        assign v-err = no
               v-txt = '' .
        find first arp where arp.arp = pcgl.dacc no-lock no-error.
        if not avail arp then assign v-err = yes
                                     v-txt = 'Не найден счет ARP'.
        else do:
            find first sub-cod where sub-cod.acc   = arp.arp
                                 and sub-cod.sub   = "arp"
                                 and sub-cod.d-cod = "clsa"
                                 no-lock no-error.
            if avail sub-cod then if sub-cod.ccode ne "msc" then assign v-err = yes
                                                                        v-txt = 'Счет ARP закрыт'.
            else do:
                run lonbalcrc.p ('arp',arp.arp,g-today,'1',yes,arp.crc,output v-res).
                if arp.type = 03 and abs(v-res) < pcgl.tramt then do:
                    assign v-err = yes
                           v-txt = 'Не хватает средств на счете ARP'.
                    if pcgl.info[1] eq '' then do:
                        find first b-pcgl where recid(b-pcgl) = recid(pcgl) exclusive-lock no-error.
                        assign b-pcgl.who     = g-ofc
                               b-pcgl.info[1] = string(time).
                        find current b-pcgl no-lock no-error.
                        next.
                    end.
                    else do:
                        v-time = int(pcgl.info[1]) no-error.
                        if time - v-time >= 3600 then do:
                            k = k + 1.
                            find first b-pcgl where recid(b-pcgl) = recid(pcgl) exclusive-lock no-error.
                            assign b-pcgl.sts     = 'err'
                                   b-pcgl.who     = g-ofc
                                   b-pcgl.info[1] = v-txt.
                            find current b-pcgl no-lock no-error.
                        end.
                        next.
                    end.
                end.
            end.
        end.
        if v-err then do:
            j = j + 1.
            find first b-pcgl where recid(b-pcgl) = recid(pcgl) exclusive-lock no-error.
            assign b-pcgl.sts     = 'err'
                   b-pcgl.who     = g-ofc
                   b-pcgl.info[1] = v-txt.
            find current b-pcgl no-lock no-error.
            next.
        end.
        find first cmp no-lock no-error.
        if avail cmp then assign v-rnnfrom = cmp.addr[2] v-namefrom = cmp.name.
        find first txb where txb.bank = pcgl.cbnk no-lock no-error.
        if avail txb then assign v-rnnto = entry(1,txb.params) v-nameto = txb.info.
        find first sysc where sysc.sysc = 'bankname' no-lock no-error.
        if avail sysc then v-nameto = 'АО ' + sysc.chval + ' ' + v-nameto.
        assign v-kod = '1' + substr(pcgl.dacc,9,1)
               v-kbe = '1' + substr(pcgl.cacc,9,1)
               v-knp = if substr(pcgl.dacc,10,4) = '2204' then '321' else if substr(pcgl.cacc,10,4) = '2204' then '311' else '890'.
        run rmzcre
           (pcgl.trnum,
            pcgl.tramt,
            pcgl.dacc,
            v-rnnfrom,
            v-namefrom,
            pcgl.cbnk,
            pcgl.cacc,
            v-nameto,
            v-rnnto,
            '0',
             no,
            v-knp,
            v-kod,
            v-kbe,
            v-nazn + ' ' + pcgl.trdes,
            '1P',
            0,
            5,
            g-today) .
            v-remtrz = return-value.

        if v-remtrz <> '' then do:
            find first remtrz where remtrz.remtrz = v-remtrz exclusive-lock no-error.
            if avail remtrz then do:
                assign remtrz.rsub = 'arp'
                       remtrz.rcvinfo[1] = '/PCGL/'
                       remtrz.rcvinfo[3] = v-remtrz.
                find current remtrz no-lock no-error.
            end.
        end.
        else j = j + 1.
        find first b-pcgl where recid(b-pcgl) = recid(pcgl) exclusive-lock no-error.
        assign b-pcgl.sts     = if v-remtrz <> '' then 'rmz' else 'err'
               b-pcgl.who     = g-ofc
               b-pcgl.remtrz1 = v-remtrz
               b-pcgl.jh1     = if v-remtrz <> '' then remtrz.jh1 else 0
               b-pcgl.info[1] = ''.

        find current b-pcgl no-lock no-error.
    end.
end.
if i ne 0 then do:
    v-txt = 'Всего проводок   = ' + string(i) + '\nиз них выполнено = ' + string(i - j) + '\n    не выполнено = ' + string(j).
    find first bookcod where bookcod.bookcod = 'pc'
                         and bookcod.code    = 'txb00'
                         no-lock no-error.
    if avail bookcod then run mail( entry(1,bookcod.name) + "@fortebank.com",g-ofc + "@fortebank.com", "Автоматические проводки по GL " + v-bank,v-txt, "", "","").
end.
i = 0.
for each pcgl where pcgl.cbnk = v-bank and pcgl.sts = 'rmz' no-lock break by pcgl.dbnk by pcgl.cacc by pcgl.dacc:
    i = i + 1.
    find first remtrz where remtrz.rdt = today  and remtrz.rcvinfo[3] = pcgl.remtrz1 no-lock no-error.
    if not avail remtrz or remtrz.jh2 = ? then next.
    find first b-pcgl where recid(b-pcgl) = recid(pcgl) exclusive-lock no-error.
    assign b-pcgl.sts     = 'OK'
           b-pcgl.remtrz2 = remtrz.remtrz
           b-pcgl.jh2     = remtrz.jh2.
    find current b-pcgl no-lock no-error.
end.