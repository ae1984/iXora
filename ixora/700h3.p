/* 700h3.p
 * MODULE 
        Отчет для Генеральной бухгалтерии.
 * DESCRIPTION 
        Консолидированный отчет по приложению 700Н к балансу . Отчет для Генеральной бухгалтерии.
 * RUN
 
 * CALLER
 
 * SCRIPT
 
 * INHERIT
        700h2.p
 * MENU 
        8-9-3-2
 * AUTHOR  
        27/08/03 nataly 
 * CHANGES
        08/10/03 nataly temp.gl  с типа integer был заменен на char
        23/03/06 nataly переведен с базы STAT на  TXB
*/

def input parameter p-bank as char no-undo.
def output parameter p-name as char no-undo.
def output parameter p-code as integer no-undo.

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

