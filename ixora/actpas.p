/* actpas.p
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

/*BIEF AUDIT REPORT. Actives + PASSIVES. 
                         08/08/02    */
def stream rpt.
def buffer a-crchis for crchis.
def buffer b-crchis for crchis.
def var bal_crc as decimal.
def var balrate_crc as decimal.
def var balrate2_crc as decimal.

def var bal_rate as decimal. 
def var balrate_rate as decimal.
def var balrate2_rate as decimal.

def var bal_prd as decimal.
def var balrate_prd as decimal.
def var balrate2_prd as decimal.
def var fname as character format "x(12)" .
def var vasof as date.
def var prd-tot as decimal extent 9.
/*
define new shared variable m as integer.
define new shared variable g as integer.
*/
def var k as integer.
output stream rpt to gap.csv.

def buffer bjl for jl.
def new  shared  temp-table temp  /*workfile*/
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

def buffer b-temp for temp.

def  new shared var v_text as char extent 8.
def  var tot as decimal  extent 16.

def var vgl as integer format 'zzzz'.
def var vcrc as char.
def var strvgl as character.

def var prz as integer.
def new shared var i as int. 
def new shared var j as int init 1. 
def new shared var v-prd as integer.
def new shared var vdt as date.


def var chc as char.
def var v-group as char.   
def new shared var v-gl as char extent 8.
def var sum as decimal.
def var sum22 as decimal.
def var sum2 as decimal.
def var sum3 as decimal.
def var sum-total as decimal.
def var hostmy   as char format 'x(15)'.
def var dirc     as char format 'x(15)'.
def var ipaddr   as char format 'x(15)'.

def new shared var v-pass as char.
for each sysc where sysc.sysc="SYS1" no-lock.
v-pass = ENTRY(1,sysc.chval).
end.

def new shared var dt$ as date .

def new shared temp-table tgl
field tgl as int format ">>>>"
field tcrc as integer
field tsum1 as dec format "->>>>>>>>>>>>>>9.99"
field tsum2 as dec format "->>>>>>>>>>>>>>9.99".
/*
m = month(today).
g = year(today).

update m label "Введите месяц расчета"
       g format "99" label "Введите год расчета" .
*/
find last bank.cls.
dt$ = bank.cls.whn.

/*dirc = 'L:/capital/common/audit'. */
find sysc where sysc.sysc eq "GLDATE" no-lock no-error.
vasof = sysc.daval.
fname = 'audit' +  substring(string(vasof),1,2) + substring(string(vasof),4,2) + '.txt'.

 {global.i}          

Function GetPeriod returns integer (input exp_dt as date,input curdate as date ).

 if exp_dt > curdate then do:
    return 0.
 end.
 else return 1.
End Function.

find last cls.
vdt = cls.whn. /*not cls.whn*/

display '   Ждите...   '  with row 5 frame ww centered .

 v_text[1] = 'ДЕН.СРЕД '.
 v_text[2] = 'БАНКИ АКТ'.
 v_text[3] = 'ССУДЫ    '.
 v_text[4] = 'ЦЕН.БУМ А '.

 v_text[5] = 'БАНКИ ПАС'.
 v_text[6] = 'КЛИЕНТЫ  '.
 v_text[7] = 'СУБ ДОЛГ '.
 v_text[8] = 'ЦЕН.БУМ П '.
    

v-gl[1] = '1001,1002,1003,1004,1005,1006,1051,1102,1103'.
v-gl[2] = '1251,1252,1253,1254,1255,1256,1257,1269,1301,1302,1303,1304,1305,1306,1307,1308,1339,1052,1053,1101,1725,1730,1732,1456'.
v-gl[3] = '1401,1403,1405,1407,1408,1411,1414,1417,1420,1422,1424,1425,1427,1439,1440,1465,1740,1742,1749,1468'.
v-gl[4] = '1201,1202,1451,1452,1454,1470,1472,1475,1745,1742,1747'.

v-gl[5] = '2011,2012,2013,2021,2022,2023,2051,2052,2053,2054,2055,2056,2057,2058,2059,2064,2065,2066,2068,2111,2112,2113,2121,2122,2123,2124,2125,2127,2551,2552,2702,2705,2706,2711,2712'.
v-gl[6] = '2201,2202,2203,2207,2211,2215,2217,2219,2221,2222,2223,2224,2225,2226,2227,2228,2229,2720,2721,2722'.
v-gl[7] = '2401,2402'.
v-gl[8] = '2301,2302,2303,2351,2352,2353,2355'.

/*-------*/
/* run comm-con.   suchkov - Убрал 
run a22.p.                            */
run a22.

 for each temp where temp.prd = ? or temp.prd = 0. 
     temp.prd = 1. 
 end.

  /*  вывод промежуточных данных*/
