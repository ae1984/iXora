/* astpr.p
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

/*parc p–rcenoЅana   2 or 5*/
def new shared var s-jh like jh.jh.
def new shared var s-aah as int.
def new shared var s-force as log init false.
def new shared var s-consol like jh.consol.
def new shared var s-line as int.
def buffer xaaa for aaa.
def var bila like aaa.cbal label "БАЛАНС".
def input parameter vo as char.
def input parameter ti as char.

def new shared var v-ast like ast.ast format "x(8)".
def new shared var v-gl  like ast.gl.         
def new shared var v-gl3 like trxlevgl.glr.
def new shared var v-gl3d like gl.des.
def new shared var v-gl4 like trxlevgl.glr.
def new shared var v-gl4d like gl.des.
def new shared var v-gl1d like gl.des.
def new shared var v-qty like ast.qty format "zzz9" init 1.         
def new shared var v-crline like ast.crline format "zzzzzzzz9.99-" init 0.
def new shared var vidop as char.
def new shared var v-fag as char format "x(3)".
def new shared var v-sum as dec format "zzz,zzz,zz9.99".
def new shared var v-ydam5 like ast.icost format "zzzzzzzz9.99-".            
def new shared var v-cont like ast.cont format "x".
def var v-icost like ast.dam format "zzzzzz,zzz,zz9.99-".            
def var v-nol like ast.dam   format "zzzzzz,zzz,zz9.99-".
def var v-atl like ast.dam   format "zzzzzz,zzz,zz9.99-".
def var v-fagn like fagn.naim.
def new shared var v-atrx as char.
def new shared var v-arem as char extent 5 format "x(55)".
def new shared var vop as int.
def new shared var sumd1 as dec format "zz,zzz,zz9.99".
def new shared var sumc1 as dec format "zz,zzz,zz9.99".
def new shared var sumd3 as dec format "zz,zzz,zz9.99".
def new shared var sumc3 as dec format "zz,zzz,zz9.99".

def var v-gldes as char.
def var v-gln as char.
def var v-kdes as char.
def var vln as int.
def var otv as log.
def var arem as char.
DEF VAR v-kf as dec init 0.
def var klud as log.
def var vdel as cha initial "^" .
def var rdes   as cha .
def var rcode   as int .
def var vparam as cha .
def var shcode as cha .
def var arem1 as char.
def var arem2 as char.
{global.i}

form
    "Nr.КАРТОЧКИ :" v-ast  "ГР.:" ast.fag  v-fagn  "  СЧЕТ :" ast.gl skip
    "НАЗВАНИЕ    :" ast.name  skip 
    "КОЛИЧЕСТВО  :" ast.qty format "zzz9" "ДАТА РЕГ. :" at 25 ast.rdt
                                                    "Инв.Nr." ast.addr[2] format 'x(20)' skip
    "               сумма до переоц.        сумма переоценки   сумма после переоц " skip             
    "ПЕРВ.СТОИМ. :" v-icost[1]   v-icost[2]  v-icost[3]   skip
    "ИЗНОС       :" v-nol[1]     v-nol[2]    v-nol[3]     skip                  
    "ОСТАТ.СТОИМ.:" v-atl[1]     v-atl[2]    v-atl[3]     skip        
    "ПРИМЕЧАНИЕ  :" ast.rem skip
    " КОЭФФИЦИЕНТ ПЕРЕСЧЕТА : " V-KF  "(+ или -) " skip
  with frame ast row 2 overlay centered no-label
                 title "   " + v-arem[1] + " " + ti. 

/*
form

"     Счет                              Субсчет   Дебет           Кредит  Вал.1" skip
"-----------------------------------------------------------------------------" skip
"001"   v-gl  v-gln format "x(27)"       v-ast           skip 
       ast.name at 12 format "x(30)"     v-dam  to 55     v-cam  to 72 skip            
"002"   kor-gl  v-gldes format "x(27)"  kor-acc  skip
v-kdes  at 12  format "x(30)"     v-dam1 to 55     v-cam1 to 72 skip
"ОПИСАНИЕ:" v-arem[1]  skip v-arem[2] at 11 skip v-arem[3] at 11
 with frame kor overlay centered no-labels row  10 .
*/

