/* pcpay.i
 * MODULE
        Клиентские операции
 * DESCRIPTION
        Дополнительная обработка транзакций по пополнению счетов по ПК
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        .
 * BASES
        BANK COMM
 * AUTHOR
        14/08/2012 id00810
 * CHANGES
            23/07/2013 Luiza - ТЗ 1883 исключение возможности повторного создания RMZ
 */

def var v-rnnfrom  as char no-undo.
def var v-rnnto    as char no-undo.
def var v-namefrom as char no-undo.
def var v-nameto   as char no-undo.
def var v-del      as char no-undo init '^'.
def var v-bank     as char no-undo.
def var v-remtrz   as char no-undo.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if avail sysc then v-bank = sysc.chval.

find first joudoc where joudoc.docnum = jh.ref and joudoc.rescha[4] ne '' no-lock no-error.
if avail joudoc then do:
    find first pcpay where pcpay.jou = joudoc.docnum no-lock no-error.
    if not avail pcpay then do:
        create pcpay.
        assign pcpay.bank  = entry(1,joudoc.rescha[4],v-del)
               pcpay.aaa   = entry(2,joudoc.rescha[4],v-del)
               pcpay.crc   = joudoc.drcur
               pcpay.amt   = joudoc.dramt
               pcpay.ref   = joudoc.docnum
               pcpay.jou   = joudoc.docnum
               pcpay.jh    = joudoc.jh
               pcpay.sts   = 'new'
               pcpay.who   = g-ofc
               pcpay.whn   = g-today.
        if pcpay.bank = v-bank then pcpay.sts = 'ready'.
        else do:
            find first cmp no-lock no-error.
            if avail cmp then assign v-rnnfrom = cmp.addr[2] v-namefrom = cmp.name.
            find first txb where txb.bank = pcpay.bank no-lock no-error.
            if avail txb then assign v-rnnto = entry(1,txb.params) v-nameto = txb.info.
            find first sysc where sysc.sysc = 'bankname' no-lock no-error.
            if avail sysc then v-nameto = 'АО ' + sysc.chval + ' ' + v-nameto.
            run rmzcre
               (pcpay.jh,
                pcpay.amt,
                joudoc.cracc,
                v-rnnfrom,
                v-namefrom,
                pcpay.bank,
                entry(3,joudoc.rescha[4],v-del),
                v-nameto,
                v-rnnto,
                '0',
                 no,
                '311',
                '14',
                '14',
                joudoc.remark[1] + ' ' + joudoc.remark[2] + ' ' + joudoc.rescha[3],
                '1P',
                0,
                5,
                g-today) .
                v-remtrz = return-value.
            if v-remtrz <> '' then do:
                pcpay.ref  = v-remtrz.
                find first remtrz where remtrz.remtrz = v-remtrz exclusive-lock no-error.
                if avail remtrz then do:
                    assign remtrz.rsub = 'arp'
                           remtrz.rcvinfo[1] = '/PC/'
                           remtrz.rcvinfo[3] = v-remtrz.
                    find current remtrz no-lock no-error.
                end.
            end.
        end.
    end.
end.
