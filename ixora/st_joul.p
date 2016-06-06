/* st_joul.p
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
=                   FOREX Details Processor                        =
=                                                                =
============================================================== */
/*
   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/


define input  parameter rec_id                 as recid.
define output parameter o_dealtrn         as character.
define output parameter o_custtrn         as character.
define output parameter o_ordins        as character.
define output parameter o_ordcust        as character.
define output parameter o_ordacc        as character.
define output parameter o_benfsr        as character.
define output parameter o_benacc        as character.
define output parameter o_benbank        as character.
define output parameter o_dealsdet        as character.
define output parameter o_bankinfo      as character.

define buffer s-jh for jh.
define buffer s-jl for jl.
define buffer s-jou for joudoc.

define variable c1 as character.
define variable c2 as character. 

define variable s1 as character.
define variable s2 as character.
def var bbcod as cha . 
/*
find sysc where sysc.sysc = "CLECOD" no-lock no-error.
  if  avail sysc then bbcod = substr(trim(sysc.chval),1,9) . else bbcod = "" .
*/
find first bankl where bankl.bank = "TXB00" no-lock no-error . 
if avail bankl then bbcod = bankl.name  + " " + bbcod . 

find s-jl where recid(s-jl) = rec_id no-lock no-error.
if not available s-jl then do:
  return "1".
end.  

find s-jh where s-jh.jh = s-jl.jh no-lock no-error.
if not available s-jh then do: 
   return "1".
end.

find first s-jou where s-jou.docnum = substring(s-jh.party, 1, 10) no-lock no-error.
if not available s-jou then do:
  return "1".
end.  

o_dealtrn = s-jou.docnum.

if s-jou.chk <> 0        then o_custtrn = "Nr. " + string(s-jou.chk).

if trim(s-jou.num) <> "" then o_custtrn = "Nr. " + trim(s-jou.num) + " ".


o_dealsdet = trim(s-jou.remark[1]) .
if (substring(s-jou.remark[2],1,199)) <> ? then o_dealsdet = o_dealsdet + trim(substring(s-jou.remark[2],1,199)) + " ".
if (s-jou.info)      <> ? then o_dealsdet = o_dealsdet + trim(s-jou.info)      + " ".
if (s-jou.passp)     <> ? then o_dealsdet = o_dealsdet + trim(s-jou.passp)     + " ".
if (s-jou.perkod)    <> ? then o_dealsdet = o_dealsdet + trim(s-jou.perkod) .

if ( s-jl.dam <> 0 ) and ( s-jou.drcur <> s-jou.crcur ) then do:  /* Forex Rate */

   define variable sellcrc as character.
   define variable buycrc  as character. 
   define variable nationalcrc as character.
   
   find first crc where crc.crc = 1 no-lock no-error.
   if available crc then nationalcrc = crc.code.
   if nationalcrc = "Ls" then nationalcrc = "LVL".
   
   find first crc where crc.crc = s-jou.drcur no-lock no-error.
   if available crc then sellcrc = crc.code.
   if sellcrc = "Ls" then sellcrc = "LVL".
   
   find first crc where crc.crc = s-jou.crcur no-lock no-error.
   if available crc then buycrc = crc.code.
   if buycrc = "Ls" then buycrc = "LVL".
   
   
   o_bankinfo = "P–rdod " + string(dramt) + " " + sellcrc .
   
   if sellcrc <> nationalcrc then    
      o_bankinfo = o_bankinfo + " Kurss: " + string(brate,"z9.999") + " " + sellcrc + 
                             " / " + string(bn) + " " + nationalcrc .
                
   o_bankinfo = o_bankinfo + " ; " + "Pёrk " + string(cramt) + " " + buycrc.
   
   if buycrc <> nationalcrc then 
      o_bankinfo = o_bankinfo + " Kurss: " + string(srate,"z9.999") + " " + buycrc + 
                " / " + string(sn) + " " + nationalcrc.

end.



if s-jl.dam <> 0 then do:  /* CounterParty - Credit Part */
  
  case cracctype:
   
   when "1" then do:   /* KASE */
        o_benfsr = trim(s-jou.info) + " ".
        if s-jou.passp <> ? then o_benfsr = o_benfsr + trim(s-jou.passp) + " ".
        if s-jou.perkod <> ? then o_benfsr = o_benfsr + trim(s-jou.perkod).       
   end.
      when "4" then do:        /* ARP */
             find first arp where arp.arp = s-jou.cracc no-lock no-error.
                   if avail arp then o_benfsr = trim(arp.des).
            end .
                         
   when "2" then do:  /* KONTS */
      find first aaa where aaa.aaa = s-jou.cracc no-lock no-error.
      find first cif where cif.cif = aaa.cif no-lock no-error.
      if available cif then do:
         o_benfsr = trim(trim(cif.prefix) + " " + trim(cif.name)).
         if cif.addr[1] <> ? then o_benfsr = o_benfsr + " " +  trim(cif.addr[1]).
         if cif.addr[2] <> ? then o_benfsr = o_benfsr + " " +  trim(cif.addr[2]).
         if cif.addr[3] <> ? then o_benfsr = o_benfsr + " " +  trim(cif.addr[3]).
         
      end.
       else do:
        o_benfsr = trim(s-jou.info) + " ".
        if s-jou.passp <> ? then o_benfsr = o_benfsr + trim(s-jou.passp) + " ".
        if s-jou.perkod <> ? then o_benfsr = o_benfsr + trim(s-jou.perkod).  
    end . 
   end.                    
  end. 
  
  
   o_benacc  = bbcod + " " + s-jou.cracc. 

end.

if s-jl.cam <> 0 then do:  /* CounterParty - Debit Part  */ 

   case dracctype:
     when "1" then do:  /* KASE */
       o_ordcust = trim(s-jou.info) + " ".
       if s-jou.passp <> ? then o_ordcust = o_ordcust + trim(s-jou.passp) + " ".
       if s-jou.perkod <> ? then o_ordcust = o_ordcust + trim(s-jou.perkod).
                  
     end.
     when "4" then do:        /* ARP */
      find first arp where arp.arp = s-jou.dracc no-lock no-error.
      if avail arp then o_ordcust = trim(arp.des).
     end .                   
     when "2" then do:        /* KONTS */
        find first aaa where aaa.aaa = s-jou.dracc no-lock no-error.
        find first cif where cif.cif = aaa.cif no-lock no-error.
        if available cif then do:
         
          o_ordcust = trim(trim(cif.prefix) + " " + trim(cif.name)).
         
         if cif.addr[1] <> ? then o_ordcust = o_ordcust + " " +  trim(cif.addr[1]).
         if cif.addr[2] <> ? then o_ordcust = o_ordcust + " " +  trim(cif.addr[2]).
         if cif.addr[3] <> ? then o_ordcust = o_ordcust + " " +  trim(cif.addr[3]).
                  
       end.
       else do:
       o_ordcust = trim(s-jou.info) + " ".
       if s-jou.passp <> ? then o_ordcust = o_ordcust + trim(s-jou.passp) + " ".
       if s-jou.perkod <> ? then o_ordcust = o_ordcust + trim(s-jou.perkod).
       end.
     end.                    
     
   end.
   
   o_ordacc  = bbcod + " " + s-jou.dracc.
   
end.


return "0".          


