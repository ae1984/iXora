/* lt-trx.i
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
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
	24.06.2006 tsoy     - Если платеж на АРП картела то показывать реквизиты Картела в АТФ банке
*/

/* ==================================================================
=                                                                    =        
=                        Statement Generator                             =
=                Deals Codes & Details Processing Unit                    =
=                                                                    =
================================================================== */        
/*06/09/02 nataly - 
1) Было убрано в комментариях к проводке  "Услуги банка по тарифу"
2) В комментариях к проводке не выводится слово "Долг" */

def var v-nazn as cha format 'x(80)'. 
def var v-ln as  log . 
def var v-tmp as cha .
def buffer c-jh for jh . 
def buffer c-jl for jl .  
         find trxcods where trxcods.trxh = b-jl.jh  and
                            trxcods.trxln = b-jl.ln and
                               trxcods.codfr = v-codfr no-lock no-error.

         if available trxcods then 
            {1}.trxcode = trxcods.code.
         else do:
            if b-jh.party begins "RMZ" then
               {1}.trxcode = "TRF".
            else 
            if trim(b-jh.party) begins "FX" then
               {1}.trxcode = "FX".
            else     
               {1}.trxcode = "MSC".
         end.

         /* ===== Amount Assign ===================== */

         if b-jl.dam <> 0 then do:
                     {1}.dc = "d".
                     {1}.amount = b-jl.dam.
         end. 
         else do: 
         if b-jl.cam <> 0 then do: 
                       {1}.dc = "c".        
                       {1}.amount = b-jl.cam.
                    end.
         end.  


            /* TRX CODE */

     if {1}.trxcode begins "CHG" then do:
       v-nazn = "" . 
  /***
      find first trxcods where trxcods.trxh eq b-jl.jh and
           trxcods.trxln = b-jl.ln and trxcods.codfr eq "faktura" 
           and trxcods.code begins "chg" no-lock no-error .
      if avail trxcods then do:
        v-tmp = trxcods.code . 
        v-ln = false . 
       for each trxcods where trxcods.trxh eq b-jl.jh and
                 trxcods.codfr eq "faktura"
                 and trxcods.code = v-tmp no-lock:
        find c-jl use-index jhln where c-jl.jh = b-jl.jh and
             c-jl.ln = trxcods.trxln no-lock no-error.
          if trxcods.trxln ne b-jl.ln 
           and c-jl.trx = b-jl.trx  then  
            do: v-ln = true . leave . end . 
       end. 
      end . 
  ***/

  v-ln=false.
  find trxcods where trxcods.trxh eq b-jl.jh and
             trxcods.trxln = b-jl.ln and trxcods.codfr eq "faktura" 
             and trxcods.code begins "chg" no-lock no-error .
  if avail trxcods then do:
        v-tmp = trxcods.code . 
        v-ln = false . 
def var v-sln as char.
def var v-jlln as int.
        v-sln="".
        v-jlln=0.
        for each trxcods where trxcods.trxh eq b-jl.jh and
                 trxcods.codfr eq "faktura"
                 and trxcods.code = v-tmp no-lock:
          v-sln=v-sln + string(trxcods.trxln) + ",". 
        end.
         
          if  lookup(string(b-jl.ln),v-sln) modulo 2 eq 0 
            then v-jlln=integer(entry(lookup(string(b-jl.ln),v-sln) - 1, v-sln)) no-error.
            else v-jlln=integer(entry(lookup(string(b-jl.ln),v-sln) + 1, v-sln)) no-error.
        if error-status:error then v-jlln=0.
        find c-jl use-index jhln where c-jl.jh = b-jl.jh and
             c-jl.ln = v-jlln no-lock no-error.
        if available c-jl then v-ln=true.
  end.


  if v-ln = true then do:
   find first fakturis where fakturis.jh eq c-jl.jh and 
                  fakturis.trx = c-jl.trx and
                  fakturis.ln eq c-jl.ln use-index jhtrxln no-lock no-error.             
   if available fakturis then 
                {1}.custtrn="Nr." + trim(string(fakturis.order)).


   find first c-jh where c-jh.jh = c-jl.jh no-lock . 

   if trim(c-jl.rem[1]) begins "409 -" or trim(c-jl.rem[1]) begins "419 -" 
   or trim(c-jl.rem[1]) begins "429 -" or trim(c-jl.rem[1]) begins "430 -" 
                                          /* "Плата за обналичивание" */ 
   then do:
        v-nazn = ": " + string(c-jl.rem[1],"x(37)"). 
   end.  
   else    if c-jh.sub = "JOU"
   then do:
        find first joudoc where c-jh.ref  = joudoc.docnum  no-lock no-error . 
        if avail joudoc then 
        find tarif2 where tarif2.str5 = joudoc.comcode 
                      and tarif2.kont = c-jl.gl  
                      and tarif2.stat = 'r' no-lock no-error.
        if not available tarif2
        then v-nazn = string(c-jl.rem[5],"x(37)").
        else v-nazn = ": " + tarif2.str5 + " - " + string(tarif2.pakalp,"x(37)"). .
   end.
   else if c-jh.sub = "RMZ"
   then do:
        find first remtrz where c-jh.ref = remtrz.remtrz no-lock no-error .
        if avail remtrz then
        find tarif2 where tarif2.str5 = string(remtrz.svccgr) 
                      and tarif2.kont = c-jl.gl 
                      and tarif2.stat = 'r' no-lock no-error.
        if not available tarif2
        then v-nazn = string(c-jl.rem[5],"x(37)").
        else v-nazn = ": " + tarif2.str5 + " - " + string(tarif2.pakalp,"x(37)").
   end.
   else  do.
         if c-jl.rem[1] ne '' then
            v-nazn = string(trim(c-jl.rem[1]) + ' ' + trim(c-jl.rem[2]),"x(37)").
         else
          v-nazn = string(c-jl.rem[5],"x(70)").
         if  c-jl.rem[5] matches '*долг*' then v-nazn = substr(v-nazn,6).
