/* aststrp.p
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

/*likv.p*/
def shared var vv-ast like ast.ast format "x(8)".
def new shared var v-ast like ast.ast format "x(8)".
def new shared var v-gl  like ast.gl.         
def var v-name like ast.name.
def var v-mfc like ast.mfc format "x(30)".
def var v-rem like ast.rem format "x(60)".
def new shared var v-qty like ast.qty format "zzz9" init 1.         
def var v-fag as char format "x(3)".
def var v-ser like ast.ser.  
def var v-noy like ast.noy init 0. 
def var v-rdt like ast.rdt.             
def var v-icost like ast.icost format "zzz,zzz,zz9.99".            
def var v-nola like ast.icost format "zzz,zzz,zz9.99".
def var v-nolp like ast.icost format "zzz,zzz,zz9.99".
def var v-salv like ast.salv init 0.        
def var v-sum as dec format "zzz,zzz,zz9.99".
def var v-ssum as dec format "zzz,zzz,zz9.99".
def var v-cont like ast.cont format "x".
def var v-ref  as decim format "zz9" init 0.
def var v-ddt  as date. 
def var v-crline like ast.crline format "zzzzzzz9.99-" init 0.
def var v-ydam5 like ast.crline format "zzzzzzz9.99-" init 0.
def var v-fagn like fagn.naim.
def var v-addr as char format "x(3)".
def var v-attn as char format "x(3)".
def var v-addrn as char format "x(25)" init " ".
def var v-attnn as char format "x(25)" init " ".
def var v-addr2 as char format "x(10)".
def var v-ldd like ast.ldd.
def var v-tr as char.
def var v-kdes as char.
def new shared var v-atrx as char.
def new shared var v-arem as char extent 5 format "x(55)".
def  var vop as int.
def  var kor-gl like jl.gl.
def  var kor-acc like jl.acc.     
def  var kor-cont like ast.cont format "x".     
def var otv as log.
def var klud as log init true.
def shared var s-jh like jh.jh.
def new shared var s-aah as int.
def new shared var s-force as log init false.
def new shared var s-consol like jh.consol.
def new shared var s-line as int.

def var v-ajh like jh.jh.
def var v-ajdt like astjln.ajdt.
def var fag like fagn.fag format "x(3)".
def var vln as int.
def var vgl as int init 0.
def var vacc as char.
def var vdam as dec init 0.
def var vcam as dec init 0.
def var amor as dec init 0.

{global.i}



form
    "ГРУП.:" fag "КАР.Nr." kor-acc  kor-gl  v-fagn   skip
    "НАЗВАНИЕ :" v-name  "    ИНВ.Nr." v-addr2 skip
  "--------------- Данные для расчета налогового износа -----------------" SKIP
    "КАТКГ." kor-cont "СТАВКА ИЗН:" v-ref  "x 2 %"
    "на" v-ddt  "ОСТ.НАЛ.СТОИМ" at 45  v-crline skip 
                "тек.года изм." at 45  v-ydam5  skip
    "СРОК ИЗНОСА (кол-во лет ):" v-noy  "  КОД ГР.ИЗНОСА :" v-ser skip
    "ОТВЕТСТВ.ЛИЦО:" v-addr " " v-addrn skip
    "МЕСТО РАСПОЛ.:" v-attn " " v-attnn skip
    "ОПИСАНИЕ  " v-arem[1] skip  
    "ОПЕРАЦИИ :" v-arem[2] skip
                 v-arem[3] at 12 
 with frame kor overlay centered no-labels row 9 
        title "  НОВАЯ КАРТОЧКА " .

form
   "ПЕРЕМЕСТИТЬ КАР"  vv-ast "ТР.Nr." s-jh  skip
 with frame ast1 overlay centered no-labels row 7 .

form
    "НАЗВАНИЕ  :" v-name  "КОЛ-ВО:" v-qty  "ДАТА РЕГ. :" v-rdt skip
    "ПРИМЕЧАНИЕ:" v-rem skip
    "ПЕРВ. СТОИМОСТЬ :" v-icost "ИЗНОС ПРИХОДА :" at 35  v-nolp skip            
    "ОСТАТ.СТОИМОСТЬ :" v-sum   "ИЗНОС НАЧИСЛ. :" at 35  v-nola  skip        
    "-------------------------------------------------------------------" skip
    "КАТЕГ." kor-cont "СТАВКА ИЗН:" v-ref  "x 2 %"
    "на" v-ddt  "ОСТ.НАЛ.СТОИМ" at 45  v-crline skip 
                "тек.года изм." at 45  v-ydam5  skip
    "ОТВЕТСТВ.ЛИЦО:" v-addr " " v-addrn skip
    "МЕСТО РАСПОЛ.:" v-attn " " v-attnn skip (1)
  with frame ast row 4 overlay centered no-label
                 title "С Карт.Nr." + v-ast + " гр." + v-fag + " счет " + string(v-gl)
                 + "/ПЕРЕМЕЩ.ОС (СТОРНО)". 

