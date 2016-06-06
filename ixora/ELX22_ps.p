
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




    def var kod as char no-undo init 14.
    def var kbe as char no-undo init 16.
    def var knp as char no-undo init 856.


    def var v-trx-atm-acc    as char.          
    def var  v-trx-comm-acc  as char. 
    def var v-comchar        as char.
    def var v-comcode as char init "72".
    def var  v-trx-comm      as deci init 40.


    def var dlm              as char init "|".
    def var rcode            as int.
    def new shared var s-jh like jh.jh.
    def var v-err            as logi init false.
    def var rdes             as char.
    def var v-trx-telecom-acc as char.
    def buffer b-mobi-telecom for mobi-telecom.


    v-trx-telecom-acc = "011999955".


    {elx.i}

    for each mobi-telecom where mobi-telecom.sts = 0 exclusive-lock:

/*      find last b-mobi-telecom where b-mobi-telecom.ref = mobi-telecom.ref and b-mobi-telecom.sts = 1 no-lock no-error. 
        if avail  b-mobi-telecom then next. */


        if is-process-uid(mobi-telecom.uid) then next.


        find sysc where sysc.sysc eq "elecs" no-lock no-error.
        if avail sysc then
           v-trx-comm-acc = sysc.chval.
        else next.

        find first eterminal  where eterminal.terminal-id = mobi-telecom.id no-lock no-error.

        v-trx-atm-acc = eterminal.acc.

        find first tarif2 where tarif2.num + tarif2.kod = '573' and tarif2.stat = 'r' no-lock no-error.
        if avail tarif2 then do:	
           v-trx-comm = tarif2.ost.
        end.
        v-comchar = string(v-trx-comm).

        s-jh = 0.

        run trxgen("opk0028", dlm,
                    string(mobi-telecom.amt )                + dlm +
                    string(v-trx-atm-acc)                    + dlm +
                    string(v-trx-telecom-acc)                + dlm +
                    "Оплата за телефон " + mobi-telecom.acc  + dlm +
                    substring(kod,1,1)                       + dlm +
                    substring(kbe,1,1)                       + dlm +
                    substring(kod,2,1)                       + dlm +
                    substring(kbe,2,1)                       + dlm +
                    knp                                      + dlm +
                    string(mobi-telecom.commis)              + dlm +
                    string(v-trx-atm-acc)                    + dlm +
                    string(v-trx-comm-acc)                   + dlm +
                    "сумма комиссии Контрагента " + v-comchar,
                    "","", output rcode, output rdes, input-output s-jh).

        if rcode ne 0 then do:
           next.
        end.
        else do:
             find jh where jh.jh = s-jh no-lock no-error.
             mobi-telecom.sts = 1.
             mobi-telecom.rdt = jh.jdt.
             mobi-telecom.jh  = s-jh.

             create commonpl.
                    commonpl.date    = jh.jdt.
                    commonpl.counter = integer(substr(mobi-telecom.acc,5, 6)).
                    commonpl.sum     = mobi-telecom.amt.
        	    commonpl.txb     = 0.
                    commonpl.grp     = 17.
                    commonpl.arp     = "011999955".
                    commonpl.uid     = "inbank".
                    commonpl.credate = today.
                    commonpl.cretime = time.
                    commonpl.type    = 1.
                    commonpl.rnnbn   = "600900017520" .
                    commonpl.npl     = "За услуги связи".
                    commonpl.comcode = "".
                    commonpl.dnum    = next-value(kztd).
                    commonpl.rko     =  1.   
       find first uid-jh where uid-jh.uid = mobi-telecom.uid and uid-jh.jh = 0 exclusive-lock no-error. 
       if avail uid-jh then  uid-jh.jh = s-jh.


        end.
    end.



