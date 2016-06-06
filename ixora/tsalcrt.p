/* org-csv.p
 * MODULE
         Пластиковые Карточки - Зарплатные проекты

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
        18/01/05 tsoy
 * CHANGES
        18/03/05 tsoy новый шаблон
        04/10/06 tsoy Если с филиала то не проводка а два платежа на сумму зачисление и сумму комссии
*/
{lgps.i}
{comm-txb.i}

def input  parameter p-remtrz like remtrz.remtrz.
def output parameter p-rez as logical.

def var crd_file as char.
def var v-rem-a as char.
def var v-rem-b as char.

def var v-amt-alm-acc  as char.
def var v-comm-alm-acc as char.

def var v-comcomp as logical.

def var v-comm as deci.
def var v-amt  as deci.
def var v-bacc  as char.

def var v-cif    as char.
def var v-cifjss as char.

def new shared temp-table cpay
           field card     as char format "x(18)"  /* N карт              */
           field sum      like jl.dam             /* Сумма к зачисл      */
           field crc      as char format "x(3)"   /* валюта              */
           field trxdes   as char                 /* описание транзакции */
           field batchdes as char                 /* описание батча      */
           field messtype as char.                /* тип зачисления      */

def var outname  as char.
def var outname1 as char.

def var str as char.

def var cnt as int.
def var cnti as int.

def var v-crc like crc.crc.

def var v-crccode as char.

def var v-hash as char.

def var endof as log.

def var v-tot-amt   as deci.
def var v-tot-amtbt as deci.

def var vbal     as decimal.
def var v-ok     as logical.

def var wascrc as logical init no. /* была ли последняя строка с валютой */
def var wasbt  as logical init no. /* была ли последняя строка с итогом  */
def var filehead as char extent 3.

def var v-templ as char.
def var v-param as char.
def var vdel as char initial "^".
def var rcode as int.
def var rdes as char.
def new shared var s-jh like jh.jh.

def temp-table tmp
           field num      as integer              /* N                   */
           field card     as char                 /* N карт              */
           field fio      as char                 /* ФИО                 */
           field sum      like jl.dam             /* Сумма к зачисл      */
           field crc      as char                 /* валюта              */
           field crccode  as char                 /* валюта              */
           field trxdes   as char                 /* описание транзакции */
           field sts      as char                 /* код статус          */
           field stsname  as char.                /* название статус     */

p-rez = true.
find remtrz where remtrz.remtrz = p-remtrz no-lock no-error.

