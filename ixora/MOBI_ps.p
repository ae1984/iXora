/* MOBI_ps.p
 * MODULE
        Элекснет
 * DESCRIPTION
        Отправка сверочной информации
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        6-1 
 * AUTHOR
        17/03/06 tsoy
 * CHANGES
        19/06/06 tsoy добавил парметр silent
        27/06/06 tsoy добавил менеджера биллинга в расылку
        05/05/06 tsoy изменил mail с kartel на beeline 
        07/06/06 tsoy изменил commit date на paydate 
	24.06.2006 tsoy отправка платежа с АРП в АТФ
	28.06.2006 tsoy поменял today na rdt
	03.07.2006 tsoy проверка на наличие денег на арп

*/

{global.i}
{lgps.i "new"}

m_pid = "MOBI_ps" .
u_pid = "MOBI_ps".

def var v-remtrz as char.

def var v-file as char no-undo. 
def var v-dt   as date no-undo. 
def var v-dt1  as date no-undo. 
def var v-dt2  as date no-undo. 

def var v-amt       as deci no-undo. 
def var v-cnt       as integer no-undo. 
def var v-cnt-bnk   as integer no-undo. 
def var v-cnt-cash  as integer no-undo. 
def var v-rem       as char no-undo. 

def var rcode as int. 
def var rdes  as cha. 
def var dlm as char init "|" .  

def var s-jh like jh.jh.  

find last kmob-snd-jh use-index rdt  no-lock no-error . 

if avail kmob-snd-jh then do:

       if kmob-snd-jh.rdt > today - 1 then 
            return.
       else
            v-dt1 = kmob-snd-jh.rdt + 1.
end.
else
v-dt1 = today - 1.
 

v-dt2 = today - 1.

v-dt1 = today.
v-dt2 = today.

do v-dt = v-dt1 to v-dt2:

        v-file = "RKC_" + string(v-dt,"99.99.9999") + ".txt".

        find first mobi-pay where mobi-pay.pay_date = v-dt no-lock no-error. 
        if not avail mobi-pay then do:
            next.                                                                       	
        end.

        output to value (v-file).

        v-amt = 0. 
        v-cnt      =  0.
        v-cnt-bnk  =  0.
        v-cnt-cash =  0.

        for each mobi-pay where mobi-pay.pay_date  =  v-dt no-lock:

            v-amt = v-amt + mobi-pay.amount.
            v-cnt =  v-cnt + 1.

            if mobi-pay.pay_src_id = "2" then v-cnt-bnk  = v-cnt-bnk  + 1.
            if mobi-pay.pay_src_id = "4" then v-cnt-cash = v-cnt-cash + 1.            

/*            put unformatted string(mobi-pay.creator_uid) ";".  */
            put unformatted string("RKC") ";".
            put unformatted mobi-pay.msisdn              ";".
            put unformatted string(mobi-pay.amount)      ";".
            put unformatted string(mobi-pay.pay_date, "99.99.9999" ) ";".
            put unformatted string(mobi-pay.pay_id)        ";".    
            put unformatted string(mobi-pay.receipt_num)  ";".    
            put unformatted string(mobi-pay.commit_date, "99.99.9999")  " ".
            put unformatted string(mobi-pay.commit_time, "HH:MM:SS") ";".
            put unformatted string(mobi-pay.pay_src_id) ";".  
/*            put unformatted string(mobi-pay.branch)       ";".*/


            put unformatted string("ALARKC00")       ";". 
            put unformatted string(mobi-pay.trade_point) ";". 
            put unformatted string(v-file)      ";" skip.    

        end.

        output close.
        v-text = 'Сформирован файл  ' + v-file.
        run lgps.

        find first comm.commonls where comm.commonls.txb     = 0 and 
                                       comm.commonls.grp     = 4 and
                                       comm.commonls.type    = 2 and 
                                       comm.commonls.visible = yes 
                                       no-lock no-error.

       v-rem = "За платежи клиентов. за " + string(v-dt) + ". Всего  " + string(v-cnt-cash) + " ТОО Расчетно-кассовый центр 1" .                    


       


       

        
        v-text = 'Сформирован платеж ' + v-remtrz + " " + v-rem.
        run lgps.

        create kmob-snd-jh.
               kmob-snd-jh.rdt  = v-dt.
               kmob-snd-jh.amt  = v-amt.
               kmob-snd-jh.rtim = time.                    
               kmob-snd-jh.rem  = "Отправка платежа единой суммой Картел. Всего " + string(v-cnt-bnk) + " ТОО Расчетно-кассовый центр 1" + v-remtrz.                    
               kmob-snd-jh.jh   = s-jh.

/*
        unix silent value("scp -q " + v-file + " transfer@192.168.2.3:\~/. " ). 
        unix silent  value("ssh transfer@192.168.2.3 ./expect_ex " + v-file).   
*/

        unix silent  value("expect /pragma/bin9/expect_ex " + v-file).   

        v-text = 'Сформирован файл и отправлен ' + v-file.
        run lgps.

        unix value("rm " + v-file). 

        v-file = "RKC_" + string(v-dt,"99.99.9999") .

        output to value (v-file) .
        for each mobi-pay where mobi-pay.pay_date  =  v-dt no-lock:
            put unformatted string(mobi-pay.pay_src_id) ";".  
            put unformatted mobi-pay.msisdn              ";".
            put unformatted string(mobi-pay.amount)      ";".
            put unformatted string(mobi-pay.commit_date, "99.99.9999")  " ".
            put unformatted string(mobi-pay.commit_time, "HH:MM:SS") ";".
            put unformatted string(mobi-pay.comm) ";" skip.
        end.
        output close.


        unix silent value("rcode " + v-file + " " + v-file + ".csv"  + " -kw > /dev/null"). 


        run mail  ( "denis@metrobank.kz", 
                    "РКЦ-1 <>", 
                    "РКЦ-1. Сверочный файл ", 
                    "См. вложение." , 
                    "1", 
                    "", 
                    v-file + ".csv"
                  ).

/*      run mail  ( "reestr@beeline.kz;denis@metrobank.kz;MSarieva@beeline.kz", 
                    "РКЦ-1 <>", 
                    "РКЦ-1. Сверочный файл ", 
                    "См. вложение." , 
                    "1", 
                    "", 
                    v-file + ".csv"
                  ). */

  

end.





