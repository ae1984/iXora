/* zatratdat.p
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
        8-7-3-12
 * AUTHOR
        29/04/05 nataly
 * CHANGES
        22/06/06 nataly убрала проводки по свертке доходов-расходов + конвертацию + добавила обработку рачетов командировочных по tn
*/

def shared var v-date as date.
def shared var v-date2 as date.
define shared var v-pril as char .

{getdeptxb.i}

/*def shared temp-table temp 
        field tn   like  bank.ofc-tn.tn
        field name like bank.ofc-tn.name
        field dep like bank.ofc-tn.dep
	field depname  like bank.ofc-tn.depname
	field post  as char
	field mon as integer
	field oklad as decimal
	field otpusk as decimal
	field nadb as decimal
	field prem as decimal
	field posob as decimal
	field hlp as decimal
	field nalog as decimal
	field otch as decimal
        index dep is primary   dep .
*/
def shared temp-table t-cods 
	field code like bank.cods.code   
	field dep  like bank.cods.dep 
	field crc  like bank.crc.code
	field gl   like bank.jl.gl
	field dam  like bank.jl.dam
	field cam  like bank.jl.cam
	field acc  like bank.jl.acc
	field jdt  like bank.jl.jdt
	field jh   like bank.jl.jh
	field who  like bank.jl.who 
	field rem  as char 
	field ls  like bank.jl.acc
	field rnn as char format 'x(9)'
         index jh jh 
         index glcods is primary gl code .


def new shared temp-table t-cods3 
	field code like bank.cods.code   
	field dep  like bank.cods.dep 
	field crc  like bank.crc.code
	field gl   like bank.jl.gl
	field dam  like bank.jl.dam
	field cam  like bank.jl.cam
	field who  like bank.jl.who 
	field acc  like bank.jl.acc
	field jdt  like bank.jl.jdt
         index gldep gl dep 
         index jdt is primary   jdt .

def temp-table tgl 
   field gl like bank.gl.gl.
 
def buffer t-cods2 for t-cods.
def input parameter p-bank as char no-undo.
def output parameter p-name as char no-undo.
def output parameter p-code as integer no-undo.
def var i as integer no-undo.

def var v-acc as char no-undo.
def var v-crc as char no-undo.
def var v-rate as decimal no-undo.
def var dt as date  no-undo.
def var v-day as integer no-undo.
def var v-jh as integer no-undo.
def var v-ls as char no-undo.

def shared var m1 as integer format 'z9'.
def shared var m2 as integer format 'z9'.
def shared var y1 as integer format '9999'.
def shared  var v-attn as char.

/*nataly*/
def var v-tarif as char no-undo.
def var v-dep as char no-undo. 
def var v-code as char no-undo.
def var v-gl like txb.jl.gl no-undo.
def buffer bjl for txb.jl.
/*nataly*/

def  var v-pr as char.

def buffer b-jl for txb.jl.
find first txb.cmp no-lock no-error.
if avail txb.cmp then p-name = txb.cmp.name.

  find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error .
     if not avail txb.sysc or txb.sysc.chval = "" then do:
         display " This isn't record OURBNK in bank.sysc file !!".
         pause.
         return ?.
     end.

     p-code = integer(substr(trim(txb.sysc.chval),4,2)).

run   mondays(m2,y1,output v-day)  .

/*расчет затрат по ОС*/
if integer(v-pril) = 3   or  integer(v-pril) = 21  then  run zatrat1.

if v-pril <> '21' and v-pril <> '35' then do:

 find bank.sysc where bank.sysc.sysc = 'pr' + v-pril no-lock no-error.
 if avail bank.sysc  then v-pr = bank.sysc.chval.

 if v-pril begins '0' then v-pril = substr(v-pril,2,1).
 find bank.sysc where bank.sysc.sysc = 'pr' + v-pril no-lock no-error.
 if not avail bank.sysc  then displ 'Не найден код'  v-pril.

  do i = 1 to num-entries(bank.sysc.chval).
  for each txb.cods where cods.code begins entry(i, bank.sysc.chval).
   if txb.cods.gl <> 0 then do:
     create tgl.
      tgl.gl = cods.gl.
   end.
  end.
  end.

/*расчет по кодам дох-расходов*/
do dt = date(m1,01,y1) to date(m2,v-day,y1):

for each tgl no-lock .
for each txb.jl  no-lock where jdt = dt and txb.jl.gl = tgl.gl .
 
  if trim(txb.jl.rem[1]) begins 'Свертка '  then next.
  if trim(txb.jl.rem[1]) begins 'CONVERSION ' then next.

  find first txb.trxcods where txb.trxcods.trxh = jl.jh and txb.trxcods.trxln = jl.ln and trxcods.trxt = 0 and codfr = 'cods' use-index trxcd_idx  no-lock no-error.
  if not avail txb.trxcods  then  next. 
