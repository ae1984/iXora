/* 8st-prfdek22.p
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

def shared temp-table temp
  field  kod  as char
  field  gl  as integer format 'zzzzzz'
  field  val  as decimal format 'z,zzz,zzz,zz9.99-'
  field rem  as char. 

def  shared var v-gl as char extent 200.
def  shared var s-gl as char extent 200.
def  shared var vasof as date.

def  shared var i as int. 
def  shared var k as int. 
def  shared var j as int init 1. 

def var m-begday as date init 01/01/1996.
def var m-endday as date.

m-endday = vasof.
do j =  1 to 8.


do i =  2 to NUM-ENTRIES(v-gl[j]):


 if length(entry(i,v-gl[j])) = 6 then  do:
 find txb.gl where  txb.gl.gl = integer(entry(i,v-gl[j])) 
     and txb.gl.totlev  = 1 no-lock no-error.

  for each txb.crc .
  find last ast.glday where ast.glday.gl = txb.gl.gl 
    and ast.glday.gdt <= vasof and ast.glday.crc = txb.crc.crc no-lock no-error.

  if available ast.glday then do:
   find last txb.crchis where txb.crchis.crc = ast.glday.crc 
     and txb.crchis.rdt <= vasof  use-index crcrdt no-lock no-error.

   find temp where temp.gl = ast.glday.gl and temp.kod = entry(1,v-gl[j])  no-error.
   if available temp then    
    temp.val =  temp.val +  (ast.glday.bal * txb.crchis.rate[1]) / 1000.
    else do:
     create temp.  temp.kod = string(entry(1,v-gl[j])). 
     temp.gl = ast.glday.gl. 
     temp.val =  (ast.glday.bal * txb.crchis.rate[1]) / 1000.
    end.

   end. /*if available glday*/
  end. /*for each crc*/
 end. /*if length(entry(i,v-gl[j])) = 6*/

 else do:
 for each txb.gl where  integer(substr(string(txb.gl.gl),1,4)) 
     = integer(entry(i,v-gl[j])) and txb.gl.totlev  = 1 no-lock.
  for each txb.crc .

  find last ast.glday where ast.glday.gl = txb.gl.gl 
    and ast.glday.gdt <= vasof and ast.glday.crc = txb.crc.crc no-lock no-error.

  if available ast.glday then do:

   find last txb.crchis where txb.crchis.crc = ast.glday.crc 
     and txb.crchis.rdt <= vasof  use-index crcrdt no-lock no-error.
   find temp where temp.gl = ast.glday.gl and temp.kod = entry(1,v-gl[j])  no-error.
   if available temp then    
    temp.val =  temp.val + (ast.glday.bal * txb.crchis.rate[1]) / 1000.
    else do:
     create temp.  temp.kod = string(entry(1,v-gl[j])). 
     temp.gl = ast.glday.gl. 
     temp.val =  (ast.glday.bal * txb.crchis.rate[1]) / 1000.
     if  entry(1,v-gl[j])  = '037' and txb.crc.crc = 4 
          then temp.val = 0 . 
     if  entry(1,v-gl[j])  = '050' and txb.crc.crc <> 4 
          then temp.val = 0 . 
    end.
   end. /*if available glday*/
  end. /*for each crc*/
  end. /*gl*/
 end. /*if length(entry(i,v-gl[j])) <> 6*/ 

 if entry(2,v-gl[j]) = '9999' 
  then do: create temp. 
           temp.gl =  integer(entry(i,v-gl[j])). 
           temp.kod = entry(1,v-gl[j]). 
   end.

 end. /*i*/
end. /*j*/


