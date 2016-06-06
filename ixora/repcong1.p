/* repcong1.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
            10/10/2012 Luiza
 * BASES
        BANK COMM TXB
 * CHANGES
                23/10/2012 Luiza по СЗ 22/10/2012 добавила пакеты для менеджеров
                09/11/2012 Luiza добавила исключение удаленных проводок
                12/11/2012 Luiza для кассиров проводки выбираем без проверки пакета
                24/06/2013 Luiza  -  ТЗ 1921
*/


def shared var dt1 as date no-undo.
def shared var dt2 as date no-undo.
def shared var v-fil-cnt as char format "x(30)".
def shared var v-fil-int as int.
def shared var v-sel2 as int no-undo.
def shared var v-id as char.
def var v-dep as int no-undo.
def var v-departs as char no-undo.
def var v-who as char no-undo.
def var v-whoname as char no-undo.
def var v-txb as char no-undo.
def var v-teller as char no-undo.
def var v-in1 as logic.
def buffer b-jh for txb.jh.
def shared var ch as char.
def var v-100100 as logic.
def var jhold as int.
def shared var v-ful1 as logic format "да/нет".
def var v-party as char.

define shared temp-table wrk no-undo
    field txb as char
    field fil as char
    field num as int
    field podr as int
    field podrname as char
    field id as char
    field fio as char
    field f as char
    field kol as int
    index ind1 is primary txb id .

function IsKass returns log (input v-ofc as char).
  find first txb.ofc where txb.ofc.ofc = v-ofc no-lock no-error.
  if avail txb.ofc then do:
    if (lookup("p00007",txb.ofc.expr[1]) > 0) or (lookup("p00008",txb.ofc.expr[1]) > 0) then return true. /* Это кассир */
    else return false.
  end.
  else return false.
end function.

function chkbuh returns logical (usr as char).
    def var v-res as logical init no.
    def var j as integer.
    find first txb.ofc where txb.ofc.ofc = usr no-lock no-error.
    if avail txb.ofc then do:
        do j = 1 to num-entries(txb.ofc.expr[1]):
            if trim(entry(j,txb.ofc.expr[1])) = "p00032" or trim(entry(j,txb.ofc.expr[1])) = "p00033"
            or trim(entry(j,txb.ofc.expr[1])) = "p00046" or trim(entry(j,txb.ofc.expr[1])) = "p00136" then do: v-res = yes. leave. end.
        end. /* do j = 1 */
    end.
    return v-res.
end.

function chdoc returns logical (input fjh as integer, ftxb as char, fparty as char).
    def var v-in as logic.
    def var v-t as int.
    v-in = false.
    for each txb.jl where txb.jl.jh = fjh no-lock .
        v-t = 1.
        do while v-t <= 5:
            if txb.jl.rem[v-t] begins "За чековые книжки" then return true.
            v-t = v-t + 1.
        end.
    end.
    /*if trim(fparty) = "" then do:*/
        for each txb.trxcods where txb.trxcods.trxh = fjh and txb.trxcods.codfr = "spnpl" no-lock.
            if txb.trxcods.code = "213" or txb.trxcods.code = "223" then return true.
        end.
    /*end.*/
    /*else do:*/
        find first txb.joudop where txb.joudop.docnum = fparty no-lock no-error.
        if available txb.joudop and txb.joudop.type <> "VTK2" and txb.joudop.type <> "PTK2" and txb.joudop.type <> "CSI2" and txb.joudop.type <> "VSI2" then return true.

        find first txb.remtrz where txb.remtrz.remtrz = substring(fparty,1,10) and txb.remtrz.jh2 = fjh no-lock no-error.
        if available txb.remtrz and txb.remtrz.source = "A" and  (txb.remtrz.rsub = "x-name" or txb.remtrz.rsub = "x-pref") then return true.

        find first txb.remtrz where txb.remtrz.remtrz = substring(fparty,1,10) and txb.remtrz.jh1 = fjh no-lock no-error.
        if available txb.remtrz and (txb.remtrz.source = "IBH" or txb.remtrz.source = "PNJ") then return true.
        if available txb.remtrz and (txb.remtrz.jh3 <= 1 or txb.remtrz.jh3 = ?)
                    and txb.remtrz.source <> "A"  and txb.remtrz.source <> "LBI" and txb.remtrz.source <> "PRR" then do:
            for each txb.jl where txb.jl.jh = txb.jh.jh no-lock.
                find first txb.aaa where txb.aaa.aaa = txb.jl.acc no-lock no-error.
                if available txb.aaa then return true.
                if txb.jl.trx = "VNB0086" then return true.
            end.
        end.

        find first txb.joudoc where txb.joudoc.docnum = fparty no-lock no-error.
        if available txb.joudoc and txb.joudoc.dracctype = "3" and txb.joudoc.cracctype = "3" then return true.
        find first b-jh where b-jh.jh = fjh no-lock no-error.
        if available b-jh and b-jh.jh2 > 0 then return true. /* проводки сдачи */
        find first filpayment where filpayment.bankfrom  = ftxb and filpayment.jh = fjh no-lock no-error.
        if available filpayment then return true.
    /*end.*/
    return false.
