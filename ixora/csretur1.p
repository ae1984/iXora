/* csretur1.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Погашение аванса кассирам РКО - монеты
 * RUN
        
 * CALLER

 * SCRIPT
        
 * INHERIT

 * MENU
        
 * AUTHOR
        29/01/04 sasco
 * CHANGES
        03/02/04 sasco Добавил проверку на остаток на АРП счете
        05/02/04 sasco Добавил код валюты через &CRC
*/


{csreturn.i

 &LABEL = "Монеты"
 
 &FORMAT = "zz,zz9.99"
 
 &SYSC = "CASDP1"
 
 &CRC = 1
 
 &LOOKUP_SYSC = " if lookup (trim(string(v-dep, ""zzz9"")), sysc.chval) > 0 then next. "
 
 &SUB-COD = "podot1003"

 &ARP_DESCR = "подотчет для сберкассы"

 &SUM = 8600
 
 &ASKSUM = "yes"

 &TRANSACTION = "
      if not comm-arp (tmp.arp, tmp.sum) then next.
      run trx (
               5,
               tmp.sum,
               1,
               '100100',
               '',
               '',
               tmp.arp,
               'Погашение подотчетной суммы, ' + tmp.fio,
               '14',
               '14',
               '890'
              ).
              "

 &CAS_SYMB = "260"

 &NUM_ORDERS = "1"

}

