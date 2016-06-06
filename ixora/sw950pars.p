/* sw950pars.p
 * MODULE
        Валютный монитор        
 * DESCRIPTION
        Валютный монитор
 RUN
 * CALLER
        стандартные для процессов
 * SCRIPT
        стандартные для процессов
 * INHERIT
        стандартные для процессов
 * MENU
        5.1
 * AUTHOR
        18.06.2004 tsoy
 * CHANGES
        29.06.2004 tsoy добавил сохранение признака Первичного остатка.
        01.07.2004 tsoy исправления в обработке поля 60F.
        31.08.2004 tsoy проверять файлы выписок только за последни 5 дней
        08.10.2004 tsoy добавил дату с до которой ичкать уникальные выписки

*/

def var v-result as char.
def var s  as char init ''.
def var v-str  as char init ''.
def var v-ref  as char init ''.

def var v-dts  as char.
def var v-dt   as date.

def var v-crcs  as char.
def var v-crci   as integer.


def var v-date as logical.

def var v-dateh as date.

define stream m-cpfl.
define stream m-infl.
define stream m-cpfldl.

def var v-ln as logical init no.

def var v-type as char.
def var v-tti as char.

def var v-id as integer.

def var v-time as integer.

def var v-lst as char init "BOE,BRF,CHG,CHK,CLR,CMI,CMN,CMS,CMT,CMZ,COL,COM,DCR,DDT,
                            DIV,ECK,EQA,FEX,INT,LBX,LDP,MSC,RTI,SEC,STO,TCK,TRF,VDA".

/*  from swift
    BOE Bill of exchange 
    BRF Brokerage fee 
    CHG Charges and other expenses 
    CHK Cheques 
    CLR Cash letters/Cheques remittance 
    CMI Cash management item - No detail 
    CMN Cash management item - Notional pooling 
    CMS Cash management item - Sweeping 
    CMT Cash management item - Topping 
    CMZ Cash management item - Zero balancing 
    COL Collections (used when entering a principal amount) 
    COM Commission 
    DCR Documentary credit (used when entering a principal amount) 
    DDT Direct Debit Item 
    DIV Dividends-Warrants 
    ECK Eurocheques 
    EQA Equivalent amount 
    FEX Foreign exchange 
    INT Interest 
    LBX Lock box 
    LDP Loan deposit 
    MSC Miscellaneous 
    RTI Returned item 
    SEC Securities (used when entering a principal amount) 
    STO Standing order 
    TCK Travellers cheques 
    TRF Transfer 
    VDA Value date adjustment (used with an entry made to withdraw an incorrectly dated entry - it will be followed by the correct entry with the relevant code) 
 */

{vm-lib.i}
{global.i}

def var v-950host as char. 
def var v-950path  as char.

def var v-lastupd as date.  

find sysc where sysc.sysc = "SW950H" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
   v-950host =  "TXB-A1177".
end. else do :
   v-950host = sysc.chval.
end.

/* 
   дата последнего обновления swift дериктории, 
   тк оказывается имена файлов могут повторяться
*/
find sysc where sysc.sysc = "SWLSTUPD" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
   v-lastupd =  08/17/04.
end. else do :
   v-lastupd = sysc.daval.
end.


find sysc where sysc.sysc = "SW950P" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
   v-950path =  "C:\\VAS\\".
end. else do :
   v-950path = sysc.chval.
end.

