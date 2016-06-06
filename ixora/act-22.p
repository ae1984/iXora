/* act-22.p
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
        19.08.2003 nadejda - для ускорения работы добавлены индексы во временную таблицу и оптимизированы циклы
*/

def  shared  temp-table temp  /*workfile*/
    field aaa  as char format "x(10)"
    field expdt  as date
    field gl   as integer
    field gltot   as integer 
    field priz as integer 
    field prd as integer
    field crc as integer 
    field subled as char
    field bal  as decimal
    field bal2 as decimal 
    field bal3 as decimal 
    field balrate  as  decimal
    field rate  as  decimal
    field totprd as decimal
    field valrate  as  decimal
    index priz is primary priz
    index priz1 priz prd
    index priz2 priz crc prd
    index priz3 priz gl
    index priz4 priz gltot prd.

def  shared var i as int. 
def  shared var j as int init 1. 
def  shared var v_text as char extent 8.
def  shared var v-gl as char extent 8.
def  shared var v-prd as integer.
def  shared var vdt as date.
def  var v-expdt as date.

/*message vdt. pause 400.*/

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
hide message no-pause.
message "Обрабатывается филиал  - " trim(txb.sysc.chval) .

do j =  1 to 8:
  /* message "j =  "  j. pause 400.
    */
do i =  1 to NUM-ENTRIES(v-gl[j]):
for each bank.gl where 
integer(substr(string(bank.gl.gl),1,4)) = integer(entry(i,v-gl[j])) and totlev  = 1 no-lock.

   /* проверка %% уровня по 1-му уровню */
  /* find trxlevgl where trxlevgl.gl eq gl.gl and trxlevgl.subled eq gl.subled 
       and  trxlevgl.level eq 2 no-lock no-error.
    if available trxlevgl then do : message substr(string(trxlevgl.glr),1,4). 
       pause 50. end.
   else do : message  " not avail " 
    substr(string(gl.gl),1,6) gl.subled. pause     50. end. */

