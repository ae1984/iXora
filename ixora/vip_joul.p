/* vip_joul.p
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
        18/11/2011 evseev  - переход на ИИН/БИН
*/

/* ==============================================================
=                  sta_joul.i form st_joul.p                    =
=                  FOREX Details Processor                      =
=       for Both Real and Archive DataBases                     =
============================================================== */
/*
   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
*/
{chbin.i}
define input  parameter rec_id          as recid.
define output parameter o_dealtrn       as character.
define output parameter o_custtrn       as character.
define output parameter o_ordinsN       as character.
define output parameter o_ordins        as character.
define output parameter o_ordcustN      as character.
define output parameter o_ordcust       as character.
define output parameter o_ordacc        as character.
define output parameter o_ordacc1       as character.
define output parameter o_benfsrN       as character.
define output parameter o_benfsr        as character.
define output parameter o_benacc        as character.
define output parameter o_benacc1       as character.
define output parameter o_benbankN      as character.
define output parameter o_benbank       as character.
define output parameter o_dealsdet      as character.
define output parameter o_bankinfo      as character.
define output parameter o_vidop         as character init "".

define buffer s-jh for jh.
define buffer s-jl for jl.
define buffer c-jl for jl.
define buffer s-jou for joudoc.

define variable c1 as character.
define variable c2 as character.

define variable s1 as character.
define variable s2 as character.

find s-jl where recid(s-jl) = rec_id no-lock no-error.
if not available s-jl then do:
  return "1".
end.

find s-jh where s-jh.jh = s-jl.jh no-lock no-error.
if not available s-jh then do:
   return "1".
end.


/* kak v hovoj
find first s-jou where s-jou.docnum = substring(s-jh.party, 1, 10) no-lock no-error.
*/

find first s-jou where s-jh.ref  = s-jou.docnum no-lock no-error.

if not available s-jou then do:
  return "1".
end.

if s-jou.jh ne s-jh.jh then do:
  return "1".
end.

o_dealtrn = s-jou.docnum.

if s-jou.chk <> 0        then o_custtrn = /*"Nr. " +*/ string(s-jou.chk).

if trim(s-jou.num) <> "" then o_custtrn = /*"Nr. " + */ trim(s-jou.num) + " ".


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


   o_bankinfo = "Покупка " + string(dramt) + " " + sellcrc .

   if sellcrc <> nationalcrc then
      o_bankinfo = o_bankinfo + " Курс: " + trim(string(brate,"zzzzzzzzzz9.999")) +
                  " " + sellcrc + " / " + string(bn) + " " + nationalcrc .

   o_bankinfo = o_bankinfo + " ; " + "Продажа " + string(cramt) + " " + buycrc.

   if buycrc <> nationalcrc then
      o_bankinfo = o_bankinfo + " Курс: " + trim(string(srate,"zzzzzzzzz9.999")) +
                  " " + buycrc + " / " + string(sn) + " " + nationalcrc.

end.



if s-jl.dam <> 0 then do:  /* CounterParty - Credit Part */
/*message cracctype. pause. */
  case cracctype:

   when "1" then do:   /* KASE */
        o_benfsr = trim(s-jou.info) + " ".
        if s-jou.passp <> ? then o_benfsr = o_benfsr + trim(s-jou.passp) + " ".
        if s-jou.perkod <> ? then o_benfsrN = o_benfsrN + trim(s-jou.perkod).
   end.

   when "2" or when "3" then do:  /* KONTS */
      find first aaa where aaa.aaa = s-jou.cracc no-lock no-error.
      find first cif where cif.cif = aaa.cif no-lock no-error.
      if available cif then do:

         o_benfsr = trim(trim(cif.prefix) + " " + trim(cif.name)).
         /***
         if cif.addr[1] <> ? then o_benfsr = o_benfsr + " " +  trim(cif.addr[1]).
         if cif.addr[2] <> ? then o_benfsr = o_benfsr + " " +  trim(cif.addr[2]).
         if cif.addr[3] <> ? then o_benfsr = o_benfsr + " " +  trim(cif.addr[3]).
         ***/
         o_benfsrN=trim(cif.jss).
      end.
      else do:
        o_benfsr = trim(s-jou.info) + " ".
        if s-jou.passp <> ? then o_benfsr = o_benfsr + trim(s-jou.passp) + " ".
        if s-jou.perkod <> ? then o_benfsrN = o_benfsrN + trim(s-jou.perkod).
      end.
   end.
   when "4"  then do:  /* ARP */
      find first arp where arp.arp = s-jou.cracc no-lock no-error.
      if available arp then do:
        /*
        find gl where gl.acc=arp.arp no-lock no-error.
        if avail gl then  o_benfsr = trim(gl.des).
        */
        o_benfsr=o_benfsr + trim(arp.des).
      end.
      else do:
        o_benfsr = trim(s-jou.info) + " ".
        if s-jou.passp <> ? then o_benfsr = o_benfsr + trim(s-jou.passp) + " ".
        if s-jou.perkod <> ? then o_benfsrN = o_benfsrN + trim(s-jou.perkod).
      end.
   end.
   when "5"  then do:  /* komisija */
           o_vidop="06".
   end.
  end.

   find sysc where sysc.sysc eq "CLECOD" no-lock no-error.
   if available sysc then o_benbankN = substring(trim(sysc.chval),7,3).

   if s-jl.dam eq s-jou.dramt then
         o_benacc  = s-jou.cracc.