form 
   "ПЕРЕМЕСТИТЬ     С                    НА    " skip
    "Nr.Карт."    v-ast  to 28  kor-acc  to 52 skip
    "Счет "       v-gl   to 28  kor-gl   to 50 skip
    "Категория "  v-cont to 28  kor-cont to 50 skip 
    "  Со стоим.  " v-ssum    " С износом    :" amor  
       with frame op overlay centered no-labels row 14.

 amor=0.
 v-ajh=s-jh.
/*displ vv-ast s-jh with frame ast1.
  update v-ast validate(v-ast ne ""," J–ievada karti‡as numurs " )
    with frame ast1.
*/
 find ast where ast.ast=vv-ast no-lock no-error.
  if not avail ast then do: message "Карточки нет ". pause 5. return. end.
  if ast.dam[1] - cam[1] eq 0 then do: message "Остаток  0 ". pause 5. return.
                                   end.  
/* update v-ajh with frame ast1.
*/
 find first astjln where astjln.aast=vv-ast and astjln.ajh=s-jh no-lock no-error.
  if not avail astjln then do: message "Транз.нет ". pause 5. next. end.
  v-ajdt=astjln.ajdt.
  v-tr=astjln.atrx.
  if year(astjln.ajdt) < year(g-today) then do:
        message " Нельзя. Дата прихода " string(astjln.ajdt). pause 5. next. end. 
  if astjln.aqty=0 then do: message " Нельзя. Пополнение карточки.". pause 5. next. end.
  if astjln.atrx<>"1" and astjln.atrx<>"11" and
     astjln.atrx<>"3" and astjln.atrx<>"31" then do: message "НЕ ПРИХОД ".
   pause 5. next. end.  
  v-ssum=astjln.aamt.
  for each astjln where astjln.ajh>v-ajh and astjln.aast=vv-ast no-lock:
      if astjln.apriz="A" then amor=amor + astjln.cam - astjln.dam.
      else do: message "НЕ ПОСЛЕДНЯЯ ОПЕРАЦИЯ. СТОРНИРОВАТЬ НЕЛЬЗЯ".
               pause 5. return. end.                  
  end.      
/*    if v-ssum=ast.dam[1] - ast.cam[1] + amor.
*/
 v-ast=ast.ast. 
 v-gl=ast.gl.
 v-fag=ast.fag.
 find fagn where fagn.fag=v-fag no-lock.
 v-fagn=fagn.naim.
 v-rdt=ast.rdt.
 v-qty=ast.qty.
 v-sum= ast.dam[1] - ast.cam[1].
 v-icost=ast.icost.
 v-nolp= ast.salv.
 v-nola= v-icost - v-nolp - v-sum.
 v-addr=ast.addr[1].
 v-addr2=ast.addr[2].
 find astotv where astotv.kotv=v-addr and astotv.priz="A" no-lock no-error.
 if avail astotv then v-addrn=astotv.otvp. 

 v-attn = ast.attn.
 find codfr where codfr.codfr = "sproftcn" and codfr.code = v-attn no-lock no-error.
 if avail codfr then  v-attnn = codfr.name[1].

 v-cont=ast.cont.
 v-name=ast.name. v-mfc=ast.mfc. v-rem=ast.rem.
 v-crline=ast.crline.
 v-ydam5=ast.ydam[5].
 v-ddt=ast.ddt[1].
 v-ldd=ast.ldd.
 displ  v-fag v-fagn v-qty  v-addr2 v-rdt v-name v-mfc v-rem 
        v-addr v-addrn v-attn v-attnn v-sum v-icost v-nola v-nolp  g-today
        v-ddt v-crline v-ydam5
        with frame ast.

pause 10.

