/* zabaldat.p
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
        03/03/03 nataly
 * CHANGES
       28/10/03 nataly были внесены след изменения
       1) для гарантий в валюте sum_ob = jl.dam * crchis.rate[1]
       2) st_obes, ost_ob берется из отчета 4-2-9 (эквивалент в тенге)
       12.12.03 nataly 
       при расчет sum_ob учитывается входящий остаток на начло месяца
*/


def input parameter p-vcbank as char.

def shared var v-god as integer format "9999".
def shared var v-month as integer format "99".
def shared var v-dtb as date.
def shared var v-dte as date.

def var v-name as char.
def var v-partner as char.
def var v-god2 as char.


def shared temp-table t-cif 
  field jh as char
  field creditor as char
  field nss as char
  field name as char
  field regdt as date
  field kodbank as char
  field kodgbank as char
  field rnn as char format "x(14)"
  field ur_phis as char format "x(1)"
  field vid_ob as char 
  field datevyd as date
  field datekon as date
  field sum_ob as decimal 
  field val_ob as char 
  field plat_vyd as decimal 
  field vid_obes as char 
  field st_obes as decimal 
  field num_obyz as char 
  field naim_ban as char 
  field naim_ben as char 
  field adr_ben as char    
  field ost_ob as decimal    .


def shared temp-table t-cif2 
  field jh as char
  field nss as char
  field name as char
  field regdt as date
  field rnn as char format "x(14)"
  field sum_ob as decimal. 

def var v-fio1 as char.
def var v-shifrotr as char.
def var v-orgform as char.
def var v-formsobs as char.
def var v-sectorek as char.

def var v-aaa as char.
def var v-rnn as char.
def var vyd as date.
def var okon as date.

def var v-res as char.
def var v-mfo as char.

def shared var prz as integer.
def var v-sum as decimal.
def var v-max as decimal init 1000000.00.  /*сумма для ФЛ, подлежащая отчету в Кредитном регистре */
def var v-dat as date.
def var v-dat1 as date.
def var v-start as date.
def var v-trx1 as char init 'uni0057'. /*выдача гарантий*/
def var v-trx2 as char init 'uni0058'. /*возврат гарантий*/
def var v-trx3 as char init 'dcl0010'. /*возврат гарантий*/
def var v-jh as integer.
def var v-crc as char.
def var v-priz as char.

def buffer bjl for txb.jl.
def buffer bjl2 for txb.jl.
def buffer bjl3 for txb.jl.
def buffer cjl for txb.jl.

def var naim_ban as char.
def var naim_ben as char.
def var adr_ben as char.
def var nss as char.

def var i1 as integer.
def var i2 as integer.
def var i3 as integer.
def var i4 as integer.
def var i5 as integer.

def var v-garan as char.
def var dfrom as date.
def var dto as date.
def var v-codfr as char.

def var sumzalog as decimal.
def var sum1 as decimal.
def var plat_vyd as decimal.
def var ost_ob as decimal.

/*выданные гарантии*/ 
do v-dat = v-dtb to v-dte:
 for each txb.jl no-lock  where /* txb.jl.jh = 6105503 and*/  txb.jl.jdt = v-dat  and txb.jl.ln = 1   :
  ost_ob = 0. v-start = ?.
 if txb.jl.trx <> v-trx1  and  txb.jl.trx <> v-trx3  and txb.jl.trx <> v-trx2 then next.
 if substr(string(txb.jl.gl),1,4) = '2203' then do:
   v-priz = "".    
  find last txb.crchis where crchis.crc = jl.crc and crchis.regdt <= jl.jdt no-lock no-error.
  sum1 = jl.dam * crchis.rate[1].

  v-aaa = txb.jl.acc.
  v-garan = "". dfrom = ?. dto = ?. sumzalog = 0. plat_vyd = 0. 

  find bjl where bjl.jh = jl.jh and substr(string(bjl.gl),1,4) = '6055' no-lock no-error.
   if avail bjl then do: 
      find last txb.crchis where crchis.crc = bjl.crc and crchis.regdt <= bjl.jdt no-lock no-error.
      v-sum = bjl.dam * crchis.rate[1].  /*сумма гарантии*/
      nss = bjl.acc. /*ссудный счет*/
   end.
   else do:  
     v-sum = 0 .  /*сумма гарантии*/
     message  'Не задан счет гарантии  для проводки ' txb.jl.jh.
   end.
/*   find txb.trxbal where trxbal.subled = 'cif' and  txb.trxbal.acc = bjl.acc and txb.trxbal.lev = 7 no-lock no-error. 
   if avail txb.trxbal then  ost_ob = trxbal.dam - trxbal.cam. else ost_ob = 0.
  */
  /*нахождение остатка обязательства*/
     find txb.aaa where aaa.aaa = bjl.acc no-lock no-error.