/*  if  not txb.trxcods.code begins '6' then next.*/

   find txb.crc where crc.crc = jl.crc no-lock no-error.
   if avail txb.crc  then v-crc = crc.code. else v-crc = "".

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
            t-cods.jh  = jl.jh
            t-cods.rem = jl.rem[1]
            t-cods.who = jl.who.
         if txb.jl.dam <> 0 then  t-cods.dam = jl.dam * v-rate .  else t-cods.cam = jl.cam * v-rate. 

     {dat.i}

 if NUM-ENTRIES(jl.rem[1], "/") > 1  and length(trim(entry(2 ,jl.rem[1], "/"))) > 4 then do:
 do i = 2 to  /* NUM-ENTRIES(jl.rem[1], "/") by 2.*/  2.

   if length(trim(entry(i  ,jl.rem[1], "/"))) > 4 then do:
   t-cods.ls =  trim(substr(trim(entry(i  ,jl.rem[1], "/")), length(trim(entry(i,jl.rem[1], "/"))) - 4)).
   if t-cods.ls begins '*' then t-cods.ls = substr(t-cods.ls,2).
     else if not trim(t-cods.ls) begins '0' then t-cods.ls = "".
  end.
 end.
/*  displ t-cods.ls.*/
end. 
end.
 end. /*gl*/
end. /*dt*/

/* displ string(time,('hh:mm:ss')).*/

def buffer bt-cods for t-cods.
 /*переносим номера лицевых карточек на другие расходы с тем же номером проводки*/
for each t-cods where t-cods.ls <> "".
  for each bt-cods where bt-cods.jh = t-cods.jh  use-index jh .
       if bt-cods.ls = "" then    bt-cods.ls = t-cods.ls.
  end. 
end. 
end. 
else do:  /*сводная отчетность*/

 displ string(time,('hh:mm:ss')).
    
do dt = date(m1,01,y1) to date(m2,v-day,y1):

for each txb.gl no-lock where totlev = 1 and (if v-pril = '21' then string(gl.gl) begins '5' else string(gl.gl) begins '4') .
for each txb.jl  no-lock where jdt = dt and txb.jl.gl = txb.gl.gl  
 use-index jdt.
 
  if trim(txb.jl.rem[1]) begins 'Свертка '  then next.
  if trim(txb.jl.rem[1]) begins 'CONVERSION ' then next.

  find first txb.trxcods where txb.trxcods.trxh = jl.jh and txb.trxcods.trxln = jl.ln and trxcods.trxt = 0 and codfr = 'cods' use-index trxcd_idx  no-lock no-error.
  if not avail txb.trxcods  then  next. 
/*  if  not txb.trxcods.code begins '6' then next.*/

   find txb.crc where crc.crc = jl.crc no-lock no-error.
   if avail txb.crc  then v-crc = crc.code. else v-crc = "".

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
            t-cods.jh  = jl.jh
            t-cods.rem = jl.rem[1]
            t-cods.who = jl.who.
         if txb.jl.dam <> 0 then  t-cods.dam = jl.dam * v-rate .  else t-cods.cam = jl.cam * v-rate. 

     {dat.i}

 if NUM-ENTRIES(jl.rem[1], "/") > 1  and length(trim(entry(2 ,jl.rem[1], "/"))) > 4 then do:
 do i = 2 to  /* NUM-ENTRIES(jl.rem[1], "/") by 2.*/  2.

   if length(trim(entry(i  ,jl.rem[1], "/"))) > 4 then do:
   t-cods.ls =  trim(substr(trim(entry(i  ,jl.rem[1], "/")), length(trim(entry(i,jl.rem[1], "/"))) - 4)).
   if t-cods.ls begins '*' then t-cods.ls = substr(t-cods.ls,2).
     else if not trim(t-cods.ls) begins '0' then t-cods.ls = "".
  end.
 end.
/*  displ t-cods.ls.*/
end. 
end.  /*jl*/
 end. /*gl*/
end.   /*dt*/
  
 displ string(time,('hh:mm:ss')).

 /*переносим номера лицевых карточек на другие расходы с тем же номером проводки*/
for each t-cods where t-cods.ls <> "".
  for each bt-cods where bt-cods.jh = t-cods.jh  use-index jh .
       if bt-cods.ls = "" then    bt-cods.ls = t-cods.ls.
  end. 
end. 
end.
  
/*для сводной или отдельной отчетности перераспределяем нули начисл %% и штрафы по кредитам*/
if v-pril = '35' or v-pril = '30' then do:
run lon1116. 

for each t-cods where (string(t-cods.gl) begins '4411'  or string(t-cods.gl) begins '4417' or string(t-cods.gl) begins '4900').
 if (t-cods.who = 'bankadm' or t-cods.who = 'superman') and t-cods.dep = '000' then do:
  delete t-cods. 
 end.
end.
/*
def stream rpt. 
output stream rpt to 'qqq.txt'.
*/
for each t-cods3 break by t-cods3.gl by t-cods3.dep.
  accum t-cods3.cam (total by t-cods3.gl by t-cods3.dep).
  if last-of(t-cods3.dep) then do: 
    create t-cods.
    buffer-copy t-cods3 to t-cods.
     t-cods.cam =  accum total by t-cods3.dep t-cods3.cam .
    /*  displ stream rpt skip t-cods.code t-cods.dep t-cods.jdt t-cods.gl t-cods.dam t-cods.cam.*/
  end.                    
end.
/*output stream rpt close.*/
end. /*pril = 35 or 30*/