/* desort.p
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
*/

/* ==============================================================
=                                                                =
=                Default Statement Formatter                        =
=             Statement Generator System                         =
=                                                                =
============================================================== */


define input parameter destination as character.



/* Temporary Tables Structure Defining --------------------------------- */

{header-t.i "shared" }
{deals.i    "shared" }

/* --------------------------------------------------------------------- */

define variable crccode as character.

define variable v-kurs as decimal.                  /* --- Currency Kurs     */
define variable v-koef as integer.                  /* --- Currency Quantity */        
define variable lines as integer initial 0.         /* --- Lines in deal          */

define variable d_t as decimal initial 0. 
define variable c_t as decimal initial 0.

define variable ordins         as character extent 4.
define variable ordcust  as character extent 4.
define variable ordacc         as character.
define variable benfsr   as character extent 4.
define variable benbank  as character extent 4.
define variable benacc   as character .
define variable dealsdet as character extent 4.
define variable bankinfo as character extent 4.


/* --------------------------------------------------------------------- */

{stlib.i}
{r-htrx2.f}

/* --------------------------------------------------------------------- */

define shared variable g-comp AS character.
define shared variable g-today as date.
define shared variable g-batch as logical.
define shared variable g-ofc   like ofc.ofc. 

define variable strbal as character initial "Промежуточный остаток".
define variable sakbal as character initial "Входящий остаток".
define variable dpre   as logical. 


new_page = yes.
frmt = "x(" + string(cols) + ")". 

/* ----- Destination Processing --------------------------------------- */

if destination = ? or destination = "" then destination = "rpt.img".

output to value (destination) page-size 0.

