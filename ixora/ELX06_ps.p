
/* ELX06_ps.p
 * BASES
        -bank -comm
 * MODULE
        Elecsnet
 * DESCRIPTION
        Проведение оплаты по платежам АЛМА-ТВ
 * MENU
 
 * AUTHOR
        25/12/2006 u00124
*/



    def var kod as char no-undo init 14.
    def var kbe as char no-undo init 16.
    def var knp as char no-undo init 856.
    def var v-trx-atm-acc    as char.          
    def var  v-trx-comm-acc  as char. 
    def var v-comchar        as char.
    def var v-comcode        as char init "74".
    def var  v-trx-comm      as deci init 40.
    def var v-trx-almatv-acc as char.
    def var v-trx-amount     as decimal.
    def var dlm              as char init "|".
    def var rcode            as int.
    def new shared var s-jh like jh.jh.
    def var v-err            as logi init false.
    def var rdes             as char.
    def buffer b-mobi-almatv for mobi-almatv.

    {elx.i}

    for each mobi-almatv where mobi-almatv.sts = 0 exclusive-lock:


        if is-process-uid(mobi-almatv.uid) then next.


        find sysc where sysc.sysc eq "elecs" no-lock no-error.
        if avail sysc then
           v-trx-comm-acc = sysc.chval.
        else next.

        find first eterminal  where eterminal.terminal-id = mobi-almatv.id no-lock no-error.
        v-trx-atm-acc = eterminal.acc. 

        v-trx-almatv-acc = "011999230". 
        v-trx-comm = comm-payment (v-trx-amount, v-comcode, "5", v-comchar).

        run trxgen("opk0028", dlm,
                    string(mobi-almatv.amt)                                          + dlm +
                    string(v-trx-atm-acc)                                            + dlm +
                    string(v-trx-almatv-acc)                                         + dlm +
                    "на сумму пополнения счета в АлмаТВ N "  + mobi-almatv.contract  + dlm +
                    substring(kod,1,1)                                               + dlm +
                    substring(kbe,1,1)                                               + dlm +
                    substring(kod,2,1)                                               + dlm +
                    substring(kbe,2,1)                                               + dlm +
                    knp                                                              + dlm +
                    string(mobi-almatv.commis)                                       + dlm +
                    string(v-trx-atm-acc)                                            + dlm +
                    string(v-trx-comm-acc)                                           + dlm +
                    "сумму комиссии Контрагента " + v-comchar,
                    "","", output rcode, output rdes, input-output s-jh).
                    if rcode ne 0 then do:
                       next.
                    end.
                    else do:
                        find jh where jh.jh = s-jh no-lock no-error.
                         mobi-almatv.sts = 1. 
                         mobi-almatv.rdt = jh.jdt.
                         mobi-almatv.jh  = s-jh.
                         mobi-almatv.dt  = jh.jdt.
      find first uid-jh where uid-jh.uid = mobi-almatv.uid and uid-jh.jh = 0 exclusive-lock no-error. 
      if avail uid-jh then  uid-jh.jh = s-jh.

                    end.
    end.









