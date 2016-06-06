/* vipuvd.p
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

 /* v-mem-or.p  for Bank Commision (CHG)   
 
    30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
 */

def input parameter p-vid as char . /*  pl ili mem, memf */ 
def input parameter rec_id as recid. 
def input parameter v-platname like cif.name.
def input parameter v-platacc like  aaa.aaa.
def input parameter v-platacc1 like  aaa.aaa.

def input parameter v-plnr as char format "x(15)". 
def input parameter v-platcode like cif.jss format "x(15)".
def input parameter v-bankplat as char format "x(9)". 
def input parameter v-platbname as char format "x(50)".
def input parameter v-polcode like cif.jss format "x(15)".
def input parameter v-polname like cif.name.
def input parameter v-polacc like  aaa.aaa.
def input parameter v-polacc1 like  aaa.aaa.
def input parameter v-bankpol as char format "x(9)". 
def input parameter v-polbname as char format "x(50)".
def input parameter v-nazn as char.
def var v-nazn1 as char format "x(73)". 
def var v-nazn2 as char format "x(73)". 
def var v-nazn3 as char format "x(73)". 
def shared var flg1 as log.

def var s-crc like crc.crc.
def var s-code like crc.code.
def var s-des like crc.des.
def var v-ln as log .
def var v-tmp as cha. 
def shared var g-today as date . 
def shared var g-batch as log . 
def var s-cif like cif.cif. 
def var v-point like point.point. 
def var v-regno like point.regno. 
def var in_cif like cif.cif. 
def var in_account like aaa.aaa.
def var in_command as char init "joe".
def var in_destination as char init "plat.img".
def var MyMonths as char extent 12 
init ["января","февраля","марта","апреля","мая","июня","июля","августа",
"сентября","октября","ноября","декабря"]. 

def var partkom as char.
def var v-datword as char format "X(30)". 
def var v-rate as deci.
def var s-date as date format "99/99/9999". 

def var v-kas like gl.gl.
def frame fr1.

def var v-sumword as char format "X(60)".
def var sumword1 as char. 
def var sumword2 as char. 
def var vcrc1 as char. def var vcrc2 as char.
def var v-bankcode as char format "X(9)".   
def var s-amt like jl.dam.
def var v-amt like jl.dam.
def var s-gl like gl.gl. 
def var sc-name like cif.name. 
def var s-sts as char format "X(3)". 
def var m-rtn as log.
def var ipos as integer init 0.
def var i as integer.
define variable s-trx like jl.trx.

find sysc where sysc.sysc = "CASHGL" no-lock no-error.
if avail sysc then v-kas = sysc.inval.

if  v-platacc = string(v-kas) then do:  
   p-vid ="mem".
   find first point no-lock no-error.
   if available point then v-regno = point.regno. 
   else v-regno = "". 

    do while index("1234567890",substring(v-regno,1,1)) eq 0:
       v-regno = substring(v-regno,2).
    end.
     i = 1.  
    do while index("1234567890",substring(v-regno,i,1)) ne 0:
       i = i + 1.
    end.
    v-regno = substring(v-regno,1,i). 
    v-platcode= v-regno.       
    find first cmp no-lock no-error.
    v-platname = cmp.name. 
end. 
if v-polacc =string(v-kas) then do:  
   p-vid = "mem".
   find first point no-lock no-error.
   if available point then v-regno = point.regno. 
   else v-regno = "". 

    do while index("1234567890",substring(v-regno,1,1)) eq 0:
       v-regno = substring(v-regno,2).
    end.
     i = 1.  
    do while index("1234567890",substring(v-regno,i,1)) ne 0:
       i = i + 1.
    end.
    v-regno = substring(v-regno,1,i). 
    v-polcode= v-regno.       
    find first cmp no-lock no-error.
    v-polname = cmp.name. 
end. 


find first cmp no-lock no-error. 

find sysc where sysc.sysc eq "CLECOD" no-lock no-error. 
if available sysc then v-bankcode = trim(sysc.chval).


find jl where recid(jl) =rec_id no-lock no-error.
if not available jl then return.
 
if jl.dam > 0 then do:
      display "На данный счет не было поступлений!!! " with frame fr1 no-label.
    pause 5.
    flg1 = false.
    return.
  end.
else do:
   flg1 = true.
   s-date = jl.jdt.  
    v-amt = jl.cam. 
    s-crc =jl.crc.
    v-polacc = jl.acc.

       find crc where crc.crc eq s-crc no-lock.
       s-code = crc.code. 
       s-des = crc.des.
     
     v-polacc = jl.acc.
     v-bankpol = v-bankcode.
     v-polbname = trim(cmp.name).
    find aaa where aaa.aaa = jl.acc no-lock no-error.
    if available aaa then do:
     find cif where cif.cif = aaa.cif no-lock no-error.
     if available cif then do:
      v-polcode = cif.jss.
      v-polname = trim(trim(cif.prefix) + " " + trim(cif.name)).  
     end.
    end. 
    if v-bankplat = substring(v-bankcode,7,3) then do:     
        v-bankplat = v-bankcode.   
        v-platbname = trim(cmp.name).
    end.   
    if v-bankplat =v-bankcode then v-platbname = trim(cmp.name).

end.
/* naznachenie plateza*/
 Run PrintOrder in This-Procedure.
    
Procedure PrintOrder:
  output to value(in_destination) append.
   put skip(1).
 /*  put skip '"' + trim(cmp.name) + '"' format "X(60)".
  */
      put skip space(35) "УВЕДОМЛЕНИЕ " format "X(23)". 
      put skip(2) space (10) "Уважаемый клиент" + "  " + trim(v-polname) format "x(56)".
      put skip(2).
      put skip "АО ""TEXAKABANK"" уведомляет, что на имя Вашей организации  ".        put s-date format "99/99/9999" "г.".
      put skip "поступили деньги в сумме" format "x(30)".
      put string(v-amt,"-zzz,zzz,zz9.99") format "x(20)". 
      put "( " + trim(s-des) format "x(20)" + " )".
      put skip (1) "В соответствии с Инструкцией ""Об организации экспортно-импортного валютного".
      put skip "контроля в Республике Казахстан"", утвержденной Постановлением Правления". 
      put skip "Национального Банка N 271 от 5 декабря 1998 г.," .
      put skip "для зачисления вышеуказанных денег на Ваш счет необходимо предоставить в ".
      put skip "АО ""TEXAKABANK"" документы для их идентификации:".
      put skip " - контракты, паспорта сделок, инвойсы  и официальное письмо с указанием ".
      put skip "характера поступивших денег.".


      put skip(5).
                             
       put skip "Директор Операционного Департамента".   
       put skip "т. 500 848". 
     

      put  skip (2) "Дата   ".
      put g-today format  "99/99/9999" "г.". 
     
  
   output close.  
End Procedure. 
