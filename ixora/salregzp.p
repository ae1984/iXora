/* salregzp.p
 * MODULE
       Клиентские операции
 * DESCRIPTION
       Зарплатные и прочие платежи - ввод платежа
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        15.1.4.1.1
 * AUTHOR
        --/--/2013 damir
 * BASES
        BANK COMM
 * CHANGES
        19.07.2013 damir - Changing copy regzpinp.p. Внедрено Т.З. № 1931.

*/

{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

{p_f_com.i}
{p_f_gs.i}
{p_f_com1.i}
{comm-rnn.i}
{trim.i}
{chbin.i}

def shared var g-today as date.
define shared variable g-ofc as character.
def var v-resident as integer init 1.

/* может запрашивать ордер или нет */
define variable canprn as log initial no.
find sysc where sysc.sysc = "BKEXCL" no-lock no-error.
if available sysc then if lookup (g-ofc, sysc.chval) > 0 then canprn = yes.

def input parameter newdoc as logical.
def input parameter rid as rowid.
def input parameter dat as date.

def new shared var pass_no as char.
def var cret as char init "".
def var v-knp as char.
def var amount as decim.
def var comsum as decimal init 0.
def var pf-name as char init ''.
def var comchar as char init "Без комиcсии".
def var doccomcode as char.
def var resultt as log init true.
def var l-str as char format 'x(1)' .
define variable oldrnn as character.
def var v-whole-sum as decimal.
def var v-acc as logi.
def var vbal like jl.dam.
def var vavl like jl.dam.
def var vhbal like jl.dam.
def var vfbal like jl.dam.
def var vcrline like jl.dam.
def var vcrlused like jl.dam.
def var vooo like aaa.aaa.
define variable vparam  as character.
define variable vdel    as character initial "^".
define variable rcode   as integer.
define variable rdes    as character.
def new shared var s-jh like jh.jh.
def var v-kont as inte.
def var v-cif as char.
def var s-rnn as char.
def var v-rtim as char no-undo. /*время ввода дебет. части платежа*/
def var v-amt as deci format ">>>>>>>>>9.99".

define frame sf skip
               salary_p.nom  label "Ном.пл.пор." format ">>>>>9" skip(1)
               salary_p.acc  label "ИИК клиента" format "x(20)" skip
               salary_p.rnn  label "РНН(ИИН/БИН) " format "x(12)" skip
               salary_p.name label "Наименование" view-as text skip(1)
               salary_p.sum  label "Сумма" format ">>>>>>>>9.99"
               salary_p.knp  label "КНП" v-knp no-label skip(1)
               v-rtim label "Время" skip
               with side-labels centered view-as dialog-box.

on help of salary_p.rnn in frame sf do:
           find first cif where cif.cif = v-cif no-lock no-error.
           if v-bin = no then salary_p.rnn = cif.jss.
           else salary_p.rnn = cif.bin.
end.

on return of salary_p.acc in frame sf
do:
    find first aaa where aaa.aaa = salary_p.acc:screen-value and aaa.sta ne 'C' no-lock no-error.
    if avail aaa then do:
        find first cif where cif.cif = aaa.cif no-lock no-error.
        if avail cif then do: assign salary_p.name = cif.prefix + " " + cif.name salary_p.rnn = (if v-bin = no then cif.jss else cif.bin) v-cif = cif.cif. end.
                     else do: message " В АО Метрокомбанк нет такого счета !" view-as alert-box button Ok. v-acc = false. end.
    end.
    else do: message " В АО Метрокомбанк нет такого счета !" view-as alert-box button Ok. v-acc = false. end.
    displ salary_p.rnn salary_p.name with frame sf.
end.

/* --------------------------------------------------- */

REPEAT:

    if newdoc then do:
        CREATE salary_p.
        salary_p.txb = seltxb.
        salary_p.rnn = "".
        oldrnn = ''.
        salary_p.rtim = time.
    end.
    else do:
        find salary_p where rowid(salary_p)=rid.
        if not avail salary_p then leave.
        oldrnn = salary_p.rnn.
    end.
    v-rtim = string(salary_p.rtim,"HH:MM:SS").
    displ salary_p.nom
    salary_p.acc
    salary_p.rnn
    salary_p.name
    salary_p.knp
    salary_p.sum
    v-rtim
    with frame sf.

    v-acc = true.
    UPDATE salary_p.nom WITH FRAME sf.

    /*Редактировать счет нельзя , т к он связан со спец инструкцией*/
    repeat:
        if newdoc then
        UPDATE salary_p.acc  WITH FRAME sf.
        if v-acc then leave.
    end.
    if keyfunction(lastkey) eq "end-error" then  return.

    UPDATE
    salary_p.knp validate (lookup(salary_p.knp, '311') > 0 and salary_p.knp ne '',"Неверный КНП!")
    WITH FRAME sf.
    /*Редактировать сумму нельзя , т к она связана со спец. инструкцией*/
    repeat on endkey undo,leave:
        if newdoc then UPDATE salary_p.sum validate (salary_p.sum > 0, "Сумма должна быть больше нуля!") WITH FRAME sf.

        assign salary_p.whn = dat salary_p.who = g-ofc.

        if newdoc then do:
            run aaa-bal777(salary_p.acc, output vbal, output vavl, output vhbal,
            output vfbal, output vcrline, output vcrlused, output vooo).

            def buffer b1-aas for aas.
            def var d_sm as decimal. d_sm = 0.
            find last b1-aas where b1-aas.aaa = salary_p.acc and b1-aas.sta = 2 no-lock no-error.
            if not avail b1-aas then do:
                find last b1-aas where b1-aas.aaa = salary_p.acc and b1-aas.sta = 11 no-lock no-error.
                if avail b1-aas then do:
                    d_sm = 0.
                    for each b1-aas where b1-aas.aaa = salary_p.acc and b1-aas.sta = 11 no-lock:
                        d_sm = d_sm + b1-aas.chkamt.
                    end.
                    vavl = vavl + d_sm.
                end.
                d_sm = 0.
                find last b1-aas where b1-aas.aaa = salary_p.acc and b1-aas.sta = 16 no-lock no-error.
                if avail b1-aas then do:
                    for each b1-aas where b1-aas.aaa = salary_p.acc and b1-aas.sta = 16 no-lock:
                        d_sm = d_sm + b1-aas.chkamt.
                    end.
                    vavl = vavl + d_sm.
                end.

                d_sm = 0.
                find last b1-aas where b1-aas.aaa = salary_p.acc and lookup(string(b1-aas.sta), "11,16") <> 0 no-lock no-error.
                if avail b1-aas then do:
                    for each b1-aas where b1-aas.aaa = salary_p.acc and lookup(string(b1-aas.sta), "4,5,6,8") <> 0 no-lock:
                        d_sm = d_sm + b1-aas.chkamt.
                    end.
                end.
                vavl = vavl + d_sm.
            end.

            find first aaa where aaa.aaa = salary_p.acc:screen-value and aaa.sta ne 'C' no-lock no-error.
            if avail aaa then do:
                find first cif where cif.cif = aaa.cif no-lock no-error.
                if not avail cif then do: message " В АО Метрокомбанк нет такого счета !" view-as alert-box button Ok. undo,retry. end.
            end.
            else do: message " В АО Метрокомбанк нет такого счета !" view-as alert-box button Ok. undo,retry. end.

            v-kont = 0. v-amt = 0.
            run SumTar(cif.cif,salary_p.sum,aaa.crc,"058",input-output v-kont,input-output v-amt).
            if vavl < salary_p.sum + v-amt then do:
                message " На текущем счете недостаточно средств для оплаты!" view-as alert-box button Ok.
                undo, leave.
            end.
            else do:
                salary_p.com = v-amt.
                leave.
            end.
        end.
    end.

    MESSAGE "Сохранить?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO-cancel
    TITLE "Зарплатные платежи " UPDATE choice as logical.

        case choice:
            when true then do:
             if newdoc then do:
                 create aas.

                 find last aas_hist where aas_hist.aaa = salary_p.acc no-lock no-error.
                 if available aas_hist then aas.ln = aas_hist.ln + 1. else aas.ln = 1.
                 salary_p.ln = aas.ln.

                 aas.sic = 'HB'.
                 aas.chkdt = g-today.
                 aas.chkno = 0.
                 aas.chkamt  = salary_p.sum.
                 aas.aaa = salary_p.acc .
                 aas.who = g-ofc.
                 aas.whn = g-today.
                 aas.regdt = g-today.
                 aas.tim = time.

                 if aas.sic = 'HB' then do:
                     find first aaa where aaa.aaa = salary_p.acc exclusive-lock.
                     if avail aaa then aaa.hbal = aaa.hbal + aas.chkamt.
                 end.

                 FIND FIRST ofc WHERE ofc.ofc = g-ofc NO-LOCK no-error.
                 if avail ofc then do:
                   aas.point = ofc.regno / 1000 - 0.5.
                   aas.depart = ofc.regno MODULO 1000.
                 end.

                 CREATE aas_hist.

                 find first aaa where aaa.aaa = salary_p.acc no-lock no-error.
                 IF AVAILABLE aaa THEN
                 DO:
                    FIND FIRST cif WHERE cif.cif= aaa.cif USE-INDEX cif NO-LOCK NO-ERROR.
                    IF AVAILABLE cif THEN DO:
                       aas_hist.cif= cif.cif.
                       aas_hist.name= trim(trim(cif.prefix) + " " + trim(cif.name)).
                    END.
                 END.

                 aas_hist.aaa= aas.aaa.
                 aas_hist.ln= aas.ln.
                 aas_hist.sic= aas.sic.
                 aas_hist.chkdt= aas.chkdt.
                 aas_hist.chkno= aas.chkno.
                 aas_hist.chkamt= aas.chkamt.
                 aas_hist.payee= aas.payee.
                 aas_hist.expdt= aas.expdt.
                 aas_hist.regdt= aas.regdt.
                 aas_hist.who= aas.who.
                 aas_hist.whn= aas.whn.
                 aas_hist.tim= aas.tim.
                 aas_hist.del= aas.del.
                 aas_hist.chgdat= g-today.
                 aas_hist.chgtime= time.
                 aas_hist.chgoper= 'A'.

                /*комиссия*/
                if salary_p.com > 0 then do:
                    create aas.

                    find last aas_hist where aas_hist.aaa = salary_p.acc no-lock no-error.
                    if available aas_hist then aas.ln = aas_hist.ln + 1. else aas.ln = 1.
                    salary_p.info[10] = string(aas.ln).
                    aas.sic = 'HB'.
                    aas.chkdt = g-today.
                    aas.chkno = 0.
                    aas.chkamt  = salary_p.com.
                    aas.aaa = salary_p.acc .
                    aas.who = g-ofc.
                    aas.whn = g-today.
                    aas.regdt = g-today.
                    aas.tim = time.

                    if aas.sic = 'HB' then do:
                        find first aaa where aaa.aaa = salary_p.acc exclusive-lock.
                        if avail aaa then aaa.hbal = aaa.hbal + aas.chkamt.
                    end.

                    FIND FIRST ofc WHERE ofc.ofc = g-ofc NO-LOCK no-error.
                    if avail ofc then do:
                        aas.point = ofc.regno / 1000 - 0.5.
                        aas.depart = ofc.regno MODULO 1000.
                    end.

                    CREATE aas_hist.
                    find first aaa where aaa.aaa = salary_p.acc no-lock no-error.
                    IF AVAILABLE aaa THEN DO:
                        FIND FIRST cif WHERE cif.cif = aaa.cif USE-INDEX cif NO-LOCK NO-ERROR.
                        IF AVAILABLE cif THEN DO:
                            aas_hist.cif= cif.cif.
                            aas_hist.name= trim(trim(cif.prefix) + " " + trim(cif.name)).
                        END.
                    END.

                    aas_hist.aaa = aas.aaa.
                    aas_hist.ln = aas.ln.
                    aas_hist.sic = aas.sic.
                    aas_hist.chkdt = aas.chkdt.
                    aas_hist.chkno = aas.chkno.
                    aas_hist.chkamt = aas.chkamt.
                    aas_hist.payee = aas.payee.
                    aas_hist.expdt = aas.expdt.
                    aas_hist.regdt = aas.regdt.
                    aas_hist.who = aas.who.
                    aas_hist.whn = aas.whn.
                    aas_hist.tim = aas.tim.
                    aas_hist.del = aas.del.
                    aas_hist.chgdat = g-today.
                    aas_hist.chgtime = time.
                    aas_hist.chgoper = 'A'.
                end.
             end.

             cret = string(rowid(salary_p)).
             leave.
            end.

            when false then undo.
            otherwise  undo, leave.
        end case.

END.

procedure SumTar:
    def input parameter p-cif as char.
    def input parameter p-sum as deci.
    def input parameter p-crc as inte.
    def input parameter p-str5 as char.
    def input-output parameter p-kont as deci.
    def input-output parameter p-amt as deci.

    p-kont = 0.
    find first tarifex where tarifex.cif = p-cif and tarifex.str5 = p-str5 no-lock no-error.
    if not avail tarifex then do:
        find first tarif2 where tarif2.str5 = p-str5 no-lock no-error.
        if avail tarif2 then do:
            if tarif2.proc > 0 then do:
                p-amt = p-sum * (tarif2.proc / 100).
                if tarif2.min1 > 0 and p-amt < tarif2.min1 then p-amt = tarif2.min1.
                if tarif2.max1 > 0 and p-amt > tarif2.max1 then p-amt = tarif2.max1.
            end.
            else p-amt = tarif2.ost.
            p-kont = tarif2.kont.
        end.
        else message "Не найден тариф для снятия комиссии!" view-as alert-box.
    end.
    else do:
        if tarifex.proc > 0 then do:
            p-amt = p-sum * (tarifex.proc / 100).
            if tarifex.min1 > 0 and p-amt < tarifex.min1 then p-amt = tarifex.min1.
            if tarifex.max1 > 0 and p-amt > tarifex.max1 then p-amt = tarifex.max1.
        end.
        else p-amt = tarifex.ost.
        p-kont = tarifex.kont.
    end.
end procedure.

hide frame sf.
return cret.