case  bank.gl.subled :
 when "cif" then do: 

   c-aaa:   
   for each txb.aaa where txb.aaa.gl = bank.gl.gl no-lock: /*and 
  (txb.aaa.cr[1] - txb.aaa.dr[1] <> 0 or txb.aaa.cr[2] - txb.aaa.dr[2] <> 0 ): 19.08.2003 nadejda */

     if (txb.aaa.cr[1] = txb.aaa.dr[1]) and (txb.aaa.cr[2] = txb.aaa.dr[2]) then next c-aaa.

 /*должны учитываться  просроченные счета, у котрых осн долг = 0,
     а 2-ой уровень не равен нулю */

     v-prd = txb.aaa.expdt  - vdt. 
     if v-prd < 0 then  v-prd = 0.

     create temp. 
     assign temp.priz =  j
            temp.prd = v-prd
            temp.expdt = txb.aaa.expdt
            temp.aaa = txb.aaa.aaa
            temp.crc = txb.aaa.crc 
            temp.subled = bank.gl.subled
            temp.gl  = bank.gl.gl 
            temp.rate = txb.aaa.rate
            temp.gltot = 999999. 

     find last bank.crchis where bank.crchis.crc = txb.aaa.crc 
           and bank.crchis.rdt <= vdt  use-index crcrdt no-lock no-error.
     if bank.gl.type eq "A" or bank.gl.type eq "E" then 
          temp.bal = (txb.aaa.dr[1] - txb.aaa.cr[1] +  txb.aaa.dr[2] - txb.aaa.cr[2]) * bank.crchis.rate[1].
     else temp.bal = (txb.aaa.cr[1] - txb.aaa.dr[1] + txb.aaa.cr[2] - txb.aaa.dr[2]) * bank.crchis.rate[1].
  end.  /*each aaa*/

 end. /*when "cif"*/
 
 when "arp" then do:
 c-arp:
 for each txb.arp where txb.arp.gl = bank.gl.gl /*and   txb.arp.cam[1] - txb.arp.dam[1] <> 0*/ no-lock : 
    if txb.arp.cam[1] = txb.arp.dam[1] then next c-arp.
  /*   v-prd = 0. */
    v-prd = txb.arp.duedt  - vdt. 
    if v-prd < 0 then  v-prd = 0.
     create temp. 
     assign temp.priz =  j
            temp.prd = v-prd
            temp.expdt = ?
            temp.aaa = txb.arp.arp
            temp.crc = txb.arp.crc 
            temp.subled = bank.gl.subled
            temp.gl  = bank.gl.gl
            temp.rate = 0
            temp.balrate = 0
            temp.gltot = 999999
            temp.valrate = 0. 
            
   
     find last bank.crchis where bank.crchis.crc = txb.arp.crc 
         and bank.crchis.rdt <= vdt  use-index crcrdt no-lock no-error.

      if bank.gl.type eq "A" or bank.gl.type eq "E" then 
           temp.bal = (txb.arp.dam[1] - txb.arp.cam[1] +  txb.arp.dam[2] - txb.arp.cam[2]) * bank.crchis.rate[1].
      else temp.bal = (txb.arp.cam[1] - txb.arp.dam[1] +  txb.arp.cam[2] - txb.arp.dam[2]) * bank.crchis.rate[1].
   end. /*each arp*/
  end. /*when "arp"*/

 when "fun" then do:
  c-fun:
  for each txb.fun where  txb.fun.gl = bank.gl.gl /*and txb.fun.cam[1] - txb.fun.dam[1] <> 0*/ no-lock:
     if txb.fun.cam[1] = txb.fun.dam[1] then next c-fun.

     v-prd = txb.fun.duedt  - vdt. 
     
     if v-prd < 0 then  v-prd = 0.
     create temp. 
     assign temp.priz =  j
            temp.prd = v-prd
            temp.expdt = txb.fun.duedt
            temp.aaa = txb.fun.fun
            temp.crc = txb.fun.crc 
            temp.subled = bank.gl.subled
            temp.gl  = bank.gl.gl
            temp.rate = txb.fun.intrate
            temp.gltot = 999999. 

     find last bank.crchis where crchis.crc = txb.fun.crc and bank.crchis.rdt <= vdt  use-index crcrdt no-lock no-error.

      if bank.gl.type eq "A" or bank.gl.type eq "E" then 
           temp.bal = (txb.fun.dam[1] - txb.fun.cam[1]  + txb.fun.dam[2] - txb.fun.cam[2]) * bank.crchis.rate[1].
      else temp.bal = (txb.fun.cam[1] - txb.fun.dam[1] +  txb.fun.cam[2] - txb.fun.dam[2]) * bank.crchis.rate[1].
    end. /*for each fun*/
  end. /*when "fun"*/

 when "dfb" then do:
  c-dfb:
  for each txb.dfb where  txb.dfb.gl = bank.gl.gl /*and txb.dfb.dam[1] - txb.dfb.cam[1] <> 0*/ no-lock:
     if txb.dfb.dam[1] = txb.dfb.cam[1] then next c-dfb.

   v-prd = txb.dfb.duedt  - vdt. 
     if v-prd < 0 then  v-prd = 0.
     create temp. 
     assign temp.priz =  j
            temp.prd = v-prd
            temp.expdt =  txb.dfb.duedt
            temp.aaa = txb.dfb.dfb
            temp.crc = txb.dfb.crc 
            temp.subled = bank.gl.subled
            temp.gl  = gl.gl
            temp.rate = txb.dfb.intrate
            temp.gltot = 999999. 

     find last bank.crchis where bank.crchis.crc = txb.dfb.crc and bank.crchis.rdt <= vdt  use-index crcrdt no-lock no-error.

      if bank.gl.type eq "A" or bank.gl.type eq "E" then 
           temp.bal = (txb.dfb.dam[1] - txb.dfb.cam[1] + txb.dfb.dam[2] - txb.dfb.cam[2] ) * bank.crchis.rate[1].
      else temp.bal = (txb.dfb.cam[1] - txb.dfb.dam[1] + txb.dfb.cam[2] - txb.dfb.dam[2]) * bank.crchis.rate[1].
    end. /*for each dfb*/
  end. /*when "dfb"*/

  when "lon" then do: 
   c-lon:
   for each txb.lon where  txb.lon.gl = bank.gl.gl no-lock use-index gl:
    /*and (txb.lon.dam[1] - txb.lon.cam[1] <> 0  or txb.lon.dam[2] - txb.lon.cam[2] <> 0 ):*/
     if txb.lon.dam[1] = txb.lon.cam[1] and txb.lon.dam[2] = txb.lon.cam[2] then next c-lon.

     create temp. 
     assign temp.priz =  j
            temp.aaa = txb.lon.lon
            temp.crc = txb.lon.crc 
            temp.subled = bank.gl.subled
            temp.gl  = bank.gl.gl. 

     if txb.lon.cdt[5] <> ? then  temp.expdt = txb.lon.cdt[5].
     else 
       if txb.lon.ddt[5] <> ? then temp.expdt =  max(txb.lon.duedt,txb.lon.ddt[5]). 
                              else temp.expdt = txb.lon.duedt.

     v-prd = temp.expdt - vdt. 
     if v-prd < 0 then v-prd = 0.

     find first txb.ln%his where txb.ln%his.lon = txb.lon.lon no-lock no-error.

     assign temp.prd = v-prd.    
            temp.rate = txb.ln%his.intrate.
            temp.gltot = 999999. 

     find last bank.crchis where bank.crchis.crc = txb.lon.crc and bank.crchis.rdt <= vdt  use-index crcrdt no-lock no-error.

      if bank.gl.type eq "A" or bank.gl.type eq "E" then 
           temp.bal = (txb.lon.dam[1] - txb.lon.cam[1] +  txb.lon.dam[2] - txb.lon.cam[2]) * bank.crchis.rate[1].
      else temp.bal = (txb.lon.cam[1] - txb.lon.dam[1] + txb.lon.cam[2] - txb.lon.dam[2]) * bank.crchis.rate[1].
  end. /*for each lon*/