/*
form
"     Счет                              Субсчет              Сумма "  skip
"-----------------------------------------------------------------------------" skip
"   "   v-gl  v-gln  format "x(27)"      v-ast     v-icost to 72 " DR" skip 
"   "   v-gl3 v-gl3d format "x(27)"      v-ast    v-nol   to 72 " DR" skip 
"   "   kor-gl  v-gldes format "x(27)"  kor-acc      v-sum to 72 " CR" skip
 v-kdes  at 12  format "x(30)"            skip 
"   "   skip
"ОПИСАНИЕ:" v-arem[1]  skip v-arem[2] at 11 skip v-arem[3] at 11
 with frame kor overlay centered no-labels row 11.

*/

hide all.
/*
 if vo="+"      then v-atrx="2".
 else if vo="-" then v-atrx="5".
 else if vo="1" then v-atrx="1".     
 else if vo="3" then v-atrx="3".
 else if vo="8" then v-atrx="81".
*/
 v-atrx=vo.  /* p */
 find asttr where asttr.asttr=v-atrx no-lock no-error.
 if avail asttr then v-arem[1]=asttr.atdes.


update v-ast validate(v-ast ne ""," ВВЕДИТЕ КАРТОЧКУ " )
    with frame ast.

 find ast where ast.ast=v-ast no-lock no-error.
  if not avail ast then do: message "КАРТОЧКИ НЕТ ". pause 5. return. end.

  if ast.dam[1] - cam[1] eq 0 then do: message "ОСТАТОК  0 ". pause 5. return.
                                   end.  
/*.
  if (ast.crline ne 0 or ast.ydam[5] ne 0) and year(ast.ddt[1])<year(g-today)
    then do:
    message " НАЧИСЛИТЬ НАЛОГ.ИЗНОС ЗА "
     + string(year(ast.ddt[1])) + " г.". pause 5. return.
  end.  
.*/

 v-ast=ast.ast. 
 v-gl=ast.gl.
 find gl where gl.gl=v-gl no-lock.
 v-gln=gl.des.
 find first trxlevgl where trxlevgl.gl = ast.gl and trxlevgl.lev = 3 no-lock no-error.
 if available trxlevgl then v-gl3 = trxlevgl.glr. else v-gl3=?.   
 find gl where gl.gl eq v-gl3 no-lock no-error.
 if available gl then v-gl3d =gl.des. else v-gl3d="".
 find first trxlevgl where trxlevgl.gl = ast.gl and trxlevgl.lev = 4 no-lock no-error.
 if available trxlevgl then v-gl4 = trxlevgl.glr. else v-gl4=?.   
 find gl where gl.gl eq v-gl4 no-lock no-error.
 if available gl then v-gl4d =gl.des. else v-gl4d="".

 v-qty=0.
 v-fag=ast.fag.
 find fagn where fagn.fag=v-fag no-lock.
 v-fagn=fagn.naim.
 v-icost[1]= ast.dam[1] - ast.cam[1].
 v-nol[1]  = ast.cam[3] - ast.dam[3].
 v-atl[1]  = v-icost[1] - v-nol[1].
 v-cont=ast.cont.   

 displ  v-ast ast.fag v-fagn ast.gl ast.qty  ast.rdt ast.name  ast.addr[2]
        v-atl[1] v-icost[1]  v-nol[1] ast.rem v-kf /*ast.ddt[1] */
        with frame ast.
 pause 0.       

