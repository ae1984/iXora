/* prildat.p
 * MODULE
        Отчет по распределению платежного оборота  
 * DESCRIPTION
        Отчет по распределению платежного оборота  
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        pril2.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        prildat.i
 * MENU
        8-12-9-12 
 * AUTHOR
        15.04.05 nataly
 * CHANGES
        11.07.06 nataly исключила трансферты счета 135400,135500,215400,215500
        10/08/06 nataly добавила новые счета, оптимизировала код
        14/02/08 marina - добавила в оборот комиссию.
        01.09.09 marinav - переводы без открытия добавила счета, добавила ПТП
        01/04/2011 madiyar - изменился справочник pdoctng
*/

def shared temp-table  temp2
   field acc as char format 'x(9)'
   field jh  as integer
   field crc as integer
   field bank as char format 'x(3)'
   field bal  as decimal
   field jdt as date
   field col1  as integer
   field priz as char.

def shared var dt1 as date  .
def shared var dt2 as date  .
def var v-branch as char.
def var v-gl  as char init "135400,215400,135500,215500,187032,187033,187034,187035,187036,187037,287033,287034,287035,287036,287037".

def shared var sum1v as integer.
def shared var sum2v as decimal.

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error .
   if not avail txb.sysc or txb.sysc.chval = "" then do:
       display " This isn't record OURBNK in bank.sysc file !!".
       pause.
   end.
v-branch  =  trim(txb.sysc.chval).


  /*расчет проводок по Money Gram*/
  def var v-dat1 as date.
  do v-dat1  = dt1 to dt2:

    {prildat.i &gl="187032"}
    {prildat.i &gl="187033"}
    {prildat.i &gl="187034"}
    {prildat.i &gl="187035"}
    {prildat.i &gl="187036"}
    {prildat.i &gl="187037"}
    {prildat.i &gl="287033"}
    {prildat.i &gl="287034"}
    {prildat.i &gl="287035"}
    {prildat.i &gl="287036"}
    {prildat.i &gl="287037"}
  
  /*расчет проводок по Чекам
   for each txb.jl no-lock where jl.jdt = v-dat1    .

   if txb.jl.gl = 286030 or txb.jl.gl = 100810 or txb.jl.gl = 187010 
   then do:
    create  temp2. 
     temp2.acc = txb.jl.acc. temp2.jh = txb.jl.jh.  temp2.crc = txb.jl.crc.
     temp2.jdt = txb.jl.jdt. temp2.col1 = 1.  temp2.priz = 'chek'.  temp2.bank = v-branch.

      find last txb.crchis where txb.crchis.crc = txb.jl.crc 
      and crchis.rdt <= jl.jdt   use-index crcrdt no-lock no-error.
   if avail txb.crchis then do:
      if txb.jl.dc = 'd' then  temp2.bal = txb.jl.dam * txb.crchis.rate[1].  
      else   temp2.bal = txb.jl.cam * txb.crchis.rate[1].
   end.
  end.
 end.*/ 
end. 
  /*расчет проводок по RMZ*/


do v-dat1  = dt1 to dt2:
 for each txb.remtrz where txb.remtrz.rdt = v-dat1 no-lock.
    if txb.remtrz.jh1 = ? then next.
    if v-branch = 'TXB00' and  txb.remtrz.ptype <> '6' and txb.remtrz.ptype <> '7' and txb.remtrz.ptype <> '3' then next.
    if v-branch = 'TXB00' and  txb.remtrz.ptype = '3' and txb.remtrz.cracc ne '004904039' then next.

    if v-branch ne 'TXB00' and txb.remtrz.ptype <> '4'  and txb.remtrz.ptype <> '3' then next.

    if lookup(string(txb.remtrz.drgl),v-gl) <> 0 or  lookup(string(txb.remtrz.crgl),v-gl) <> 0 or txb.remtrz.rsub = 'tsf' then next.

    find txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.remtrz.remtrz and  txb.sub-cod.d-cod = 'pdoctng' no-lock no-error.

    create  temp2. 
     temp2.acc = txb.remtrz.remtrz +  ' ' + txb.remtrz.ptype + txb.remtrz.source +  ' ' 
                 + txb.remtrz.dracc +  ' ' + remtrz.cracc. temp2.jh = txb.remtrz.jh1.  temp2.crc = txb.remtrz.fcrc.
     temp2.jdt = txb.remtrz.rdt. temp2.col1 = 1. /* temp2.priz = 'chek'.*/  temp2.bank = v-branch.

    find last txb.crchis where txb.crchis.crc = txb.remtrz.fcrc and crchis.rdt <= remtrz.rdt   use-index crcrdt no-lock no-error.
    if avail txb.crchis then temp2.bal = txb.remtrz.amt * txb.crchis.rate[1].  

    if not avail txb.sub-cod then temp2.priz = 'N/A'.
    else do:
        case txb.sub-cod.ccod:
         when '01' then temp2.priz = 'плат поруч'.
         when '02' then temp2.priz = 'плат треб'.
         when '03' or when '04' or when '05' or when '07' or when '09' or when '10' then temp2.priz = 'инкасс'.
         when '08' then temp2.priz = 'плат извещ'.
         when '11' then temp2.priz = 'прям дебет'.
         when '12' then temp2.priz = 'плат ордер'.
         when '17' then temp2.priz = 'почт перев'.
         when '18' then temp2.priz = 'упл налог банкомат'.
         otherwise temp2.priz = 'N/A'.
        end.
    end.
   /*входящие платежи*/
   if v-branch = 'TXB00' and txb.remtrz.ptype = '7' then temp2.priz = 'плат поруч' .
   if v-branch ne 'TXB00' and txb.remtrz.ptype = '3' then temp2.priz = 'плат поруч' .

   /*исходящие платежи*/
    if not avail txb.sub-cod and txb.remtrz.source = 'P01' then temp2.priz = 'плат поруч'. /*возврат сумм со счета 099902799*/
    if not avail txb.sub-cod and txb.remtrz.source = 'MDD' then temp2.priz = 'плат поруч'. /*платежи Казначейства*/

    if not avail txb.sub-cod and txb.remtrz.source = 'prr' then temp2.priz = 'без откр счета'. /*налоговые платежи, АЛСЕКО, сот связь,ALMA TV*/
   if not avail txb.sub-cod and txb.remtrz.source = 'pnj' then do:                          /*пенсионные платежи*/
      find txb.gl where txb.gl.gl = txb.remtrz.drgl no-lock no-error.  
      if not avail txb.gl then displ txb.remtrz.drgl remtrz.remtrz.
      if txb.gl.sub = 'cif' then  temp2.priz = 'плат поруч'.           /* пенсионные платежи для ЮЛ со счета клиента*/
      else temp2.priz = 'без откр счета'.                              /* пенсионные платежи для ФЛ с транзитного ARP*/
    end.
    if txb.remtrz.cracc = '004904039' then temp2.priz = 'плат треб'. 
     
  /*временно*/
     if temp2.priz = 'N/A' then do:
       if txb.remtrz.source = 'IBH' and remtrz.fcrc = 1 then temp2.priz = 'плат поруч'. 
       else if  temp2.crc <> 1 then temp2.priz = 'заявл перев'. 
            else temp2.priz = 'без откр счета'. 
    end.

 end. /*RMZ*/
