/* a_tng4.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
        Возврат внутрибанковских переводов.
 * BASES
        BANK COMM
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        05/09/2012 Luiza
 * CHANGES
            13/09/2012 Luiza  -  перекомпиляция
*/


{mainhead.i}

define input parameter new_document as logical.
def new shared var  s-remtrz like remtrz.remtrz.

define variable m_sub as character initial "jou".
def var vtmpl as char no-undo.
def var vdel as char no-undo initial "^".
def var vparam as char no-undo.
def var rcode as int no-undo.
def var rdes as char no-undo.
define new shared variable s-jh like jh.jh.
def var v_dt as int init 287032.
def var v-arpout as char no-undo.
def var v-arpin as char no-undo.
def var v-arp1 as char no-undo.
def var v-arp2 as char no-undo.
def var v-pnp as char format "x(20)". /* счет клиента*/
def var v_trx as int no-undo.
def var s-bnrnn as char.    /*   РНН банка получателя */
def var b-bnrnn as char.    /*   РНН банка отправителя */

def var v-viddoc as char init "01".
def var v-rmzdoc like remtrz.remtrz.
def var v-ref as char.
def var v_code as char  no-undo init "14".  /* КОД*/
def var v_kbe as char  no-undo init "14".  /* КБе*/
def var v_knp as char no-undo init "190".  /* КНП*/
def var v_bank as char no-undo.
def var v_bankb as char no-undo.
def var v_bankp as char no-undo.
def var v_swibic as char no-undo.
def shared var v_u as int no-undo.
def var v_doc as char.
define variable quest as logical format "да/нет" no-undo.
def var v-bb  as char no-undo.

def  new shared var v_oper as char no-undo format "x(140)".
def  var v_oper1 as char no-undo format "x(140)".
def  var v_oper2 as char no-undo.
def  var v_oper3 as char no-undo .
def  var v_oper4 as char no-undo.
def  var v_oper5 as char no-undo .
def  var v_oper6 as char no-undo.
def  var v_oper7 as char no-undo .
def new shared var v_crc as int  no-undo format "9" init 1.
def  var v_sum as decimal no-undo format ">>>,>>>,>>>,>>>,>>9.99".

def  var v-ja as logi no-undo format "Да/Нет" init yes.
def  var v_label as char no-undo.
def  var vj-label as char no-undo.

/*--------EK---------------*/
def shared var v-nomer like cslist.nomer no-undo.
def shared var v-ek as integer no-undo.
def var v-crc_val as char no-undo format "xxx".
def var v-chEK as char format "x(20)". /* счет ЭК*/
/*------------------------------------*/

{keyord.i}

def var v-dt1 as date.
def var v-dt2 as date.

define temp-table w-doc
       field bnk as char
       field rmz as char
       field jh1 as inte
       field sum as decimal
       field dracc as char
       field oper as char.

function isProductionServer returns logical.
    def var res as logical no-undo.
    res = no.
    def var v-text as char no-undo.
    input through "hostname | awk -F'.' '\{print $1\}'".
    repeat:
        import unformatted v-text.
        v-text = trim(v-text).
        if v-text <> '' then leave.
    end.
    if v-text = "ixora01" then res = yes.
    return res.
end function.

define button but label " "  NO-FOCUS.

/*проверка банка*/
def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    MESSAGE "There is no record OURBNK in bank.sysc file !!" view-as alert-box.
    hide message.
    return.
end.
s-ourbank = trim(sysc.chval).


{lgps.i "new"}
pause 0.
/* для использования BIN */
{chk12_innbin.i}
pause 0.
{chbin.i}
pause 0.

{comchk.i}
pause 0.

if v-bin  then v_label = " ИИН            :". else v_label = " РНН            :".

find first cmp no-lock.
v_bankb = cmp.name.