/*      if not avail aaa then message 'No aaaa ! ' txb.bjl.jh.*/
     find txb.gl where gl.gl = txb.aaa.gl no-lock no-error.
/*     if not avail gl then message 'No GL ! ' txb.bjl.jh.*/
     find txb.trxlevgl where trxlevgl.gl   eq  aaa.gl 
                     and trxlevgl.subled  eq  'cif' 
                     and trxlevgl.level   eq  7      
                     no-lock no-error.

     /* 12.12.03 найдем остаток на начло отчетного месяца*/
     find first bjl3 where bjl3.gl   =  trxlevgl.glr
                      and bjl3.acc  =  aaa.aaa
                      and bjl3.jdt < v-dtb no-lock no-error.
    if avail bjl3 then  v-start =  bjl3.jdt.
     if v-start <> ? then do:
        do v-dat1 = v-start to v-dtb - 1:
        for each bjl3 where bjl3.gl   =  trxlevgl.glr
                      and bjl3.acc  =  aaa.aaa
                      and bjl3.jdt  eq v-dat1 no-lock.

            if bjl3.dc = 'd' then ost_ob = ost_ob + bjl3.dam.
            else ost_ob = ost_ob - bjl3.cam.
        end. 
        end.
      end.  /*v-start <> ?*/

        do v-dat1 = v-dtb to v-dte:
        for each bjl2 where bjl2.gl   =  trxlevgl.glr
                      and bjl2.acc  =  aaa.aaa
                      and bjl2.jdt  eq v-dat1 no-lock.

            if bjl2.dc = 'd' then ost_ob = ost_ob + bjl2.dam.
            else ost_ob = ost_ob - bjl2.cam.
        end. 
        end.
        find last crchis where crchis.crc = txb.aaa.crc and crchis.regdt <= v-dte
         no-lock no-error.      
           ost_ob = ost_ob * crchis.rate[1].

  /*нахождение остатка обязательства*/

      i1 = index(bjl.rem[3],":").
      i2 = index(bjl.rem[4],":").
      i3 = index(bjl.rem[5],":"). 
        if i1 > 0 then  naim_ban  = substr(bjl.rem[3], i1 + 1).  
        if i2 > 0 then  naim_ben  = substr(bjl.rem[4], i2 + 1).
        if i3 > 0 then  adr_ben   = substr(bjl.rem[5], i3 + 1).  

            i1 = index(bjl.rem[1], "N").
            i2 = index(bjl.rem[1], "от").
            i3 = index(bjl.rem[1], "до").
            i4 = index(bjl.rem[2], ":").
            i5 = index(bjl.rem[2], "Сумма").

      if i1 > 0 and i2 > 0 then   v-garan = trim(substr(bjl.rem[1],i1 + 1,i2 - i1 - 1 )). 
      if i2 > 0 and i3 > 0 then   dfrom  =  date(substr(bjl.rem[1],i2 + 3,i3 - i2 - 3)).
      if i3 > 0            then   dto = date(substr(bjl.rem[1],i3 + 3)).
      if i4 > 0 and i5 > 0 then   v-codfr = trim(substr(bjl.rem[2],i4 + 2,i5 - i4 - 2)).
      if i5 > 0            then  do: 
       find last txb.crchis where crchis.crc = bjl.crc and crchis.regdt <= bjl.jdt no-lock no-error.
       sumzalog = decimal(trim(substr(bjl.rem[2],i5 + 6))).
       sumzalog =  sumzalog * crchis.rate[1].
      end.
  if v-codfr = "06" then  sumzalog = sum1. /*если обеспечение -  депозит, то сумма обеспечения - сумма 1-ой линии */
  find cjl where cjl.jh = jl.jh and substr(string(cjl.gl),1,1) = '4' no-lock no-error.
   if avail cjl then plat_vyd = cjl.cam. else plat_vyd = 0.

  find txb.crc where txb.crc.crc = bjl.crc no-lock no-error.
  v-crc = txb.crc.code.  /*валюта гарантии*/

  find txb.aaa where txb.aaa.aaa = v-aaa no-lock no-error.
   if not avail txb.aaa then message 'not avail' txb.jl.jh txb.jl.acc.
  find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
  v-rnn = txb.cif.jss.

  find txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif  and txb.sub-cod.d-cod = 'clnsts' no-lock no-error.
  if avail txb.sub-cod then v-priz = txb.sub-cod.ccode .
   else message 'Не задан признак клиента (ЮЛ/ФЛ) !!!'.

   if v-priz = '0' then v-priz = '1'.
   else if v-priz = '1' then v-priz = '2'.

  if v-aaa  = "" or v-rnn = "" then message 'Не задан счет и клиент по гарантии '
   skip 'номер транзакции ' txb.jl.jh view-as alert-box.

   find txb.sysc where txb.sysc.sysc = 'clecod' no-lock no-error.
   if avail txb.sysc then v-mfo = txb.sysc.chval. else v-mfo = "".
 

    create t-cif.
    assign t-cif.jh = string(txb.jl.jh)
           t-cif.regdt = txb.jl.jdt
           t-cif.kodbank = v-mfo
           t-cif.kodgbank = '190501914'
           t-cif.rnn = "'" + trim(txb.cif.jss)
           t-cif.ur_phis  = v-priz
           t-cif.vid_ob   =  '20' /*гарантии*/ 
           t-cif.sum_ob  = v-sum 
           t-cif.creditor  = '1' 
           t-cif.val_ob  = v-crc
           t-cif.name = txb.cif.name
           t-cif.naim_ban = naim_ban  
           t-cif.naim_ben = naim_ben  
           t-cif.adr_ben = adr_ben 
           t-cif.nss = nss.
           if v-codfr = "" then  t-cif.vid_obes = "" . else t-cif.vid_obes ="'" + trim(v-codfr).

   assign  t-cif.st_obes = sumzalog
           t-cif.plat_vyd = plat_vyd
           t-cif.num_obyz  = v-garan
           t-cif.ost_ob  = ost_ob
           t-cif.datevyd  = dfrom
           t-cif.datekon  = dto.

  end.  /*2203*/
  else if substr(string(txb.jl.gl),1,4) = '6055' then do:
   v-priz = "".    
  find last txb.crchis where crchis.crc = jl.crc and crchis.regdt <= jl.jdt no-lock no-error.
  sum1 = jl.dam * crchis.rate[1].

  v-aaa = txb.jl.acc.
  v-garan = "". dfrom = ?. dto = ?. sumzalog = 0. plat_vyd = 0. 

   find  last txb.crchis where crchis.crc = jl.crc and crchis.regdt <= jl.jdt no-lock no-error.
   v-sum = jl.dam * crchis.rate[1].  /*сумма гарантии*/
  nss = jl.acc. /*ссудный счет*/
