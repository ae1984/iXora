/* astpc.p
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
        21/04/05 sasco исправил примечание в проводке
        10.02.10 marinav - расширение поля счета до 20 знаков
*/

/* papild summas   1 or 3*/
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
def var v-ast1 like ast.ast format "x(8)".
def new shared var v-gl  like ast.gl.         
define new shared variable v-gl3 like trxlevgl.glr.
define new shared variable v-gl4 like trxlevgl.glr.
def new shared var v-qty like ast.qty format "zzz9" init 1.         
def new shared var vidop as char.
def new shared var v-fag as char format "x(3)".
def new shared var v-sum as dec format "zzz,zzz,zzz,zz9.99".
def new shared var v-cont like ast.cont format "x".
/*
def new shared var v-crline like ast.crline format "zzzzzzzz9.99-" init 0.
def new shared var v-ydam5 like ast.icost format "zzzzzzzz9.99-".            
*/
def var atld as dec  format "zzzzzz,zzz,zz9.99" init 0.
def var atlc as dec  format "zzzzzz,zzz,zz9.99" init 0.
def var fondd as dec format "zzzzzz,zzz,zz9.99" init 0.
def var fondc as dec format "zzzzzz,zzz,zz9.99" init 0.
def new shared var v-icost like ast.dam format "zzzzzz,zzz,zz9.99-".            
def var v-nol  like ast.dam format "zzzzzz,zzz,zz9.99-".
def var v-atl  like ast.dam format "zzzzzz,zzz,zz9.99-".
def var v-fond like ast.dam format "zzzzzz,zzz,zz9.99-".
def var v-ydam4 like ast.dam format "zzzzzz,zzz,zz9.99-".
def var v-ycam4 like ast.dam format "zzzzzz,zzz,zz9.99-".
def var v-fond1 as dec       format "zzz,zzz,zzz,zz9.99".
def var v-fagn like fagn.naim.
def new shared var v-atrx as char.
def new shared var v-arem as char extent 5 format "x(55)".
def new shared var vop as int.
def new shared var kor-gl like jl.gl.
def new shared var kor-gl1 like jl.gl.
def new shared var kor-acc like arp.arp.
def new shared var kor-acc1 like arp.arp.
define var kodcrc like crc.code.
def var v-gldes as char.
def var v-gln as char.
def var v-kdes1 as char.
def var v-gldes1 as char.
define new shared variable v-gl3d like gl.des.
define new shared variable v-gl4d like gl.des.
def var v-kdes as char.
def var v-str1 as char.
def var v-str2 as char.
def var v-str3 as char.
def var v-str4 as char.
def var v-str5 as char.
def var vln as int.
def var otv as log.
def var vdel as cha initial "^" .
def var rdes   as cha .
def var rcode   as int .
def var vparam as cha .
def var shcode as cha .
def var arem as char.
def var arem1 as char.
def var arem2 as char.
def new shared var sumd1 as dec format "zzzzzz,zzz,zz9.99".
def new shared var sumc1 as dec format "zzzzzz,zzz,zz9.99".
def new shared var sumd3 as dec format "zzzzzz,zzz,zz9.99".
def new shared var sumc3 as dec format "zzzzzz,zzz,zz9.99".
def var klud as log .
{global.i}

form
    "Nr.КАРТОЧКИ :" v-ast  "ГР.:" ast.fag  v-fagn  "  СЧЕТ :" ast.gl skip
    "НАЗВАНИЕ    :" ast.name  skip 
    "КОЛИЧЕСТВО  :" ast.qty format "zzz9" "ДАТА РЕГ. :" at 40 ast.rdt skip
    "      Суммы   до операции           +/-      после операции " skip
    "БАЛАНС.СТОИМ:" v-icost[1]  v-icost[2] v-icost[3] skip
    "ИЗНОС       :" v-nol[1]    v-nol[2]   v-nol[3]   skip                  
    "ОСТАТ.СТОИМ.:" v-atl[1]    v-atl[2]   v-atl[3]   skip        

    "ПРИМЕЧАНИЕ  :" ast.rem skip(1)
  with frame ast row 2 overlay centered no-label
                 title "   " + v-arem[1] + " " + ti. 

