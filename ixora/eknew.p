/*eknew.p
 * MODULE
        Экспресс кредиты
 * DESCRIPTION
        Выдача по ЭК
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3-2-7-1
 * AUTHOR
        11.11.2013 Lyubov
 * CHANGES
        11.11.2013 Lyubov - ТЗ 2040, отправка смс-уведомления при выдаче на ПК
*/

{global.i}
{pk.i}

{lonlev.i}
{pkduedt.i}

def shared var v-cifcod  as char no-undo.
def shared var v-bank    as char no-undo.
def shared var s-ln      as inte no-undo.

def new shared var v-iin as char no-undo.
def new shared var summa as deci no-undo.

s-pkankln = s-ln.

def new shared var s-lgr like lgr.lgr.
def var v-addr as char no-undo.
def var v-addrfakt as char no-undo.
def var v-addr1 as char no-undo.
def var v-addrfakt1 as char no-undo.
def var v-shifr as char no-undo.
def new shared var s-longrp like longrp.longrp.
def new shared var s-aaa like aaa.aaa.

define new shared variable v_doc as character init "".
define new shared variable s-jh as int.
define variable vdel    as character no-undo initial "^".
define variable rcode   as integer no-undo.
define variable rdes    as character no-undo.
define variable knpln1  as character no-undo init "411".
define variable knpln2  as character no-undo init "890".
define variable vparam  as character no-undo.
define variable totsum  as decimal no-undo.
define variable comsum  as decimal no-undo.
define variable v-sumdplk as decimal no-undo.
def var v-arpcard as char no-undo.
define variable i as int no-undo.

def var v-bal       as deci no-undo.
def var v-balt      as deci no-undo.
def var v-nxt       as int no-undo.
def var v-typ       as char no-undo.
def var v-lgr       like lgr.lgr no-undo.
def var qaaa        like aaa.aaa no-undo.
def var qarp        like arp.arp no-undo.
def var v-profcn    as char no-undo.
def var v-sex       as char no-undo.
def var v-sts       as char no-undo.
def var v-chk       as char no-undo format "x(6)".
def var v-file      as char no-undo.
def var v-knp       as char no-undo.
def var v-acc20     as char no-undo.
def var v-acc20val  as char no-undo.
def var v-num       as char no-undo.
def var v-kod       as char no-undo.
def var v-maillist  as char.
def var v-zag       as char.
def var v-str       as char.
def var v-tel       as char.
def var v-metam     as char.
def var v-issue     as char.
def var v-sprcod    as char.

def buffer b-aaa for aaa.

def new shared var v-resref as integer no-undo.

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = '10' and pkanketa.ln = s-ln exclusive-lock no-error.
if not avail pkanketa then leave.

v-iin = pkanketa.rnn.

if pkanketa.cdt = ? or pkanketa.cwho = "" then do:
   message "Выдача кредита еще не утверждена!" view-as alert-box title "".
   return.
end.
v-cifcod = pkanketa.cif.
s-lon    = pkanketa.lon.

