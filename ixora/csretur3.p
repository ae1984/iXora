/* csretur3.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Погашение аванса кассирам крупных РКО - обменник по 100200, все валюты
 * RUN
        
 * CALLER

 * SCRIPT
        
 * INHERIT

 * MENU
        
 * AUTHOR
        02/02/04 sasco
 * CHANGES
        26/03/04 sasco Изменил текстовку назначения платежа
        31/03/04 sasco Количество кассовых ордеров = 0
*/



define variable v-crc as integer initial 1.

update v-crc format "z9" label "Введите код валюты" 
       with row 2 centered overlay side-labels frame getcrc.
hide frame v-crc.



{csreturn.i

 &LABEL = "Подотчет"
 
 &FORMAT = "zzz,zzz,zz9.99"
 
 &SYSC = "CASDP3"
 
 &CRC = v-crc
 
 &LOOKUP_SYSC = " if lookup (trim(string(v-dep, ""zzz9"")), sysc.chval) = 0 then next. "
 
 &SUB-COD = "obmen1002"

 &ARP_DESCR = "подотчет для обменных операций"

 &SUM = 0
 
 &ASKSUM = "no"

 &TRANSACTION = "
      if not comm-arp (tmp.arp, tmp.sum) then next.
      run trx (
               5,
               tmp.sum,
               v-crc,
               '100100',
               '',
               '',
               tmp.arp,
               'Наличные деньги ' + trim(tmp.rko) + ', ' + trim(tmp.fio),
               '14',
               '14',
               '890'
              ).
              "

 &CAS_SYMB = "260"

 &NUM_ORDERS = "0"

}