end. /*when lon*/

 otherwise  do: 
/*
 if bank.gl.subled <> "" then do: 
    message "НЕ ОБСЧИТЫВАЕТСЯ СЧЕТ ГК " gl.gl 
    " subled= "  bank.gl.subled. pause 1. end.
*/    
     for each txb.glbal where txb.glbal.gl = bank.gl.gl and txb.glbal.bal <> 0 no-lock.
       create temp.
       assign temp.aaa = "000000000"
              temp.crc = txb.glbal.crc
              temp.subled = bank.gl.subled
              temp.gl  = bank.gl.gl 
              temp.gltot = 999999
              temp.prd = 0
              temp.rate = 0
              temp.valrate = 0 
              temp.balrate = 0
              temp.priz =  j.
       
       find last bank.crchis where bank.crchis.crc = txb.glbal.crc and bank.crchis.rdt <= vdt  use-index crcrdt no-lock no-error.
       temp.bal = txb.glbal.bal * bank.crchis.rate[1].

   /*    find first txb.cif no-lock. 
   message  txb.cif.cif " " txb.glbal.bal  " "  bank.crchis.rate[1] " " temp.bal. pause 300.
   */
    
      end.
    end. /*otherwise*/
end case.


  end. /*gl*/
 end. /*i*/
end. /*j*/

/*ввиду того , что остатки по гк 1465 (3-ий уровень) хранятся 
только в trxbal */

 for each  txb.trxbal where txb.trxbal.subled = "lon" and  
       (txb.trxbal.lev = 3) and txb.trxbal.dam - txb.trxbal.cam <> 0 no-lock.

   find  temp where temp.subled eq "lon" and  temp.aaa = txb.trxbal.acc no-error.
   find last bank.crchis where bank.crchis.crc = txb.trxbal.crc and bank.crchis.rdt <= vdt  use-index crcrdt no-lock no-error.

  if available temp then 
/*      temp.bal2 =  (trxbal.cam - trxbal.dam) * bank.crchis.rate[1]. */
      temp.bal =  temp.bal +  (trxbal.dam - trxbal.cam) * bank.crchis.rate[1]. 
   else do:
     find txb.lon where txb.lon.lon = txb.trxbal.acc no-lock no-error.
     v-prd = txb.lon.duedt  - vdt. 
     if v-prd < 0 then  v-prd = 0.
    create temp. temp.priz = 3. temp.gltot = 999999. temp.crc = txb.trxbal.crc. 
    temp.prd  = v-prd.  temp.aaa = txb.trxbal.acc.
    temp.bal  =  temp.val + (trxbal.cam - trxbal.dam) * bank.crchis.rate[1]. 
/*    temp.bal2 =  (trxbal.dam - trxbal.cam) * bank.crchis.rate[1]. */
   end.
  
end.

/*ввиду того , что остатки по гк 1439 (6-ой уровень) хранятся 
только в trxbal */

 for each  txb.trxbal where txb.trxbal.subled = "lon" and  
       (txb.trxbal.lev = 6) and txb.trxbal.dam - txb.trxbal.cam <> 0 no-lock.

   find  temp where temp.subled eq "lon" and  temp.aaa = txb.trxbal.acc no-error.
   find last bank.crchis where bank.crchis.crc = txb.trxbal.crc and bank.crchis.rdt <= vdt  use-index crcrdt no-lock no-error.
   if available temp then 
     temp.bal = temp.bal +  (trxbal.dam - trxbal.cam) * bank.crchis.rate[1]. 
/*     temp.bal3 =  (trxbal.dam - trxbal.cam) * bank.crchis.rate[1]. */
   else do:
     find txb.lon where txb.lon.lon = txb.trxbal.acc no-lock no-error.
     v-prd = txb.lon.duedt  - vdt. 
     if v-prd < 0 then  v-prd = 0.
     create temp. temp.priz = 3. temp.gltot = 999999. temp.crc = txb.trxbal.crc. 
     temp.prd  = v-prd. temp.aaa = txb.trxbal.acc.
     temp.bal  =  temp.bal + (trxbal.dam - trxbal.cam) * bank.crchis.rate[1]. 
/*    temp.bal3 =  (trxbal.dam - trxbal.cam) * bank.crchis.rate[1]. */
   end.
  
end.
