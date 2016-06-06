/* pkkdsts.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Верхнее меню статус КД
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        11/05/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        17/06/2010 galina - добавила обработку "07" статуса
*/

{global.i}
{pk.i}
{pk-sysc.i}

def var pk-kdsts as char no-undo.
def var pknew-kdsts as char no-undo.
def var pk-kddt as date no-undo.
def var pknew-kddt as date no-undo.
def var pk-kdguaran as char no-undo.
def var pknew-kdguaran as char no-undo.
if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln "не найдена !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

def shared frame pkank.

{pkanklon.f}

do transaction on error undo, retry:
   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "kdsts" no-lock no-error.
   if avail pkanketh then do:
        v-kdsts = pkanketh.value1.
        if v-kdsts = '05' or v-kdsts = '06' then v-kddt = date(pkanketh.value2).
        if v-kdsts = '07' then v-kdguaran = pkanketh.value2 .
   end.
   pk-kdsts = v-kdsts.
   update v-kdsts with frame pkank.
   pknew-kdsts = v-kdsts.



   v-kdstsdes = "".
   find first codfr where codfr.codfr = 'kdsts' and codfr.code = v-kdsts no-lock no-error.
   if avail codfr then v-kdstsdes = codfr.name[1].
   display v-kdstsdes with frame pkank.

   if  pknew-kdsts = '05' or pknew-kdsts = '06' then do:
       pk-kddt = v-kddt.
       update v-kddt with frame pkank.
       pknew-kddt = v-kddt.
   end.
   if  pknew-kdsts = '07' then do:
       pk-kdguaran  = v-kdguaran .
       update v-kdguaran with frame pkank.
       pknew-kdguaran  = v-kdguaran.
   end.

   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "kdsts" exclusive-lock no-error.
   if not avail pkanketh then do:
       create pkanketh.
       assign pkanketh.bank = s-ourbank
              pkanketh.credtype = s-credtype
              pkanketh.ln = s-pkankln
              pkanketh.kritcod = "kdsts".
   end.
   pkanketh.value1 = pknew-kdsts.
   if pknew-kddt <> ? then pkanketh.value2 = string(pknew-kddt,'99/99/9999').
   else if trim(pknew-kdguaran) <> '' then do:
        pkanketh.value2 = pknew-kdguaran.
   end.
   if pknew-kddt = ? and trim(pknew-kdguaran) = '' then pkanketh.value2 = ''.

   run pkhis.
   find current pkanketh no-lock.

end.

procedure pkhis.
    create pkankhis.
    assign pkankhis.bank = s-ourbank
           pkankhis.credtype = s-credtype
           pkankhis.ln = s-pkankln
           pkankhis.type = 'kdsts'
           pkankhis.chval = pk-kdsts
           pkankhis.who = g-ofc
           pkankhis.whn = g-today
           pkankhis.rescha[1] = pknew-kdsts.
    if pknew-kdsts = '05' or pknew-kdsts = '06' then do:
        create pkankhis.
        assign pkankhis.bank = s-ourbank
               pkankhis.credtype = s-credtype
               pkankhis.ln = s-pkankln
               pkankhis.type = 'kddt'
               pkankhis.chval = string(pk-kddt,'99/99/9999')
               pkankhis.who = g-ofc
               pkankhis.whn = g-today
               pkankhis.rescha[1] = string(pknew-kddt,'99/99/9999').
    end.
    if pknew-kdsts = '07' then do:
        create pkankhis.
        assign pkankhis.bank = s-ourbank
               pkankhis.credtype = s-credtype
               pkankhis.ln = s-pkankln
               pkankhis.type = 'kdguaran'
               pkankhis.chval = pk-kdguaran
               pkankhis.who = g-ofc
               pkankhis.whn = g-today
               pkankhis.rescha[1] = pknew-kdguaran.
    end.
end procedure.
