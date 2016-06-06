/* r-depaaa5.p
 * MODULE
        Отчет по начисленному вознаграждению 
 * DESCRIPTION
        Отчет по начисленному вознаграждению
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        r-depo5.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-13-2 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
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
def shared var v-branch as char.
def shared var v-name as char.
def shared  stream nur.

def shared var sum1v as integer.
def shared var sum2v as decimal.

/*for each temp2. delete temp2. end.*/
  /*расчет проводок по Money Gram*/
  def var v-dat1 as date.
  do v-dat1  = dt1 to dt2:

  /*расчет проводок по Money Gram*/
 case v-branch:
  when 'pragma' then 
  do:
    {obor2.i &arp="'188076015'" &gl="187030"}
    {obor2.i &arp="'088076115'" &gl="287032"}
  end.
    when 'branch1' then do: 
    {obor2.i &arp="'150076516'" &gl="187030"}
    {obor2.i &arp="'150076215'" &gl="287032"}
   end.
   when 'branch2' then do: 
    {obor2.i &arp="'250076210'" &gl="187030"}
    {obor2.i &arp="'250076511'" &gl="287032"}
   end.
   when 'branch3' then do: 
    {obor2.i &arp="'350076682'" &gl="187030"}
    {obor2.i &arp="'350076381'" &gl="287032"}
   end.
 end. /*case*/

  /*расчет проводок по Чекам*/
   for each txb.jl no-lock where jl.jdt = v-dat1    .

   if txb.jl.gl = 286030 or txb.jl.gl = 100810 or txb.jl.acc = '000076805'  or txb.jl.gl = 187010 
   then do:
    create  temp2. 
     temp2.acc = txb.jl.acc. temp2.jh = txb.jl.jh.  temp2.crc = txb.jl.crc.
     temp2.jdt = txb.jl.jdt. temp2.col1 = 1.  temp2.priz = 'chek'.  temp2.bank = v-branch.

      find last txb.crchis where txb.crchis.crc = txb.jl.crc 
      and crchis.rdt <= jl.jdt   use-index crcrdt no-lock no-error.
    if txb.jl.dc = 'd' then  temp2.bal = txb.jl.dam * txb.crchis.rate[1].  
    else   temp2.bal = txb.jl.cam * txb.crchis.rate[1].
  end.
 end. /*jl*/

  /*расчет проводок по RMZ*/
 for each txb.remtrz where txb.remtrz.rdt = v-dat1 no-lock.
    if txb.remtrz.jh1 = ? then next.
    if txb.remtrz.ptype <> '6' and txb.remtrz.ptype <> '7' then next.
   find txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.remtrz.remtrz and 
     txb.sub-cod.d-cod = 'pdoctng' no-lock no-error.
    create  temp2. 
     temp2.acc = txb.remtrz.remtrz +  ' ' + txb.remtrz.ptype. temp2.jh = txb.remtrz.jh1.  temp2.crc = txb.remtrz.fcrc.
     temp2.jdt = txb.remtrz.rdt. temp2.col1 = 1. /* temp2.priz = 'chek'.*/  temp2.bank = v-branch.

      find last txb.crchis where txb.crchis.crc = txb.remtrz.fcrc 
      and crchis.rdt <= remtrz.rdt   use-index crcrdt no-lock no-error.
    temp2.bal = txb.remtrz.amt * txb.crchis.rate[1].  

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
    end .
   end.
    if txb.remtrz.ptype = '7' then temp2.priz = 'плат поруч' .

    if not avail txb.sub-cod and txb.remtrz.source = 'prr' then temp2.priz = 'без откр счета'.
    if txb.remtrz.cracc = '002904467' or txb.remtrz.cracc = '003904602' or txb.remtrz.cracc = '000904016'  
        then temp2.priz = 'без откр счета'.
 end. /*RMZ*/

  /*расчет проводок по платежным ордерам 2.1 - 2.8*/
   for each txb.joudoc where joudoc.whn = v-dat1  no-lock.
    if txb.joudoc.jh = ? then next.
    create  temp2. 
     temp2.acc = txb.joudoc.docnum . temp2.jh = txb.joudoc.jh.  temp2.crc = txb.joudoc.drcur.
     temp2.jdt = txb.joudoc.whn.  temp2.col1 = 1.  temp2.priz = 'платеж ордер'.  temp2.bank = v-branch.

      if joudoc.drcur = 0 then do:
         find first txb.jl where txb.jl.jh = txb.joudoc.jh and jl.dam = txb.joudoc.dramt  no-lock no-error.
         find last txb.crchis where txb.crchis.crc = txb.jl.crc  
          and crchis.rdt <= jl.jdt   use-index crcrdt no-lock no-error.
         temp2.bal = txb.joudoc.dramt * txb.crchis.rate[1].  
       end.
      else do:
         find last txb.crchis where txb.crchis.crc = txb.joudoc.drcur  
          and crchis.rdt <= joudoc.whn   use-index crcrdt no-lock no-error.
          temp2.bal = txb.joudoc.dramt * txb.crchis.rate[1].  
      end.
       find commonls where commonls.arp = joudoc.dracc  no-error.
       if avail commonls then temp2.priz = 'без откр счета'.

   end.  /*joudoc*/

   for each txb.jh where txb.jh.jdt = v-dat1 no-lock.
    find  txb.ujo where ujo.whn = jh.jdt and txb.ujo.docnum = jh.ref  no-lock no-error.
    if not avail txb.ujo then next.
    if txb.ujo.jh = ? then next.
    create  temp2. 
     temp2.acc = txb.ujo.docnum . temp2.jh = txb.ujo.jh. 
     temp2.jdt = txb.ujo.whn.  temp2.col1 = 1.  temp2.priz = 'платеж ордер'.  temp2.bank = v-branch.

         find first txb.jl where txb.jl.jh = txb.ujo.jh   no-lock no-error.
         find last txb.crchis where txb.crchis.crc = txb.jl.crc  
          and crchis.rdt <= jl.jdt   use-index crcrdt no-lock no-error.
     if jl.dam <> 0 then  do: 
        temp2.bal = txb.jl.dam * txb.crchis.rate[1].   
        find commonls where commonls.arp = jl.acc  no-error.
       if  avail commonls then temp2.priz = 'без откр счета'.
      end.
      else temp2.bal = txb.jl.cam * txb.crchis.rate[1]. 
         temp2.crc = txb.jl.crc.
   end.  /*jh*/
  
  end. /*v-dat*/
  