for each acc_list break by acc_list.crc by acc_list.aaa .
    new_acc = yes.
    t1 = fa3.

    if first-of (acc_list.crc) then do: 
     find first crc where crc.crc = acc_list.crc no-lock no-error.
      if crc.code = "Ls" then 
         crccode = "LVL".
      else    
         crccode = crc.code.
         
      tcrc = crccode.
    end.
    
    /* -- Account Header Position Checking -- */
    
    lines = 30.  /* Minimum row for account output */
    if row_in_page + lines >= rows then do:
          new_page = no.
          do while new_page = no :
             run pskip(1).
          end.
    end.  
    
    page_num = 1.
    
    /* --- Statement Header Generation --- */
 
    {defhed.i}
 
    /* ----------------------------------- */
    
    
    /* -------------------------------------- */
    /* --- Account Header --- */
    
        put "Konts " acc_list.aaa " " crccode  . 
        new_acc = no. 
        run pskip(0).
        
            /* .. Opening Balance .. */      
         
        find first deals where deals.account = acc_list.aaa and 
                               deals.servcode = "ob"        and
                               deals.d_date = acc_list.d_from no-error. 
        
         if available deals then 
            intermbal = deals.amount. 
         else
            intermbal = 0.
        
    /* -------------------------------- */
    
    
    /* ---- Transaction Processing --- */   

      for each deals where deals.account = acc_list.aaa and 
                         ( deals.servcode = "lt" or deals.servcode = "st" ) and
                           deals.d_date >= acc_list.d_from and
                           deals.d_date <= acc_list.d_to  
                           break by deals.account 
                                 by deals.dc     descending
                                 by deals.amount descending
                                 by deals.trxtrn.

        dpre = yes.
       
      if new_page = yes or first-of(deals.account)  then do:
       
               /* ---- Deals List Header */
        
        {acched.i}
        
        if first-of(deals.account) then 
           put sakbal format "x(20)" at 11.
        else 
           put strbal format "x(20)" at 11.
        
        if intermbal < 0 then do:
             put absolute(intermbal) format "z,zzz,zzz,zzz,zz9.99" at 40.
        end.     
        else do:  
             put intermbal format "z,zzz,zzz,zzz,zz9.99" at 55.
        end.     
             
        run pskip(0).     
        
        if first-of(deals.account) then do:
               put fill ("-",cols) format frmt. run pskip(0).
            end.   
               
            new_page = no.
               
      end. /* ... new page ... new account ... */ 
 
     /* ......................................................................... */
     
     
     /* String Quantity Calculation */
     
       lines = 2. /* --- TRN & Amount --- */
       
       /* --- Deals Details */

        
       if deals.dc = "c" then do:

        ordins[1] = substring(deals.ordins,1,35).
        if ordins[1] <> "" then lines = lines + 1.
         ordins[2] = substring(deals.ordins,36,70).
         if ordins[2] <> "" then lines = lines + 1.
         ordins[3] = substring(deals.ordins,71,106).
         if ordins[3] <> "" then lines = lines + 1. 
         ordins[4] = substring(deals.ordins,106,140).
         if ordins[4] <> "" then lines = lines + 1.
         
         ordcust[1] = substring(deals.ordcust,1,35).
         if ordcust[1] <> "" then lines = lines + 1.
         ordcust[2] = substring(deals.ordcust,36,70).
         if ordcust[2] <> "" then lines = lines + 1.
         ordcust[3] = substring(deals.ordcust,71,106).
         if ordcust[3] <> "" then lines = lines + 1.
         ordcust[4] = substring(deals.ordcust,106,140).
         if ordcust[4] <> "" then lines = lines + 1.
               
         ordacc = substring(deals.ordacc, 1, 35).
         if ordacc <> ? then lines = lines + 1.
         
       end.
       
       else do: /* --- deals.dc = "d" --- */
       
        benbank[1] = substring(deals.benbank,1,35).
        if benbank[1] <> "" then lines = lines + 1.
         benbank[2] = substring(deals.benbank,36,70).
         if benbank[2] <> "" then lines = lines + 1.
         benbank[3] = substring(deals.benbank,71,106).
         if benbank[3] <> "" then lines = lines + 1.
         benbank[4] =  substring(deals.benbank,106,140).
         if benbank[4] <> "" then lines = lines + 1.
        
        benacc  = substring(deals.benacc,1,35).
        if benacc <> "" then lines = lines + 1.

        benfsr[1] = substring(deals.benfsr,1,35).
         if benfsr[1] <> "" then lines = lines + 1.
         benfsr[2] = substring(deals.benfsr,36,70).
         if benfsr[2] <> "" then lines = lines + 1.
         benfsr[3] = substring(deals.benfsr,71,106).
         if benfsr[3] <> "" then lines = lines + 1.
         benfsr[4] = substring(deals.benfsr,106,140).
         if benfsr[4] <> "" then lines = lines + 1.

       end.  
       
       if deals.trxcode begins "COM" then do:
         find first codfr where codfr.codfr = v-codfr and codfr.code = deals.trxcode no-lock no-error. 
         if not available codfr then do:
            dealsdet[1] = "Комиссия.".
            dealsdet[2] = "".
            dealsdet[3] = "".
            dealsdet[4] = "".
         end.
         else do:
            dealsdet[1] = codfr.name[1].
            dealsdet[2] = "".
            dealsdet[3] = "".
            dealsdet[4] = "".
         end.
         if dealsdet[1] <> "" then lines = lines + 1.
       end.
       else do:
         dealsdet[1] = substring(deals.dealsdet,1,35).
         if dealsdet[1] <> "" then lines = lines + 1.
         dealsdet[2] =  substring(deals.dealsdet,36,70).
         if dealsdet[2] <> "" then lines = lines + 1.
         dealsdet[3] = substring(deals.dealsdet,71,106).
         if dealsdet[3] <> "" then lines = lines + 1.
         dealsdet[4] = substring(deals.dealsdet,106,140).
         if dealsdet[4] <> "" then lines = lines + 1.
         
         
         bankinfo[1] = substring(deals.bankinfo,1,35).
         if bankinfo[1] <> "" then lines = lines + 1.
         bankinfo[2] =  substring(deals.bankinfo,36,70).
         if bankinfo[2] <> "" then lines = lines + 1.
         bankinfo[3] = substring(deals.bankinfo,71,106).
         if bankinfo[3] <> "" then lines = lines + 1.
         bankinfo[4] = substring(deals.bankinfo,106,140).
         if bankinfo[4] <> "" then lines = lines + 1.
         
       end.
       
        
 if row_in_page + lines >= rows then do:
    
    do while new_page = no :
       run pskip(1).
    end.
    
    /* ---- Deals List Header */
    
    {acched.i}
    
    put strbal format "x(20)" at 11.
        
        if intermbal < 0 then 
             put absolute(intermbal) format "z,zzz,zzz,zzz,zz9.99" at 40.
        else  
             put intermbal format "z,zzz,zzz,zzz,zz9.99" at 55.
             
    run pskip(1).     
    
    /* put fill ("-",cols) format frmt. run pskip(0). */
    
    new_page = no. 
       
 end. /* ... row_in_page + lines >= rows ... */
     
     /* ........................... */ 
     

        put deals.d_date at 1 .

        put deals.trxtrn format "x(10)" at 11.
        put deals.custtrn format "x(10)" at 22.


        if deals.dc = "d"  then do:
              put deals.amount format "z,zzz,zzz,zzz,zz9.99" at 40.
              intermbal = intermbal - deals.amount.
           end.   
        else do: 
              put deals.amount format "z,zzz,zzz,zzz,zz9.99" at 55. 
              intermbal = intermbal + deals.amount.
           end.   
        
        run pskip(0).

        put upper(deals.trxcode) to 10 format "x(5)". 

        if deals.dealtrn <> "" then do:
              put deals.dealtrn format "x(16)" at 11 .
              run pskip(0).
        end.


        /* --- Ordering Customer --- */

       if deals.dc = "c" then do:

        if ordins[1] <> "" then do: put ">" at 9 ordins[1] format "x(35)" at 11. run pskip(0). end.
        if ordins[2] <> "" then do: put ordins[2] format "x(35)" at 11. run pskip(0). end.
        if ordins[3] <> "" then do: put ordins[3] format "x(35)" at 11. run pskip(0). end.
        if ordins[4] <> "" then do: put ordins[4] format "x(35)" at 11. run pskip(0). end.         
         
         if ordcust[1] <> "" then do: put ">" at 9 ordcust[1] format "x(35)" at 11. run pskip(0). end.
        if ordcust[2] <> "" then do: put ordcust[2] format "x(35)" at 11. run pskip(0). end.        
        if ordcust[3] <> "" then do: put ordcust[3] format "x(35)" at 11. run pskip(0). end.
        if ordcust[4] <> "" then do: put ordcust[4] format "x(35)" at 11. run pskip(0). end.
        
        if ordacc <> "" then do: put ">" at 9 ordacc format "x(35)" at 11. run pskip(0). end.     
        
       end.

        /* --- Beneficiar --- */

       else do: /* --- if deals.dc = "d" --- */ 
      
        if benbank[1] <> "" then do: put ">" at 9 benbank[1] format "x(35)" at 11. run pskip(0). end.
        if benbank[2] <> "" then do: put benbank[2] format "x(35)" at 11. run pskip(0). end.
        if benbank[3] <> "" then do: put benbank[3] format "x(35)" at 11. run pskip(0). end.
        if benbank[4] <> "" then do: put benbank[4] format "x(35)" at 11. run pskip(0). end.

         if benfsr[1] <> "" then do: put ">" at 9 benfsr[1] format "x(35)" at 11. run pskip(0). end.
         if benfsr[2] <> "" then do: put benfsr[2] format "x(35)" at 11. run pskip(0). end.
         if benfsr[3] <> "" then do: put benfsr[3] format "x(35)" at 11. run pskip(0). end.
        if benfsr[4] <> "" then do: put benfsr[4] format "x(35)" at 11. run pskip(0). end.
        
        if benacc <> "" then do: put ">" at 9 benacc format "x(35)" at 11. run pskip(0). end.

       end.

        /* --- Deals Details --- */

        if dealsdet[1] <> "" then do: put ">" at 9 dealsdet[1] format "x(35)" at 11. run pskip(0). end.
        if dealsdet[2] <> "" then do: put dealsdet[2] format "x(35)" at 11. run pskip(0). end.
        if dealsdet[3] <> "" then do: put dealsdet[3] format "x(35)" at 11. run pskip(0). end.
        if dealsdet[4] <> "" then do: put dealsdet[4] format "x(35)" at 11. run pskip(0). end.
        
        /* --- Bank Information --- */
        
        if bankinfo[1] <> "" then do: put ">" at 9 bankinfo[1] format "x(35)" at 11. run pskip(0). end.
        if bankinfo[2] <> "" then do: put bankinfo[2] format "x(35)" at 11. run pskip(0). end.
        if bankinfo[3] <> "" then do: put bankinfo[3] format "x(35)" at 11. run pskip(0). end.
        if bankinfo[4] <> "" then do: put bankinfo[4] format "x(35)" at 11. run pskip(0). end.

     /* ......................................................................... */
     
       /* ---- TRX_CODE Table Update ---- */
         
          find first trx_codes where trx_codes.code = deals.trxcode no-error.
          if not available trx_codes then do: 
             find first codfr where codfr.codfr = v-codfr and
                                    codfr.code = deals.trxcode no-lock no-error.
               if available codfr then do:
                  create trx_codes.
                  trx_codes.code = deals.trxcode.
                  trx_codes.name = codfr.name[1].
               end.                     
          end.
       /* --------------------------------- */

      end.  /* for each deals ... */

     /* ---- Turnover Processing ---------------------------------------------------- */ 
      
      d_t = 0.
      c_t = 0.
      
      find first deals where deals.account = acc_list.aaa and 
                             deals.servcode = "ldt" and 
                             deals.d_date = acc_list.d_to no-error.
      if available deals then d_t = deals.amount. 
      
      find first deals where deals.account = acc_list.aaa and 
                             deals.servcode = "lct"       and
                             deals.d_date = acc_list.d_to no-error.
      if available deals then c_t = deals.amount. 
      
      if c_t <> 0 and d_t <> 0 then lines =  9.
        else lines = 13.
      
      if row_in_page + lines >= rows then do:
          do while new_page = no :
             run pskip(1).
          end.
      end.  

  if c_t <> 0 or d_t <> 0  then do:       
    
    run pskip(0).
    
    put fill ("-",cols) format frmt . run pskip(0).      
    
    put "Kop–" at 1.
    
   /* .. Debit Turnover .. */
    
      if d_t <> 0 then  
          put d_t format "z,zzz,zzz,zzz,zz9.99" at 35. 
      else             
          put 0   format "z,zzz,zzz,zzz,zz9.99" at 35.
   
   /* .. Credit Turnover .. */
   
      if c_t <> 0 then do:
         put c_t format "z,zzz,zzz,zzz,zz9.99" at 55. run pskip(1). 
      end.   
      else do: 
         put 0 format "z,zzz,zzz,zzz,zz9.99" at 55. run pskip(1).
      end.   
      
   end. /* Turnover ... */      
   
   /* --------------------------------------------------------------------------------- */
  
   /* ======================== Balances Output ======================================= */ 
   
   balance_mode = yes.
   
   if dpre = no then do:
   
      put fill("-",75) format "x(75)". run pskip(0).
      put "ДЕБЕТ " to 60.
      put "КРЕДИТ " to 75.
      run pskip(0).
      put fill("-",75) format "x(75)". run pskip(0).
      
      find first deals where deals.account = acc_list.aaa and 
                             deals.servcode = "ob"        and
                             deals.d_date = acc_list.d_from no-error. 
      if available deals then do:
         if deals.amount < 0 then  
             put "Входящий остаток" at 1 absolute(deals.amount) format "z,zzz,zz~ z,zzz,zz9.99" at 40.
         else 
             put "Входящий остаток" at 1 deals.amount format "z,zzz,zzz,zzz,zz9.~ 99" at 55 . 
         run pskip(0).           
      end.   
      
   end.
   
   /* .. Closing Balance .. */      
         
   find first deals where deals.account = acc_list.aaa and 
                          deals.servcode = "cb"        and 
                          deals.d_date = acc_list.d_to no-error. 
      if available deals then do:
         if deals.amount < 0 then  
             put "Исходящий остаток" at 1 absolute(deals.amount) format "z,zzz,zzz,zzz,zz9.99" at 40.
         else 
             put "Исходящий остаток" at 1 deals.amount format "z,zzz,zzz,zzz,zz9.99" at 55 . 
         run pskip(0).           
      end.   
       
   /* .. Available Balance */      
    
   find first deals where deals.account = acc_list.aaa and 
                          deals.servcode = "ab"        and
                          deals.d_date = acc_list.d_to  no-error. 
      if available deals then do:
         if deals.amount < 0 then     
             put "Доступный остаток" at 1 absolute(deals.amount) format "z,zzz,zzz,zzz,zz9.99" at 40. 
         else 
             put "Доступный остаток" at 1 deals.amount format "z,zzz,zzz,zzz,zz9.99" at 55. 

         /* if acc_list.hbal = 0 then new_acc = yes. */
         
         new_acc = yes.
         
         run pskip(0).      
      end.   
      