form 
"Сумма переоценки    до операции           +/-      после операции" skip
" основной стоим.:" v-ydam4[1] v-ydam4[2] v-ydam4[3] skip   
"         износа :" v-ycam4[1] v-ycam4[2] v-ycam4[3] skip    
"Фонда переоценки:"  v-fond[1]  v-fond[2] v-fond[3] skip 
  with frame pereo row 14 overlay centered no-labels no-hide
    title "  КОРРЕКТИРОВКА ФОНДА ПЕРЕОЦЕНКИ ".



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

form
"     Счет                                Субсчет                           Сумма " kodcrc skip
"---------------------------------------------------------------------------------------" skip
"   "   v-str1  format "x(87)"  skip 
"   "   v-str2  format "x(87)"  skip 
""  kor-gl  v-gldes format "x(32)"   kor-acc      v-sum to 83 v-str3 skip
 v-kdes  at 12  format "x(30)"            skip 
  skip(4)
"ОПИСАНИЕ:" v-arem[1]  skip v-arem[2] at 11 skip v-arem[3] at 11
 with frame kor overlay  no-labels row 5 width 100.

form
 v-str4 format "x(84)"  skip
""  kor-gl1  v-gldes1 format "x(32)"  kor-acc1      v-fond1 to 83 v-str5 skip
       v-kdes1  at 12  format "x(30)"            skip 
 with frame kor4 overlay column 2 no-labels row 15 width 100 no-box.

form
" ОПИСАНИЕ:"  v-arem[1] at 11  skip v-arem[2] at 11 skip v-arem[3] at 11
 with frame kor5 overlay no-labels row 18 column 2 no-box.



hide all.
 if vo="+"      then v-atrx="2".
 else if vo="-" then v-atrx="5".
 else if vo="1" then v-atrx="1".     
 else if vo="3" then v-atrx="3".
 else if vo="8" then v-atrx="81".

 find asttr where asttr.asttr=v-atrx no-lock no-error.
 if avail asttr then v-arem[1]=asttr.atdes.


update v-ast validate(v-ast ne ""," ВВЕДИТЕ КАРТОЧКУ " )
    with frame ast.
v-ast1=v-ast.
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
 if vo="1" or vo="3" or vo="8" then do: 
   find first astjln where astjln.aast=v-ast and (substr(astjln.atrx,1,1)=vo or 
                 astjln.atrx="71") use-index astdt no-lock no-error.
   if not avail astjln then do:
                     message "Операций '" v-arem[1] "' с карт. " v-ast " не было".
                     pause 5. return. end.             
  end.  

 v-ast=ast.ast. 
 v-gl=ast.gl.
 find gl where gl.gl=v-gl no-lock.
 v-gln=gl.des.
 find first trxlevgl where trxlevgl.gl=ast.gl and trxlevgl.lev=3 no-lock no-error.
 if available trxlevgl then v-gl3 = trxlevgl.glr. else v-gl3=?.   
 find gl where gl.gl eq v-gl3 no-lock no-error.
 if available gl then v-gl3d =gl.des. else v-gl3d="".

 find first trxlevgl where trxlevgl.gl=ast.gl and trxlevgl.lev=4 no-lock no-error.
 if available trxlevgl then v-gl4 = trxlevgl.glr. else v-gl4=?.   
 find gl where gl.gl eq v-gl4 no-lock no-error.
 if available gl then v-gl4d =gl.des. else v-gl4d="".
 find first crc where crc.crc=ast.crc no-lock.
 kodcrc=crc.code.


 v-qty=0.
 v-fag=ast.fag.
 find fagn where fagn.fag=v-fag no-lock.
 v-fagn=fagn.naim.
 v-icost[1]= ast.dam[1] - ast.cam[1].
 v-nol[1]  = ast.cam[3] - ast.dam[3].
 v-fond[1] = ast.cam[4] - ast.dam[4].
 v-atl[1]  = v-icost[1] - v-nol[1].
 v-cont=ast.cont.  
 v-ydam4[1]=ast.ydam[4].
 v-ycam4[1]=ast.ycam[4].
 displ  v-ast ast.fag v-fagn ast.gl ast.qty  ast.rdt ast.name /*ast.addr[2]*/
        v-atl[1] v-icost[1]  v-nol[1]  ast.rem /*ast.ddt[1]*/
        v-atl[3]
        with frame ast.
 pause 0.       

