/* vip_cit.p
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
def var v-cif as char.
define variable s1 as character.
define variable s2 as character.
{chbin.i}
find s-jl where recid(s-jl) = rec_id no-lock no-error.
if not available s-jl then do:
  return "1".
end.

find s-jh where s-jh.jh = s-jl.jh no-lock no-error.
if not available s-jh then do:
   return "1".
end.

  if s-jh.sub="UJO" then do:
     find first ujo where ujo.docnum =s-jh.ref no-lock no-error.
       if avail ujo then do:
          o_dealtrn = ujo.docnum.
          o_custtrn = ujo.docnum.
          if trim(ujo.num) ne "" then o_custtrn=ujo.num.
       end.
  end.


o_dealsdet = trim(s-jl.rem[1]) + " " +
             trim(s-jl.rem[2]) + " " +
             trim(s-jl.rem[3]) + " " +
             trim(s-jl.rem[4]) + " " +
             trim(s-jl.rem[5]).

  /* kor kont */
  find first c-jl use-index jhln where c-jl.jh = s-jl.jh and
             c-jl.ln ne s-jl.ln and c-jl.crc=s-jl.crc and
             c-jl.dam =s-jl.cam and c-jl.cam=s-jl.dam no-lock no-error.

  if avail c-jl then do:

             v-cif = "".
             find gl where gl.gl = c-jl.gl no-lock.
             if gl.subled eq "arp"
             then do:
                  find arp where arp.arp eq c-jl.acc no-lock no-error.
                  v-cif = arp.cif.
             end.
             else if gl.subled eq "bill"
             then do:
                  find bill where bill.bill eq c-jl.acc no-lock no-error.
                  v-cif = bill.cif.
             end.
             else if gl.subled eq "cif"
             then do:
                  find aaa where aaa.aaa eq c-jl.acc no-lock no-error.
                  v-cif = aaa.cif.
             end.
             else if gl.subled eq "lcr"
             then do:
                  find lcr where lcr.lcr eq c-jl.acc no-lock no-error.
                  v-cif = lcr.cif.
             end.
             if gl.subled = "lon"
             then do:
                  find lon where lon.lon = c-jl.acc no-lock no-error.
                  v-cif = lon.cif.
             end.
             else if gl.subled eq "ock"
             then do:
                  find ock where ock.ock eq c-jl.acc no-lock no-error.
                  find aaa where aaa.aaa = ock.aaa no-lock no-error.
                  v-cif = aaa.cif.
             end.

  end.

if s-jl.dam <> 0 then do:  /* CounterParty - Credit Part */

   find sysc where sysc.sysc eq "CLECOD" no-lock no-error.
   if available sysc then o_benbankN = substring(trim(sysc.chval),7,3).

       if avail c-jl then do:
                o_benacc=trim(c-jl.acc).
                if o_benacc="" then o_benacc =trim(string(c-jl.gl)).

                            /*  else o_benacc1=trim(string(c-jl.gl)). */
       end.

      find first cif where cif.cif = v-cif no-lock no-error.
      if available cif then do:

         o_benfsr = trim(trim(cif.prefix) + " " + trim(cif.name)).
         o_benfsrN= trim(cif.jss).
      end.
      else do:
        if avail gl then  o_benfsr = trim(gl.des).
                                    /* o_benfsr=o_benfsr + trim(arp.des). */
      end.

end.
if s-jl.cam <> 0 then do:  /* CounterParty - Debit Part  */

   find sysc where sysc.sysc eq "CLECOD" no-lock no-error.
   if available sysc then o_ordinsN = substring(trim(sysc.chval),7,3).

   if avail c-jl then do:
                o_ordacc=trim(c-jl.acc).
                if o_ordacc="" then o_ordacc =trim(string(c-jl.gl)).
                             /*  else o_ordacc1=trim(string(c-jl.gl)). */
   end.

      find first cif where cif.cif = v-cif no-lock no-error.
      if available cif then do:

         o_ordcust = trim(trim(cif.prefix) + " " + trim(cif.name)).
         if v-bin then o_ordcustN= trim(cif.bin).
         else o_ordcustN= trim(cif.jss).
      end.
      else do:
        if avail gl then  o_ordcust = trim(gl.des).
                                    /* o_benfsr=o_benfsr + trim(arp.des). */
      end.
end.

return "0".





