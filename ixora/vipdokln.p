/* vipdokln.p
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

/*vipdokln.p */

define input parameter in_jh    as char. /*   */
define input parameter in_ln    as char. 
define input parameter in_acc   like aaa.aaa.  /* Customer's Account  */
/*
define input parameter in_date_from      as date.  /* Period Begin  */
define input parameter in_date_to        as date. /* Period End   */
define input parameter in_p_vip        as char. /* put vipiska   */
*/
define input parameter in_p_mem        as char. /* Put mem.ord.  */
define input parameter in_p_memf        as char. /* Put mem.ord.  */
define input parameter in_p_pld        as char. /* Put plat.por. deb.   */
define input parameter in_p_uvd        as char. /* Put plat.por. deb.   */

/*
define input parameter in_p_plc        as char. /* Put plat.por. kred.  */
*/
define output parameter o_err   as log. /* Customer's Account  */

def var v-point like point.point. 
def var v-regno like point.regno. 
define var pvid       as char. 
def shared var g-today as date.
define var rec_id       as recid.
define var o_dealtrn         as character.
define var o_custtrn         as character.  /* dok.numurs */
define var o_ordinsN        as character.  /* maksataja dati */
define var o_ordins        as character.
define var o_ordcustN        as character.
define var o_ordcust        as character.
define var o_ordacc        as character.
define var o_ordacc1        as character.
define var o_benfsrN        as character.  /* sanemeja dati */
define var o_benfsr        as character.
define var o_benacc           as character.
define var o_benacc1           as character.
define var o_benbankN   as character.
define var o_benbank        as character.
define var o_dealsdet        as character.
define var o_bankinfo   as character.
define var o_vidop      as character.



def var in_destination as char init "dok.img".
def var in_destination0 as char init "vipiska.img".


def var v-ndok as char format "X(9)" .
def var v-voper as char format "X(7)".
def var v-bank as char format "X(9)" init "XXX".
def var v-kor as char format "x(12)".
def var v-ln as log init false.
def var v-ok as log init false.
def var v-tmp as cha. 
def var v-add as cha. 
def var v-vp as cha.
def var i as int.
def var v-bankcode as char format "X(9)" init "XXX".   
def var v-crccode like crc.code.
define buffer c-jl for jl.

find sysc where sysc.sysc eq "CLECOD" no-lock no-error. 
if available sysc then v-bankcode = substring(trim(sysc.chval),7,3).   
 unix silent rm -f value("mem.img").  

 unix silent rm -f value("plat.img").  
 output to "1.img".
 output close.  



find point where point.point eq v-point no-lock no-error.
  if available point then v-regno = point.regno.
  else do: 
   find first point no-lock no-error.
   if available point then v-regno = point.regno. 
   else v-regno = "". 
  end.

do while index("1234567890",substring(v-regno,1,1)) eq 0:
v-regno = substring(v-regno,2).
end.
i = 1.  
do while index("1234567890",substring(v-regno,i,1)) ne 0:
i = i + 1.
end.

v-regno = substring(v-regno,1,i). 

find aaa where aaa.aaa eq in_acc no-lock no-error.
if not avail aaa then return /* err */.
find lgr where lgr.lgr=aaa.lgr no-lock no-error.
if avail lgr and lgr.led eq "ODA" then return. /* err*/ /*( CDA "DDA" SAV)*/

find cif where cif.cif= aaa.cif no-lock no-error .   /*err */


find first jh where jh.jh eq integer(in_jh) no-lock no-error.
if not avail jh then return.   


Find  jl WHERE   jl.jh = integer(in_jh) and  jl.ln = integer(in_ln)
                 use-index jhln  NO-LOCK.
  
/*
  if aaa.gl ne jl.gl then next.
  
  if jl.lev ne 1 then next.

  if jl.rem[1] begins "O/D PROTECT" or
     jl.rem[1] begins "O/D PAYMENT" then next.
*/                     
  rec_id=recid(jl).
  v-ndok="".
  v-voper="01".
  v-bank=v-bankcode.
  v-kor="X".
  find jh where jh.jh=jl.jh no-lock no-error. 
  v-ok=false.
  v-vp="".
  IF jl.dc = "D"
  then do:  
       find trxcods where trxcods.trxh eq jl.jh and
             trxcods.trxln = jl.ln and trxcods.codfr eq "faktura" 
             and trxcods.code begins "chg" no-lock no-error .
       if avail trxcods then do:
        v-tmp = trxcods.code . 
        v-ln = false . 