vop=0.

ma:
repeat on error undo,retry on endkey undo,return:
 
  update v-icost[2] with frame ast.
  v-icost[3]=v-icost[1] + v-icost[2].  
  displ v-icost[3] with frame ast. pause 0.
  if v-icost[3] <= 0 then do: message " <= 0 " . next ma. end.

  update v-nol[2] with frame ast.
  v-nol[3]=v-nol[1] + v-nol[2].  
  displ v-nol[3] with frame ast. pause 0.
  if v-nol[3] < 0 then do: message " < 0 " . next ma. end.
  if v-nol[3] > v-icost[3]  then do: message " > " v-icost[3] . next ma. end.

  v-atl[3]=v-icost[3] - v-nol[3].
  displ v-atl[3] with frame ast. pause 0.

 if vo="3" then repeat:
       displ v-fond[1] v-ydam4[1] v-ycam4[1] with frame pereo.
         update v-ydam4[2] v-ycam4[2] with frame pereo.
          v-fond[2]=v-ydam4[2] - v-ycam4[2]. 
         update v-fond[2] with frame pereo.
         
         if v-ydam4[2] ne 0 and v-ycam4[2] ne 0 and
            v-fond[2] ne (v-ydam4[2] - v-ycam4[2]) 
         then message " проверьте суммы".
         /*else
         if v-fond[2] < 0 then message " фонд переоценки < 0 ". 
         */
         else do:
          if v-ydam4[2] eq 0 and v-ycam4[2] eq 0 then v-ydam4[2]=v-fond[2].
          v-ydam4[3]=v-ydam4[1] + v-ydam4[2].   
          v-ycam4[3]=v-ycam4[1] + v-ycam4[2].   
          v-fond[3]=v-ydam4[3] - v-ycam4[3].
          displ v-ycam4[2] v-fond[2] v-ydam4[3] v-ycam4[3] v-fond[3] v-ydam4[2]
               with frame pereo. leave. 
         end.
        
 end.

 find asttr where asttr.asttr=v-atrx no-lock no-error.
 if avail asttr then v-arem[1]=asttr.atdes.

  if v-icost[2] > 0 then do: sumd1=v-icost[2].   sumc1=0.
                                         vidop="D". arem1=arem.
            v-str1=string(v-gl,"zzzzz9") + " " +
            substring(v-gln + "                                      ",1,29)
            + substring(v-ast,1,10) + "                 " +      
            string(sumd1,"zzz,zzz,zzz,zz9.99") + "  DR".

  end. 
  else do: sumc1=v-icost[2] * (-1). sumd1=0.
                                         vidop="C". arem2=arem. 
            v-str1=string(v-gl,"zzzzz9") + " " +
            substring(v-gln + "                                     ",1,29)
            + substring(v-ast,1,10) + "                 " +      
            string(sumc1,"zzz,zzz,zzz,zz9.99") + "  CR".

  end.

  if v-nol[2]   < 0 then do: sumd3=v-nol[2] * (-1).   sumc3=0.
  
            v-str2=string(v-gl3,"zzzzz9") + " " +
            substring(v-gl3d + "                                    ",1,29)
            + substring(v-ast,1,10) + "                 " +      
            string(sumd3,"zzz,zzz,zzz,zz9.99") + "  DR".
  end. 
  else do: sumc3=v-nol[2] .         sumd3=0.
            v-str2=string(v-gl3,"zzzzz9") + " " +
            substring(v-gl3d + "                                    ",1,29)
            + substring(v-ast,1,10) + "                 " +      
            string(sumc3,"zzz,zzz,zzz,zz9.99") + "  CR".
  end.
  v-sum=sumd1 - sumc1 + sumd3 - sumc3. /* atl.vert.*/
  arem1="". arem2="".
  if v-sum >= 0 then do: v-str3= " CR".       atld=v-sum. atlc=0. 
                                            vidop="D". arem1=arem.

  end.
  else do: v-sum=v-sum * (-1).  v-str3=" DR". atld=0. atlc=v-sum.
                                           vidop="C". arem2=arem.
  end.

 vop=1.