vop=0.
m1:
repeat on error undo,retry on endkey undo,return:
 
  update v-kf with frame ast.

  v-icost[2]=v-icost[1] * v-kf.
  v-nol[2]  =v-nol[1] * v-kf.
  v-atl[2]  =v-icost[2] - v-nol[2].

  v-icost[3]=v-icost[2] + v-icost[1].
  v-nol[3]  =v-nol[2]   + v-nol[1].
  v-atl[3]  = v-icost[3] - v-nol[3].
  
  displ v-icost[2] v-nol[2] v-atl[2]
        v-icost[3] v-nol[3] v-atl[3] with frame ast.  

  update v-icost[2] v-nol[2] with frame ast.

  v-icost[3]=v-icost[2] + v-icost[1].
  v-nol[3]  =v-nol[2]   + v-nol[1].
  v-atl[3]  = v-icost[3] - v-nol[3].
  
  displ v-icost[3] v-nol[3] v-atl[3] with frame ast.  
  
 find asttr where asttr.asttr=v-atrx no-lock no-error.
 if avail asttr then v-arem[1]=asttr.atdes.
 
  /* + " (кф. + trim(string(v-kf)) + ")". */

  update v-arem[1] v-arem[2] v-arem[3] with frame ast.
  arem=trim(trim(v-arem[1]) + " " + trim(v-arem[2]) + " " + trim(v-arem[3])).
  arem1="". arem2="". 
  if v-icost[2] > 0 then do: sumd1=v-icost[2].   sumc1=0.
                                         vidop="D". arem1=arem.
                    end. 
                    else do: sumc1=v-icost[2] * (-1). sumd1=0.
                                         vidop="C". arem2=arem. 
                    end.

  if v-nol[2]   < 0 then do: sumd3=v-nol[2] * (-1).   sumc3=0. end. 
                    else do: sumc3=v-nol[2] .         sumd3=0. end.

  
 vop=1.
/*
 displ v-dam1 v-cam1  v-arem[1] v-arem[2] v-arem[3] kor-gl kor-acc with frame kor.
 message " 1 - ARP " /* 2 - Касса 3 - Счет клиента 4 - Счет гл.кн. 5 - EPS" */
          update vop auto-return format "9".
if vop <=0 or vop >5 then undo,next m1.


{ast-jlk.i}
*/

    otv=true.
    message "  ОПЕРАЦИЮ ВЫПОЛНИТЬ ?  " UPDATE otv format "да/нет".
    if not otv then next m1 . /*return. */

klud=true.

 DO transaction:

                  
   shcode="AST0004".
   vdel="^".
   vparam=string(sumd1)   + vdel +
          ast.ast         + vdel + 
          arem1           + vdel +
          string(sumc3)   + vdel +
          string(sumc1)   + vdel +
          arem2           + vdel +
          string(sumd3).  
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

        find ast where ast.ast=v-ast exclusive-lock.
                   ast.ofc=g-ofc.
                   ast.updt=g-today.
                   ast.ydam[4]=ast.ydam[4] + sumd1 - sumc1.
                   ast.ycam[4]=ast.ycam[4] + sumc3 - sumd3.

         find first astatl where astatl.agl=ast.gl and astatl.ast=ast.ast and
                                 astatl.dt=g-today exclusive-lock no-error. 
             if not available astatl then create astatl. 
             astatl.ast=ast.ast.
             astatl.agl=v-gl.
             astatl.fag=ast.fag.
             astatl.dt=g-today.
             astatl.icost= ast.dam[1] - ast.cam[1].
             astatl.nol= ast.cam[3] - ast.dam[3].
             astatl.atl=astatl.icost - astatl.nol.
             astatl.qty=ast.qty.
             astatl.fatl[4]= ast.cam[4] - ast.dam[4].  


           create astjln.
           astjln.ajh = s-jh.
           astjln.aln = 1.
           astjln.awho = g-ofc.
           astjln.ajdt = g-today.
           astjln.arem[1]= v-arem[1].
           astjln.arem[2]= v-arem[2].
           astjln.aamt = 0.
           astjln.dam = ?. 
           astjln.cam=  ?.   
           astjln.adc = vidop.  
           astjln.d[1]= sumd1.       
           astjln.c[1]= sumc1.  
           astjln.d[3]= sumd3.       
           astjln.c[3]= sumc3.  
           astjln.d[4]= sumc3 + sumc1. 
           astjln.c[4]= sumd1 + sumd3.
           astjln.agl = ast.gl.   
           astjln.aqty = 0.
           astjln.aast = ast.ast.
           astjln.afag = ast.fag.
           astjln.atrx= v-atrx.
           astjln.ak= ast.cont.
           astjln.apriz="".
           astjln.korgl=v-gl4.
           astjln.koracc=ast.ast.
           astjln.vop=vop. /* gl.gr */

       run x-jlvouR.
       pause 0 .

   end.
klud=false.

 END.  /*transaction*/

leave.
end. /*repeat*/

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