/*
   /* .. Hold Balances .. */ 
   if acc_list.hbal <> 0 then  
   for each deals where deals.account = acc_list.aaa and deals.servcode = "hbi" break by deals.account.     
       put deals.dealsdet format "x(11)"  deals.amount . run pskip(0).
       put "           " deals.in_value " " deals.d_date " ". 
       put deals.ordcust  format "x(30)" "  /  Izpld:".
       put deals.who      format "x(30)". 
       if last-of ( deals.account ) then new_acc = yes.
       run pskip(0).
   end.    
*/
    
run pskip(5).

/* --- Statement footer Output --- */

put "========================== DOKUMENTA BEIGAS ===============================".
run pskip(1).


if not last( acc_list.aaa ) then do:
  frmt = "x(" + string(cols) + ")".
  put fill ("_",cols) format frmt. run pskip(1).
  run pskip(1).
end.  

balance_mode = no.  

/* === FormFeed Service Code === */

if formfeed = yes then  put chr(12).

/* --- History Registration --- */

define variable r-cif like cif.cif.

run getcv("h-cif",output r-cif).

run hwr(r-cif, acc_list.aaa, acc_list.seq, acc_list.stmsts, acc_list.d_from, acc_list.d_to, "desort" ).         
 
if return-value = "1" then do:
   run elog("HISTWR","ERR", "History Writer execution not completed.Terminated.").
   return "1".
end.

/* ----------------------------*/
dpre = no.
end. /* Account List ... */

put skip(1).

/* -------- Codes List Generation ----------------------- */

{codeslist.i}

/* ------------------------------------------------------ */

output close.

/* -------------------------------------------------------------------- */