m1:
repeat on endkey undo,next ma: 
 vop=1.

 displ v-str1  v-str2 v-str3 v-arem[1] v-arem[2] v-arem[3]
       kor-gl kor-acc v-sum with frame kor.

/*
 message " 1 - ARP " /* 2 - Касса 3 - Счет клиента 4 - Счет гл.кн. 5 - EPS" */
          update vop auto-return format "9".
if vop <=0 or vop >5 then undo,next ma.
*/

{ast-jlk.i}
kor-acc1=kor-acc.
if v-fond[2] ne 0 then do:

  if v-fond[2] > 0 then do: v-fond1=v-fond[2]. v-str5= " DR".
     v-str4=string(v-gl4,"zzzzz9") + " " +
            substring(v-gl4d + "                                    ",1,29)
          + substring(v-ast,1,10) + "                   " +      
            string(v-fond1,"zzz,zzz,zzz,zz9.99") + "  CR".
            fondc=v-fond1. fondd=0.
  end.
  else do: v-fond1=v-fond[2] * (-1).  v-str5=" CR".
      v-str4=string(v-gl4,"zzzzz9") + " " +
            substring(v-gl4d + "                                    ",1,29)
            + substring(v-ast,1,10) + "                 " +      
            string(v-fond1,"zzz,zzz,zzz,zz9.99") + "  DR".
            fondd=v-fond1. fondc=0.

  end.
  pause 0.
  displ  v-str4 v-fond1 v-str5 with frame kor4.

/*
 message "ДЕБЕТ : 1 - ARP "  
          update vop auto-return format "9".
*/
   message " Введите номер ARP".
   update kor-acc1 with frame kor4.
   find arp where arp.arp eq kor-acc1 no-lock no-error.
   if not available arp then do: bell. {mesg.i 2203}. undo,retry. end.
   if arp.crc <> 1 then do: bell. {mesg.i 9813}. undo,next. end.
   kor-gl1=arp.gl.
   v-kdes1=arp.des.
   displ kor-gl1 v-kdes1 with frame kor4. 
   find gl where gl.gl=kor-gl1 no-lock no-error.
   if gl.sts eq 9 then do: bell. {mesg.i 1827}. undo,next. end.
   v-gldes1=gl.des. displ v-gldes1 with frame kor4.

end.
else kor-acc1=kor-acc.


 /*. displ v-sum1 with frame kor. .*/
  pause 0.
  update v-arem[1] v-arem[2] v-arem[3] with frame kor5.

leave.
end. /*repeat m1*/


/*
leave.
end. /*repeat ma*/

*/
 otv=true.
repeat on endkey undo,retry:
 message "  ОПЕРАЦИЮ ВЫПОЛНИТЬ ?  " UPDATE otv format "да/нет".
   if not otv then return.
   
leave.
end.
klud=true.

