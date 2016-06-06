/* 9st-prf11.p
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
       17.11.05 nataly внесены изменения в связи с новой 9-ой строкой
       23/03/06 nataly переделала с базы STAT -> TXB
       04/07/06 tsoy - добавил индекс в таблицу wf1
       06/10/06 u00121 - добавил индекс в таблицу wf2, а также no-undo

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
def var rez as char no-undo.
def var priz as char no-undo.
def var valut as char no-undo.
def var num as integer no-undo.
def shared stream st-out.

def new shared temp-table wf1 no-undo
    field wdfb  like txb.dfb.dfb
    field wname like txb.bankl.bank
    field wgeo as char
    field wrez as char
    field wkod as char
    field wcrc  like txb.crc.crc
    field wsumpr  as decimal
    field wsumLs  as decimal
    field wlne like txb.bankl.lne
    index idx1-wf1 wdfb wcrc
    index idx2-wf1 wkod.


def new shared temp-table wf2 no-undo
    field wfun  like txb.fun.fun
    field wname like txb.bankl.bank
    field wgeo as char
    field wgl like txb.fun.gl
    field wrez as char
    field wkod as char
    field wcrc  like txb.crc.crc
    field wsumpr  as decimal format "z,zzz,zzz,zz9.99-"
    field wsumLs  as decimal format "z,zzz,zzz,zz9.99-"
    field wlne like txb.bankl.lne
    index idx1-wf2 wfun wcrc
    index idx2-wf2 wkod.

  for each wf1. delete wf1. end.
  for each wf2. delete wf2. end.
run r-do1n.
run r-do2n.

do j = 1 to 4:
do i =  5 to NUM-ENTRIES(s-gl[j]):


 case  entry(1 ,s-gl[j]):
 when '015' then do:
 create temp. temp.kod =  entry(1 ,s-gl[j]). 
 temp.rem = entry(i - 1 ,s-gl[j]).

 if entry(i - 1 ,s-gl[j]) = 'd1t' then do:
  for each wf1 where not( trim(wf1.wkod) matches '*035*') and not( trim(wf1.wkod) matches '*058*')  . 
   temp.val =  temp.val + round(wf1.wsumpr / 1000, 0)  + round(wf1.wsumLs / 1000, 0)  .
  end.
 end.
 if entry(i - 1 ,s-gl[j]) = 'd2t' then do:
  for each wf2 where not(trim(wf2.wkod) matches '*035*') and not( trim(wf2.wkod) matches '*058*') . 
   temp.val =  temp.val + round(wf2.wsumpr / 1000, 0)  + round(wf2.wsumLs / 1000, 0) .
  end.
 end.
 end. /*015*/
 otherwise do:
  /*if there is only one symbol*/
 create temp. temp.kod =  entry(1 ,s-gl[j]). 
 temp.rem = entry(i ,s-gl[j]).

 find  txb.sthead where rptform = '7pn' 
      and rptfrom = vasof and rptto = vasof no-error. 
 if not available txb.sthead then do: message 'Нет данных по отчету  7pn' 
       'за '  vasof .  return. end. 

  rez = entry(2 ,s-gl[j]). priz = entry(3 ,s-gl[j]).
  valut = entry(4 ,s-gl[j]).

  if rez = '*' and priz = '*' then do:
   for each txb.stdata where stdata.referid = sthead.referid
       and stdata.x1 >= '0000009' and
       substr(stdata.fun,1,4) matches entry(i ,s-gl[j])
         and   substr(stdata.fun,7,1) eq trim(valut) .
         num = R-INDEX ( stdata.fun, ',' ) .
         temp.val = temp.val + decimal(substr(stdata.fun,num + 1)).
   end.
  end. /*if rez = '*' */
 else do:
   for each txb.stdata where stdata.referid = sthead.referid
       and stdata.x1 >= '0000009' and
       substr(stdata.fun,1,4) matches entry(i ,s-gl[j])
         and   substr(stdata.fun,6,1) eq trim(priz) and
          substr(stdata.fun,5,1) eq trim(rez)  and 
          substr(stdata.fun,7,1) eq trim(valut) .
         num = R-INDEX ( stdata.fun, ',' ) .
        /* message substr(stdata.fun,1,7) ' ' decimal(substr(stdata.fun,num + 1)).*/
         temp.val = temp.val + decimal(substr(stdata.fun,num + 1)).
    end.
   end. /*if rez <> '*' */
  end.
 end case.
 end.  /*i*/
end.   /*j*/  