ma:
repeat on error undo,retry on endkey undo,return:
   update fag validate(fag ne "" and fag<>v-fag," ВВЕДИТЕ НОМЕР ГРУППЫ " )
         with frame kor. 
   find fagn where fagn.fag=fag exclusive-lock no-error.
    if fag<>v-fag then do:
      kor-acc=fag + string(fagn.pednr, "99999").
      fagn.pednr= fagn.pednr + 1.
      find ast where ast.ast=kor-acc no-lock no-error.
       if avail ast then do: pause 1. release fagn. next. end.
    end.
    else kor-acc=v-ast. /* net ! */



    kor-gl=fagn.gl. v-fagn=fagn.naim.
    v-ser=fagn.ser.
    kor-cont=fagn.cont.
    v-noy =fagn.noy.
    v-ref=integer(fagn.ref).
   release fagn.


   displ kor-gl kor-acc v-fagn v-name v-rem v-noy v-ser v-addr v-addrn
         v-attn v-attnn kor-cont v-ref v-ddt v-crline   v-addr2 
         v-ydam5 v-ddt
    with frame kor.   pause 0.
  update  v-name v-addr2 kor-cont v-ref with frame kor.
  if v-ast=kor-acc and v-cont=kor-cont then  next ma.
  v-rem=v-rem + " P–rv.no ".
  if v-ast<>kor-acc then   v-rem=v-rem + v-ast.
  if v-cont<>kor-cont then v-rem=v-rem + " no kat." + v-cont.
   update v-rem v-noy v-ser with frame kor.
 
   update  v-addr validate(can-find(astotv where astotv.kotv = v-addr and astotv.priz = "A"),
         " КОДА " + v-addr + " НЕТ  В СЛОВАРЕ") with frame kor.
 find astotv where astotv.kotv = v-addr and astotv.priz = "A" no-lock no-error.
 if avail astotv then v-addrn = astotv.otvp.
  displ v-addrn with frame kor.

  update  v-attn validate(can-find(codfr where codfr.codfr = "sproftcn" and 
         codfr.code = v-attn and codfr.code matches "..."),
         " КОДА " + v-attn + " НЕТ В СЛОВАРЕ") with frame kor.
 find codfr where codfr.codfr = "sproftcn" and codfr.code = v-attn no-lock no-error.
 if avail codfr then  v-attnn = codfr.name[1].
  displ v-attnn with frame kor.

 
  v-arem[1]="Сторно ".
  if v-ast<>kor-acc then   v-arem[1]=v-arem[1] + "с " + v-ast.
  if v-cont<>kor-cont then v-arem[1]=v-arem[1] + " кат." + v-cont.
  v-arem[1]=v-arem[1] + " на " + kor-acc .
  if v-cont<>kor-cont then v-arem[1]=v-arem[1] + " кат." + kor-cont.

   v-arem[2]="Сторно опер." + string(v-ajh) + " " + string(v-ajdt). 
   update v-arem[1] v-arem[2] v-arem[3] with frame kor.

klud=false.
leave.
end. /* ma */

   if klud then do transaction:
                 find fagn where fagn.fag=fag exclusive-lock no-error.
                 if kor-acc=string(fag + string(fagn.pednr - 1, "99999")) then
                  fagn.pednr= fagn.pednr - 1.
                 release fagn.
                 return.         
  end.

 /*v-ssum= v-icost - v-nolp.
 */
 amor= v-ssum - v-sum.

 display v-ast v-gl v-cont kor-acc kor-gl kor-cont v-ssum amor with frame op. 
 pause 0.

 otv=true.
 message "  ОПЕРАЦИЮ ВЫПОЛНИТЬ ?  " UPDATE otv format "да/нет".
   if not otv then do transaction:
                find fagn where fagn.fag=fag exclusive-lock no-error.
                 if kor-acc=string(fag + string(fagn.pednr - 1, "99999")) then
                  fagn.pednr= fagn.pednr - 1.
                 release fagn.
                 return.
   end.
   do transaction:
         run x-jhnew.
   end.
otv=false.
Do transaction on error undo, return:

 find first astjln where astjln.aast=vv-ast and astjln.ajh=v-ajh and 
                         astjln.aamt=v-ssum .
 astjln.stdt=g-today. astjln.stjh=s-jh.                        

find jh where jh.jh eq s-jh.

jh.party = "AST".
jh.sts=0.
jh.crc = 1.
vln=0.
klud=true.
def var v as int.
def var vd as dec init 0.
def var vc as dec init 0.

