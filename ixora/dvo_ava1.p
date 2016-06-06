/* dvo_ava1.p
 * MODULE
        Внутрибанковские операции
 * DESCRIPTION
        Пополнение карточных счетов сотрудников Банка работниками ДВО
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        dvo_ava
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-3-5
 * AUTHOR
        08.01.2013 Lyubov
 * BASES
        BANK COMM
 * CHANGES
        11.01.2013 Lyubov - по ошибке находился старый 9значный счет, добавила проверку длины счета
        14.01.2013 Lyubov - некорректно определялся счет по кредиту
*/

{keyord.i}
{global.i}
{lgps.i}

define input parameter new_document as logical.
define variable m_sub as character initial "jou".
def shared var v_u as int no-undo.
def shared var s-remtrz like remtrz.remtrz.

def var v_codfr as char format "x(1)" init "2". /*код операций  табл codfr для doch.codfr */
def var phand      as handle no-undo.

def var v-tmpl      as char no-undo.
def var vdel        as char no-undo initial "^".
def var v-param     as char no-undo.
def var v-param1    as char no-undo.
def var rcode       as inte no-undo.
def var rdes        as char no-undo.
def var l-ans       as logi no-undo.
def var v-vd        as char no-undo initial '/IDN/'.

def var v-title as char                 no-undo. /*наименование платежа */
def var v-sum   as deci                 no-undo. /* сумма*/
def var v-arp   as char format "x(20)"  no-undo. /* счет карточка ARP*/
def var v-crc   as inte                 no-undo. /* Валюта*/
def var v-chet  as char format "x(20)"  no-undo. /* счет клиента*/
def var v-send  as char format "x(20)"  no-undo. /* счет отправителя*/
def var v-cif   as char format "x(6)"   no-undo. /* cif клиент*/
def var v-name  as char format "x(20)"  no-undo. /* клиент*/
def var v-code  as char format "x(2)"   no-undo. /* КОД*/
def var v-kbe   as char format "x(2)"   no-undo. /* КБе*/
def var v-knp   as char format "x(3)"   no-undo. /* КНП*/
def var v-nazn  as char format "x(45)"  no-undo. /* Назначение платежа*/

def var v-ref    as char no-undo init "б/н".
def var v-priory as char no-undo init "o".
def var v-transp as int  no-undo init 5.
def var v-fil    as char no-undo.
def var v-bb     as char no-undo.
def var v-countr as char no-undo init 'KZ'.

def var vj-label as char no-undo.
def var v-ja     as logi no-undo format "Да/Нет" init no.
def var quest    as logi.

def var v-ccode as char format "x(6)"   no-undo.

def var v-joudoc  as char no-undo format "x(10)".
def var v-trx     as inte no-undo.
def var v_doc_num as char no-undo.
def var v_docwho  as char no-undo.
def var v_docdt   as date no-undo.
define new shared variable s-jh like jh.jh.
def buffer b-aaa for aaa.

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

find first cmp no-lock no-error.

v-title = ' Пополнение карточных счетов сотрудников Банка работниками ДВО '.
define button but label " "  NO-FOCUS.