/* 2000 */

   if o_benacc eq "" then do:
       find first c-jl use-index jhln where c-jl.jh = s-jl.jh and
             c-jl.ln ne s-jl.ln and c-jl.crc=s-jl.crc and
             c-jl.dam =s-jl.cam and c-jl.cam=s-jl.dam no-lock no-error.

       if avail c-jl then do:
                o_benacc=trim(c-jl.acc).
                if o_benacc="" then o_benacc=trim(string(c-jl.gl)).
                            /*   else o_benacc1=trim(string(c-jl.gl)). */
       end.
   end.

end.

if s-jl.cam <> 0 then do:  /* CounterParty - Debit Part  */

   case dracctype:
     when "1" then do:  /* KASE */
       o_ordcust = trim(s-jou.info) + " ".
       if s-jou.passp <> ? then o_ordcust = o_ordcust + trim(s-jou.passp) + " ".
       if s-jou.perkod <> ? then o_ordcustN = o_ordcustN + trim(s-jou.perkod).

     end.
     when "2" or when "3" then do:      /* KONTS */
        find first aaa where aaa.aaa = s-jou.dracc no-lock no-error.
        find first cif where cif.cif = aaa.cif no-lock no-error.
        if available cif then do:

          o_ordcust = trim(trim(cif.prefix) + " " + trim(cif.name)).

       /***
         if cif.addr[1] <> ? then o_ordcust = o_ordcust + " " +  trim(cif.addr[1]).
         if cif.addr[2] <> ? then o_ordcust = o_ordcust + " " +  trim(cif.addr[2]).
         if cif.addr[3] <> ? then o_ordcust = o_ordcust + " " +  trim(cif.addr[3]).
       ***/
          if v-bin then o_ordcustN=trim(cif.bin).
          else o_ordcustN=trim(cif.jss).
       end.
       else do:

       o_ordcust = trim(s-jou.info) + " ".
       if s-jou.passp <> ? then o_ordcust = o_ordcust + trim(s-jou.passp) + " ".
       if s-jou.perkod <> ? then o_ordcustN = o_ordcustN + trim(s-jou.perkod).

       end.
     end.
     when "4"  then do:  /* ARP */
      find first arp where arp.arp = s-jou.dracc no-lock no-error.
      if available arp then do:
        /*
        find gl where gl.acc=arp.arp no-lock no-error.
        if avail gl then  o_ordcust = trim(gl.des).
        */
        o_ordcust=o_ordcust + trim(arp.des).
      end.
      else do:
        o_ordcust = trim(s-jou.info) + " ".
        if s-jou.passp <> ? then o_ordcust = o_ordcust + trim(s-jou.passp) + " ".
        if s-jou.perkod <> ? then o_ordcust = o_ordcust + trim(s-jou.perkod).
      end.
     end.
     when "5"  then do:  /* komisija */
           o_vidop="06".
     end.

   end.
   find sysc where sysc.sysc eq "CLECOD" no-lock no-error.
   if available sysc then o_ordinsN = substring(trim(sysc.chval),7,3).

   if s-jl.cam eq s-jou.cramt then
           o_ordacc  = s-jou.dracc.

/* 2000 */

   if o_ordacc eq "" then do:
       find first c-jl use-index jhln where c-jl.jh = s-jl.jh and
             c-jl.ln ne s-jl.ln and c-jl.crc=s-jl.crc and
             c-jl.dam =s-jl.cam and c-jl.cam=s-jl.dam no-lock no-error.

       if avail c-jl then do:
                o_ordacc=trim(c-jl.acc).
                if o_ordacc="" then o_ordacc =trim(string(c-jl.gl)).
                            /*   else o_ordacc1=trim(string(c-jl.gl)). */
       end.
   end.


end.




return "0".