if avail remtrz and remtrz.source = "IBH"  then do:

    find ib.doc where ib.doc.remtrz = remtrz.remtrz no-lock no-error. 
    
        if avail ib.doc and ib.doc.type = 1 and ib.doc.subtype = 4 then do: 

                define var bwxpath as char.

                bwxpath = "NTMAIN:L:\\Users\\Departments\\Bwx\\repl\\in\\".

                find sysc where sysc.sysc = "CRDSLR" no-lock no-error.
                if avail sysc then bwxpath = TRIM (sysc.chval).
                else do :
                          v-text = "PD CRD : Не найдена переменная CRDSLR в таблице SYSC ".
                          run lgps. 
                          p-rez = false.
                          return.
                     end.


                find first sysc where sysc.sysc = "CRDIN" no-lock.
                if avail sysc then crd_file = trim(sysc.chval) + trim(ib.doc.remtrz).

                if not avail sysc then do:
                   v-text = "PD CRD : Ошибка настроек при анализе файла Зарпл. проекта ".
                   p-rez = false.
                   run lgps. 
                   return.
                end.

                input from value (crd_file).

                import unformatted str no-error.

                    /* обработка строк файла */
                    if num-entries( str, ";" ) > 2  then do:
                        filehead[1] = trim(entry(1, str, ";")).
                        {crd-csv.i}
                    end. else do:
                        {crd-txt.i}             
                    end.                    

                input close.       
 
                v-comcomp = true.
                
                find first salary_set where salary_set.cif = doc.cif no-lock no-error.
                if avail salary_set then do:
                     if salary_set.com = 2 then do:
                         v-comcomp = false.
                     end.
                end. else do:
                   v-text = "PD CRD : Не найдена настройка для  клиента  " + doc.cif + " Платеж: " +  remtrz.remtrz. 
                   p-rez = false.
                   run lgps. 
                   return.
                end.

                for each tmp break by tmp.sts by tmp.num:

                      create cpay.                                            
                           cpay.card      = tmp.card .   
                           cpay.crc       = tmp.crccode  .   
                           cpay.trxdes    = "TRANSFER FROM EMPLOYER" .
                           cpay.batchdes  = "TRANSFER FROM EMPLOYER" .
                           cpay.messtype  = "PAYSAL".

                           if v-comcomp then do:      
                               cpay.sum       = tmp.sum.    
                           end. else do:      /* Комиссию оплачивает сотрудник */
                               cpay.sum       = tmp.sum - (tmp.sum * salary_set.prc / 100).    
                           end.

                           v-tot-amt = v-tot-amt + cpay.sum.
                end.                     
                                         
                run crdpaygen (output outname).

                v-text =  "PD CRD : FILE WAS CREATED " + outname .
                run lgps.

                /* если все нормально то формируем 2 проводки Дт 908 Кр 460813 Дт 908 Кт 505*/
                /*расчитаем комиссию */
                 v-comm = 0.

                 v-comm = remtrz.amt - v-tot-amt.

                 if v-crccode = "KZT" then v-crc  = 1.
                 if v-crccode = "USD" then v-crc  = 2.

                 v-amt = v-tot-amt.

                 find sysc where sysc.sysc = "CRDKZT" no-lock no-error.
                 if avail sysc then v-bacc = entry(2,sysc.chval).

                 if v-crccode = "USD" then do:     
                     find sysc where sysc.sysc = "CRDUSD" no-lock no-error.
                     if avail sysc then v-bacc = entry(2,sysc.chval).
                 end.

                 v-param = string(v-comm)       + vdel + /* Cумма комиссии */
                           string(remtrz.cracc) + vdel + /* Счет для поплнения платежей через Интернет */
                           string(v-amt)        + vdel + /* Сумма по спискам */
                           string(v-bacc).             /* ARP счет для зп на карточки */  

                 s-jh = 0.

                 /*Если Алмата то проволддка  на 904 */
                 if comm-txb() = "TXB00" then do:

                    run trxgen("opk0022", vdel, v-param,"","",output rcode,output rdes, input-output s-jh ).
                    if rcode ne 0 then do:
                        v-text = rdes.
                        run lgps. 
                        p-rez = false.
                        return.
                    end.

                    v-text = "PD CRD : Создана проводка  N " + string(s-jh)  + " Платеж: " + p-remtrz .
                    run lgps. 

                 end. else do:


                               
                               find sysc where sysc.sysc  = "CRDKZTALM" no-lock no-error.
                                  v-amt-alm-acc   = entry(1,sysc.chval).
                                  v-comm-alm-acc  = entry(2,sysc.chval).

                                if v-crccode = "USD" then do:     
                                   
                                   find sysc where sysc.sysc  = "CRDUSDALM" no-lock no-error.
                                      v-amt-alm-acc   = entry(1,sysc.chval).
                                      v-comm-alm-acc  = entry(2,sysc.chval).
                                end.



                                 find aaa where aaa.aaa = remtrz.dracc  no-lock no-error.
                                 if avail aaa then do:
                                    find cif where cif.cif = aaa.cif no-lock no-error.
                                    if avail cif then 
                                        v-cif    = cif.name.
                                        v-cifjss = cif.jss.
                                 end.

                                 /* Делаем 2 платежа на Алмату */

                                 /* На сумму комиссии  */

                                 run commpl(
                                 	time,                                                        /*  1 Номер документа */                           
                                 	v-comm,                                                      /*  2 Сумма платежа */                             
                                 	remtrz.cracc,                                                /*  3 Счет отправителя т.е. АРП счет */            
                                 	"TXB00",                                                     /*  4 Банк получателя */                           
                                 	v-comm-alm-acc,                                                 /*  5 Счет получателя */                           
                                 	0,                                                           /*  6 КБК */                                       
                                 	no,                                                          /*  7 Тип бюджета - проверяется если есть КБК */   
                                 	"Сч.для авт.пополнения карт/сч",                             /*  8 Бенефициар */                                
                                 	"600900050984",                                              /*  9 РНН Бенефициара */                           
                                 	"311",                                                       /* 10 KNP */                                       
                                 	"19",                                                        /* 11 Kod */                                       
                                 	"14",                                                        /* 12 Kbe */                                       
                                 	"Пополнение карт. счетов ЗП проект, сумма комиссии " + remtrz.remtrz +       /* 13 Назначение платежа */                        
                                 	"~nКлиент : " + string(remtrz.ord),                                  
                                 	"1P",                                                        /* 14 Код очереди */                               
                                 	0,                                                           /* 15 Кол-во экз. */                               
                                 	5,                                                           /* 16 remtrz.cover (для проверки даты валютирования т.е. 1-CLEAR00 или 2-SGROSS00) */            
                                 	v-cifjss,                                                    /* 17 РНН отправителя */                                                                              
                                 	v-cif,                                                       /* 18 ФИО отпр. если не найдено в базе RNN */      
                                        today                                                      /*19 параметр даты факт приема платежа marinav*/
                                 ).                                                               
                                 v-rem-a = return-value.


                                 /* На сумму пополнения  */

                                 run commpl(
                                 	time,                                                        /*  1 Номер документа */                           
                                 	v-amt,                                                       /*  2 Сумма платежа */                             
                                 	remtrz.cracc,                                                /*  3 Счет отправителя т.е. АРП счет */            
                                 	"TXB00",                                                     /*  4 Банк получателя */                           
                                 	v-amt-alm-acc,                                                 /*  5 Счет получателя */                           
                                 	0,                                                           /*  6 КБК */                                       
                                 	no,                                                          /*  7 Тип бюджета - проверяется если есть КБК */   
                                 	"Сч.для авт.пополнения карт/сч",                             /*  8 Бенефициар */                                
                                 	"600900050984",                                              /*  9 РНН Бенефициара */                           
                                 	"311",                                                       /* 10 KNP */                                       
                                 	"19",                                                        /* 11 Kod */                                       
                                 	"14",                                                        /* 12 Kbe */                                       
                                 	"Пополнение карт. счетов ЗП проект " + remtrz.remtrz +       /* 13 Назначение платежа */                        
                                 	"~nКлиент : " + string(remtrz.ord),                                                              
                                 	"1P",                                                        /* 14 Код очереди */                               
                                 	0,                                                           /* 15 Кол-во экз. */                               
                                 	5,                                                           /* 16 remtrz.cover (для проверки даты валютирования т.е. 1-CLEAR00 или 2-SGROSS00) */            
                                 	v-cifjss,                                                    /* 17 РНН отправителя */                                                                              
                                 	v-cif,                                                       /* 18 ФИО отпр. если не найдено в базе RNN */      
                                        today                                                      /*19 параметр даты факт приема платежа marinav*/
                                 ).                                                               
                                 
                                 v-rem-b = return-value.
                                 

                                 find remtrz where  remtrz.remtrz = v-rem-a exclusive-lock no-error.
                                 if avail  remtrz then do:
                                       remtrz.rsub = "arp".
                                       remtrz.rcvinfo[1] = "CRDZPCOMMFILL-IBH".
 
                                 end.
                                 find remtrz where  remtrz.remtrz =  v-rem-a no-lock no-error.

                                 v-text = "PD CRD : Создан Платеж на Алмату на сумму комиссии " + p-remtrz + " -> " + v-rem-a.
                                 run lgps. 

                                 find remtrz where  remtrz.remtrz = v-rem-b exclusive-lock no-error.
                                 if avail  remtrz then do:
                                       remtrz.rsub = "arp".
                                       remtrz.rcvinfo[1] = "CRDZPFILL-IBH".
                                 end.
                                 find remtrz where  remtrz.remtrz =  v-rem-b no-lock no-error.

                                 v-text = "PD CRD : Создан Платеж на Алмату на сумму основного платежа " + p-remtrz + " -> " + v-rem-b.
                                 run lgps. 


                 end.
              
                /* копирование файла в архив */
                str = crd_file + "." +
                      string(day(today),"99") + string(month(today),"99") +
                      string(year(today),"9999") + "-" + string(time).

                unix silent value ("cp " + crd_file + " " + str).

                /* Выкладываем файл */
                unix silent value ("rcp " + outname + " " + bwxpath).
                
                v-text =  "PD CRD : FILE WAS COPY to BWX " + outname + " Платеж: " +  p-remtrz.
                run lgps. 

                /* скопируем исходный файл */
                unix silent value ("staffcrd " + str).

                /* скопируем файл со списком для BWX */
                outname1 = outname + "." + string(time).
                unix silent value ("cp " + outname + " " + outname1).
                unix silent value ("staffcrd " + outname1).


                unix silent value ("rm -f " + outname).
                unix silent value ("rm -f " + str).

                output through 'mail' value( ' -s ' + '"CRD:WASCREATED ' + trim(remtrz.remtrz) + '" ' + ' it@elexnet.kz,salary@elexnet.kz' ).
                                             put unformatted '' skip(1) 
                                             "id-doc = "  string(doc.id,"9999999")  skip
                                             "RMZ = " trim(ib.doc.remtrz) skip(1)
                                             v-text.
                output close.

        end.

end.