form
    s-remtrz label  " Документ               " format "x(10)" v_trx label   "        ТРН " format "zzzzzzzzz"           but skip(1)
    v-viddoc label  " Вид документа          " validate(can-find(first codfr where codfr.codfr = 'pdoctng' no-lock), "Нет такого кода вида документов! F2-помощь") format "x(2)" help "F2 - помощь" skip
    v-ref    label  " Nr.плат.поруч          " format "x(29)" validate (v-ref <> "" or v-ref = "б/н" ,"если платежное поручение без номера наберите 'б/н'! ") help "Если ПлПоруч без номера наберите 'б/н'!Иначе только цифры" skip
    v-arpout label  " АРП счет отправителя   " format "x(20)" skip
    v_bankb  label  " Банк бенефициара       " format "x(60)"  skip
    v_swibic label  " БИК банка бенефициара  " validate(can-find(first comm.txb where comm.txb.bank = v_swibic and comm.txb.consolid = yes no-lock),"Неверный Бик филиала!") skip
    v_crc    label  " Валюта перевода        " help "Введите код валюты, F2-помощь" format "9"  skip
    v_sum    label  " Сумма перевода         " help " Введите сумму перевода" validate(v_sum > 0,"Проверьте значение суммы!") format ">>>,>>>,>>>,>>>,>>9.99" skip
    v-arpin  label  " АРП счет получателя    " format "x(20)" skip
    v_bankp  label  " Банк получататель      " format "x(60)"  skip
    v_code   label  " КОД                    " validate(length(v_code) = 2, "Hеверное значение кода") skip
    v_kbe    label  " КБе                    "  validate(length(v_kbe) = 2, "Hеверное значение КБе") skip
    v_knp    label  " КНП                    "  format "x(3)" skip
    v_oper   label  " Назнач. платежа" format "x(55)" skip
    v_oper2  label  "                " format "x(70)" skip
    v_oper3  label  "                " format "x(70)" skip
    v_oper4  label  "                " format "x(70)" skip
    v_oper5  label  "                " format "x(70)" skip
    v_oper6  label  "                " format "x(70)" skip
    v_oper7  label  "                " format "x(70)" skip

vj-label no-label v-ja no-label
WITH  SIDE-LABELS column 5 row 5 TITLE "Возврат внутрибанковского перевода в тенге" width 95 FRAME f_main.


form
     v_oper1 VIEW-AS EDITOR SIZE 68 by 6
     with frame detpay column 7 row 23 overlay  title "Назначение платежа" .

def frame f-date
   v-dt1 label "С  " format "99/99/99" validate(v-dt1 <= today, "Некорректная дата!") skip
   v-dt2 label "По " format "99/99/99" skip
with side-labels column 35 row 9 overlay title "Задайте период для поиска входящих платежей ".

DEFINE QUERY q-doc FOR w-doc.
DEFINE BROWSE b-doc QUERY q-doc
    DISPLAY w-doc.bnk label "Банк " format "x(5)" w-doc.rmz label "RMZdoc " format "x(10)" w-doc.jh1 label "Транзакция" format "zzzzzzzzz9"
    w-doc.sum label "Сумма " format ">>>,>>>,>>9.99" w-doc.oper label "Назначение платежа " format "x(50)"  WITH  15 DOWN.
DEFINE FRAME f-doc b-doc  WITH overlay  COLUMN 3 SIDE-LABELS row 10  width 100 NO-BOX.

on help of s-remtrz in frame f_main do:
    run h-remtrz.
    s-remtrz = frame-value.
end.

on "END-ERROR" of frame f_main do:
    hide frame f_main.
    return.
end.
on "END-ERROR" of frame f-doc do:
    hide frame f-doc.
    return.
end.

on help of s-remtrz in frame f_main do:
    run a_help-joudoc("TN1").
    s-remtrz = frame-value.
end.


if new_document then do:  /* создание нового документа  */
    clear frame f_main no-pause.
    vj-label  = " Сохранить документ?...........".
    find first nmbr no-lock no-error.
    run n-remtrz.   /*получили новый номер для rmz в переменной s-remtrz***/
    find first nmbr no-lock no-error.
    run save_doc.
end.  /* end new document */

else do:   /* редактирование документа   */
    clear frame f_main no-pause.
    s-remtrz = "".
    run view_doc ("").
    if keyfunction (lastkey) = "end-error" then do:
        hide all.
        if this-procedure:persistent then delete procedure this-procedure.
        return.
    end.
    if v_u = 2 then do:       /* update */
        do transaction:
            vj-label  = " Сохранить изменения документа?...........".
            find remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
            if available remtrz then do:
                if remtrz.jh1 ne ? then do:
                    message "Транзакция уже проведена. Для редактирования удалите транзакцию." view-as alert-box.
                    return.
                end.
                if remtrz.rwho ne g-ofc then do:
                    message substitute ("Документ создан &1 .", remtrz.rwho) view-as alert-box.
                    return.
                end.
            end.
            run save_doc.
        end.
    end.   /* end  v_u = 2 */