Do transaction:

   arem=trim(trim(v-arem[1]) + " " + trim(v-arem[2]) + " " + trim(v-arem[3])).
   arem1 = arem.
   arem2 = arem.

   shcode="AST0003".
   vparam=string(atld)        + vdel +   /* atlik.vert >0*/
          ast.ast             + vdel +  
          kor-acc             + vdel +
          arem1               + vdel +
          string(atlc)        + vdel +   /* atlik.vert <0 */
          arem2               + vdel +
          string(sumc3)       + vdel +         /* noliet >0 */
          string(sumd3)       + vdel +         /* noliet <0 */
          string(fondc)       + vdel +         /* fond parv.>0 */
          kor-acc1            + vdel +
          string(fondd)              .
          

   s-jh = 0.
   run trxgen(shcode,vdel,vparam,"","",output rcode,output rdes,
              input-output s-jh).
   if rcode > 0 or s-jh = 0  then
   do:
         Message " Error: " + string(rcode) + ":" +  rdes .
         pause .
         undo,next ma.
   end.
   else 
   do:
       find ast where ast.ast=v-ast exclusive-lock.
               ast.ofc=g-ofc.
               ast.updt=g-today.
               ast.ydam[4]=ast.ydam[4] + v-ydam4[2].
               ast.ycam[4]=ast.ycam[4] + v-ycam4[2].

      /*.   run ast-jln(output otv).
         if otv =false then undo,next m1.
      tagad zdes .*/
      create astjln.
      astjln.ajh = s-jh.
      astjln.aln = 1.
      astjln.awho = g-ofc.
      astjln.ajdt = g-today.
      astjln.arem[1]=substring(v-arem[1],1,55).
      astjln.arem[2]=substring(v-arem[2],1,55).
      astjln.arem[3]=substring(v-arem[3],1,55).
      astjln.arem[4]=substring(v-arem[4],1,55).
       
      astjln.d[1]=sumd1.
      astjln.c[1]=sumc1.
      astjln.d[3]=sumd3.
      astjln.c[3]=sumc3.  
      astjln.d[4]=v-ycam4[2].
      astjln.c[4]=v-ydam4[2].  
   /*.
      astjln.aamt = v-sum. 
      astjln.dam= sumd1.   
      astjln.cam= sumc1.   
     
   .*/
      if vidop="D" then do:
        astjln.adc = "D".    
      end.
      else do:
        astjln.adc = "C".   
      end.
   
      astjln.agl = v-gl.
      astjln.aqty= v-qty.
      astjln.aast = v-ast.
      astjln.afag = v-fag.
      astjln.atrx= v-atrx.
      astjln.ak=v-cont.
    /*
      astjln.crline=v-crline.
      astjln.prdec[1]=v-ydam5.
     */
      astjln.icost=v-icost[2].
      astjln.korgl=kor-gl.
      astjln.koracc=kor-acc.
      astjln.vop=vop.
      /*astjln.kpriz= " " + string(vop) + " " + string(kor-gl) + " " + kor-acc.
      */
      if (vop=7 and v-atrx="6") or substring(v-atrx,1,1)="9" then
      astjln.apriz="A".
      find ast where ast.ast=v-ast no-lock no-error.
      find first astatl where astatl.agl=v-gl and astatl.ast=v-ast and
           astatl.dt=g-today exclusive-lock no-error. 
             if not available astatl then create astatl. 
             astatl.ast=v-ast.
             astatl.agl=v-gl.
             astatl.fag=v-fag.
             astatl.dt=g-today.
             astatl.icost=ast.dam[1] - ast.cam[1] . /*ast.icost.*/
             astatl.nol=  ast.cam[3] - ast.dam[3].
             astatl.fatl[4]= ast.cam[4] - ast.dam[4].
             astatl.atl=astatl.icost - astatl.nol.
             astatl.qty=ast.qty.
               

       run x-jlvouR.
       pause 0 .
       klud=false.
   end.
 end. /* tranz*/
/* n */
 
leave.
end. /*repeat ma*/

release ast.
release astatl.
release astjln.


if rcode = 0 and not klud then repeat:
  otv=false.

  message "  Повторить печать?  " UPDATE otv format "да/нет". 

/* 
  message "  Повторить печать?  "
           view-as alert-box question buttons yes-no title "" update otv.
*/
 if  otv then do: 
    message "ПЕЧАТЬ ОРДЕРА # " + string(s-jh) + " ".
    run x-jlvouR.  pause 0.
 end.
 else leave.
end.




