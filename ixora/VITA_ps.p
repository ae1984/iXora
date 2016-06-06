/* VITA_ps.p
 * MODULE
        Внутрибанковские операции
 * DESCRIPTION
        Витамин->Иксора
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
        02/08/2011 madiyar
 * BASES
        BANK COMM
 * CHANGES
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
        04.01.2013 evseev - иин/бин
        04/09/2013 galina - ТЗ1885 добавила формирование платежей по погашению кредита "Астана бонус"
        30/09/2013 galina - ТЗ2117 в платеже по погашению кредита "Астана бонус" указывается ИИН и наименоване клиента
        20/11/2013 madiyar - объединил создание проводки и изменение статуса в одну транзакцию
*/

{nbankBik.i}
def shared var g-today as date.

def var v-bankbin as char.
find sysc where sysc.sysc = "bnkbin" no-lock no-error.
if avail sysc then v-bankbin = sysc.chval.


def buffer b-vita for vita.
def var v-sts as char no-undo.
def var v-rnn as char no-undo.

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display "VITA_ps: There is no record OURBNK in bank.sysc file !!".
   return.
end.
s-ourbank = trim(sysc.chval).

find first cmp no-lock no-error.
if not avail cmp then do:
    display "VITA_ps: There is no cmp record !!".
    return.
end.



def var v-rmz like remtrz.remtrz no-undo.

def var v-templ as char no-undo.
def var s-jh like jh.jh.
def var v-param as char no-undo.
def var vdel as char no-undo initial "^".
def var rcode as int no-undo.
def var rdes as char no-undo.

def var v-err2 as char no-undo.

/* в первую очередь проводим внутр. транзакции с ГК 285440 - следующими операциями с этого счета средства будут забираться */
for each vita where vita.bank = s-ourbank and vita.sts = "new" no-lock:
    v-sts = "trx".
    s-jh = 0.
    v-err2 = ''.
    if vita.trxtype = "jou" then do:
        find first arp where arp.arp = vita.ctAcc no-lock no-error.
        if avail arp and arp.gl = 285440 then do:
            case vita.templ:
                when "jou0036" then v-param = '' + vdel +
                                              string(vita.amt) + vdel +
                                              "1" + vdel +
                                              vita.dtAcc + vdel +
                                              vita.ctAcc + vdel +
                                              vita.rem + vdel +
                                              "1" + vdel +
                                              "1" + vdel +
                                              "840".
                when "uni0004" then v-param = string(vita.amt) + vdel +
                                              "1" + vdel +
                                              vita.dtAcc + vdel +
                                              vita.ctAcc + vdel +
                                              vita.rem + vdel +
                                              "1" + vdel +
                                              "4" + vdel +
                                              "840".
                when "uni0003" then v-param = string(vita.amt) + vdel +
                                              "1" + vdel +
                                              vita.dtAcc + vdel +
                                              vita.ctAcc + vdel +
                                              vita.rem + vdel +
                                              "1" + vdel +
                                              "4" + vdel +
                                              "840".
                when "uni0001" then v-param = string(vita.amt) + vdel +
                                              "1" + vdel +
                                              vita.dtAcc + vdel + '' + vdel + '1' + vdel + '' + vdel +
                                              vita.ctAcc + vdel + '' + vdel + '1' + vdel + '' + vdel +
                                              vita.rem + vdel +
                                              "1" + vdel +
                                              "1" + vdel +
                                              "4" + vdel +
                                              "4" + vdel +
                                              "840".
                otherwise do:
                    v-err2 = "Ошибка идентификации шаблона, проводка не создана!".
                    v-sts = "err".
                end.
            end. /* case */

            do transaction:

                if v-sts = "trx" then do:
                    s-jh = 0.
                    run trxgen (vita.templ, vdel, v-param, "arp", '', output rcode, output rdes, input-output s-jh).
                    if rcode <> 0 then do:
                        v-err2 = rdes.
                        v-sts = "err".
                    end.
                end.


                find b-vita where rowid(b-vita) = rowid(vita) exclusive-lock.
                b-vita.jh = s-jh.
                b-vita.sts = v-sts.
                b-vita.err2 = v-err2.
                find current b-vita no-lock.
            end.
        end.
    end.
end.