end.  /*else do: */


procedure save_doc:
    displ s-remtrz with frame f_main.
    pause 0.
    update  v-dt1 v-dt2 with frame f-date.
    empty temp-table w-doc.
    find first arp where arp.gl = v_dt and arp.crc = v_crc and length(arp.arp) >= 20 and arp.des MATCHES "*вх*" and not arp.des  MATCHES "*СП*" no-lock no-error.
    find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "clsa" and sub-cod.ccode = "msc" no-lock no-error.
    if not available arp then do:
        message "Не найден АРП счет по счету ГК 287032!" view-as alert-box.
        hide all.
        if this-procedure:persistent then delete procedure this-procedure.
        return.
    end.
    v-arp1 = arp.arp.
    for each remtrz where remtrz.cracc = v-arp1 and remtrz.valdt1 >= v-dt1 and remtrz.valdt2 <= v-dt2  no-lock.
        create w-doc.
        w-doc.bnk = remtrz.sbank.
        w-doc.rmz = remtrz.remtrz.
        w-doc.jh1 = remtrz.jh1.
        w-doc.sum = remtrz.amt.
        w-doc.dracc = remtrz.sacc.
        w-doc.oper = trim(remtrz.detpay[1]) + ' ' + trim(remtrz.detpay[2]).
    end.
    find first w-doc no-error.
    if not available w-doc then do:
        message "За указанный период платежей нет!" view-as alert-box.
        hide all.
        if this-procedure:persistent then delete procedure this-procedure.
        return.
    end.
    OPEN QUERY  q-doc FOR each w-doc.
    ENABLE ALL WITH FRAME f-doc.
    wait-for return of frame f-doc
    FOCUS b-doc IN FRAME f-doc.
    v-rmzdoc = w-doc.rmz.
    v_bank = w-doc.bnk.
    v-arpin = w-doc.dracc.
    hide FRAME f-doc.
    find first remtrz where remtrz.remtrz = v-rmzdoc no-lock.
    v-ref =  substring(remtrz.ref,1,24).
    v-arpout =  v-arp1.
    v_crc = remtrz.fcrc.
    v_sum = remtrz.amt.
    v-viddoc  = "01".
    v_code = "14".
    v_kbe = "14".
    v_knp = "190".
    if new_document then v_oper = "Возврат внутрибанковского перевода в тенге ".
    find first txb where txb.bank  = v_bank no-lock no-error.
    v_bankp = 'АО "ForteBank" ' + trim(txb.info).
    v_swibic = trim(txb.mfo).
    if v-bin then s-bnrnn = entry(3,txb.params,",").
    else s-bnrnn = entry(1,txb.params,",").
    find first txb where txb.bank  = s-ourbank no-lock no-error.
    if v-bin then b-bnrnn = entry(3,txb.params,",").
    else b-bnrnn = entry(1,txb.params,",").

    find first arp where arp.gl = v_dt and arp.crc = v_crc and length(arp.arp) >= 20 and arp.des MATCHES "*исх*" and not arp.des  MATCHES "*СП*" no-lock no-error.
    find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "clsa" and sub-cod.ccode = "msc" no-lock no-error.
    if not available arp then do:
        message "Не найден АРП счет по счету ГК 287032!" view-as alert-box.
        hide all.
        if this-procedure:persistent then delete procedure this-procedure.
        return.
    end.
    v-arp2 = arp.arp.
    displ v-viddoc v-ref v-arpout v_bankb v_swibic v_crc v_sum v-arpin v_bankp v_code v_kbe v_knp v_oper v_oper2 v_oper3 v_oper4 v_oper5 v_oper6 v_oper7 vj-label with frame f_main.
    pause 0.
    v_oper1 = v_oper + v_oper2 + v_oper3 + v_oper4 + v_oper5 + v_oper6 + v_oper7.
    repeat:
        update v_oper1 no-label go-on("return") with frame detpay.
        if length(v_oper1) > 482 then message 'Назначение платежа превышает 482 символа!'.
        else leave.
    end.
    hide frame detpay.
    v_oper = substring(v_oper1,1,55).
    v_oper2 = substring(v_oper1,56,70).
    v_oper3 = substring(v_oper1,127,70).
    v_oper4 = substring(v_oper1,198,70).
    v_oper5 = substring(v_oper1,266,70).
    v_oper6 = substring(v_oper1,337,70).
    v_oper7 = substring(v_oper1,408,70).
    displ v_oper v_oper2 v_oper3 v_oper4 v_oper5 v_oper6 v_oper7 with frame f_main.
    update v-ja with frame f_main.


    if v-ja then do:
        if new_document then do:
            create remtrz.
            remtrz.remtrz = s-remtrz.
        end.
        else find remtrz where remtrz.remtrz = s-remtrz exclusive-lock.
        remtrz.ptype = "4".
        remtrz.rdt = g-today.
        remtrz.amt = v_sum.
        remtrz.payment = v_sum.
        find first bankl where bankl.bank = v_bank no-lock no-error.
        if not avail bankl then do:
            message "Не найдена запись в таблице bankl!" view-as alert-box.
            undo, return.
        end.
        remtrz.bb[1] = bankl.name .
        remtrz.bb[2] = bankl.addr[1].
        remtrz.bb[3] = bankl.addr[2] + " " + bankl.addr[3].

        remtrz.bn[1] = v_bankp.
        if v-bin then remtrz.bn[3] = " /RNN/" + s-bnrnn.   /*" /IDN/"*/
        else remtrz.bn[3] = " /RNN/" + s-bnrnn.
        remtrz.ba = v-arpin.
        remtrz.ord = v_bankb.
        if v-bin then remtrz.ord = trim(remtrz.ord)  + " /RNN/" + b-bnrnn.  /*" /IDN/" */
        else remtrz.ord = trim(remtrz.ord)  + " /RNN/" + b-bnrnn.
        remtrz.bi = "NON".
        remtrz.chg = 7. /* to  outgoing process */
        remtrz.cover = 5.
        remtrz.sbank = s-ourbank.
        find ofc where ofc.ofc eq g-ofc no-lock.
        remtrz.ref = "PU" + string(integer(truncate(ofc.regno / 1000 , 0)),"9999")
            + "    " + s-remtrz + "-S" + trim(remtrz.sbank) +
            fill(" " , 12 - length(trim(remtrz.sbank))) +
            (trim(remtrz.dracc) + fill(" " , 10 - length(trim(remtrz.dracc)))) +
            substring(string(g-today),1,2) + substring(string(g-today),4,2) +
            substring(string(g-today),7,2).
        remtrz.outcode = 6.
        remtrz.fcrc = v_crc.
        remtrz.tcrc = v_crc.
        remtrz.ordcst[1] = remtrz.ord.
        remtrz.ordins[1] = v_bankb.
        v-bb = trim(bb[1]) + " " + trim(bb[2]) + " " + trim(bb[3]) .
        remtrz.actins[1] = "/" + substr(v-bb,1,34) .
        remtrz.actins[2] = substr(v-bb,35,35) .
        remtrz.actins[3] = substr(v-bb,70,35) .
        remtrz.actins[4] = substr(v-bb,105,35) .
        remtrz.actinsact = v_bank.
        remtrz.ben[1] = remtrz.bn[1] + remtrz.bn[3].
        remtrz.detpay[1] = trim(v_oper1).
        remtrz.rbank = v_bank.
        remtrz.valdt1 = g-today.
        remtrz.valdt2 = g-today.
        remtrz.rwho = g-ofc.
        remtrz.rtim = time.
        remtrz.tlx = no.
        remtrz.dracc = v-arp1.
        remtrz.drgl = v_dt.
        find first bankt where bankt.cbank = "TXB00" and bankt.racc = "1" and bankt.crc = 1 no-lock no-error.
        remtrz.cracc = bankt.acc .    /*  Корсчет банка */
        find first dfb where dfb.dfb = bankt.acc no-lock no-error.
        remtrz.crgl = dfb.gl. /* 135100 */
        remtrz.sacc = v-arpout.
        remtrz.racc = v-arpin.
        remtrz.sqn = trim(s-ourbank) + "." + trim(s-remtrz) + ".." + v-ref.
        remtrz.scbank = trim(s-ourbank).
        remtrz.rcbank = "TXB00".
        remtrz.rsub = "arp".
        remtrz.source = "P".

        if new_document then do:
            create joudop.
            joudop.docnum = s-remtrz.
        end.
        else find joudop where joudop.docnum = s-remtrz exclusive-lock.
        joudop.who = g-ofc.
        joudop.whn = g-today.
        joudop.tim = time.
        joudop.lname = v_bank.
        joudop.type = "TN1".
        find current joudop no-lock no-error.

        find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = s-remtrz and sub-cod.d-cod = 'pdoctng' no-lock no-error.
        if not avail sub-cod then do:
            create sub-cod.
            sub-cod.sub = 'rmz'.
            sub-cod.acc = s-remtrz.
            sub-cod.d-cod = 'pdoctng'.
            sub-cod.ccode = v-viddoc.
            sub-cod.rdt = g-today.
        end.
        find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = s-remtrz and sub-cod.d-cod = 'iso3166' no-lock no-error.
        if not avail sub-cod then do:
            create sub-cod.
            sub-cod.sub = 'rmz'.
            sub-cod.acc = s-remtrz.
            sub-cod.d-cod = 'iso3166'.
            sub-cod.ccode = "KZ".
            sub-cod.rdt = g-today.
        end.
        find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = s-remtrz and sub-cod.d-cod = "eknp" no-lock no-error.
        if not available sub-cod then do:
            create sub-cod.
            sub-cod.acc = s-remtrz.
            sub-cod.sub = "rmz".
            sub-cod.d-cod  = "eknp".
            sub-cod.ccode = "eknp".
            sub-cod.rcode = v_code + "," + v_kbe + "," + v_knp.
            sub-cod.rdt = g-today.
        end.
        m_pid = "P".
        run rmzque .
        pause 0.
        release que.
        run chgsts(input "rmz", remtrz.remtrz, "new").
        find current remtrz no-lock no-error.
        displ s-remtrz with frame f_main.
        pause 0.
    end.