/*----- nataly
        if  c-jl.rem[5] matches '*долг*' then v-nazn = "".*/
         end.

               /*             displ b-jl . displ v-nazn .    */ 

/*  ----- nataly
    {1}.dealsdet =  "Услуги банка по тарифу " +  string(v-nazn).*/

    if c-jl.acc = "011999832"  then  
       {1}.dealsdet = "Оплата за телефон " +  substr(trim(c-jl.rem[1]),11, length(trim(c-jl.rem[1])))   + ". Сумма " +  REPLACE(string( (c-jl.cam + c-jl.dam ), '>>>,>>>,>>9.99' ),","," ")  + " в т.ч. НДС " + string((c-jl.cam + c-jl.dam) * 0.15).   
    else
       {1}.dealsdet =  string(v-nazn).       

  end. 
  else                          
/*----- nataly 
    {1}.dealsdet = "Услуги банка по тарифу. ".*/
    {1}.dealsdet = "".

                                        
                                  
                 if trim(b-jh.party) begins "RMZ" or 
                    trim(b-jh.party) begins "FX"  or 
                    trim(b-jh.party) begins "JOU" then
                    {1}.dealtrn = substring(trim(b-jh.party), 1, 10).
                 else 
                 if b-jh.sub="UJO" then do:
                     find first ujo where ujo.docnum =b-jh.ref no-lock no-error. 
                     if avail ujo then do:
                        {1}.dealtrn = ujo.docnum.
                     /*  if trim(ujo.num) ne "" then {1}.custtrn=ujo.num. */
                     end.
                 end.
                 else
                    {1}.dealtrn = "".

                 {1}.who = b-jl.who.

            end.  /* CHG */
            else do:
         
            /* --- Standart Transaction Information Processing --- */


                  {1}.who = b-jl.who.

  find first prfxset where ( trim(b-jh.party) begins prfxset.oppr )  no-lock no-error.
                  if not available prfxset then do:

                       if b-jh.sub="UJO" then do:
                        find first ujo where ujo.docnum =b-jh.ref no-lock no-error. 
                        if avail ujo then do:
                             {1}.dealtrn = ujo.docnum.
                          if trim(ujo.num) ne "" then 
                             {1}.custtrn="Nr." + trim(ujo.num).
                        end.
                       end.

                       {1}.dealsdet =  trim(b-jl.rem[1]) + " " +
                                       trim(b-jl.rem[2]) + " " + 
                                       trim(b-jl.rem[3]) + " " + 
                                       trim(b-jl.rem[4]) + " " +
                                       trim(b-jl.rem[5]).  
                  end.
                  else do:
                     run value(prfxset.procsr)(in_recid, output o_dealtrn, output o_custtrn, output o_ordins, output o_ordcust, output o_ordacc, output o_benfsr, output o_benacc, output o_benbank, output o_dealsdet, output o_bankinfo).
                     if return-value = "0" then do:
                        {1}.dealtrn  = o_dealtrn.
                        {1}.custtrn  = o_custtrn.
                        {1}.ordins   = o_ordins.
                        {1}.ordcust  = o_ordcust. 
                        {1}.ordacc   = o_ordacc.
                        {1}.benfsr   = o_benfsr.
                        {1}.benbank  = o_benbank.
                        {1}.benacc   = o_benacc.
                        {1}.dealsdet = o_dealsdet.   
                        {1}.bankinfo = o_bankinfo.

                     end.
                     else do:
                       
                       {1}.dealsdet =  trim(b-jl.rem[1]) + " " +
                                       trim(b-jl.rem[2]) + " " + 
                                       trim(b-jl.rem[3]) + " " + 
                                       trim(b-jl.rem[4]) + " " +
                                       trim(b-jl.rem[5]).  

                        run elog("ADPROST/ADD_DEAL","ERR", "Error due deal details processing by: " + prfxset.procsr + " " + string(b-jl.jh) + ". Terminated.").

                     end.
                     
                     {vkins.i {1} } /* --- Valsts Kase Processing --- */
                  end.
            end.
      