do v=1 to 6:

 if v=1 and amor>0 and v-ast<>kor-acc then do: klud=false.
        find ast where ast.ast=v-ast.
                   ast.ofc=g-ofc.
                   ast.updt=g-today.
                   ast.amt[5]=ast.amt[5] - amor.
            release ast.       
     v-atrx="91".
     vgl=v-gl. vacc=v-ast. vdam=amor. vcam=0. 

 end.
 if v=2 and amor>0 and v-ast<>kor-acc then do: klud=false.
     find gl where gl.gl=v-gl no-lock no-error.
     vgl=gl.gl1. vacc="". vdam=0. vcam=amor.  
 end.
 if v=3 then do: klud=false.
           find ast where ast.ast=v-ast.
                   ast.icost= ast.icost - v-icost.
                   ast.qty= ast.qty - v-qty.
                   ast.crline=ast.crline - v-crline. 
                   ast.ydam[5]=ast.ydam[5] - v-ydam5. 
                   ast.ofc=g-ofc.
                   ast.updt=g-today.
            release ast.       
       v-atrx=substring(v-tr,1,1) + "6".
    /* v-atrx="68" --> 16  36.*/
     vgl=v-gl. vacc=v-ast. vdam=0. vcam=v-ssum. 
 end.
 if v=4 then do: klud=false.
             find ast where ast.ast=kor-acc no-error.
             if not avail ast then   create ast.
                   ast.ast=kor-acc.
                   ast.gl=kor-gl.
                   ast.crc=1.
                   ast.fag=fag.
                   ast.name=v-name.
                   ast.addr[1]=v-addr.
                   ast.addr[2]=v-addr2.
                   ast.attn=v-attn.
                   ast.rem=v-rem.
                   ast.noy=v-noy.
                   ast.mfc=v-mfc.
                   ast.ser=v-ser.

                   ast.rdt=v-rdt.
                   ast.icost=v-icost.
                   ast.amt[3]=v-icost - v-nolp.
                   ast.salv=v-nolp.
                   ast.qty=v-qty.
                   ast.meth=v-qty.
                   ast.who=g-ofc.
                   ast.whn=today.
                   ast.ofc=g-ofc.
                   ast.updt=g-today.

                   ast.ddt[1]=v-ddt.
                   ast.crline=v-crline. 
                   ast.ydam[5]=v-ydam5.
                   ast.cont=kor-cont.
                   ast.ref=string(v-ref).
                   ast.ldd=v-ldd.
            release ast.       
       v-atrx=substring(v-tr,1,1) + "1".
     /*  v-atrx="18".---> 11 31*/
     vgl=kor-gl. vacc=kor-acc. vdam=v-ssum. vcam=0. 
 end.


 if v=5 and amor>0 and v-ast<>kor-acc then do: klud=false.
  
        find ast where ast.ast=kor-acc.
                   ast.who=g-ofc.
                   ast.whn=today.
                   ast.updt=g-today.
                   ast.amt[5]=ast.amt[5] + amor.
            release ast.       
     v-atrx="91".
     vgl=kor-gl. vacc=kor-acc. vdam=0. vcam=amor. 
 end.

 if v=6 and amor>0 and v-ast<>kor-acc then do: klud=false.
     find gl where gl.gl=kor-gl no-lock no-error.
     vgl=gl.gl1. vacc="". vdam=amor. vcam=0.  
    
 end.

 if not klud then do: vln=vln + 1.
 run ast-jls(vln, vgl, vacc, vdam, vcam, v-icost, v-crline, v-ydam5, output otv). 
      if not otv then undo,retry.
      klud=true.
      vd= vd + vdam. vc= vc + vcam.
 end.
    
end. /*do*/
if vd<>vc then do:  message "НЕТ Баланса  ...". undo,retry. end.

find first jl where jl.jh=s-jh no-lock no-error.
if available jl then do:
  message "ПЕЧАТЬ ОРДЕРА # " + string(s-jh) + " ".
run x-jlvou.
pause 0.
if jh.sts ne 6 then do:
  for each jl of jh:
    jl.sts = 5.
  end.
  jh.sts = 5.
end.
end.
otv=true.
End. /*trans*/

if not otv then do transaction: 
                find fagn where fagn.fag=fag exclusive-lock no-error.
                 if kor-acc=string(fag + string(fagn.pednr - 1, "99999")) then
                  fagn.pednr= fagn.pednr - 1.
                 release fagn.
                 return.
end.
else run astst.
