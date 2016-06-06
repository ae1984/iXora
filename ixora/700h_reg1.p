/* 700h_reg1.p
 * MODULE 
        Отчет для Генеральной бухгалтерии.
 * DESCRIPTION 
        отчет по приложению 700Н к балансу . Отчет для Генеральной бухгалтерии.
 * RUN
 
 * CALLER
 
 * SCRIPT
 
 * INHERIT
        
 * MENU 
        8-8-3-10
 * BASES
        BANK COMM TXB
 * AUTHOR  
        28.10.09 marinav 
 * CHANGES
*/

def shared temp-table temp
  field  kod  as char
  field  gl  as char format 'x(7)'
  field  val  as decimal format 'z,zzz,zzz,zz9.99-'
  field rem  as char. 

def  shared var vasof as date.

def var rez as char no-undo.
def var priz as char no-undo.
def var num as integer no-undo.
def var i1 as integer no-undo.


find txb.sthead where rptfrom = vasof and rptto = vasof and rptform = '7pn' .
  for each txb.stdata where stdata.referid = sthead.referid
    and  stdata.x1 >= '0000009'.
     i1 = index(stdata.fun,',').
     if  i1 > 0  and substr(stdata.fun,1,1) <> '0' then do:
/*      message substr(stdata.fun,1,7) substr(stdata.fun,i1 + 1).*/
      create temp.
      temp.gl = substr(stdata.fun,1,7).
     temp.val = decimal(substr(stdata.fun,i1 + 1)).
    end.
  end.