end.


/*расчет проводок по платежным ордерам 2.1 - 2.8*/
  do v-dat1  = dt1 to dt2:
   for each txb.joudoc where txb.joudoc.whn = v-dat1  no-lock.
    if txb.joudoc.jh = ? then next.
     
       find first txb.jl where txb.jl.jh = txb.joudoc.jh and lookup(string(txb.jl.gl),v-gl) > 0  no-lock no-error.
       if avail txb.jl then next.
       
       create  temp2. 
        temp2.acc = txb.joudoc.docnum . temp2.jh = txb.joudoc.jh.  temp2.crc = txb.joudoc.drcur.
        temp2.jdt = txb.joudoc.whn.  temp2.col1 = 1.  temp2.priz = 'платеж ордер'.  temp2.bank = v-branch.

       if joudoc.drcur = 0 then do:
         find first txb.jl where txb.jl.jh = txb.joudoc.jh and jl.dam = txb.joudoc.dramt  no-lock no-error.
         if not avail txb.jl then next.
         find last txb.crchis where txb.crchis.crc = txb.jl.crc  
          and crchis.rdt <= jl.jdt   use-index crcrdt no-lock no-error.
          if avail txb.crchis then temp2.bal = txb.joudoc.dramt * txb.crchis.rate[1].  
       end.
       else do:
         find last txb.crchis where txb.crchis.crc = txb.joudoc.drcur  
          and crchis.rdt <= joudoc.whn   use-index crcrdt no-lock no-error.
            if avail txb.crchis then temp2.bal = txb.joudoc.dramt * txb.crchis.rate[1].  
       end.
       find last txb.crchis where txb.crchis.crc = txb.joudoc.comcur  
          and crchis.rdt <= joudoc.whn   use-index crcrdt no-lock no-error.
          if avail txb.crchis then temp2.bal = temp2.bal + txb.joudoc.comamt * txb.crchis.rate[1].  

       find commonls where commonls.arp = joudoc.dracc  no-error.
       if avail commonls then temp2.priz = 'без откр счета'.

   end.  /*joudoc*/
 end.


  do v-dat1  = dt1 to dt2:
   for each txb.jh where txb.jh.jdt = v-dat1  no-lock.
 
     find first txb.jl where txb.jl.jh = txb.jh.jh and lookup(string(txb.jl.gl),v-gl) > 0  no-lock no-error.
     if avail txb.jl then next.
   
    find  txb.ujo where txb.ujo.whn = txb.jh.whn and txb.ujo.docnum = txb.jh.ref  no-lock no-error.
    if not avail txb.ujo then next.
    if txb.ujo.jh = ? then next.
    create  temp2. 
     temp2.acc = txb.ujo.docnum . temp2.jh = txb.ujo.jh. 
     temp2.jdt = txb.jh.jdt.  temp2.col1 = 1.  temp2.priz = 'платеж ордер'.  temp2.bank = v-branch.

         find first txb.jl where txb.jl.jh = txb.ujo.jh   no-lock no-error.
         if not avail txb.jl then next.
         find last txb.crchis where txb.crchis.crc = txb.jl.crc  
          and crchis.rdt <= jl.jdt   use-index crcrdt no-lock no-error.
            if not avail txb.crchis then next.

     if jl.dam <> 0 then  do: 
        temp2.bal = txb.jl.dam * txb.crchis.rate[1].   
        find commonls where commonls.arp = jl.acc  no-error.
       if  avail commonls then temp2.priz = 'без откр счета'.
      end.
      else temp2.bal = txb.jl.cam * txb.crchis.rate[1]. 
         temp2.crc = txb.jl.crc.
   end.  /*jh*/
  
  end. /*v-dat*/