for each vita where vita.bank = s-ourbank and vita.sts = "new" no-lock:
    v-sts = "trx".
    s-jh = 0.
    v-err2 = ''.
    if vita.trxtype = "jou" then do:

        case vita.templ:
            when "jou0036" then v-param = '' + vdel +
                                          string(vita.amt) + vdel +
                                          "1" + vdel +
                                          vita.dtAcc + vdel +
                                          vita.ctAcc + vdel +
                                          vita.rem + vdel +
                                          "1" + vdel +
                                          "1" + vdel +
                                          "840".
            when "uni0004" then v-param = string(vita.amt) + vdel +
                                          "1" + vdel +
                                          vita.dtAcc + vdel +
                                          vita.ctAcc + vdel +
                                          vita.rem + vdel +
                                          "1" + vdel +
                                          "4" + vdel +
                                          "840".
            when "uni0003" then v-param = string(vita.amt) + vdel +
                                          "1" + vdel +
                                          vita.dtAcc + vdel +
                                          vita.ctAcc + vdel +
                                          vita.rem + vdel +
                                          "1" + vdel +
                                          "4" + vdel +
                                          "840".
            when "uni0001" then v-param = string(vita.amt) + vdel +
                                          "1" + vdel +
                                          vita.dtAcc + vdel + '' + vdel + '1' + vdel + '' + vdel +
                                          vita.ctAcc + vdel + '' + vdel + '1' + vdel + '' + vdel +
                                          vita.rem + vdel +
                                          "1" + vdel +
                                          "1" + vdel +
                                          "4" + vdel +
                                          "4" + vdel +
                                          "840".
            when "jou0033" then v-param = '' + vdel +
                                          string(vita.amt) + vdel +
                                          "1" + vdel +
                                          vita.dtAcc + vdel +
                                          vita.ctAcc + vdel +
                                          vita.rem + vdel +
                                          "1" + vdel +
                                          "890".

            otherwise do:
                v-err2 = "Ошибка идентификации шаблона, проводка не создана!".
                v-sts = "err".
            end.
        end. /* case */

        do transaction:
            if v-sts = "trx" then do:
                s-jh = 0.
                run trxgen (vita.templ, vdel, v-param, "arp", '', output rcode, output rdes, input-output s-jh).
                if rcode <> 0 then do:
                    v-err2 = rdes.
                    v-sts = "err".
                end.

            end.

            find b-vita where rowid(b-vita) = rowid(vita) exclusive-lock.
            b-vita.jh = s-jh.
            b-vita.sts = v-sts.
            b-vita.err2 = v-err2.
            find current b-vita no-lock.
        end.
    end.
    else
    if vita.trxtype = "rmz" then do:
        v-rmz = ''.
        v-rnn = ''.
        find first txb where txb.bank = vita.bank2 no-lock no-error.
        if avail txb then v-rnn = entry(3,txb.params).

        find first arp where arp.arp = vita.dtAcc no-lock no-error.
        if not avail arp then do:
            v-err2 = "Не найден транзитный счет " + vita.dtAcc + "!".
            v-sts = "err".
        end.

        do transaction:
            if v-sts = "trx" then do:
                /*погашение кредита*/

                if substr(vita.ctAcc,10,4) = '2205' then do:
                    v-nbankru = ''.
                    v-rnn = ''.

                    find first txb where txb.bank =  'TXB' + substr(vita.ctAcc,19,2) no-lock no-error.
                    if avail txb then do:
                        if connected ("txb") then disconnect "txb".
                        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password) no-error.
                        if error-status:error then next.
                        else do:
                            run getcifsname(vita.ctAcc, output v-nbankru).
                            run getcifiin(vita.ctAcc, output v-rnn).
                        end.
                        if connected ("txb") then disconnect "txb".
                    end.
                    run rmzcre (
                                1,
                                vita.amt,
                                vita.dtAcc,
                                v-bankbin, /* rnn */
                                cmp.name,
                                vita.bank2,
                                vita.ctAcc,
                                v-nbankru,
                                v-rnn,
                                '0', /* kbk */
                                no,
                                "890", /* knp */
                                '14', /* kod */
                                '19', /* kbe */
                                vita.rem,
                                '1P',
                                0,
                                5,
                                g-today
                                ).
                end.

                else run rmzcre (
                                 1,
                                 vita.amt,
                                 vita.dtAcc,
                                 v-bankbin, /* rnn */
                                 cmp.name,
                                 vita.bank2,
                                 vita.ctAcc,
                                 v-nbankru,
                                 v-rnn,
                                 '0', /* kbk */
                                 no,
                                 "840", /* knp */
                                 '14', /* kod */
                                 '14', /* kbe */
                                 vita.rem,
                                 '1P',
                                 0,
                                 5,
                                 g-today
                                 ).
                v-rmz = return-value.
            end.

            if v-rmz <> '' then do:
                find first remtrz where remtrz.remtrz = v-rmz exclusive-lock no-error.
                if avail remtrz then do:
                    remtrz.source = 'P'.
                    remtrz.ordins[1] = " ".
                    remtrz.ordins[2] = " ".
                    remtrz.valdt1 = g-today.
                    remtrz.valdt2 = g-today.
                end.
            end.
            find b-vita where rowid(b-vita) = rowid(vita) exclusive-lock.
            b-vita.remtrz = v-rmz.
            b-vita.sts = v-sts.
            b-vita.err2 = v-err2.
            find current b-vita no-lock.
        end.
    end.
end.