/*for each temp where temp.priz = 3 break by temp.priz 
      by  substr(string(temp.gl),1,4) . 
  
   ACCUMULATE temp.bal (total by  temp.priz  by substr(string(temp.gl),1,4)).
  if first-of(temp.priz) then put stream rpt skip 'temp.priz= ' temp.priz.
 put stream rpt skip  
   temp.aaa ' ' temp.subled ' '  temp.crc ' '     
   temp.expdt ' '  temp.prd ' ' temp.gl format 'zzzzzz' 
  temp.bal / 1000 format '->>>>>>>>>>9' at 65 ';' .

 if last-of(substr(string(temp.gl),1,4)) then  do:
  sum = ACCUMulate total  by (substr(string(temp.gl),1,4)) temp.bal.   
   put stream rpt skip sum / 1000 format '->>>>>>>>>>9' at 55 ';'.   
  end.

end. */
/*    ----------    */

 for each temp.
  if temp.prd > 1 and temp.prd < 31 then temp.prd = 1 + 1.
  if temp.prd >= 31 and temp.prd < 92 then temp.prd = 2 + 1.
  if temp.prd >= 92 and temp.prd < 183 then temp.prd = 3 + 1.
  if temp.prd >= 183 and temp.prd < 365 then temp.prd = 4 + 1.
  if temp.prd >= 365 and temp.prd < 1095 then temp.prd = 5 + 1.
  if temp.prd >= 1095 and temp.prd < 1825 then temp.prd = 6 + 1.
  if temp.prd >= 1825  then temp.prd = 7 + 1.
 end.

/* валюты other */
for each temp where temp.crc <> 1  and temp.crc <> 2 and temp.crc <> 3.
 temp.crc = 4.
end.

do k = 1 to 8:
   find first temp where temp.priz = k and temp.crc = 1 no-lock no-error.
   if not available temp then  do: create temp. temp.crc = 1. temp.priz = k. temp.prd = 1.  end.

   find first temp where temp.priz = k and temp.crc = 2 no-lock no-error.
   if not available temp then  do: create temp. temp.crc = 2. temp.priz = k. temp.prd = 1.  end.

   find first temp where temp.priz = k and temp.crc = 3 no-lock no-error.
   if not available temp then  do: create temp. temp.crc = 3. temp.priz = k. temp.prd = 1.  end.
 
   find first temp where temp.priz = k and temp.crc = 4 no-lock no-error.
   if not available temp then  do: create temp. temp.crc = 4. temp.priz = k. temp.prd = 1.  end.
end.

  for each temp  where  break  by temp.priz by temp.crc  by  temp.prd :
     ACCUMULATE temp.bal (total by  (temp.priz)).
     ACCUMULATE temp.bal (total by  (temp.prd)).
     ACCUMULATE temp.bal (total by  (temp.crc)).

    
  if last-of(temp.prd) then do:  
   sum =   ACCUMulate total  by (temp.prd)   temp.bal.
    prd-tot[temp.prd] = sum / 1000.
  end. /*last-of*/

  if last-of(temp.crc) then  do: 
   sum =   ACCUMulate total  by (temp.crc)   temp.bal.

   find crc where crc.crc = temp.crc no-lock.

   put stream rpt skip v_text[temp.priz]   ';'  crc.code ';'
    prd-tot[1]  format '>>>>>>>>>>>9-' ';' prd-tot[2] format '>>>>>>>>>>>9-' ';'
    prd-tot[3]  format '>>>>>>>>>>>9-' ';' prd-tot[4] format '>>>>>>>>>>>9-' ';'
    prd-tot[5]  format '>>>>>>>>>>>9-' ';' prd-tot[6] format '>>>>>>>>>>>9-' ';' 
    prd-tot[7]  format '>>>>>>>>>>>9-' ';' prd-tot[8]  format '>>>>>>>>>>>9-' ';'.
    prd-tot[9] = sum.

   do k = 1 to 9: prd-tot[k] = 0. end.

  end. /*last of*/

 end.   /*temp*/

put stream rpt skip string(time,'hh:mm:ss') ';' g-today ';'.

/*----------*/
for each tgl break by tgl.tgl:
    def var sum$ as dec format "->>>>>>>>>>>>>>9.99".
    sum$ = sum$ + tgl.tsum2.
/*    if last-of(tgl.tgl) then do:
        put stream rpt skip tgl.tgl ';'  sum$ / 1000  format "->>>>>>>>>>>>>>9.99" ';' skip.
        sum$ = 0.
    end. */
end.
    put stream rpt skip 'ACTIV ' ';'  sum$ / 1000  format "->>>>>>>>>>>>>>9" ';' skip.

/*-----------*/
output stream rpt close.


hide all no-pause .

/* unix silent un-dos rpt.img value(fname). pause 0.

 ipaddr = 'ntmain.texakabank.kz'.
 input through value("rcp " + fname + " " + ipaddr + ":" + dirc + ";echo $?" ). pause 0.
  */

unix silent cptwin gap.csv excel.exe.

/* run menu-prt('gap.csv'). */

pause 0.