end procedure.


procedure view_doc:
    define input parameter s as char.
    if s = "" then update s-remtrz help "Введите номер документа, F2-помощь" with frame f_main.
    else s-remtrz = s.
    if keyfunction (lastkey) = "end-error" then do:
        hide all.
        if this-procedure:persistent then delete procedure this-procedure.
        return.
    end.
    if trim(s-remtrz) = "" then undo, return.
    displ s-remtrz with frame f_main.
    pause 0.
    find joudop where joudop.docnum = s-remtrz no-lock no-error.
    if available joudop then do:
        if joudop.type <> "TN1" then do:
            message substitute ("Документ не относится к типу возврат внутрибаковского перевода") view-as alert-box.
            return.
        end.
    end.
    find remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
    if not available remtrz then do:
        message "Документ не найден." view-as alert-box.
        undo, return.
    end.
    if remtrz.fcrc <>  1 then do:
        message substitute ("Не тенговый платеж") view-as alert-box.
        return.
    end.
    if remtrz.jh1 ne ? and v_u = 2 then do:
        message "Транзакция уже проведена. Для редактирования удалите транзакцию." view-as alert-box.
        return.
    end.
    if remtrz.rwho ne g-ofc and v_u = 2 then do:
        message substitute ("Документ создан &1 .", remtrz.rwho) view-as alert-box.
        return.
    end.
    v_trx = remtrz.jh1.
    v-ref =  remtrz.ref.
    v-arpout = remtrz.sacc.
    v_crc = remtrz.fcrc.
    v_sum = remtrz.amt.
    v-arpin = remtrz.racc.
    v-viddoc  = "01".
    v_code = "14".
    v_kbe = "14".
    v_knp = "190".
    v_oper1 = trim(remtrz.detpay[1]).
    v_oper = substring(v_oper1,1,55).
    v_oper2 = substring(v_oper1,56,70).
    v_oper3 = substring(v_oper1,126,70).
    v_oper4 = substring(v_oper1,196,70).
    v_oper5 = substring(v_oper1,266,70).
    v_oper6 = substring(v_oper1,336,70).
    v_oper7 = substring(v_oper1,406,70).
    v_bank = joudop.lname.
    find first txb where txb.bank  = v_bank no-lock no-error.
    v_bankp = 'АО "ForteBank" ' + trim(txb.info).
    v_swibic = trim(txb.mfo).
    displ v-viddoc v-ref v-arpout v_bankb v_swibic v_crc v_sum v-arpin v_bankp v_code v_kbe v_knp v_oper v_oper2 v_oper3 v_oper4 v_oper5 v_oper6 v_oper7  with frame f_main.