if pkanketa.sts = "23" and pkanketa.trx1 = 0 then do transaction:
    s-jh = 0.
    v_doc = "LON0179".

    totsum = pkanketa.summa.
    comsum = 0.
    qaaa   = pkanketa.aaa.

    find first bookcod where bookcod.bookcod = 'pctrans' and bookcod.code = s-ourbank no-lock no-error.
    qarp = bookcod.name.

    /* выбор КНП выдачи в зависимости от срока кредита */
    find first pksysc where pksysc.credtype = '10' and pksysc.sysc = "knplon" no-lock no-error.
    knpln1 = entry(if pkanketa.srok <= 12 then 1 else 2, pksysc.chval).
    find first pksysc where pksysc.credtype = '10' and pksysc.sysc = "knpcom" no-lock no-error.
    knpln2 = string(pksysc.chval).

    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = "emetam" no-lock no-error.
    if avail pkanketh then v-metam = pkanketh.value1.

    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = "eissu" no-lock no-error.
    if avail pkanketh then v-issue = pkanketh.value1.

    find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'evidfin' no-lock no-error.
    if avail pkanketh then do:
        if pkanketh.value1 = 'кредит' then v-sprcod = '1,2,3,4'.
        if pkanketh.value1 = 'рефинансирование' then v-sprcod = '5,6,7,8,9,10'.

        find first pcstaff0 where pcstaff0.bank = v-bank and pcstaff0.cif = v-cifcod and pcstaff0.sts = 'OK' no-lock no-error.
        find first hdbkcif where can-do(v-sprcod,hdbkcif.hdbkcod) and ((not pcstaff0.cifb begins 'TXB' and hdbkcif.cif = pcstaff0.cifb) or
                                       (pcstaff0.cifb begins 'TXB' and hdbkcif.cif = 'OURBNK')) and not hdbkcif.del and hdbkcif.con no-lock no-error.
        find first credhdbk where credhdbk.hdbkcod = hdbkcif.hdbkcod no-lock no-error.
        if v-metam = 'аннуитет'                   then comsum = (totsum * credhdbk.comann) / 100.
        if v-metam = 'дифференцированные платежи' then comsum = (totsum * credhdbk.comdif) / 100.
    end.

    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = "eissu" no-lock no-error.
    if avail pkanketh then do:
        if pkanketh.value1 = 'карту' then v-sumdplk = totsum - comsum.
    end.

    v-knp = if pkanketa.srok <= 12 then '411' else '413'.

    find first pcstaff0 where pcstaff0.cif = v-cifcod no-lock no-error.
    find first cif where cif.cif = v-cifcod no-lock no-error.
    if cif.fax <> '' then v-tel = cif.fax.
    else v-tel = pcstaff0.tel[2].

    if v-tel <> '' then do:
        v-tel = replace(v-tel,'(','').
        v-tel = replace(v-tel,')','').
        v-tel = replace(v-tel,' ','').
        v-tel = replace(v-tel,'-','').
        v-tel = replace(v-tel,',',';').
        if length(v-tel) = 10 then v-tel = '+7' + v-tel.
        if substr(v-tel,1,1) = '7' and length(v-tel) = 11 then v-tel = '+' + v-tel.
        if v-tel begins '8' then v-tel = '+7' + substr(v-tel,2).
    end.

    vparam = string(totsum) + vdel + s-lon + vdel + qaaa + vdel + 'выдача кредита, счет № ' + qaaa + ', ' + string(today,'99.99.9999') + ', '
           + ', ' + pkanketa.name + ', КНП - ' + v-knp + vdel + v-knp + vdel + string(comsum) + vdel + 'списание комиссии за предоставление кредита, счет №'
           + qaaa + ', ' + string(today,'99.99.9999') + ', ' + pkanketa.name + ', КНП - 490' + vdel + string(v-sumdplk) + vdel + qarp + vdel
           + 'перевод кредитных средств на карт-счет клиента, счет' + pcstaff0.aaa + ', ' + string(today,'99.99.9999') + ', ' + pkanketa.name
           + ', КНП - 190'.

    run trxgen (v_doc, vdel, vparam, "", "", output rcode, output rdes, input-output s-jh).
    if rcode <> 0 then do: message rcode rdes. pause 100. return. end.
    if s-jh ne 0 then do:
        message " Сформирована проводка по выдаче: " s-jh view-as alert-box.
        v-nxt = 0.
        for each lnscg where lnscg.lng eq pkanketa.lon and lnscg.f0 eq 0 and lnscg.flp gt 0 no-lock:
            v-nxt = lnscg.flp.
        end.

        create lnscg.
        lnscg.lng = pkanketa.lon.
        lnscg.f0 = 1.
        lnscg.paid = totsum.
        lnscg.stdat = g-today.
        lnscg.jh = s-jh.
        lnscg.whn = g-today.
        lnscg.who = g-ofc.
        lnscg.schn = "  1. .   " + string(lnscg.flp,"zzzz").
        lnscg.stval = totsum.
        lnscg.flp = 1.
        create lnscg.
        lnscg.lng = pkanketa.lon.
        lnscg.f0 = 1.
        lnscg.paid = totsum.
        lnscg.stdat = g-today.
        lnscg.schn = "  1. .   " + string(lnscg.flp,"zzzz").
        lnscg.stval = totsum.

        run lonresadd(s-jh).
        if comsum > 0 then do:
            create lnscc.
            assign lnscc.lon = pkanketa.lon
                   lnscc.comid = ''
                   lnscc.sch = yes
                   lnscc.stdat = pkanketa.duedt
                   lnscc.stval = comsum.
        end.
        if v-sumdplk > 0 then do:
            create pcpay.
            assign pcpay.bank = s-ourbank
                   pcpay.aaa  = pcstaff0.aaa
                   pcpay.crc  = 1
                   pcpay.amt  = v-sumdplk
                   pcpay.ref  = pkanketa.lon + '_' + string(pkanketa.ln)
                   pcpay.jh   = s-jh
                   pcpay.sts  = 'ready'
                   pcpay.who  = g-ofc
                   pcpay.whn  = g-today
                   pcpay.info[1] = substr(s-ourbank,4).
            /*-------SMS------*/

            if v-tel <> '' and v-issue = 'карту' then do:
                run addatk(yes,"Vam odobren credit. V skorom vremeni na Vashu kartu budet zachislena summa kredita. Blagodarim za Vash vybor! ForteBank. Tel: 88000707007",v-tel,pkanketa.bank,pkanketa.cif,next-value(smsbatch)).
                message "SMS-уведомление создано!" view-as alert-box information buttons ok.
            end.
        end.

        find first pc_lncontr where pc_lncontr.acc = pkanketa.aaa and pc_lncontr.contr = pkanketa.rescha[1] no-lock no-error.
        if not avail pc_lncontr then do:
            create pc_lncontr.
            assign pc_lncontr.acc      = pkanketa.aaa
                   pc_lncontr.iin      = pkanketa.rnn
                   pc_lncontr.contr    = pkanketa.rescha[1]
                   pc_lncontr.stdate   = pkanketa.docdt
                   pc_lncontr.edate    = pkanketa.duedt
                   pc_lncontr.amt      = pkanketa.summa
                   pc_lncontr.prem     = pkanketa.rateq
                   pc_lncontr.pen      = 0.2
                   pc_lncontr.eff_%    = pkanketa.resdec[1]
                   pc_lncontr.whn      = g-today
                   pc_lncontr.who      = g-ofc
                   pc_lncontr.ow_limdt = g-today
                   pc_lncontr.crtype   = '10'.
        end.

        /* запишем номер проводки */
        /*find current pkanketa exclusive-lock.*/
        pkanketa.trx1 = s-jh.
        pkanketa.sts = '40'.
        pkanketa.resdat[1] = g-today.
        /*find current pkanketa no-lock.*/

        find first codfr where codfr.codfr = 'clmail' and codfr.code = 'oomail' no-lock no-error.
        if not avail codfr then do:
            message 'Нет справочника адресов рассылки' view-as alert-box.
            return.
        end.
        else do:
            i = 1.
            do i = 1 to num-entries(codfr.name[1],','):
                v-maillist = v-maillist + entry(i,codfr.name[1],',') + '@fortebank.com,'.
            end.
            v-zag = 'Выдача кредита'.
            v-str = "Здравствуйте! Клиенту: " + pcstaff0.cif + ", " + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                  + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ", номер анкеты: " + string(pkanketa.ln)
                  + " выдан Экспресс кредит! Дата поступления задачи: " + string(today) + ', ' + string(time,'hh:mm:ss')
                  + ". Бизнес-процесс: Экспресс кредит".
            run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
        end.

    end. /* s-jh <> 0 */
end. /* do transaction */
release pkanketa.

do transaction on error undo, retry:
    find lon where lon.lon = pkanketa.lon exclusive-lock no-error.
    if avail lon then do:
        if lon.lcr = "" then lon.lcr = "M".
        release lon.
    end.
end.

procedure addatk.
    define input parameter v-sendtxt as logi.
    define input parameter v-txt as char.
    define input parameter v-mob as char.
    define input parameter v-bank as char.
    define input parameter v-cif as char.
    define input parameter v-batchid as inte.

    def buffer b-smspool for comm.smspool.

    create b-smspool.
    b-smspool.bank = v-bank.
    b-smspool.id = next-value(smsid).
    b-smspool.tell = v-mob.
    b-smspool.pdate = today.
    b-smspool.ptime = time.
    b-smspool.pwho = g-ofc.
    b-smspool.state = 2.
    b-smspool.cif = v-cif.
    b-smspool.batchid = v-batchid.
    if v-sendtxt then b-smspool.mess = v-txt.
    b-smspool.source = "CredLimit".
end procedure.