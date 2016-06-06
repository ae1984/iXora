/* getdeptxb.i
 * MODULE
    %% по кредитам и штрафам
 * DESCRIPTION
    %% по кредитам и штрафам
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
        22/06/06 nataly
 * CHANGES
        28/06/2006 madiyar - пропускаем кредиты с lon.opnamt = 0
*/

def var v-bal1 as deci no-undo.
def var v-bal2 as deci no-undo.
def var v-bal3 as deci no-undo.
def var v-bal as deci no-undo.

def var v-tax1 as deci no-undo.
def var v-tax2 as deci no-undo.
def var v-tax3 as deci no-undo.
def var v-tax as deci no-undo.

def var v-res as deci no-undo.
def var v-day as integer no-undo.
def var v-gl  as integer.
def var v-gltax  as integer.

def var dt as date .
def buffer  b-cods for txb.cods.

def shared var m1 as integer format 'z9'.
def shared var m2 as integer format 'z9'.
def shared var y1 as integer format '9999'.
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
         index gldep gl dep 
        index jdt is primary   jdt .

v-res = 0.
{getdeptxb.i}

for each t-cods3.
 delete t-cods3.
end.

run   mondays(m2,y1,output v-day)  .
for each txb.lon  no-lock:
  
  if lon.opnamt = 0 then next.
  
  v-bal = 0. v-bal1 = 0. v-bal2 = 0. v-bal3 = 0. v-gl = 0.
  v-tax = 0. v-tax1 = 0. v-tax2 = 0. v-tax3 = 0. v-gltax = 0.
 /*%% по кредитам*/
  find last txb.histrxbal where histrxbal.subled = 'lon' and histrxbal.acc = lon.lon and histrxbal.level = 11 and histrxbal.dt < date(m1,01,y1) and histrxbal.crc = 1 no-lock no-error.
  if avail txb.histrxbal then v-bal1 = histrxbal.cam - histrxbal.dam.

  find last txb.histrxbal where histrxbal.subled = 'lon' and histrxbal.acc = lon.lon and histrxbal.level = 11 and histrxbal.dt <= date(m2,v-day,y1) and histrxbal.crc = 1 no-lock no-error.
  if avail txb.histrxbal then v-bal2 = histrxbal.cam - histrxbal.dam.

  v-bal = v-bal2 - v-bal1. /*остаток %% на дату*/

  find first txb.trxlevgl where trxlevgl.gl = lon.gl and trxlevgl.lev = 11 no-lock no-error . 
   if avail trxlevgl then v-gl =  trxlevgl.glr.
   else do: message 'not avail trxlevgl lev 11 lon= ' lon.lon. next. end.

  /*штрафы*/
  find last txb.histrxbal where histrxbal.subled = 'lon' and histrxbal.acc = lon.lon and histrxbal.level = 16 and histrxbal.dt < date(m1,01,y1) and histrxbal.crc = 1 no-lock no-error.
  if avail txb.histrxbal then v-tax1 = histrxbal.dam - histrxbal.cam.

  find last txb.histrxbal where histrxbal.subled = 'lon' and histrxbal.acc = lon.lon and histrxbal.level = 16 and histrxbal.dt <= date(m2,v-day,y1) and histrxbal.crc = 1 no-lock no-error.
  if avail txb.histrxbal then v-tax2 = histrxbal.dam - histrxbal.cam.

  v-tax = v-tax2 - v-tax1. /*остаток штрафа на дату*/

/*  find first txb.trxlevgl where trxlevgl.gl = lon.gl and trxlevgl.lev = 16 no-lock no-error . 
   if avail trxlevgl then v-gltax =  trxlevgl.glr.
   else do: message 'not avail trxlevgl lev 16 lon= ' lon.lon. next. end.*/
    v-gltax = 490000.

   /*собираем проводки %% и штрафов за день*/
do dt = date(m1,01,y1) to date(m2,v-day,y1):
  for each txb.lonres where lonres.lon = lon.lon and lonres.jdt = dt  and (lonres.lev = 11 or lonres.lev = 16)  no-lock:
    if lonres.lev = 11 then do:
     if lonres.dc = 'c' then v-bal3 = v-bal3 - lonres.amt.
     else v-bal3 = v-bal3 + lonres.amt.
    end.
    if lonres.lev = 16 then do:
     if lonres.dc = 'd' then v-tax3 = v-tax3 - lonres.amt.
     else v-tax3 = v-tax3 + lonres.amt.
    end.
  end.
 end.

 v-bal = v-bal + v-bal3. /*остаток на дату + проводки за день по %% по кредиту*/
 v-tax = v-tax + v-tax3. /*остаток на дату + проводки за день по штрафам */
 
 if v-bal <= 0 then do:
    v-bal = 0. 
  end.

 if v-tax <= 0 then do:
    v-tax = 0. 
  end.

 if v-gl <> 0 then  find first txb.cods  where cods.gl = v-gl no-lock no-error. if not avail cods 
 then do:
      message 'Не найден код доходов для счета ' lon.lon dt. 
      next.
  end.

 if v-gltax <> 0 then  find first b-cods  where b-cods.gl = v-gltax no-lock no-error. if not avail b-cods 
 then do:
      message 'Не найден код доходов для счета ' lon.lon dt. 
      next.
  end.
  /*формируем таблицу расшифровки  %% доходов  по департаментам*/
    find t-cods3 where t-cods3.code = cods.code and t-cods3.dep = getdep(txb.lon.cif)  and t-cods3.crc = 'kzt' and 
      t-cods3.gl = v-gl and t-cods3.who = 'bankadm' and t-cods3.jdt = dt no-error.
  if not avail t-cods3 then do: 
  create t-cods3.
    assign 
            t-cods3.code = cods.code
            t-cods3.dep  = getdep(txb.lon.cif)
            t-cods3.crc  = 'kzt'
            t-cods3.gl   = v-gl
            t-cods3.jdt  = date(m2,v-day,y1)
            t-cods3.who  = 'bankadm'
            t-cods3.acc  =  ""
            t-cods3.dam  = 0.

  end.
            t-cods3.cam  =  t-cods3.cam + v-bal.

  /*формируем таблицу расшифровки  штрафов по департаментам*/
    find t-cods3 where t-cods3.code = b-cods.code and t-cods3.dep = getdep(txb.lon.cif)  and t-cods3.crc = 'kzt' and 
      t-cods3.gl = v-gltax and t-cods3.who = 'bankadm' and t-cods3.jdt = dt no-error.
  if not avail t-cods3 then do: 
  create t-cods3.
    assign 
            t-cods3.code = b-cods.code
            t-cods3.dep  = getdep(txb.lon.cif)
            t-cods3.crc  = 'kzt'
            t-cods3.gl   = v-gltax
            t-cods3.jdt  = date(m2,v-day,y1)
            t-cods3.who  = 'bankadm'
            t-cods3.acc  =  ""
            t-cods3.dam  = 0.

  end.
            t-cods3.cam  =  t-cods3.cam + v-tax.
  /* v-res = v-res + v-bal.*/
end.   /*lon*/


