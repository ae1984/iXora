
/* ELX06_ps.p
 * BASES
        -bank -comm
 * MODULE
        Elecsnet
 * DESCRIPTION
        Проведение оплаты по платежам KCELL
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

    def var v-trx-amount     as decimal.
    def var dlm              as char init "|".
    def var rcode            as int.
    def new shared var s-jh like jh.jh.
    def var v-err            as logi init false.
    def var rdes             as char.
    def var  v-trx-k-cell-acc as char.          /* счет k-cell                                      */
    def buffer b-mobi-kcell for mobi-kcell.


    v-trx-k-cell-acc = "019467476".

    {elx.i}


    for each mobi-kcell where mobi-kcell.sts = 0 exclusive-lock:
        find last b-mobi-kcell where b-mobi-kcell.ref =  mobi-kcell.ref and b-mobi-kcell.sts = 1 no-lock no-error. 
        if avail  b-mobi-kcell then next.


if is-process-uid(mobi-kcell.uid) then next.




        find sysc where sysc.sysc eq "elecs" no-lock no-error.
        if avail sysc then
           v-trx-comm-acc = sysc.chval.
        else next.
        find first eterminal  where eterminal.terminal-id = mobi-kcell.trade_point no-lock no-error.
        v-trx-atm-acc = eterminal.acc.
        v-trx-comm = comm-payment (mobi-kcell.amount + mobi-kcell.comm, v-comcode, "5", v-comchar).

        s-jh = 0.
        run trxgen("opk0027", dlm,                      
                    string(mobi-kcell.amount)  + dlm +
                    string(v-trx-atm-acc)               + dlm +
                    string(v-trx-k-cell-acc)               + dlm +
                    "на сумму пополнения телефона " + mobi-kcell.msisdn + dlm +
                    substring(v-kod,1,1) + dlm +
                    substring(v-kbe,1,1) + dlm +
                    substring(v-kod,2,1) + dlm +
                    substring(v-kbe,2,1) + dlm +
                    v-knp  + dlm  +
                    string(mobi-kcell.comm)                  + dlm +
                    string(v-trx-atm-acc)               + dlm +
                    string(v-trx-comm-acc)              + dlm +
                    "сумму комиссии Контрагента " + v-comchar,
                    "","", output rcode, output rdes, input-output s-jh).
                    if rcode ne 0 then do:
                       next.
                    end.
                    else do:
                         find jh where jh.jh = s-jh no-lock no-error.
                         mobi-kcell.sts = 1.
                         mobi-kcell.receipt_num  = string(s-jh).    
                         mobi-kcell.commit_date  = jh.jdt.
                         mobi-kcell.commit_time  = jh.tim.          

                         create mobtemp.
                         assign  
                         mobtemp.valdate  = today
                         mobtemp.cdate   = today
                         mobtemp.ctime   = time
                         mobtemp.sum     = mobi-kcell.amount
                         mobtemp.who     = "inbank"
                         mobtemp.state   = 3
                         mobtemp.phone   = mobi-kcell.msisdn
                         mobtemp.ref     = mobi-kcell.ref
                         mobtemp.joudoc  = string(s-jh)	
                         mobtemp.rid     = 0
                         mobtemp.npl     = "Платеж за телефон " + mobi-kcell.msisdn + " " + string(today).


  find first uid-jh where uid-jh.uid = mobi-kcell.uid and uid-jh.jh = 0 exclusive-lock no-error. 
  if avail uid-jh then  uid-jh.jh = s-jh.





                    end.
    end.









