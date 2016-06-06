/* vip_dil.p
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

/* ===================================================================
=                             VIP_DIL.P                              =
=================================================================== */
/*
   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
*/

define input  parameter rec_id         as recid.
define output parameter o_dealtrn      as character.
define output parameter o_custtrn      as character.
define output parameter o_ordinsN      as character.
define output parameter o_ordins       as character.
define output parameter o_ordcustN     as character.
define output parameter o_ordcust      as character.
define output parameter o_ordacc       as character.
define output parameter o_ordacc1      as character.
define output parameter o_benfsrN      as character.
define output parameter o_benfsr       as character.
define output parameter o_benacc       as character.
define output parameter o_benacc1      as character.
define output parameter o_benbankN     as character.
define output parameter o_benbank      as character.
define output parameter o_dealsdet     as character.
define output parameter o_bankinfo     as character.
define output parameter o_vidop        as character init "".

define buffer s-jh for jh.
define buffer s-jl for jl.
define buffer s-dil for dealing_doc.
{chbin.i}
find s-jl where recid(s-jl) = rec_id no-lock no-error.
if not available s-jl then do:
  return "1".
end.
else
 do:
    find prev s-jl no-lock no-error.
    o_ordacc = trim(s-jl.acc). if o_ordacc = "" then o_ordacc = trim(string(s-jl.gl)).
    find next s-jl no-lock no-error.
    /*o_benacc = s-dil.vclientaccno.          */
 end.

find s-jh where s-jh.jh = s-jl.jh no-lock no-error.
if not available s-jh then do:
   return "1".
end.

find first s-dil where s-jh.ref  = s-dil.docno no-lock no-error.

if not available s-dil then do:
  return "1".
end.

if s-dil.jh ne s-jh.jh then do:
  if s-dil.jh2 ne s-jh.jh then do:
     return "1".
  end.    end.

/* -----------------------------------------------------------------------*/


o_dealtrn = s-dil.docno.                                 /* nomer dokumenta */


find first cmp no-lock no-error.                         /* o_benbank */
if available cmp then o_benbank = cmp.name.

                                                         /* o_benbankN */
find sysc where sysc.sysc eq "CLECOD" no-lock no-error.
if available sysc then o_benbankN = substring(trim(sysc.chval),7,3).


o_custtrn = STRING(s-dil.DocNo). /* ???????? */          /* o_custtrn */


find sysc where sysc.sysc eq "CLECOD" no-lock no-error.  /* o_ordinsN */
if available sysc then
       o_ordinsN = substring(trim(sysc.chval),7,3).

/* o_ordins - ne nado ????? */                         /* ---- o_ordins --- */


/*                                                         /* scheta v bankah */
if s-dil.DocType eq 1 or s-dil.DocType eq 2 then do:     /* tenge -> valuta  */
    o_ordacc = s-dil.tclientaccno.
    o_benacc = s-dil.vclientaccno.
end.
else do:                                                 /* valuta -> tenge */
    o_ordacc = s-dil.vclientaccno.
    o_benacc = s-dil.tclientaccno.
end.
*/
                                                     /* o_ordcust, o_ordcustN */

/****
find first aaa where aaa.aaa = s-dil.tclientAccNo or aaa.aaa = vclientAccNo
                no-lock no-error.
****/

/* --- iskat klienta so
       schetom otpravitela
        -> ordacc */
find first aaa where aaa.aaa = o_ordacc no-lock no-error.
find first cif where cif.cif = aaa.cif no-lock no-error.
if available cif then do:
        o_ordcust = trim(trim(cif.prefix) + " " + trim(cif.name)).
        if v-bin then  o_ordcustN =trim(cif.bin).
        else o_ordcustN =trim(cif.jss).
end.


/* --- iskat klienta
       so schetom poluchatela
       -> benacc */
find first aaa where aaa.aaa = o_benacc no-lock no-error.
find first cif where cif.cif = aaa.cif no-lock no-error.
if available cif then do:
        o_benfsr = trim(trim(cif.prefix) + " " + trim(cif.name)).
           o_benfsrN =trim(cif.jss).
end.

/********  NE PRAVILNO !!!
o_benfsr = cmp.name.     /* ???? poluchatel = bank */    /* o_benfsr = PHH */
o_benfsrN = cmp.addr[2].                                 /* o_benfsrN = adres*/
****************************/


/* o_dealsdet - ne nado ????? */                        /* --- o_dealsdet ---*/

/* o_bankinfo - ne nado ????? */                        /* --- o_bankinfo ---*/

/* o_vidop    - ne nado ????? */                        /* --- o_vidop --- */

return "0".