input through value("rsh  " + v-950host + " ""dir /b  " + v-950path + "*.prt""") no-echo.
    repeat:
      import unformatted s.

         /*Проверка */
          find first swhd where swhd.fname = trim(s) and swhd.rdt >= v-lastupd no-lock no-error.
          
         /*Если небыло еще копируем и начинаем парсить*/
         if not avail swhd then do: 
         run savelog ("swtrx", "BEGIN PARSE FILE " + trim(s)).

              input stream m-cpfl through  value ("rcp " + v-950host + ":" + replace(v-950path,"\\","\\\\") + trim(s) + " " + trim(s) + "; echo $?").
              repeat:
                import stream m-cpfl v-result.
              end.
              
            input stream m-cpfl close.

            v-date = no.
            input stream m-infl from value(trim(s)).

            repeat:
            do transaction:
              import stream m-infl unformatted v-str.
              
              v-str = trim(v-str).
              
              if v-str <> "" then do:
                 if not v-date then do:  
                     v-date = yes.
                     v-dateh = date (substr(v-str, 1,8)).
                     v-time  = str-to-time(substr(v-str, 10,8)).
                 end.
              end.

              if index (trim(v-str),"Instance Type and Transmission") > 0 then do:
                  v-id = next-value (swid).
                  create swhd.
                     swhd.swid   = v-id.
                     swhd.rdt    = v-dateh. 
                     swhd.fname  = trim(s). 
                     swhd.rtime  = v-time. 
              end.

              if trim(v-str) begins "Swift Output" then do: 
                  v-str = SpaceDelete(v-str).
                  v-type = entry(5, trim(v-str)," ").

                  if lookup(v-type,  "950,940,942") <= 0  then do:
                  
                        do while not (trim(v-str) begins "\{CHK:"):
                            import stream m-infl unformatted v-str.
                        end.  
                  end. 
                  find swhd where swhd.swid  = v-id exclusive-lock no-error.
                      swhd.type  = v-type. 
              end.

              if trim(v-str) begins "Sender" then do: 
                   find swhd where swhd.swid  = v-id exclusive-lock no-error.
                   swhd.snd = entry(NUM-ENTRIES(trim(v-str), " "), trim(v-str)," "). 
              end.

              if trim(v-str) begins "20:" then do: 
                  import stream m-infl unformatted v-str.
                  find swhd where swhd.swid  = v-id exclusive-lock no-error.
                  swhd.trref = trim(v-str).     
              end.

              if trim(v-str) begins "25:" then do: 
                  import stream m-infl unformatted v-str.
                  find swhd where swhd.swid  = v-id exclusive-lock no-error.
                  swhd.acc = trim(v-str).     
              end.
              
              if trim(v-str) begins "28C:" then do: 
                  import stream m-infl unformatted v-str.
                  find swhd where swhd.swid  = v-id exclusive-lock no-error.
                  swhd.f28 = trim(v-str).     
              end.
              

              if trim(v-str) begins "60F:" or trim(v-str) begins "60M:" then do: 

                  find swhd where swhd.swid  = v-id exclusive-lock no-error.                  

                  if trim(v-str) begins "60F:"  then 
                     swhd.info[1] =  "F".
                  else
                     swhd.info[1] =  "M".

                  /*Type*/
                  import stream m-infl unformatted v-str.

                  if entry(NUM-ENTRIES(trim(v-str), " "), trim(v-str)," ") = "Credit" then 
                      swhd.f60type =  "C".  
                  else
                      swhd.f60type =  "D".

                  /*Date*/
                  import stream m-infl unformatted v-str.
                  v-dts = entry(2, trim(v-str),":").
                  run to_date (trim(v-dts), output v-dt).

                  swhd.f60dt = v-dt.      

                  /*Currency*/
                  import stream m-infl unformatted v-str.
                  v-crcs = entry(2, trim(v-str),":").
                  run to_crc (trim(v-crcs), output v-crci).

                  swhd.f60crc = v-crci. 
                  /*Amount*/
                  import stream m-infl unformatted v-str.
                  swhd.f60amt = sw-to-prog-amt (entry(2, trim(v-str),"#")).

              end.
             
              /*Обрабатываем информацию о платежах*/
              if trim(v-str) begins "61:" and lookup(v-type,  "950,942") > 0 then do:               
                   v-ln = yes.
                   import stream m-infl unformatted v-str. /*Пропускаем одну строчку*/
                   do while v-ln: 
                     import stream m-infl unformatted v-str. 
                     if trim(v-str) begins "62F:" 
                         or trim(v-str) begins "62M:" 
                         or index (trim(v-str),"Message Trailer") > 0  
                         then do: 
                        v-ln = no.
                        leave.
                     end.

                     v-ref = substr (v-str, 32, 27).
                     v-str = SpaceDelete(v-str).

                     if NUM-ENTRIES(v-str,"#") <>3 then next.
                     if NUM-ENTRIES(v-str," ") < 5 then next.
                     v-tti = entry(NUM-ENTRIES(trim(v-str), " ") - 3, trim(v-str)," ").    

                     /* if lookup(substr(v-tti, 2, 3),  v-lst) = 0 then next. */
                     create swdt.
                            swdt.swid = v-id.
                            v-dts = entry (1, trim(v-str), " ").
                            swdt.rdt  = date(substr(v-dts, 5,2) + "/" + substr(v-dts, 3,2 ) + "/" +  substr(v-dts, 1,2)).
                            swdt.type = entry (2, trim(v-str), " ").
                            swdt.ref  = trim(v-ref).
                            /* swdt.ref  = entry (3, trim(v-str), " "). */
                            swdt.amt  = sw-to-prog-amt (entry(2, trim(v-str),"#")).
                            swdt.oper = entry (NUM-ENTRIES(trim(v-str), " "), trim(v-str), " ").
 
                     import stream m-infl unformatted v-str. 
                            swdt.ref2  = trim(v-str).

                   end. 
              end.

              /*Обрабатываем информацию о платежах*/
              if trim(v-str) begins "61:" and v-type = "940" then do:               
                     v-ln = yes.
                     import stream m-infl unformatted v-str. /*Пропускаем одну строчку*/
                     do while v-ln: 
                         import stream m-infl unformatted v-str. 
                         if trim(v-str) begins "62F:" 
                             or trim(v-str) begins "62M:" 
                             or trim(v-str) begins "86:" 
                             or index (trim(v-str),"Message Trailer") > 0  
                             then do: 
                                  v-ln = no.
                                  leave.
                             end.

                         v-ref = substr (v-str, 32, 27).
                         v-str = SpaceDelete(v-str).
                         if NUM-ENTRIES(v-str,"#") <>3 then next.
                         if NUM-ENTRIES(v-str," ") < 5 then next.

                         v-tti = entry(NUM-ENTRIES(trim(v-str), " ") - 3, trim(v-str)," ").    
                         if NUM-ENTRIES(v-str,"#") = 3 and
                            NUM-ENTRIES(v-str," ") > 5  then do:

                            create swdt.
                                swdt.swid = v-id.
                                v-dts = entry (1, trim(v-str), " ").
                                swdt.rdt  = date(substr(v-dts, 5,2) + "/" + substr(v-dts, 3,2 ) + "/" +  substr(v-dts, 1,2)).
                                swdt.type = entry (3, trim(v-str), " ").
                                swdt.ref  = trim(v-ref).
                                swdt.amt  = sw-to-prog-amt (entry(2, trim(v-str),"#")).
                                swdt.oper = entry (NUM-ENTRIES(trim(v-str), " "), trim(v-str), " ").

                                import stream m-infl unformatted v-str. 
                                swdt.ref2  = trim(v-str).

                          end.
                     end.
              end.




             if trim(v-str) begins "62M:"  or trim(v-str) begins "62F:"  then do: 

                  find swhd where swhd.swid  = v-id exclusive-lock no-error.                  
                  /*Type*/
                  import stream m-infl unformatted v-str.
                  if entry(NUM-ENTRIES(trim(v-str), " "), trim(v-str)," ") = "Credit" then 
                      swhd.f62type =  "C".    
                  else
                      swhd.f62type =  "D".    
                  /*Date*/
                  import stream m-infl unformatted v-str.
                  v-dts = entry(2, trim(v-str),":").
                  run to_date (trim(v-dts), output v-dt).
                  swhd.f62dt = v-dt. 
                  
                  /*Currency*/
                  import stream m-infl unformatted v-str.
                  v-crcs = entry(2, trim(v-str),":").
                  run to_crc (trim(v-crcs), output v-crci).
                  swhd.f62crc = v-crci. 

                  /*Amount*/
                  import stream m-infl unformatted v-str.
                  swhd.f62amt = sw-to-prog-amt (entry(2, trim(v-str),"#")).

              end.

              if trim(v-str) begins "64:" then do: 
                  find swhd where swhd.swid  = v-id exclusive-lock no-error.                  
                  /*Type*/
                  import stream m-infl unformatted v-str.
                  if entry(NUM-ENTRIES(trim(v-str), " "), trim(v-str)," ") = "Credit" then 
                      swhd.f64type = "C".    
                  else
                      swhd.f64type = "D".    

                  /*Date*/
                  import stream m-infl unformatted v-str.
                  v-dts = entry(2, trim(v-str),":").
                  run to_date (trim(v-dts), output v-dt).
                  swhd.f64dt = v-dt.    

                  /*Currency*/
                  import stream m-infl unformatted v-str.
                  v-crcs = entry(2, trim(v-str),":").
                  run to_crc (trim(v-crcs), output v-crci).
                  swhd.f64crc =   v-crci.

                  /*Amount*/
                  import stream m-infl unformatted v-str.
                  swhd.f64amt = sw-to-prog-amt (entry(2, trim(v-str),"#")).
              end.

              if index (trim(v-str),"\{DLM:\}") > 0 then 
            end. 
            end. 
            input stream m-infl close.
            run savelog ("swtrx", "END PARSE FILE " + trim(s)).
            input stream m-cpfldl through value("rm  " + trim(s)) no-echo.
         end. 

end.
input close.



