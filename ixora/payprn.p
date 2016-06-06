/* payprn.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
    01.04.2002 sasco печать банка-посред. для пенсионных
    08.12.2003 sasco МФО берется из таблицы comm.txb
    25.05.2004 kanat если валюта тенге то выводится сумма в тенге, если не в тенге - то выводится сумма с кодом валюты 
                     в платежное поручение.
    02/07/2007 madiyar - убрал упоминание кодов конкретных филиалов
*/


function idx returns int ( str1 as char, str2 as char).
def var i as int init 0.
    i = index(str1, str2).
    if i = 0 then return length(str1) + 1.
    return i.
end.

def shared var s-remtrz like remtrz.remtrz.
find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.

define variable v-bik as char.

find first txb where txb.visible and txb.bank = remtrz.sbank and txb.city = txb.txb no-lock no-error.
if available txb then v-bik = txb.mfo.
                 else v-bik = remtrz.sbank.


OUTPUT TO pla.txt.
    PUT   "ПЛАТЕЖНОЕ ПОРУЧЕНИЕ  # " AT 20 trim(substring(remtrz.sqn,19,8))
    SKIP.
    PUT  STRING(remtrz.rdt,"99/99/99") AT 25  " г." SKIP.
    PUT   "СУММА" AT 60   SKIP.
    PUT FILL("-",70)  FORMAT "x(70)" SKIP.
    PUT   "Отправитель денег:"
          ":" at 35
          "ИИК"  AT 41  
          ":"    at 46
          "КОд"  AT 48
          ":"    at 52 
          remtrz.amt format '>,>>>,>>>,>>9.99' 
          ":" AT 70  SKIP.
    find first sub-cod where sub = "rmz" and acc = remtrz.remtrz 
        and d-cod = "eknp" use-index dcod no-lock no-error.          
    put   ord format 'x(34)'
          ":" at 35
          ":" at 46
          (if avail sub-cod then substring(sub-cod.rcode,1,2) else "")
            format 'x(2)' at 49
          ":" at 52
          ":" at 70 SKIP.
    put   
          substring(ord, 35) format 'x(34)'
          ":" at 35
          sacc format "x(9)" at 36
          ":-----:" at 46
          ":" at 70 SKIP.
    def var rnn as char.      
    rnn = substring(ord,idx(ord,"/RNN/") + 5, 12).
    if rnn = "" then do:
      find first cmp no-lock no-error.
      rnn = cmp.addr[2].
    end.
    PUT "РНН " 
        rnn format 'x(12)'
        ":" at 35
        ":" at 52       
        ":" AT 70 SKIP.
    PUT "Банк-получатель:".    
    PUT ":----------------:" at 35
        ":" AT 70 SKIP.
    find first bankl where bankl.bank = sbank no-lock no-error.
    PUT  bankl.name format "x(34)" 
        ":"   at 35
        "БИК" AT 41
        ":" at 52
        ":" AT 70  SKIP.
    PUT substring(bankl.name, 35) format "x(34)"
        ":" at 35
        v-bik format "x(9)"
        ":" at 52      
        ":" AT 70 SKIP.
    PUT FILL("-",34) FORMAT "x(34)"
        ":----------------:" at 35
        ":" at 70 SKIP.
    PUT  "Бенефициар:"
         ":" at 35
         "ИИК"  AT 41
         ":"    at 46
         "КБе"  AT 48
         ":"    at 52
         ":" AT 70  SKIP.
    put  substring(bn[1],1,idx(bn[1],"/") - 1) format 'x(34)'
         ":" at 35
         ":" at 46
         (if avail sub-cod then substring(sub-cod.rcode,4,2) else "")
            format 'x(2)' at 49
         ":" at 52
         ":" at 70 SKIP.
    put  substring(substring(bn[1],1,idx(bn[1],"/")), 35) format 'x(34)'
         ":" at 35
         substr(remtrz.ba,1,10) format "x(10)" at 36
         ":-----:" at 46
         ":" at 70 SKIP.


    if index(bn[3],"/RNN/") <> 0 then
    PUT "РНН "
         substring(bn[3],idx(bn[3],"/RNN/") + 5) format 'x(12)'
         ":" at 35
         ":" at 52
         ":" AT 70 SKIP.
    else if index(bn[1],"/RNN/") <> 0 then
    PUT "РНН "
         substring(bn[1],idx(bn[1],"/RNN/") + 5) format 'x(12)'
         ":" at 35
         ":" at 52
         ":" AT 70 SKIP.
    else
    PUT "РНН "
         ":" at 35
         ":" at 52
         ":" AT 70 SKIP.


    PUT "Банк бенефициара:".     
    PUT ":----------------:" at 35
        ":" AT 70 SKIP.
    find first bankl where bankl.bank = rbank no-lock no-error.
    PUT  bankl.name format 'x(34)'
        ":" at 35
        "БИК" AT 41
        ":" at 52
        ":" AT 70  SKIP.
    PUT  substring(bankl.name, 35) format 'x(34)'
        ":" at 35
        rbank at 36
        ":" at 52
        ":" AT 70 SKIP.


    PUT  FILL("-",34) format 'x(34)'
         ":" at 35
         FILL("-",34) format 'x(16)' 
         ":" at 52
         ":" AT 70 SKIP.

    def var b-med-bik as char init '190501109'.
    def var b-med-bn as char.
    /* для пенсионных платежей - банк посредник */
    if remtrz.rcvinfo[1] begins '/PSJ/' then
    do:
       if remtrz.intmed <> '' and (not (remtrz.intmed matches '*-*'))
       and length(trim(remtrz.intmed)) = 9 then b-med-bik = trim(remtrz.intmed).

       find first bankl where bankl.bank = b-med-bik no-lock no-error.
       if avail bankl then b-med-bn = bankl.name. else b-med-bn = ''.

    PUT  "Банк-посредник:"
        ":" at 35
        "БИК" AT 41
        ":" at 52
        ":" AT 70  SKIP

        substring(b-med-bn,1,34) format "x(34)"
        ":" at 35
        b-med-bik format "x(9)"
        ":" at 52
        ":" AT 70  SKIP.
    if length(b-med-bn) > 34 then
    put substring(b-med-bn,35,34) format "x(34)"
        ":" at 35
        ":" at 52
        ":" AT 70  SKIP.

    PUT FILL("-",70)  FORMAT "x(70)" SKIP.
    end.

    def var sum as char.
    run Sm-vrd(amt, output sum).



    if remtrz.tcrc = 1 then do:
    sum = sum + " тенге " + 
    string((if (amt - integer(amt)) < 0 then 1 + (amt - integer(amt)) else
    (amt - integer(amt))) * 100, "99") + " тиын".
    end.
    else do:
    find first crc where crc = remtrz.tcrc no-lock no-error.
    if avail crc then do:
    sum = sum + string((if (amt - integer(amt)) < 0 then 1 + (amt - integer(amt)) else
    (amt - integer(amt))) * 100, "99") + " " + crc.code.
    end.
    end.



    PUT "Сумма прописью: " sum FORMAT "x(52)"  ":" AT 70 SKIP.
    PUT substring(sum, 53) FORMAT "x(68)"  ":" AT 70 SKIP.

    PUT FILL("-",25)  FORMAT "x(25)" at 45 
        ":" AT 70 SKIP.
    put "Дата получения товара (оказания услуг)"
        ":" at 44
        "Код назначения" at 45
        ":" at 59
        (if avail sub-cod then substring(sub-cod.rcode,7,3) else "")
            format 'x(3)' at 62
        ":" AT 70 SKIP.
    put "" format 'x(12)'
            ":" at 44
            "платежа       " at 45
            ":" at 59
            ":" AT 70 SKIP.
    PUT "Назначение платежа:"
        ":" at 44
        FILL("-",25)  FORMAT "x(25)" at 45
        ":" AT 70 SKIP.
    PUT detpay[1] format 'x(43)'
        ":" at 44
        "Код бюджетной " at 45
        ":" at 59
        if substring(trim(remtrz.ba), length(trim(remtrz.ba)) - 6, 1) = "/" then
          substring(trim(remtrz.ba), length(trim(remtrz.ba)) - 5, 6) else "      "
          format 'x(6)' at 62
        ":" AT 70 SKIP.
    PUT detpay[2] format 'x(43)'  
        ":" at 44
        "классификации " at 45
        ":" at 59
        ":" AT 70 SKIP.
    PUT detpay[3] format 'x(43)'
        FILL("-",25)  FORMAT "x(25)" at 45
        ":" AT 70 SKIP.
    PUT detpay[4] format 'x(43)'  
        ":" at 44
        "Дата          " at 45
        ":" at 59
        string(remtrz.valdt1) format 'x(10)' at 60
        ":" AT 70 SKIP.
    PUT "" format 'x(43)'       
        ":" at 44
        "валютирования " at 45
        ":" at 59
        ":" AT 70 SKIP.
    PUT FILL("-",70)  FORMAT "x(70)" SKIP.
    PUT "Проведено банком-получателем"  at 40  SKIP.
    PUT "М.П." AT 7    SKIP.    
    PUT "Подписи клиента" AT 3 "Подписи банка" AT 48 sKIP.
    PUT CHR(13) FORMAT "x(1)".
    PUT CHR(10) FORMAT "x(1)".
OUTPUT CLOSE.

unix silent prit pla.txt.        
