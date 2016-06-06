/* amkor.p
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
	19.10.2005 u00121   - описание переменной s-aah измененно
*/

/*amort.redi¦ёЅana amkor.p*/
def new shared var s-jh like jh.jh.
def new shared var s-aah as int.
def new shared var s-line as int.
def new shared var v-ast like ast.ast format "x(8)".
def new shared var v-gl  like ast.gl.         
def new shared var v-qty like ast.qty format "zzz,zz9-".         
def new shared var v-fag as char format "x(3)".
def new shared var v-icost like ast.icost format "zzz,zzz,zz9.99-" init 0.            
def new shared var v-crline like ast.icost format "zzz,zzz,zz9.99-" init 0.            
def new shared var v-ydam5 like ast.crline .
def new shared var v-sum as dec format "zzz,zzz,zz9.99- ".
def new shared var v-atl as dec format "zzz,zzz,zz9.99-".
def new shared var v-cont like ast.cont format "x".
def new shared var v-icotst like ast.icost init 0.
def new shared var v-atrx as char.
def new shared var v-arem as char extent 5 format "x(55)".
def new shared var vop as int.
def new shared var kor-gl like jl.gl.
def new shared var kor-acc like ast.ast.
def new shared var vidop as char.
def var v-name like ast.name.
def var v-mfc like ast.mfc format "x(30)".
def var v-rem like ast.rem.
def var v-noy like ast.noy. 
def var v-rdt like ast.rdt.             
def var v-nol like ast.icost format "zzz,zzz,zz9.99-".
def var v-nolp like ast.icost format "zzz,zzz,zz9.99-".
def var v-salv like ast.salv.        
def var v-ser like ast.ser format "x(5)".        
def var v-ref  as decim format "zz9".
def var v-ddt  as date. 
def var v-amor as dec format "zzz,zzz,zz9.99-".
def var v-fagn like fagn.naim.
def var v-ldd like ast.ldd.
def var v-addr as char format "x(3)".
def var v-attn as char format "x(3)".
def var v-addrn as char format "x(25)" init " ".
def var v-attnn as char format "x(25)" init " ".
def var v-gln as char.
def var v-gldes as char.
def var v-kdes as char.
def var v-dam as dec format "zzz,zzz,zz9.99" init 0.
def var v-cam as dec format "zzz,zzz,zz9.99" init 0.
def var v-dam1 as dec format "zzz,zzz,zz9.99" init 0.
def var v-cam1 as dec format "zzz,zzz,zz9.99" init 0.
def var otv as log.
def var klud as log init true.
def var v-gl3 like trxlevgl.gl.
def var v-gl3d like gl.des.
def var vdel as cha initial "^" .
def var rdes   as cha .
def var rcode   as int .
def var vparam as cha .
def var shcode as cha .

{global.i}

form
"     Счет                              Субсчет   Дебет           Кредит  Вал.1" skip
"-----------------------------------------------------------------------------" skip
"001"   v-gl3  v-gl3d format "x(27)"       v-ast           skip 
ast.name  at 12  format "x(30)"     v-dam to 55     v-cam to 72 skip
"002"   kor-gl  v-gldes format "x(27)"  kor-acc  skip
v-kdes  at 12  format "x(30)"     v-dam1 to 55     v-cam1 to 72 skip
"ОПИСАНИЕ:" v-arem[1]  skip v-arem[2] at 11
  with frame kor overlay centered no-labels row 11.

form
    "ГРУППА     :" v-fag  v-fagn        "     СЧЕТ  :" at 53 v-gl skip
    "КАРТОЧКА   :" v-ast  v-name        "ДАТА РЕГИС.:" at 53 v-rdt skip  
    "-------------------------------------------------------------------------" skip
    "БАЛАНС.СТОИМОСТЬ:" v-icost    "           СЧЕТ    :"  v-qty skip             
    "НАЧИСЛ.АМОРТИЗ. :" v-nol                                    skip        
    "ОСТАТОЧНАЯ СТОИМ:" v-atl      "  МЕСЯЧНАЯ АМОРТИЗ.:" v-amor skip
    "-------------------------------------------------------------------------"skip
    "СРОК ИЗНОСА (КОЛ-ВО ЛЕТ )    :" v-noy  "  КОД ГР.ИЗНОСА  :"  v-ser skip
    "ПОСЛЕДН.ДАТА РАСЧЕТА АМОРТИЗ.:" v-ldd                              skip
    "СУММА КОРРЕКТИР.ИЗНОСА (+/-) :" v-sum                              skip
    "-------------------------------------------------------------------------" skip
    "ОТВЕТСТВ.ЛИЦО:" v-addr " " v-addrn skip
    "МЕСТО РАСПОЛ.:" v-attn " " v-attnn skip 
    "ПРИМЕЧАНИЕ   :" v-rem              skip 
  with frame ast row 4 overlay centered no-label
                     title "  КОРРЕКТИРОВКА  АМОРТИЗАЦИИ   ".
