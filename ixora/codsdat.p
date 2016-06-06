/* codsdat.p
 * MODULE
        Отчет по кодам доходов/расходов операций
 * DESCRIPTION
        Отчет по кодам доходов/расходов операций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        r-cods.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-7-3-14
 * AUTHOR
        29/04/05 nataly
 * CHANGES
        26.05.05 nataly был ускорен алгоритм работы программы
        29/09/05 nataly было детализировано начисление %% по счетам - таблица t-cods3
        25.11.05 nataly добавлен выбор счета ГК 
        19/06/06 nataly убраны проводки по свертке доходов-расходов, по конвертации
        09/11/06 nataly при разбивке по депозитам поставила dt
*/



def shared var v-date as date.
def shared var v-date2 as date.
def shared var v-gl as char.

def shared temp-table t-cods 
	field code like bank.cods.code   
	field dep  like bank.cods.dep 
	field crc  like bank.crc.code
	field gl   like bank.jl.gl
	field dam  like bank.jl.dam
	field cam  like bank.jl.cam
	field acc  like bank.jl.acc
	field jdt  like bank.jl.jdt
	field rem  as char 
	field jh   like bank.jl.jh
	field who  like bank.jl.who 
        index jdt is primary   jdt .

def shared temp-table t-cods3 
	field code like bank.cods.code   
	field dep  like bank.cods.dep 
	field crc  like bank.crc.code
	field gl   like bank.jl.gl
	field dam  like bank.jl.dam
	field cam  like bank.jl.cam
	field who  like bank.jl.who 
	field acc  like bank.jl.acc
	field jdt  like bank.jl.jdt
        index jdt is primary   jdt .

def input parameter p-bank as char.
def output parameter p-name as char.

def var v-acc as char no-undo.
def var v-crc as char no-undo.
def var v-rate as decimal no-undo.
def var dt as date  no-undo.

def var v-dep as char no-undo. 
def var v-code as char no-undo.


find first txb.cmp no-lock no-error.
if avail txb.cmp then p-name = txb.cmp.name.

{getdeptxb.i}

do dt = v-date to v-date2:
for each txb.gl no-lock where string(gl.gl) begins v-gl.
for each txb.jl  no-lock where jdt = dt and txb.jl.gl = txb.gl.gl use-index jdt.

  if trim(txb.jl.rem[1]) begins 'Свертка '  then next.
  if trim(txb.jl.rem[1]) begins 'CONVERSION ' then next.

  find first txb.trxcods where txb.trxcods.trxh = jl.jh and txb.trxcods.trxln = jl.ln and trxcods.trxt = 0 and codfr = 'cods' use-index trxcd_idx  no-lock no-error.
  if not avail txb.trxcods then next.
  for each txb.trxcods no-lock where trxh = jl.jh  and trxcods.trxln = jl.ln and  trxcods.trxt = 0 and codfr = 'cods' use-index trxcd_idx .

   find txb.crc where crc.crc = jl.crc no-lock no-error.
   if avail txb.crc  then v-crc = crc.code. else v-crc = "".

   find txb.cods where cods.code = trxcods.code no-lock no-error.
   if avail txb.cods  then v-acc = cods.acc. else v-acc = "".

   find last txb.crchis where crchis.crc = jl.crc 
       and crchis.rdt <= dt   use-index crcrdt no-lock no-error.
   if not available txb.crchis then do:  
     message 'Не задан курс для валюты ' jl.crc .
     v-rate =  1. 
   end.
   else do: 
     v-rate =  crchis.rate[1]. 
    end. 
    create t-cods.
       assign 
            t-cods.code = substr(trxcods.code,1,7)
            t-cods.dep = substr(trxcods.code,8,3)
            t-cods.crc = v-crc
            t-cods.gl  =  jl.gl
            t-cods.jdt = jl.jdt
            t-cods.acc =  v-acc
            t-cods.rem = jl.rem[1]
            t-cods.jh  = jl.jh
            t-cods.who = jl.who.
         if txb.jl.dam <> 0 then  t-cods.dam = jl.dam * v-rate .  else t-cods.cam = jl.cam * v-rate. 
     {dat.i}
  end.
 end.
 end. /*gl*/
end. /*dt*/

  if v-gl begins '4411' or v-gl begins '4417' or v-gl begins '4900' then 
   do:
     run lon1116n. 
   end.
   /*раскидываем расходы по депозитам*/
if v-gl begins '5' then do:
 do dt = v-date to v-date2:
  for each t-cods where t-cods.who = 'bankadm'  and t-cods.jdt = dt and t-cods.dam <> 0 break by t-cods.gl .
   if first-of(t-cods.gl) then do:
   for each txb.accr where accr.fdt = dt and accr.gl = t-cods.gl.
       find first txb.cods where txb.cods.gl = t-cods.gl no-lock no-error.

    find t-cods3 where t-cods3.code = cods.code and t-cods3.dep = accr.dep  and t-cods3.crc = 'kzt' and 
      t-cods3.gl = t-cods.gl and t-cods3.who = 'bankadm' and t-cods3.jdt = t-cods.jdt no-error.
   if not avail t-cods3 then do: 

   create t-cods3.
      find  txb.aaa where aaa.aaa = accr.aaa no-lock no-error.
      find last txb.crchis where crchis.crc = aaa.crc and crchis.whn <= dt no-lock no-error.

       assign 
            t-cods3.code = t-cods.code
            t-cods3.dep  = accr.dep
            t-cods3.crc  = 'kzt'
            t-cods3.gl   =  t-cods.gl
            t-cods3.jdt  = t-cods.jdt
            t-cods3.who  =  t-cods.who
            t-cods3.acc  =  ""
            t-cods3.cam  = 0.
     end.
            t-cods3.dam  =  t-cods3.dam +  accr.accrued * crchis.rate[1].
    end.  /*accr*/
   end.  /*gl*/
  end.  /*t-cods*/
 end. /*dt*/
end.
