
/* ELX06_ps.p
 * BASES
        -bank -comm
 * MODULE
        Elecsnet
 * DESCRIPTION
        Проведение оплаты по платежам K-MOBILE
 * MENU
 
 * AUTHOR
        25/12/2006 u00124
*/



    def var v-kod as char no-undo init 19.
    def var v-kbe as char no-undo init 16.
    def var v-knp as char no-undo init 890.


    def var v-trx-atm-acc    as char.          
    def var  v-trx-comm-acc  as char. 
    def var v-comchar        as char.
           def var v-comcode as char init "72".
    def var  v-trx-comm      as deci init 40.
    def var v-trx-almatv-acc as char.
    def var v-trx-amount     as decimal.
    def var dlm              as char init "|".
    def var rcode            as int.
    def new shared var s-jh like jh.jh.
    def var v-err            as logi init false.
    def var rdes             as char.
    def var v-trx-k-mobile-acc as char.
    def buffer b-mobi-beeline for mobi-beeline.


    v-trx-k-mobile-acc = "011999832".



    {elx.i}

    for each mobi-beeline where mobi-beeline.sts = 0 exclusive-lock:

/*      find last b-mobi-pay where b-mobi-pay.ref = mobi-pay.ref and b-mobi-pay.sts = 1 no-lock no-error. 
        if avail  b-mobi-pay then next.  */


        if is-process-uid(mobi-beeline.uid) then next.




        find sysc where sysc.sysc eq "elecs" no-lock no-error.
        if avail sysc then
           v-trx-comm-acc = sysc.chval.
        else next.

        find first eterminal  where eterminal.terminal-id = mobi-beeline.trade_point  no-lock no-error.
        v-trx-atm-acc = eterminal.acc.
        v-trx-comm =  comm-payment (mobi-beeline.amount + mobi-beeline.comm, v-comcode, "5", v-comchar).



        s-jh = 0.
        run trxgen("opk0028", dlm,                      
                    string(mobi-beeline.amount)                  + dlm +
                    string(v-trx-atm-acc)                    + dlm +
                    string(v-trx-k-mobile-acc)               + dlm +
                    "на сумму пополнения телефона " + mobi-beeline.msisdn + dlm +
                    substring(v-kod,1,1)                     + dlm +
                    substring(v-kbe,1,1)                     + dlm +
                    substring(v-kod,2,1)                     + dlm +
                    substring(v-kbe,2,1)                     + dlm +
                    v-knp                                    + dlm  +
                    string(mobi-beeline.comm)                    + dlm +
                    string(v-trx-atm-acc)                    + dlm +
                    string(v-trx-comm-acc)                   + dlm +
                    "сумму комиссии Контрагента " + v-comchar ,
                    "","", output rcode, output rdes, input-output s-jh).
                    if rcode ne 0 then do:
                       next.
                    end.  
                    else do:
                         find jh where jh.jh = s-jh no-lock no-error.
                         mobi-beeline.sts         = 1.
                         mobi-beeline.receipt_num = string(s-jh).
                         mobi-beeline.commit_date = jh.jdt.
                         mobi-beeline.commit_time  = jh.tim. 
      find first uid-jh where uid-jh.uid = mobi-beeline.uid and uid-jh.jh = 0 exclusive-lock no-error. 
      if avail uid-jh then  uid-jh.jh = s-jh.

                    end.
    end.









