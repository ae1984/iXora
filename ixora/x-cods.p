/* x-cods.p
 * MODULE
        Редактирование кодов доходов/расходов по заданной транзакции
 * DESCRIPTION
        Меню редактирования кодов доходов/расходов по заданной транзакции
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        help-code,hepl-dep
 * MENU
        6-14-1
 * AUTHOR
        23.03.05 nataly
 * CHANGES
        26.04.05 nataly если код не проставлен, показывать "000000" и счет ГК
        08.06.05 nataly счет ГК показывается из проводки, а не из справочника 
        13/12/05 nataly добавлен  код доходов
*/

{global.i}

def temp-table tcash 
  field ln like jl.ln
  field code like cods.code
  field dep like cods.dep 
  field gl like cods.gl 
  field acc like cods.acc
  field des like cods.des 
   index qq ln .

def var i as int.
def var ttt as cha format "x(40)".
def var d-amt like aal.amt.
def var c-amt like aal.amt.
def var v-amt like jl.dam.
def var what as cha format "x(15)".
def var icrc as int.
def var nn as int.
def var jl-damcam like jl.dam .
def var p-pjh like jh.jh.
def var okey as log.
def var c-gl like gl.gl.

def var vcha3 as cha.
def buffer cash for sysc.

define buffer b-tcash for tcash.
define new shared variable s-ln like jl.ln.
define new shared variable s-newrec as logical.
define new shared frame menu.
define variable v-newhead as logical.
define variable v-newline as logical.
define variable v-cnt as integer.
define variable v-down as integer.
define variable v-tmpline as integer.
define variable v-ans as logical.
define variable v-top as int initial -1.
def var jl-rem as cha . 
def var jl-delta like jl.dam .
def var v-gl like gl.gl.

{x-cods.f}

v-yes = false.

repeat:
okey = false.

display p-pjh with frame qqq.

do on error undo ,retry :
 clear frame cont.
 hide frame cont .
 for each tcash.
  delete tcash.
 end.

 update p-pjh validate
  (can-find(jh where jh.jh eq p-pjh),"Проводка с номером " + string(p-pjh) + " не найдена !") 
  with frame qqq.
  clear frame cont.
 find jh where jh.jh = p-pjh no-lock no-error.
 if not avail jh then return.

 if trim(jh.party) = 'deleted' 
   then do:
    message 'Проводка удалена! Работа с кодами невозможна ! ' view-as alert-box.
   undo,retry.
  end.

do:
find first jl where jl.jh = p-pjh no-lock no-error.
if not available jl then next.

 find jh where jh.jh = jl.jh no-lock no-error. 
 if not avail jh then return.
okey = false.
icrc = 0.
  
for each jl no-lock  of jh .
 if substr(string(jl.gl),1,1) = '5'  or substr(string(jl.gl),1,1) = '4' then do: okey = true. next. end.
end.

if not okey then do:
  message  vcha3.
  bell. bell.
  pause.
  next.
end.

if okey then do:
  ttt = jh.party .
  display ttt with frame qqq.

for each jl of jh no-lock use-index jhln where substr(string(jl.gl),1,1) = '5'  or substr(string(jl.gl),1,1) = '4' 
    break by jl.jh by jl.crc with 12 down centered  frame www:

find  trxcods where trxcods.trxh = jl.jh and trxcods.trxln = jl.ln and 
    trxcods.codfr = 'cods' no-lock  no-error.
 if avail trxcods then do:
  create tcash.
  tcash.ln = trxcods.trxln.
  tcash.code = substr(trxcods.code,1,7).
  tcash.dep = substr(trxcods.code,8,3).
  find cods where cods.code = tcash.code no-lock no-error.
  if avail cods then do:
   tcash.gl = /*cods.gl.*/ jl.gl. /*08.06.05 nataly*/
   tcash.des = cods.des. 
   tcash.acc = cods.acc.
  end.
  else do:            /*26.04.05 nataly*/
   tcash.gl =   jl.gl.
   tcash.des = "". 
   tcash.acc = "".
  end.                 /*26.04.05 nataly*/
  end.
end. 

find first tcash  exclusive-lock no-error.
if available tcash then

do transaction:
{brwppg.i 
&first = " form jl-rem format 'x(67)' label ' Примечание' 
  with no-label row 19 centered no-box side-label    
  overlay frame dop .  form jl-damcam label ' Сумма     ' 
   jl-delta label 'Остаток' with side-label no-box overlay 
  row 18 frame dop1 . 
  
 ON HELP of tcash.code  in FRAME frm DO:
  run help-code(tcash.gl,tcash.acc).
     tcash.code:screen-value = return-value.
     tcash.code = tcash.code:screen-value.
end.

 ON HELP of tcash.dep  in FRAME frm DO:
  run help-dep(tcash.dep).
     tcash.dep:screen-value = return-value.
     tcash.dep = tcash.dep:screen-value.
end.

 " 
&h = "14"
&file = "tcash"
&form = " 
      tcash.ln label '#Лн' format 'zzz'  
      tcash.code label ' Код' validate( can-find(cods where cods.code = tcash.code and cods.gl = tcash.gl no-lock), 'Код не найден или не соответствует счету ГК!') format 'x(7)'
      tcash.dep label 'Деп-т' format '999'
       validate( can-find(codfr where codfr.codfr = 'sdep' and codfr.code = tcash.dep no-lock) or tcash.dep = '000','Департамент не найден!') 
      tcash.gl label 'Счет ГК' format 'zzzzzz'
      tcash.des label ' Описание        ' format 'x(38)'       "
&addcon = "true"
&updcon = "true"
&where  = " use-index qq " 
&delcon = " true"
&retcon = " false"
&enderr = " 

  for each trxcods where trxcods.trxh = p-pjh and trxcods.codfr = 'cods' exclusive-lock . 
    delete trxcods . 
  end .  

 for each tcash no-lock where tcash.code ne """" . 

       create trxcods. 
              assign 
                 trxcods.trxh  = p-pjh
                 trxcods.trxln = tcash.ln
                 trxcods.codfr = 'cods'
                 trxcods.code =  tcash.code + tcash.dep.
 end. 

 " 
&start = " "
&frame-phrase = " with centered 14 down " 
&predisp = " 
    display 
 '<Enter> - изменить,<^+N> - добавить,<^+D> - удалить,<F2>-помощь,<F4>-выход ' 
     with row 22 centered no-box . 
"
&disp = "tcash.ln  tcash.code tcash.dep tcash.gl tcash.des "
&seldisp = 
"tcash.ln tcash.code tcash.dep tcash.gl tcash.des "
&preupd = "   " 

&upd = " tcash.code validate( can-find(cods where cods.code = tcash.code and cods.gl = tcash.gl no-lock), 'Код выбран неверно!')
         tcash.dep       "

&poscreat = " "
&postcre = "   
          display tcash.ln tcash.code tcash.dep  tcash.gl with frame frm . " 
&addupd = " tcash.code tcash.dep "
&postadd = " leave. "

&postupd = "
  if tcash.code ne """" then do:
   find cods  where cods.code = tcash.code no-lock no-error. 
   if avail cods then tcash.des = cods.des.
  end.  "
&posdelete = "  " 
}
        end. /* do transaction */
 else message 'У данной проводки не проставлен код расходов/доходов! ' view-as alert-box.
      end.
    end.
  end.
end.