end function.

function chwho returns char (input p1 as char, fparty1 as char).
    def var res as char.
    res = "".
    if p1 begins "super" then do:
        find first txb.remtrz where txb.remtrz.remtrz = fparty1 /*and txb.remtrz.source  = "IBH"*/ no-lock no-error.
        if available txb.remtrz and (txb.remtrz.source  = "IBH" or txb.remtrz.source = "PNJ") then do:
           find first txb.doc_who_create where txb.doc_who_create.docno = remtrz.remtrz no-lock no-error.
           if avail txb.doc_who_create then res = txb.doc_who_create.who_cr.
           else res = remtrz.cwho.
        end.
        if available txb.remtrz and txb.remtrz.source  <> "IBH" and txb.remtrz.source <> "PNJ" then res = txb.remtrz.rwho.
    end.
    else res = p1.
    return res.
end function.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
v-txb = trim(txb.sysc.chval).

find first txb.cmp no-lock no-error.
if available txb.cmp then v-fil-cnt = txb.cmp.name.
message  "Ждите, идет подготовка данных для отчета " + v-fil-cnt .
pause 1.
v-fil-int = v-fil-int + 1.

case v-sel2:
    when 1 then do: run sel1. if v-ful1 then run repcongr. end.
    when 2 then do:  run sel2. if v-ful1 then run repcongr. end.
    when 3 then do: run sel1. run sel2. if v-ful1 then run repcongr. end.
    when 4 then do: if IsKass(v-id) then run sel3. else run sel4. if v-ful1 then run repcongr. end.
end.

procedure sel1:
    for each txb.jh where txb.jh.jdt >= dt1 and txb.jh.jdt <= dt2 and txb.jh.sts = 6 and
        (not txb.jh.party begins "Storn" and not txb.jh.party begins "Delet" and not trim(txb.jh.party) begins "Lon") and
        (txb.jh.who begins "id" or txb.jh.who begins "super")  no-lock:
        v-who = chwho(txb.jh.who,txb.jh.party).
        find first txb.ofc where txb.ofc.ofc = v-who no-lock no-error.
        if available txb.ofc then v-whoname = ofc.name. else v-whoname = "".

        if not IsKass(v-who) /*and chkbuh(v-who)*/ then do: /* менеджеры */
            if txb.jh.party = "" then v-party = substring(trim(txb.jh.ref),1,11).
            else v-party = txb.jh.party.
            if chdoc(txb.jh.jh,v-txb,v-party)  then do:
                find first wrk where wrk.txb = v-txb and wrk.id = v-who no-lock no-error.
               if not available wrk then do:
                    create wrk.
                    wrk.txb = v-txb.
                    wrk.fil = v-fil-cnt.
                    wrk.podrname = "Операционный отдел".
                    wrk.id = v-who.
                    wrk.fio = v-whoname.
                    wrk.f = string(txb.jh.jh).
                    wrk.kol = 0.
                end.
                wrk.kol = wrk.kol + 1.
            end.
        end.
    end.
end procedure.