end procedure.

Procedure Delete_document.
    do transaction on error undo, retry:
        vj-label  = " Удалить документ?..................".
        run view_doc (s-remtrz).
        find remtrz where remtrz.remtrz eq s-remtrz no-lock no-error.
        if available remtrz then do:
            if not (remtrz.jh1 eq 0 or remtrz.jh1 eq ?) then do:
                message "Транзакция уже проведена, удаление в данном меню запрещено." view-as alert-box.
                undo, return.
            end.
            if remtrz.rwho ne g-ofc then do:
               message substitute ("Документ принадлежит &1. Удалять нельзя.", remtrz.rwho) view-as alert-box.
               undo, return.
            end.
            displ vj-label no-label format "x(35)"  with frame f_main.
            pause 0.
            update v-ja  with frame f_main.
            if v-ja then do:
                find remtrz where remtrz.remtrz = s-remtrz no-error.
                if available remtrz then delete remtrz.
                find first remtrz no-lock no-error.
                for each substs where substs.sub = "rmz" and  substs.acc = s-remtrz exclusive-lock.
                    delete substs.
                end.
                find first substs  no-error.

                find cursts where cursts.sub = "rmz" and  cursts.acc = s-remtrz  exclusive-lock no-error.
                if available cursts then delete cursts.
                find first cursts no-lock no-error.

                for each sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = s-remtrz exclusive-lock.
                    delete sub-cod.
                end.
                for each que where que.remtrz = s-remtrz exclusive-lock.
                    delete que.
                end.
            end.
        end.
        apply "close" to this-procedure.
        delete procedure this-procedure.
        hide message.
        hide frame f_main.
    end. /* end transaction */