ma:
repeat on error undo,retry on endkey undo,return  :
 v-atrx="91".
 update v-ast validate(can-find(ast where ast.ast= v-ast),"КАРТОЧКИ НЕТ " )
    with frame ast.

 find ast where ast.ast=v-ast no-lock no-error.
   if ast.dam[1] - cam[1] + ast.dam[3] - ast.cam[3] eq 0 then do: 
      message "ОСТАТОК 0. ". pause 5. return. 
   end.  
 
 v-gl=ast.gl. 


 find gl where gl.gl=v-gl no-lock.
 v-gln=gl.des.

 

  find first trxlevgl where trxlevgl.gl = ast.gl and trxlevgl.lev = 3 no-lock no-error.
   if available trxlevgl then v-gl3 = trxlevgl.glr. else v-gl3=?.   
    
  find gl where gl.gl eq v-gl3 no-lock no-error.
  if available gl then v-gl3d =gl.des. else v-gl3d="".


 v-fag=ast.fag.
 find fagn where fagn.fag=v-fag no-lock.
 v-fagn=fagn.naim.
 v-rdt=ast.rdt.
 v-qty=ast.qty.
 v-icost= ast.dam[1] - ast.cam[1].
 v-nol = ast.cam[3] - ast.dam[3].
 v-atl= v-icost - v-nol.
 v-addr=ast.addr[1].
 v-noy =ast.noy.
 v-ldd =ast.ldd.
 v-amor=  round(ast.icost / ast.noy / 12,0).
 v-ser =ast.ser.
 find astotv where astotv.kotv=v-addr and astotv.priz="A" no-lock no-error.
 if avail astotv then v-addrn=astotv.otvp. 
 v-attn=ast.attn.
 
/* место расположения - из справочника Профит-центров */
/* find astotv where astotv.kotv=v-attn and astotv.priz="V" no-lock no-error.
 if avail astotv then  v-attnn=astotv.otvp.*/
 find codfr where codfr.codfr = 'sproftcn' and codfr.code = v-attn no-lock no-error.
 if avail codfr then v-attnn = trim(codfr.name[1]).

 v-cont=ast.cont.
 v-name=ast.name. v-mfc=ast.mfc. v-rem=ast.mfc.

 displ  v-fag v-fagn v-ast v-gl v-qty  v-rdt v-name  v-rem 
        v-addr v-addrn v-attn v-attnn v-sum v-icost  v-nol 
        v-atl  v-ldd v-amor v-noy v-ser with frame ast.

do on error undo,retry on endkey undo,next ma:
  update  v-sum validate(v-sum<>0 ,"")  with frame ast.
    v-atl=v-atl - v-sum.  v-nol=v-nol + v-sum.
    
  disp v-atl v-nol  with frame ast. pause 0. 
   v-arem[1]="КОРРЕКТИРОВКА АМОРТИЗАЦИИ ЗА " .
/*
   if v-atl < 1 then do: 
     message "ОСТАТ.СУММА МЕНЬШЕ 1 . ПРОВЕРЬТЕ СУММУ !!!". next ma.
   end.
*/ 
   if v-atl > v-icost  then do: 
     message "ОСТАТ.СТОИМОСТЬ > ПЕРВОНАЧ.СТОИМОСТЬ, ИСПРАВЬТЕ СУММУ!!!". next ma.
   end.

   find gl where gl.gl=v-gl and gl.gl1 > 0 no-lock no-error.
     if not available gl then do:
       message string(v-gl,"zzzzz9") + " СЧЕТУ НЕТ СЧЕТА ЗАТРАТ(Амортизации)".
       pause 10. next.
    end.
   else do: kor-gl= gl.gl1.  /* kor-acc ="".*/
        find first gl where gl.gl=kor-gl no-lock no-error.
        if not avail gl then do: message string(kor-gl) + " СЧЕТА НЕТ !".
          pause 3. next ma. end.
        else v-gldes= gl.des. 
   end.