def var v-sln as char.
def var v-jlln as int.
        v-sln="".
        v-jlln=0.
        for each trxcods where trxcods.trxh eq jl.jh and
                 trxcods.codfr eq "faktura"
                 and trxcods.code = v-tmp no-lock:
          v-sln=v-sln + string(trxcods.trxln) + ",". 
        end.
         
          if  lookup(string(jl.ln),v-sln) modulo 2 eq 0 
            then v-jlln=integer(entry(lookup(string(jl.ln),v-sln) - 1, v-sln)) no-error.
            else v-jlln=integer(entry(lookup(string(jl.ln),v-sln) + 1, v-sln)) no-error.
        if error-status:error then v-jlln=0.
        find c-jl use-index jhln where c-jl.jh = jl.jh and
             c-jl.ln = v-jlln no-lock no-error.
      
        if available c-jl /*and v-ln*/
        then do:
             find first fakturis where fakturis.jh eq jl.jh and 
                  fakturis.trx = c-jl.trx and
                  fakturis.ln eq c-jl.ln use-index jhtrxln no-lock no-error.             
             if available fakturis
             then do:
                o_custtrn=trim(string(fakturis.order)).
                v-voper="06".
                o_benbankN=v-bankcode.
                o_benfsrN=v-regno.
                find first cmp no-lock.
                o_benfsr=cmp.name.
                o_benacc=trim(c-jl.acc).
                if o_benacc="" then o_benacc=trim(string(c-jl.gl)).
                            /*   else o_benacc1=trim(string(c-jl.gl)). */
                
                v-ok=true.
                v-vp="f".
             end.
        end.
       end.
  END.
  
 
  IF not v-ok then DO:    
   If jh.sub="RMZ"  and not (jh.party begins "Storned")  
   then do:
        v-ndok=jh.ref.
        run vip_rmze(rec_id, output o_dealtrn,output o_custtrn, output o_ordinsN, output o_ordins, output o_ordcustN, output o_ordcust, output o_ordacc, output o_ordacc1,output o_benfsrN,output o_benfsr, output o_benacc, output o_benacc1, output o_benbankN, output o_benbank, output o_dealsdet,  output o_bankinfo, output o_vidop).
        if return-value = "0" then do:
             v-ndok=o_custtrn.
             v-ok=true.
             v-vp="p".
             o_dealsdet=o_dealsdet + o_bankinfo.
        end. 
   End. 
   else If jh.sub="JOU" and not (jh.party begins "Storned" )
   then do: v-ndok=jh.ref.
        run vip_joul(rec_id, output o_dealtrn,output o_custtrn, output o_ordinsN, output o_ordins, output o_ordcustN, output o_ordcust, output o_ordacc, output o_ordacc1,output o_benfsrN,output o_benfsr, output o_benacc, output o_benacc1, output o_benbankN, output o_benbank, output o_dealsdet,  output o_bankinfo, output o_vidop).
        if return-value = "0" then do:
             v-ok=true.
             v-vp="p".
             o_dealsdet=o_dealsdet + o_bankinfo.
        end. 
        
    End. 

/*------------------------------------------------------------*/
   else If jh.sub="DIL" and not (jh.party begins "Storned" )
   then do:
        v-ndok=jh.ref.
        run vip_dil(rec_id, output o_dealtrn,output o_custtrn, output o_ordinsN, output o_ordins, output o_ordcustN, output o_ordcust, output o_ordacc,output o_ordacc1,output o_benfsrN,output o_benfsr, output o_benacc,output o_benacc1, output o_benbankN, output o_benbank, output o_dealsdet, output o_bankinfo,output o_vidop).
    if return-value = "0" then do:
            v-ok=true.
            v-vp="p".
            o_dealsdet=o_dealsdet + o_bankinfo.
        end.
    End.        
/*-------------------------------------------------------------------*/ 
    If not v-ok then do: 
        run vip_cit(rec_id, output o_dealtrn,output o_custtrn, output o_ordinsN, output o_ordins, output o_ordcustN, output o_ordcust, output o_ordacc, output o_ordacc1,output o_benfsrN,output o_benfsr, output o_benacc, output o_benacc1, output o_benbankN, output o_benbank, output o_dealsdet,  output o_bankinfo, output o_vidop).
        if return-value = "0" then do:
              /* dati sanemeja: o_ben */             
              /* jl.cam <> 0   dati maksataja o_ord */
             v-ok=true.
             v-vp="p".
             o_dealsdet=o_dealsdet + o_bankinfo.
        end. 
   End. 
  END.


 if in_p_mem = "1" then pvid = "mem".
 else if in_p_memf = "1" then pvid = "memf".
 else if in_p_pld = "1" then pvid = "pl".
 else if in_p_uvd = "1" then pvid = "uvd".


/*message v-vp  in_p_mem in_p_memf in_p_pld pvid. pause 222.*/ 

 if (v-vp="f" and in_p_pld="1") or 
    (v-vp="p" and (in_p_mem="1" or in_p_memf="1")) or 
    (v-vp="p" and in_p_pld="1") then do: 
         run vipplat(pvid,rec_id,o_custtrn,o_ordcustN,o_ordcust,o_ordacc,o_ordacc1,o_ordinsN,o_ordins,o_benfsrN,o_benfsr,o_benacc,o_benacc1,o_benbankN,o_benbank,o_dealsdet). 
 end.
 else if v-vp="f" and (in_p_mem="1" or in_p_memf="1") then run vipfaktur(pvid,in_acc,c-jl.jh,c-jl.ln,jl.dam).  
 else if in_p_uvd="1" then do:
           /* display "The procedure is running". */
           /* run vipuvd(pvid,in_acc,c-jl.jh,c-jl.ln,jl.cam).*/
         run vipuvd(pvid,rec_id,o_custtrn,o_ordcustN,o_ordcust,o_ordacc,o_ordacc1,o_ordinsN,o_ordins,o_benfsrN,o_benfsr,o_benacc,o_benacc1,o_benbankN,o_benbank,o_dealsdet). 

 end.

   v-add="cat 1.img".
/* message search("mem.img"). pause 335. */
   if search("mem.img")  ne  ? then   v-add=v-add + " mem.img".  
   if search("plat.img") ne  ? then   v-add=v-add + " plat.img".
   v-add=v-add + " >> dok.img".

   unix silent value(v-add).
   unix silent rm -f value("1.img"). 
   clear all no-pause.  

                     