end procedure.

procedure Create_transaction:
    vj-label = " Выполнить транзакцию?..................".
    run view_doc (s-remtrz).
    find remtrz where remtrz.remtrz eq s-remtrz no-lock no-error.
    if remtrz.jh1 ne ? and remtrz.jh1 <> 0 then do:
        message "Транзакция уже проведена." view-as alert-box.
        undo, return.
    end.
    if remtrz.rdt ne g-today then do:
        message substitute ("Документ создан &1 .", remtrz.rdt) view-as alert-box.
        undo, return.
    end.
    if remtrz.rwho ne g-ofc then do:
        message substitute ("Документ создан &1 .", remtrz.rwho) view-as alert-box.
        undo, return.
    end.
    enable but with frame f_main.
    pause 0.
    run ispognt.
    disable but with frame f_main.
    if remtrz.jh1 > 0 then do:
        v_trx = remtrz.jh1.
        run trxsts (input v_trx, input 6, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes.
            undo, return .
        end.
        MESSAGE "ДОКУМЕНТ СФОРМИРОВАН, НОМЕР ПРОВОДКИ: " + string(v_trx) view-as alert-box.
        run chgsts(input "rmz", remtrz.remtrz, "rdy").
        view frame f_main.
        displ v_trx with frame f_main.
    end.
end procedure.

procedure Delete_transaction:
    if s-remtrz eq "" then undo, retry.
    find remtrz where remtrz.remtrz eq s-remtrz.
    if locked remtrz then do:
        message "ДОКУМЕНТ ЗАНЯТ ДРУГИМ ПОЛЬЗОВАТЕЛЕМ." view-as alert-box.
        pause 3.
        undo, return.
    end.

    if remtrz.jh1 eq ? then do:
        message "Транзакция не существует." view-as alert-box.
        pause 3.
        undo, return.
    end.

    if remtrz.rwho ne g-ofc then do:
        message "Этот документ не ваш." view-as alert-box.
        pause 3.
        undo, return.
    end.
    s-jh = remtrz.jh1.
    run rmzcano.
    hide all no-pause.
    view frame f_main.
    pause 0.
end procedure.

procedure print_transaction:
    if s-remtrz eq "" then undo, retry.
    find remtrz where remtrz.remtrz eq s-remtrz no-lock no-error.

    if remtrz.jh1 eq ? then do:
        message "Транзакция не существует." view-as alert-box.
        undo, return.
    end.

    do transaction:
        s-jh = remtrz.jh1.
        run printvouord(2).
    end. /* transaction */
end procedure.

procedure prtppp1:
    run connib.
    run prtppp.
    if connected ('ib') then disconnect 'ib'.
end procedure.