end. 
m1:
repeat on error undo,retry on endkey undo,next ma:
  
 if v-sum<0 then do: 
     v-dam = v-sum * (-1). v-cam=0. 
     v-cam1= v-dam.        v-dam1=0. 
     v-sum=v-dam. vidop="D".
 end.         
 else do: 
     v-cam =v-sum.         v-dam=0.
     v-dam1=v-cam.         v-cam1=0. 
     v-sum=v-cam. vidop="C".
 end.         
 v-icost=0.
 v-crline=0.

 displ v-gl3 v-gl3d v-ast ast.name kor-gl v-gldes v-dam v-cam 
       v-dam1 v-cam1  v-arem[1] v-arem[2]  with frame kor.

 update v-arem[1] v-arem[2] with frame kor.         

klud=false.
 
leave.
end. /*repeat*/

leave.
end. /*ma*/

 otv=true.
repeat on endkey undo,retry:
 message "  ОПЕРАЦИЮ ВЫПОЛНИТЬ ?  " UPDATE otv format "да/нет".
  if not otv then return.
leave.
end.

klud=true.
 do transaction:
           find ast where ast.ast=v-ast.

                  
   shcode="AST0001".
   vdel="^".
   vparam=string(v-cam)   + vdel +
          string(kor-gl)  + vdel +
          ast.ast         + vdel + 
          trim(v-arem[1]) + trim(v-arem[2]) + vdel +
          string(v-dam).  
   s-jh = 0.
   run trxgen(shcode,vdel,vparam,"","",output rcode,output rdes,
              input-output s-jh).

   if rcode > 0  then
   do:
        Message " Error: " + string(rcode) + ":" +  rdes .
        pause .
        undo, return . 
   end.
   else 
   do:


        ast.ldd = ast.updt.
        ast.amt[5] = ast.amt[5] + v-cam - v-dam.
        ast.ofc=g-ofc.
        ast.updt=g-today.



         find first astatl where astatl.agl=v-gl and astatl.ast=ast.ast and
                                 astatl.dt=g-today no-error. 
             if not available astatl then create astatl. 
             astatl.ast=ast.ast.
             astatl.agl=v-gl.
             astatl.fag=ast.fag.
             astatl.dt=g-today.
             astatl.icost= ast.dam[1] - ast.cam[1].
             astatl.nol= ast.cam[3] - ast.dam[3].
             astatl.fatl[4]= ast.cam[4] - ast.dam[4].
             astatl.atl=astatl.icost - astatl.nol.
             astatl.qty=ast.qty.


        /* запись  1 линии в astjln */
           create astjln.
           astjln.ajh = s-jh.
           astjln.aln = 1.
           astjln.awho = g-ofc.
           astjln.ajdt = g-today.
           astjln.arem[1]= v-arem[1].
           astjln.aamt = v-cam - v-dam.
           astjln.dam = v-dam. 
           astjln.cam= v-cam.   
           astjln.adc = vidop.  
           astjln.d[3]= v-dam.       
           astjln.c[3]= v-cam.  
           astjln.agl = ast.gl.   
           astjln.aqty = ast.qty.
           astjln.aast = ast.ast.
           astjln.afag = ast.fag.
           astjln.atrx= "91".
           astjln.ak= ast.cont.
           astjln.apriz="A".
           astjln.korgl=kor-gl.
           astjln.koracc="".
           astjln.vop=4. /* gl.gr */

       run x-jlvouR.
       pause 0 .
       klud=false.
   end.
END.  /*transaction*/

release ast.
release astatl.
release astjln.

if rcode = 0 and not klud then repeat:
  otv=false.
  message "  Повторить печать?  " UPDATE otv format "да/нет". 
 if  otv then do: 
    message "ПЕЧАТЬ ОРДЕРА # " + string(s-jh) + " ".
    run x-jlvouR.  pause 0.
 end.
 else leave.
end.






 
