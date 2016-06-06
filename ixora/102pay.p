/* 102pay.p
 * MODULE
        Операционный
 * DESCRIPTION
        Загрузка инкассовых распоряжений
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
        28/02/2008 alex
 * BASES
        BANK COMM
 * CHANGES
        28/10/2010 madiyar - 780300 -> 830300
        02/05/2012 evseev - логирование значения aaa.hbal
        17.09.2012 evseev - ТЗ-1445
*/

define buffer b-aash for aas_hist.
def var s-vcourbank as char no-undo.
def var v-usrglacc as char no-undo.
def var v-jh like jh.jh no-undo.
def var vparam2 as char no-undo.
def var rcode as inte no-undo.
def var rdes as char no-undo.
def var vdel as char initial "^" no-undo.
def var v-ofc1 as char no-undo.
def var s-aaa like aaa.aaa no-undo.
def shared var g-today as date.
def shared var g-ofc as char.
def var v-dep like ofchis.depart no-undo.
define var op_kod as char format "x(1)" no-undo.
def var v-pay as log.
def var vbal like jl.dam.
def var vavl like jl.dam.
def var vhbal like jl.dam.
def var vfbal like jl.dam.
def var vcrline like jl.dam.
def var vcrlused like jl.dam.
def var vooo like aaa.aaa.
{get-dep.i}
{aas2his.i &db = "bank"}

for each inc100 where (inc100.bank eq s-vcourbank) and (inc100.stat eq 1) and inc100.stat2 = "" no-lock:
    if (inc100.mnu eq "rwp") or (inc100.mnu eq "rws") then do:
        find first aaa where aaa.aaa eq inc100.iik exclusive-lock no-error.
        find last cif where cif.cif = aaa.cif no-lock no-error.
        if avail cif then do:
            message "Наименование клиента:" cif.name  skip "РНН клиента:" cif.jss view-as alert-box question buttons ok title "Визуальный контроль".
        end.
        message "Внимание: Прочие инкассовые расп. оплачиваются в обычных пунктах меню". pause 3.
        message "".
        pause 0.

        do transaction on error undo, return :
            create aas.
            find last b-aash where b-aash.aaa = aaa.aaa and b-aash.ln <> 7777777 use-index aaaln no-lock no-error.
            if available b-aash then aas.ln = b-aash.ln + 1.
            else aas.ln = 1.
            assign aas.aaa = aaa.aaa
                aas.regdt = g-today
                aas.docprim = string(inc100.sum)
                aas.fnum = string(inc100.num)
                aas.docdat = date(inc100.dt)
                aas.bnfname = inc100.bnf
                aas.rnnben = inc100.dpname
                aas.bicben = ""
                aas.bankben = ""
                aas.iikben = inc100.reschar[2]
                aas.knp = string(inc100.knp).

            find first budcodes where budcodes.code eq integer(aas.kbk) no-lock no-error.
            if avail budcodes then aas.payee = budcodes.name.

            find last bankl where bankl.bic = aas.bicben no-lock no-error.
            if avail bankl and aas.bicben <> "" then do:
                aas.bankben = bankl.name.
            end.
            aas.chkamt  = 100000000000.00.
            aas.sta     = 9.
            aas.who     = g-ofc.
            aas.fsum    = decimal(aas.docprim).
            aas.irsts   = "не оплачено".
            aas.activ   = True.
            aas.contr   = False.
            aas.tim     = time.
            aas.whn     = g-today.
            aas.who     = g-ofc.
            aas.sic     = 'HB'.
            s-aaa       = aaa.aaa.
            if aas.sic = 'HB' then do:
                find first aaa where aaa.aaa = s-aaa exclusive-lock.
                run savelog("aaahbal", "102pay ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal + aas.chkamt) + " ; " + string(aas.chkamt)).
                aaa.hbal = aaa.hbal + aas.chkamt.
            end.

            find last cif where cif.cif = aaa.cif no-lock no-error.
            if avail cif then aas.cif = cif.cif.

            if s-vcourbank = "txb00" then do:
                find last vnebal where vnebal.usr = substr(cif.fname, 1, 8) no-lock no-error.
                if avail vnebal then do:
                    v-usrglacc = vnebal.gl.
                end.
                else do:
                    v-ofc1 =  string(get-dep(trim(substr(cif.fname, 1, 8)), g-today)).
                    find last vnebal where vnebal.usr = v-ofc1  no-lock no-error.
                    if avail vnebal then do:
                        v-usrglacc = vnebal.gl.
                    end.
                end.
            end.
            else do:
                find last vnebal where vnebal.usr = s-vcourbank no-lock no-error.
                if avail vnebal then do:
                    v-usrglacc = vnebal.gl.
                end.
            end.
            if s-vcourbank = "" then do:
                message "Не удалось найти счет Г/К для зачисления на внебаланс! (обсл менеджер-"substr(cif.fname,1,8) ") ".
                pause.
                undo, return.
            end.

            /* Блокируем сумму и производим транзакцию на внебаланс */
            if aas.chkamt <> 0 and v-usrglacc <> "" then do:
                message "Внимание. Сумма будет зачислена на счет внебаланса " v-usrglacc vnebal.k2  view-as alert-box question buttons yes-no update v-pay.
                if not v-pay then do: undo, return. end.
                v-jh = 0.
                vparam2 = aas.docprim + vdel + string(1) + vdel + v-usrglacc + vdel + "830300" + vdel + /*"учет суммы И.Р. " +*/ aaa.aaa + vdel + aaa.aaa + vdel.
                run trxgen("vnb0005", vdel, vparam2, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                if rcode ne 0 then do:
                    message rdes view-as alert-box title "".
                    undo, return.
                end.
                else do:
                    message "Произведена транзакция #" v-jh " по  учету суммы ИР на внебаланс ".
                    pause.
                end.
            end.
            else do:
                if aas.chkamt = 0 then do:
                    message "Невозможно зачислить сумму 0.0 на внебаланс".
                    pause.
                    return.
                end.
                if v-usrglacc = "" then do:
                    message "Не удалось найти счет Г/К для зачисления на внебаланс! (обсл менеджер-"substr(cif.fname,1,8) ") ".
                    pause.
                    return.
                end.
            end.
            FIND FIRST ofc WHERE ofc.ofc = g-ofc NO-LOCK.
            aas.point = ofc.regno / 1000 - 0.5.
            aas.depart = ofc.regno MODULO 1000.
            op_kod = 'A'.
            RUN aas2his.
        end. /*transaction*/
    end.
end.