/*   find txb.trxbal where trxbal.subled = 'cif' and  txb.trxbal.acc = jl.acc and txb.trxbal.lev = 7 no-lock no-error. 
   if avail txb.trxbal then  ost_ob = trxbal.dam - trxbal.cam. else ost_ob = 0.
  */

  /* 12.12.03 нахождение остатка обязательства*/
     find txb.aaa where aaa.aaa = jl.acc no-lock no-error.
/*      if not avail aaa then message 'No aaaa ! ' txb.jl.jh.*/
     find txb.gl where gl.gl = txb.aaa.gl no-lock no-error.
/*     if not avail gl then message 'No GL ! ' txb.jl.jh.*/
     find txb.trxlevgl where trxlevgl.gl   eq  aaa.gl 
                     and trxlevgl.subled  eq  'cif' 
                     and trxlevgl.level   eq  7      
                     no-lock no-error.

     /*найдем остаток на начло отчетного месяца*/
     find first bjl3 where bjl3.gl   =  trxlevgl.glr
                      and bjl3.acc  =  aaa.aaa
                      and bjl3.jdt < v-dtb no-lock no-error.
    if avail bjl3 then  v-start =  bjl3.jdt.
     if v-start <> ? then do:
        do v-dat1 = v-start to v-dtb - 1:
        for each bjl3 where bjl3.gl   =  trxlevgl.glr
                      and bjl3.acc  =  aaa.aaa
                      and bjl3.jdt  eq v-dat1 no-lock.

            if bjl3.dc = 'd' then ost_ob = ost_ob + bjl3.dam.
            else ost_ob = ost_ob - bjl3.cam.
        end. 
        end.
      end.  /*v-start <> ?*/


        do v-dat1 = v-dtb to v-dte:
        for each bjl2 where bjl2.gl   =  trxlevgl.glr
                      and bjl2.acc  =  aaa.aaa
                      and bjl2.jdt  eq v-dat1 no-lock.

            if bjl2.dc = 'd' then ost_ob = ost_ob + bjl2.dam.
            else ost_ob = ost_ob - bjl2.cam.
        end. 
        end.
        find last crchis where crchis.crc = txb.aaa.crc and crchis.regdt <= v-dte
         no-lock no-error.      
           ost_ob = ost_ob * crchis.rate[1].

  /*нахождение остатка обязательства*/

      i1 = index(jl.rem[3],":").
      i2 = index(jl.rem[4],":").
      i3 = index(jl.rem[5],":"). 
        if i1 > 0 then  naim_ban  = substr(jl.rem[3], i1 + 1).  
        if i2 > 0 then  naim_ben  = substr(jl.rem[4], i2 + 1).
        if i3 > 0 then  adr_ben   = substr(jl.rem[5], i3 + 1).  

            i1 = index(jl.rem[1], "N").
            i2 = index(jl.rem[1], "от").
            i3 = index(jl.rem[1], "до").
            i4 = index(jl.rem[2], ":").
            i5 = index(jl.rem[2], "Сумма").

      if i1 > 0 and i2 > 0 then   v-garan = trim(substr(jl.rem[1],i1 + 1,i2 - i1 - 1 )). 
      if i2 > 0 and i3 > 0 then   dfrom  =  date(substr(jl.rem[1],i2 + 3,i3 - i2 - 3)).
      if i3 > 0            then   dto = date(substr(jl.rem[1],i3 + 3)).
      if i4 > 0 and i5 > 0 then   v-codfr = trim(substr(jl.rem[2],i4 + 2,i5 - i4 - 2)).
      if i5 > 0            then  do: 
       find last txb.crchis where crchis.crc = jl.crc and crchis.regdt <= jl.jdt no-lock no-error.
       sumzalog = decimal(trim(substr(jl.rem[2],i5 + 6))).
       sumzalog =  sumzalog * crchis.rate[1].
      end.

  if v-codfr = "06" then sumzalog = sum1. /*если обеспечение -  депозит, то сумма обеспечения - сумма 1-ой линии */

  find cjl where cjl.jh = jl.jh and substr(string(cjl.gl),1,1) = '4' no-lock no-error.
   if avail cjl then plat_vyd = cjl.cam. else plat_vyd = 0.

  find txb.crc where txb.crc.crc = jl.crc no-lock no-error.
  v-crc = txb.crc.code.  /*валюта гарантии*/

  find txb.aaa where txb.aaa.aaa = v-aaa no-lock no-error.
   if not avail txb.aaa then message 'not avail' txb.jl.jh txb.jl.acc.
  find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
  v-rnn = txb.cif.jss.

  find txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif  and txb.sub-cod.d-cod = 'clnsts' no-lock no-error.
  if avail txb.sub-cod then v-priz = txb.sub-cod.ccode .
   else message 'Не задан признак клиента (ЮЛ/ФЛ) !!!'.

   if v-priz = '0' then v-priz = '1'.
   else if v-priz = '1' then v-priz = '2'.

  if v-aaa  = "" or v-rnn = "" then message 'Не задан счет и клиент по гарантии '
   skip 'номер транзакции ' txb.jl.jh view-as alert-box.

   find txb.sysc where txb.sysc.sysc = 'clecod' no-lock no-error.
   if avail txb.sysc then v-mfo = txb.sysc.chval. else v-mfo = "".
 

    create t-cif.
    assign t-cif.jh = string(txb.jl.jh)
           t-cif.regdt = txb.jl.jdt
           t-cif.kodbank = v-mfo
           t-cif.kodgbank = '190501914'
           t-cif.rnn = "'" + trim(txb.cif.jss)
           t-cif.ur_phis  = v-priz
           t-cif.vid_ob   =  '20' /*гарантии*/ 
           t-cif.sum_ob  = v-sum 
           t-cif.creditor  = '1' 
           t-cif.val_ob  = v-crc
           t-cif.name = txb.cif.name
           t-cif.naim_ban = naim_ban  
           t-cif.naim_ben = naim_ben  
           t-cif.adr_ben = adr_ben 
           t-cif.nss = nss.
           if v-codfr = "" then  t-cif.vid_obes = "" . else t-cif.vid_obes ="'" + trim(v-codfr).

   assign  t-cif.st_obes = sumzalog
           t-cif.plat_vyd = plat_vyd
           t-cif.num_obyz  = v-garan
           t-cif.ost_ob  = ost_ob
           t-cif.datevyd  = dfrom
           t-cif.datekon  = dto.

   end. /*6055*/
 end. /*jl*/
end.   /*v-dat*/


/*возвращенные гарантии*/ 
do v-dat = v-dtb to v-dte:
 for each txb.jl no-lock  where txb.jl.jdt = v-dat  and substr(string(txb.jl.gl),1,4) = '6055' use-index jdt  :

 if txb.jl.trx <> v-trx2 then next.

    nss = jl.acc. /*ссудный счет*/
    v-sum = jl.cam.  /*сумма гарантии*/
    find txb.aaa where txb.aaa.aaa = nss no-lock no-error.
    find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
 

    create t-cif2.
    assign t-cif2.jh = string(txb.jl.jh)
           t-cif2.regdt = txb.jl.jdt
           t-cif2.sum_ob  = v-sum 
           t-cif2.nss = nss
           t-cif2.name = txb.cif.name
           t-cif2.rnn = "'" + trim(txb.cif.jss).
                
 end. /*jl*/
end.   /*v-dat*/