form
    v-joudoc label " Документ               " format "x(10)"   v-trx label "           ТРН " format "zzzzzzzzz"          but skip
    v-crc    label " Валюта                 " format ">9" validate(can-find(first crc where crc.crc = v-crc and crc.sts <> 9 no-lock),"Неверный код валюты!") skip
    v-sum    label " Сумма                  " validate(v-sum > 0, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip
    v-chet   label " Счет по ПК             " format "x(20)" validate(can-find(first pccards where pccards.aaa = v-chet and pccards.sts = 'OK' no-lock), "Счет отсутствует или закрыт") skip
    v-name   label " Клиент                 " format "x(60)" skip
    v-arp    label " Транзитный cчет (ARP)  " format "x(20)"
    v-nazn   label " Назначение платежа     " skip
    v-send   label " Счет отправителя       " skip
    v-code   label " КОД                    " skip
    v-kbe    label " КБе                    " skip
    v-knp    label " КНП                    " skip
    skip
    vj-label no-label v-ja no-label
    WITH  SIDE-LABELS CENTERED ROW 7
    TITLE v-title width 100 FRAME f_main.

on help of v-nazn in frame f_main do:
    {itemlist.i
     &file = "codfr"
     &frame = "row 6 centered scroll 1 20 down width 91 overlay "
     &where = " codfr.codfr = 'avans-n' and codfr.code <> 'msc' "
     &flddisp = " codfr.code label 'Code' format 'x(8)' codfr.name[1] label 'value' format 'x(80)' "
     &chkey = "code"
     &index  = "cdco_idx"
     &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
    v-nazn = codfr.name[1].
    v-ccode = codfr.code.
    display v-nazn with frame f_main.
end.
on help of v-joudoc in frame f_main do:
    run a_help-joudoc1 ("PCI").
    v-joudoc = frame-value.
end.
on help of v-chet in frame f_main do:
    run h-pc PERSISTENT SET phand.
    v-chet = frame-value.
    displ v-chet with frame f_main.
end.

on "END-ERROR" of frame f_main do:
  hide frame f_main no-pause.
end.
m_pid = "P".
if new_document then do:  /* создание нового документа  */
    clear frame f_main.
    vj-label  = " Сохранить новый документ?...........".
    find nmbr where nmbr.code eq "JOU" no-lock no-error.
    v-joudoc = "JOU" + string (next-value (journal), "999999") + nmbr.prefix.
    find first nmbr no-lock no-error.

    if s-ourbank = 'TXB00' then do:
        find first nmbr no-lock no-error.
        run n-remtrz.   /* получили новый номер для rmz в переменной s-remtrz */
        find first nmbr no-lock no-error.
    end.

    do transaction:
        displ v-joudoc format "x(10)" with frame f_main.
        assign v-ja = yes
               v-crc = 1
               v-sum = 0
               v-chet = ""
               v-name = ""
               v-arp = ""
               v-nazn = ""
               v-send = ""
               v-code = "14"
               v-kbe = ""
               v-knp = "870".
        run save_doc.
    end.
end.  /* end new document */

else do:   /* редактирование документа   */
    run view_doc.
    if v_u = 2 then do:       /* update */
        vj-label  = " Сохранить изменения документа?...........".
        run view_doc.
        find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
        if available joudoc then do:
            find joudop where joudop.docnum = v-joudoc no-lock no-error.
            if available joudop then do:
                if joudop.type <> "PCI" then do:
                    message "Документ не относится к типу пополнение картсчетов сотрудников " view-as alert-box.
                    return.
                end.
           end.
            if joudoc.jh ne ? then do:
                message "Транзакция уже проведена. Для редактирования удалите транзакцию." view-as alert-box.
                return.
            end.
            if joudoc.who ne g-ofc then do:
                message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box.
                return.
            end.
        end.
        do transaction:
            run save_doc.
        end.
    end.   /* end  v_u = 2 */
end.  /*else do: */

procedure save_doc:
    displ v-joudoc v-crc v-code v-knp vj-label with frame f_main.
    update v-sum v-chet with frame f_main.
    find first pccards where pccards.aaa = v-chet and pccards.sts = 'OK' no-lock no-error.
    if avail pccards then do:
        v-name = pccards.sname.
        displ v-name with frame f_main.
        v-fil  = substr(pccards.aaa,19,2).
    end.
    find first pcstaff0 where pcstaff0.aaa = v-chet and pcstaff0.sts = 'OK' no-lock no-error.
    if avail pcstaff0 then do:
        if pcstaff0.rez then v-kbe = '19'.
        else v-kbe = '29'.
        displ v-kbe with frame f_main.
    end.
    else do:
        message 'Не найдена запись в таблице pcstaff0! Обратитесь в ДИТ!' view-as alert-box.
        return.
    end.
    find first bookcod where bookcod.bookcod = 'pctrans' and bookcod.code = 'txb' + v-fil no-lock no-error.
    if avail bookcod then do:
        v-arp = bookcod.name.
        displ v-arp with frame f_main.
    end.
    else do:
        message 'Транзитный счет не найден' view-as alert-box.
        return.
    end.
    update v-nazn with frame f_main.
    find last arp where arp.gl = int(v-ccode) and arp.crc = v-crc no-lock no-error.
    if avail arp then do:
        v-send = arp.arp.
        displ v-send with frame f_main.
    end.
    update v-ja with frame f_main.

    if v-ja then do:
        if new_document then do:
            create joudoc.
            joudoc.docnum = v-joudoc.
            create joudop.
            joudop.docnum = v-joudoc.
        end.
        else do:
            find joudoc where joudoc.docnum = v-joudoc exclusive-lock.
            find joudop where joudop.docnum = v-joudoc exclusive-lock.
        end.
        assign
        joudoc.who   = g-ofc
        joudoc.whn   = g-today
        joudoc.tim   = time
        joudoc.dramt = v-sum
        joudoc.dracctype = "4"
        joudoc.dracc = v-send
        joudoc.drcur = v-crc
        joudoc.cramt = v-sum
        joudoc.crcur = v-crc
        joudoc.cracc = v-arp
        joudoc.cracctype = "4"
        joudoc.info = v-name
        joudoc.remark[1] = 'Пополнение карточных счетов сотрудников Банка'
        joudoc.remark[2] = v-chet.
        run chgsts("JOU", v-joudoc, "new").
        find current joudoc no-lock no-error.
        joudop.who = g-ofc.
        joudop.whn = g-today.
        joudop.tim = time.
        joudop.type = "PCI".
        find current joudop no-lock no-error.
        find first sub-cod where sub-cod.sub = "jou" and sub-cod.acc = v-joudoc and sub-cod.d-cod = "eknp" exclusive-lock no-error.
        if not available sub-cod then do:
            create sub-cod.
            sub-cod.acc = v-joudoc.
            sub-cod.sub = "jou".
            sub-cod.d-cod  = "eknp".
            sub-cod.ccode = "eknp".
        end.
        sub-cod.rdt = g-today.
        sub-cod.rcode = v-code + "," + v-kbe + "," + v-knp.
        displ v-joudoc with frame f_main.

        if s-ourbank = 'TXB00' then do:
            if new_document then do:
                create remtrz.
                remtrz.remtrz = s-remtrz.
            end.
            else find first remtrz where remtrz.remtrz = s-remtrz exclusive-lock.

            find sysc where sysc.sysc = "bnkbin" no-lock no-error.
            if not avail sysc then do:
                  create sysc. sysc.sysc = 'BNKBIN'.  sysc.des = 'БИН банка'.
            end.

            assign remtrz.ptype   = "N"
                   remtrz.rdt     = g-today
                   remtrz.rtim    = time
                   remtrz.amt     = v-sum
                   remtrz.payment = v-sum
                   remtrz.svca    = 0
                   remtrz.svcp    = 0.
                   remtrz.ord     = caps(trim(cmp.name)) + ' ' + v-vd + sysc.chval.

            if remtrz.ord = ? then run mail("IXqueuerr@fortebank.com", "bankadm@fortebank.kz", "Поле ORD = ?", "dvo_ava1.p 276", "1", "", "").

            assign remtrz.chg        = 7
                   remtrz.cover      = v-transp
                   remtrz.ref        = v-ref
                   remtrz.outcode    = 6
                   remtrz.fcrc       = v-crc
                   remtrz.tcrc       = v-crc
                   remtrz.detpay[1]  = s-remtrz + ' Пополнение карточных счетов сотрудников Банка '
                   remtrz.sbank      = s-ourbank
                   remtrz.rbank      = 'txb' + v-fil
                   remtrz.valdt1     = g-today
                   remtrz.rwho       = g-ofc
                   remtrz.tlx        = no
                   remtrz.dracc      = v-send
                   remtrz.drgl       = int(v-ccode) /*286012.*/
                   remtrz.sacc       = v-send
                   remtrz.racc       = v-arp
                   remtrz.sqn        = trim(s-ourbank) + "." + trim(s-remtrz) + ".." + v-ref
                   remtrz.scbank     = trim(s-ourbank)
                   remtrz.source     = "P"
                   remtrz.ben[1]     = v-name
                   remtrz.ben[2]     = v-chet
                   remtrz.ben[3]     = " " + v-vd + sysc.chval
                   remtrz.rcvinfo[1] = '/PC/'
                   remtrz.rcvinfo[3] = s-remtrz
                   remtrz.ba         = remtrz.racc
                   remtrz.rsub       = 'arp'
                   remtrz.cracc      = v-send.

            find first bankt where bankt.cbank = 'TXB16' and bankt.racc = "1" and bankt.crc = v-crc no-lock no-error.
            if avail bankt then remtrz.cracc = bankt.acc .

            find first b-aaa where b-aaa.aaa = bankt.acc no-lock no-error.
            if avail b-aaa then remtrz.crgl = b-aaa.gl. /*215200*/

            find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
            if avail bankl then
            assign remtrz.rcbank = bankl.cbank
                   remtrz.bb[1]  = bankl.name
                   remtrz.bb[2]  = bankl.addr[1]
                   remtrz.bb[3]  = bankl.addr[2] + " " + bankl.addr[3].

            assign remtrz.scbank     = remtrz.sbank
                   remtrz.ordins[1]  = 'АО "ForteBank"'
                   remtrz.ordins[2]  = " "
                   remtrz.ordins[3]  = ""
                   remtrz.ordins[4]  = " "
                   remtrz.ordcst[1]  = remtrz.ord
                   remtrz.bn[1]      = remtrz.bb[1]
                   remtrz.bn[2]      = remtrz.bb[2]
                   remtrz.bn[3]      = " " + v-vd + sysc.chval
                   remtrz.rcvinfo[2] = string(g-today).
            v-bb = trim(remtrz.bb[1]) + " " + trim(remtrz.bb[2]) + " " + trim(remtrz.bb[3]) .
            assign remtrz.actins[1] = "/" + substr(v-bb,1,34)
                   remtrz.actins[2] = substr(v-bb,35,35)
                   remtrz.actins[3] = substr(v-bb,70,35)
                   remtrz.actins[4] = substr(v-bb,105,35)
                   remtrz.actinsact = remtrz.rbank
                   remtrz.valdt2    = g-today
                   remtrz.ptype     = '4'.

            find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = s-remtrz and sub-cod.d-cod = 'pdoctng' exclusive-lock no-error.
            if not avail sub-cod then do:
                create sub-cod.
                assign sub-cod.sub   = 'rmz'
                       sub-cod.acc   = s-remtrz
                       sub-cod.d-cod = 'pdoctng'
                       sub-cod.rdt   = g-today.
            end.
            find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = s-remtrz and sub-cod.d-cod = "eknp" exclusive-lock no-error.
            if not available sub-cod then do:
                create sub-cod.
                assign sub-cod.sub   = "rmz"
                       sub-cod.acc   = s-remtrz
                       sub-cod.d-cod = "eknp"
                       sub-cod.ccode = "eknp".
            end.
            assign sub-cod.rdt   = g-today
                   sub-cod.rcode = v-code + "," + v-kbe + "," + v-knp.
            find current sub-cod no-lock no-error.
            find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = s-remtrz and sub-cod.d-cod = "iso3166" exclusive-lock no-error.
            if not available sub-cod then do:
                create sub-cod.
                assign sub-cod.sub    = "rmz"
                       sub-cod.acc    = s-remtrz
                       sub-cod.d-cod  = "iso3166"
                       sub-cod.ccode  = v-countr
                       sub-cod.rdt    = g-today.
            end.
            find current sub-cod no-lock no-error.
            run rmzque .
            pause 0.
            release que.
            run chgsts(input "rmz", remtrz.remtrz, "new").
            find current remtrz no-lock no-error.
        end.
    end.
end procedure.

procedure view_doc:
    update v-joudoc help "Введите номер документа, F2-помощь" with frame f_main.
    if keyfunction (lastkey) = "end-error" then do:
        hide all.
        if this-procedure:persistent then delete procedure this-procedure.
        return.
    end.
    if trim(v-joudoc) = "" then undo, return.
    displ v-joudoc with frame f_main.

    find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
    if not available joudoc then do:
        message "Документ не найден." view-as alert-box.
        undo, return.
    end.
    find joudop where joudop.docnum = v-joudoc no-lock no-error.
    if available joudop and joudop.type <> "PCI" then do:
            message substitute ("Документ не относится к типу пополнение картсчетов сотрудников ") view-as alert-box.
            return.
    end.
    if joudoc.jh > 1 and v_u = 2 then do:
        message "Транзакция уже проведена. Для редактирования удалите транзакцию." view-as alert-box.
        return.
    end.
    if joudoc.who ne g-ofc and v_u = 2 then do:
        message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box.
        return.
    end.
    v-trx  = joudoc.jh.
    v-sum  = joudoc.dramt.
    v-crc  = joudoc.drcur.
    v-chet = joudoc.remark[2].
    v-name = joudoc.info.
    v-arp  = joudoc.cracc.
    v-send = joudoc.dracc.
    find first arp where arp.arp = v-send no-lock no-error.
    if avail arp then do:
        find first codfr where codfr = 'avans-n' and codfr.code = string(arp.gl) no-lock no-error.
        if avail codfr then v-nazn = codfr.name[1].
    end.
    find first aaa where aaa.aaa = v-chet no-lock no-error.
    if avail aaa then do:
        v-cif = aaa.cif.
    end.
    find first cif where cif.cif = v-cif no-lock no-error.
    if avail cif then v-name = trim(trim(cif.prefix) + " " + trim(cif.name)).
    find first sub-cod where sub-cod.sub = "jou" and sub-cod.acc = v-joudoc and sub-cod.d-cod = "eknp" no-lock no-error.
    if avail sub-cod then do:
        v-code = entry(1,sub-cod.rcode,',').
        v-kbe = entry(2,sub-cod.rcode,',').
        v-knp = entry(3,sub-cod.rcode,',').
    end.
    find first jh where jh.jh = s-jh no-lock no-error.
    if avail jh then s-remtrz = jh.ref.
    v-ja = yes.
    displ v-joudoc v-trx v-chet v-name v-crc v-sum v-arp v-nazn v-send v-code v-kbe v-knp with  frame f_main.
end procedure.

procedure Create_transaction:
    if s-ourbank <> 'TXB00' then do:
        vj-label = " Выполнить транзакцию?..................".
        run view_doc.
        find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
        if joudoc.jh ne ? and joudoc.jh <> 0 then do:
            message "Транзакция уже проведена." view-as alert-box.
            undo, return.
        end.
        if joudoc.whn ne g-today then do:
            message substitute ("Документ создан &1 .", joudoc.whn) view-as alert-box.
            undo, return.
        end.
        if joudoc.who ne g-ofc then do:
            message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box.
            undo, return.
        end.
        v-ja = yes.
        displ vj-label no-label format "x(35)"  with frame f_main.
        pause 0.
        update v-ja  with frame f_main.
        if not v-ja or keyfunction (lastkey) = "end-error" then do:
            apply "close" to this-procedure.
            delete procedure this-procedure.
            hide frame f_main.
            return.
        end.
        v-param = string(v-sum) + vdel + v-send + vdel + v-arp + vdel + 'Пополнение карточных счетов сотрудников Банка' + vdel + ''.
        v-tmpl  = "vnb0010".
        run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.
        find joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error no-wait.
        joudoc.jh = s-jh.
        find current joudoc no-lock no-error.

        MESSAGE "ДОКУМЕНТ СФОРМИРОВАН, НОМЕР ПРОВОДКИ: " + string(s-jh) view-as alert-box.
        run chgsts(input "jou", v-joudoc, "trx").
        v-trx = s-jh.
        display v-trx with frame f_main.
        find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.

        find last pcpay where pcpay.aaa = v-chet and pcpay.whn = g-today and pcpay.ref = v-joudoc no-lock no-error.
        if not avail pcpay then do:
            create pcpay.
            assign pcpay.bank = s-ourbank
                   pcpay.aaa  = v-chet
                   pcpay.crc  = v-crc
                   pcpay.amt  = v-sum
                   pcpay.who  = g-ofc
                   pcpay.whn  = g-today
                   pcpay.ref = v-joudoc
                   pcpay.jh  = s-jh
                   pcpay.sts = 'ready'.
        end.
        else if avail pcpay and pcpay.sts = 'del' then do:
            find current pcpay exclusive-lock no-error.
            pcpay.sts = 'ready'.
        end.
        release pcpay.
    end.
    else do:
        vj-label = " Выполнить транзакцию?..................".
        run view_doc.
        find first remtrz where remtrz.remtrz eq s-remtrz no-lock no-error.
        if avail remtrz then do:
            if remtrz.jh1 ne ? and remtrz.jh1 <> 0 then do:
                message "Транзакция уже проведена." view-as alert-box error.
                undo, return.
            end.
            if remtrz.rdt ne g-today then do:
                message substitute ("Документ создан &1 .", remtrz.rdt) view-as alert-box error.
                undo, return.
            end.
            if remtrz.rwho ne g-ofc then do:
                message substitute ("Документ создан &1 .", remtrz.rwho) view-as alert-box error.
                undo, return.
            end.
        end.
        else do:
            message ' Нет записи в таблице REMTRZ! ' view-as alert-box.
            return.
        end.
        v-ja = yes.
        displ vj-label no-label format "x(35)"  with frame f_main.
        pause 0.
        update v-ja  with frame f_main.
        if not v-ja or keyfunction (lastkey) = "end-error" then do:
            apply "close" to this-procedure.
            delete procedure this-procedure.
            hide frame f_main.
            return.
        end.
        enable but with frame f_main.
        pause 0.
        run ispognt.
        disable but with frame f_main.
        if remtrz.jh1 > 0 then do:
            v-trx = remtrz.jh1.
            run trxsts (input v-trx, input 6, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                undo, return .
            end.
            MESSAGE "ДОКУМЕНТ СФОРМИРОВАН, НОМЕР ПРОВОДКИ: " + string(v-trx) view-as alert-box.
            run chgsts(input "rmz", remtrz.remtrz, "rdy").
            view frame f_main.
            displ v-trx with frame f_main.
            find joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error no-wait.
            joudoc.jh = v-trx.
            find current joudoc no-lock no-error.
        end.
    end.
    view frame f_main.
end procedure.

procedure print_transaction:
    if v-joudoc eq "" then undo, retry.
    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
    if joudoc.jh eq ? then do:
        message "Транзакция не существует." view-as alert-box.
        undo, return.
    end.
    s-jh = joudoc.jh.
    run vou_bank(1).
end procedure.