procedure sel2:
    for each txb.jh where txb.jh.jdt >= dt1 and txb.jh.jdt <= dt2 and txb.jh.sts = 6 and
        (not txb.jh.party begins "Storn" and not txb.jh.party begins "Delet" and not trim(txb.jh.party) begins "Lon") and
        (txb.jh.who begins "id" or txb.jh.who begins "super")  no-lock:
        find first txb.jl where txb.jl.jh = txb.jh.jh no-lock no-error.
        if available txb.jl then v-who = txb.jl.teller.
        find first txb.ofc where txb.ofc.ofc = v-who no-lock no-error.
        if available txb.ofc then v-whoname = ofc.name. else v-whoname = "".

        /*if IsKass(v-who) then do:*/ /* кассиры */
            v-in1 = true.
            v-100100 = false.
            for each txb.jl where txb.jl.jh = txb.jh.jh no-lock.
                if txb.jl.gl = 100110 or txb.jl.gl = 100200 or txb.jl.trx = "VNB0041" or txb.jl.trx = "VNB0042" then v-in1 = false.
                if txb.jl.gl = 100100 then v-100100 = true.
            end.
            /*if v-100100 = false then if txb.jh.sub = "rmz" then v-in1 = false.*/
            if v-in1 and v-100100 then do:
                find first wrk where wrk.txb = v-txb and wrk.id = v-who no-lock no-error.
                if not available wrk then do:
                    create wrk.
                    wrk.txb = v-txb.
                    wrk.fil = v-fil-cnt.
                    wrk.podrname = "Отдел кассовых операций".
                    wrk.id = v-who.
                    wrk.fio = v-whoname.
                    wrk.f = string(txb.jh.jh).
                    wrk.kol = 0.
                end.
                wrk.kol = wrk.kol + 1.
            end.
        /*end.*/
    end.
end procedure.

procedure sel3:
    for each txb.jh where txb.jh.jdt >= dt1 and txb.jh.jdt <= dt2 and txb.jh.sts = 6 and
        (not txb.jh.party begins "Storn" and not txb.jh.party begins "Delet" and not trim(txb.jh.party) begins "Lon") and
        (txb.jh.who begins "id" or txb.jh.who begins "super")  no-lock:
        find first txb.jl where txb.jl.jh = txb.jh.jh no-lock no-error.
        if available txb.jl and  txb.jl.teller = v-id then do:
            v-who = txb.jl.teller.
            find first txb.ofc where txb.ofc.ofc = v-who no-lock no-error.
            if available txb.ofc then v-whoname = ofc.name. else v-whoname = "".

            /*if IsKass(v-who) then do:*/ /* кассиры */
                v-in1 = true.
                v-100100 = false.
                for each txb.jl where txb.jl.jh = txb.jh.jh no-lock.
                    if txb.jl.gl = 100110 or txb.jl.gl = 100200 or txb.jl.trx = "VNB0041" or txb.jl.trx = "VNB0042" then v-in1 = false.
                    if txb.jl.gl = 100100 then v-100100 = true.
                end.
                /*if v-100100 = false then if txb.jh.sub = "rmz" then v-in1 = false.*/
                if v-in1 and v-100100 then do:
                    find first wrk where wrk.txb = v-txb and wrk.id = v-who no-lock no-error.
                    if not available wrk then do:
                        create wrk.
                        wrk.txb = v-txb.
                        wrk.fil = v-fil-cnt.
                        wrk.podrname = "Отдел кассовых операций".
                        wrk.id = v-who.
                        wrk.fio = v-whoname.
                        wrk.f = string(txb.jh.jh).
                        wrk.kol = 0.
                    end.
                    wrk.kol = wrk.kol + 1.
                end.
            end.
        /*end.*/
    end.
end procedure.

procedure sel4:
    for each txb.jh where txb.jh.jdt >= dt1 and txb.jh.jdt <= dt2 and txb.jh.sts = 6 and
        (not txb.jh.party begins "Storn" and not txb.jh.party begins "Delet" and not trim(txb.jh.party) begins "Lon") and
        (txb.jh.who begins "id" or txb.jh.who begins "super")  no-lock:
        v-who = chwho(txb.jh.who,txb.jh.party).
        if v-who = v-id then do:
            find first txb.ofc where txb.ofc.ofc = v-who no-lock no-error.
            if available txb.ofc then v-whoname = ofc.name. else v-whoname = "".

           /* if chkbuh(v-who) then do:*/ /* менеджеры */
                if txb.jh.party = "" then v-party = substring(trim(txb.jh.ref),1,11).
                else v-party = txb.jh.party.
                if chdoc(txb.jh.jh,v-txb,v-party) then do:
                    find first wrk where wrk.txb = v-txb and wrk.id = v-who no-lock no-error.
                   if not available wrk then do:
                        create wrk.
                        wrk.txb = v-txb.
                        wrk.fil = v-fil-cnt.
                        wrk.podrname = "Операционный отдел".
                        wrk.id = v-who.
                        wrk.fio = v-whoname.
                        wrk.f = string(txb.jh.jh).
                        wrk.kol = 0.
                    end.
                    wrk.kol = wrk.kol + 1.
                end. /*if chdoc(txb.jh.jh*/
            end. /*if chkbuh(v-who)   */
        end.
    /*end.*/
end procedure.



