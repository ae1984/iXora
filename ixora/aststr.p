/* aststr.p
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
        12.12.03 suchkov Исправлена ошибка при сторнировании ремонта
*/

def shared var s-jh like jh.jh.
def var s-jhs like jh.jh.
def shared var vv-ast like ast.ast format "x(8)".
def new shared buffer b-astjln for astjln.
def var v-dam as dec format "zzz,zzz,zz9.99".
def var v-cam as dec format "zzz,zzz,zz9.99".
def new shared var v-sum as dec format "zzz,zzz,zz9.99".
def var v-atl like ast.icost format "zzz,zzz,zz9.99".

def var v-ajh like jh.jh.
def var v-ajdt like astjln.ajdt.
def new shared var v-atrx as char.
def new shared var vop as int.
def  new shared var kor-gl like jl.gl.
def  new shared var kor-acc like jl.acc.     
def var v-kdes as char.
def var v-gldes as char.
def new shared var v-arem as char extent 5 format "x(55)".
def var otv as log.
def var klud as log init true.
def new shared var vidop as char.
def new shared var v-ast like ast.ast.
def new shared var v-gl  like ast.gl.         
def new shared var v-qty like ast.qty format "zzz,zz9".         
def new shared var v-fag as char format "x(3)".
def new shared var v-cont like ast.cont format "x".
def new shared var v-crline like ast.crline .
def var v-nol as dec format "z,zzz,zzz,zzz,zz9.99" .
def new shared var v-icost like ast.icost .
def new shared var v-ydam5 as dec format "zzzzzzz9.99-" init 0.
define new shared variable v-gl3 like trxlevgl.glr.
define new shared variable v-gl4 like trxlevgl.glr.
define new shared variable v-am like trxlevgl.glr.
define new shared variable v-gl3d like gl.des.
define new shared variable v-gl4d like gl.des.
define new shared variable v-gl1d like gl.des.
define new shared variable v-gl1  like ast.gl.
def var rdes   as cha .
def var rcode   as int .

def var sumd1 as dec format "zz,zzz,zz9.99".
def var sumc1 as dec format "zz,zzz,zz9.99".
def var sumd3 as dec format "zz,zzz,zz9.99".
def var sumc3 as dec format "zz,zzz,zz9.99".
def var sumd4 as dec format "zz,zzz,zz9.99".
def var sumc4 as dec format "zz,zzz,zz9.99".



{global.i}
{astjln.f}
/*
form
"     Счет                              Субсчет   Дебет           Кредит  Вал.1" skip
"-----------------------------------------------------------------------------" skip
"001"   astjln.agl       astjln.aast  at 25 skip  
         ast.name at 12       astjln.cam format "zzz,zzz,zz9.99" to 55 
                              astjln.dam format "zzz,zzz,zz9.99" to 72 skip            
"002"   kor-gl  v-gldes format "x(27)"  kor-acc skip
         v-kdes  at 12 format "x(30)"  v-cam to 55     v-dam to 72 skip(1)
"ОПИСАНИЕ:" v-arem[1]  skip v-arem[2] at 11 skip v-arem[3] at 11 skip(1)
 with frame kor overlay centered no-labels row  9 .

*/
 find ast where ast.ast=vv-ast no-lock no-error.
  if not avail ast then do: message "КАРТОЧКИ НЕТ ". pause 5. return. end.
 find first astjln where astjln.aast=vv-ast and astjln.ajh=s-jh
      use-index astdt no-lock no-error.
  if not avail astjln then do: message "ТРАН. НЕТ ". pause 5. next. end.

/** ??? VREMENNO
 if astjln.ajdt=g-today then do:
    message 'Операция выполнена сегодня. УДАЛИТЕ'. pause 5. return.
 end.
**/ 
 v-qty=0.
 v-ajh=s-jh.
 v-ajdt=astjln.ajdt.
  If astjln.atrx <> "1"  and
     astjln.atrx <> "11" and
     astjln.atrx <> "6"  and
     astjln.atrx <> "9"  and
     astjln.atrx <> "91" and
     astjln.atrx <> "2"  and
     astjln.atrx <> "3"  and
     astjln.atrx <> "31" and
     astjln.atrx <> "81" and
     astjln.atrx <> "86" and
     astjln.atrx <> "4"  and
     astjln.atrx <> "p"  and
     astjln.atrx <> "r"  and    /* suchkov */
     astjln.atrx <> "r1" and    /* suchkov */
     astjln.atrx <> "5" 
      then do: message "Выполните другую операцию.". pause 5. return. end.
/*  nedrikst stornet :  " */

             find ast where ast.ast=astjln.aast no-lock no-error.
             v-atl=ast.dam[1] - ast.cam[1] + ast.dam[3] - ast.cam[3].
             v-icost = ast.dam[1] - ast.cam[1].
             v-nol = ast.cam[3] - ast.dam[3]. 
             v-gl1 = astjln.agl. 
             find gl where gl.gl eq ast.gl no-lock no-error.
             if available gl then v-gl1d =gl.des.
 
             find first trxlevgl where trxlevgl.gl = ast.gl and
                     trxlevgl.lev = 3 no-lock no-error.
             if avail trxlevgl then v-gl3 = trxlevgl.glr. else v-gl3=?.   
             v-am = v-gl3. 
             find gl where gl.gl eq v-gl3 no-lock no-error.
             if avail gl then v-gl3d =gl.des. else v-gl3d="".
             v-am =v-gl3.
             find first trxlevgl where trxlevgl.gl = ast.gl and
                     trxlevgl.lev = 4 no-lock no-error.
             if avail trxlevgl then v-gl4 = trxlevgl.glr. else v-gl4=?.   
             find gl where gl.gl eq v-gl4 no-lock no-error.
             if avail gl then v-gl4d =gl.des. else v-gl4d="".

    displ   v-gl1 astjln.agl ast.rdt  v-atl v-am v-icost v-nol v-gl3
            ast.qty astjln.ajdt 
            g-today
            astjln.awho astjln.c[1] astjln.d[1] astjln.d[3] astjln.c[3]
            astjln.d[4] astjln.c[4]
            astjln.aqty astjln.ajh astjln.arem[1] astjln.arem[2]
            astjln.korgl astjln.koracc astjln.kpriz astjln.atrx 
            astjln.stdt astjln.stjh /*astjln.crline*/ v-gl3 v-am v-gl4
            /*astjln.prdec[1]*/
            with frame astjln. 
            pause 0.


   v-atrx=substring(astjln.atrx,1,1) + "0".
   v-arem[1]="Сторно опер." + string(v-ajh) + "  " + string(v-ajdt). 
   kor-gl=astjln.korgl.
   kor-acc=astjln.koracc.
   sumc1=astjln.d[1].       
   sumd1=astjln.c[1].  
   sumc3=astjln.d[3].       
   sumd3=astjln.c[3].
   sumc4=astjln.d[4].
   sumd4=astjln.c[4].  
   if astjln.adc = "D"  then vidop="C". else vidop="D". 

  otv=false.
 do on endkey undo,return:
   message "  ОПЕРАЦИЮ СТОРНИРОВАТЬ ?  " UPDATE otv format "да/нет".
   pause 0.
   if not otv then return.
 end.  


klud=true.
 do transaction:


   s-jhs = 0.
   run trxstor(s-jh,6,output s-jhs,output rcode,output rdes).

   if rcode > 0 or  s-jhs = 0  then
   do:
        Message " Error: " + string(rcode) + ":" +  rdes .
        pause .
        undo, return . 
   end.
   else 
   do:

        find ast where ast.ast=vv-ast exclusive-lock.

        ast.ldd = ast.updt.
        ast.ofc=g-ofc.
        ast.updt=g-today.
        ast.icost=ast.dam[1] - ast.cam[1].

    find first astjln where astjln.aast=vv-ast and astjln.ajh=s-jh
                      use-index astdt exclusive-lock no-error.
    if avail astjln then do: astjln.stdt=g-today. astjln.stjh=s-jhs. end.

    if substring(astjln.apriz,1,1) = "A" then
              ast.amt[5]=ast.amt[5] - astjln.c[3] + astjln.d[3].

    ast.ydam[5]= ast.ydam[5] -  astjln.prdec[1]. /* 80 ? */

    if astjln.adc = "D"   then do:     
              ast.crline= ast.crline -  astjln.crline.

           if substring(astjln.apriz,1,1) ne "A" then
              ast.qty =ast.qty  - astjln.aqty.
    end.           
    else if astjln.adc="C"  then do:

              ast.crline= ast.crline +  astjln.crline.

           if substring(astjln.apriz,1,1) ne "A" then
              ast.qty =ast.qty  + astjln.aqty.
    end.
    
    
   if astjln.atrx="1" or astjln.atrx="3" or astjln.atrx="81" then do:
                   ast.amt[3]=ast.amt[3] - (astjln.d[1] - astjln.c[1] + /*vdam.*/
                                            astjln.d[3] - astjln.c[3]).
                                /* ast.amt[3]=ast.amt[3] - vdam. */
                   ast.meth=ast.meth - astjln.aqty.  
    end.
    else if astjln.atrx="10" or astjln.atrx="30" then do:
                   ast.amt[3]=ast.amt[3] + (astjln.d[1] - astjln.c[1] + /*vcam.*/
                                            astjln.d[3] - astjln.c[3]).
                   ast.meth=ast.meth + astjln.aqty.  
    end.
    
    if astjln.atrx="r1" or astjln.atrx="r" then do:
   
    end.

    if astjln.atrx="11" or astjln.atrx="31" or astjln.atrx="71" then do:
                   ast.meth=ast.meth - astjln.aqty.  
    end.
    else if astjln.atrx="9"  then do:
            ast.ldd=ast.cdt[1].
            if ast.cdt[1]<>? then do:
               ast.cdt[1]= if month(ast.cdt[1])=1 
                          then date(12,28,year(ast.cdt[1]) - 1) 
                          else date(month(ast.cdt[1]) - 1,28,year(ast.cdt[1])). 
              if ast.rdt >ast.cdt[1] then ast.cdt[1]=?.
            end.
    end.

   if substring(astjln.atrx,1,1) = "p"  then do:
             ast.ydam[4]=ast.ydam[4] - (astjln.d[1] - astjln.c[1]).
             ast.ycam[4]=ast.ycam[4] - (astjln.c[3] - astjln.d[3]).
    end.
   else do:
      ast.ydam[4]=ast.ydam[4] - astjln.c[4].
      ast.ycam[4]=ast.ycam[4] - astjln.d[4].
   end.

   if ast.qty<0 or ast.dam[1] - ast.cam[1]<0 then 
   do:  message "minus". pause 100.  end.


         find first astatl where astatl.agl=ast.gl and astatl.ast=ast.ast and
                                 astatl.dt=g-today exclusive-lock no-error. 
             if not available astatl then create astatl. 
             astatl.ast=ast.ast.
             astatl.agl=ast.gl.
             astatl.fag=ast.fag.
             astatl.dt=g-today.
             astatl.icost=ast.dam[1] - ast.cam[1].
             astatl.nol  =ast.cam[3] - ast.dam[3].
             astatl.fatl[4]  =ast.cam[4] - ast.dam[4].
             astatl.atl  =astatl.icost - astatl.nol.
             astatl.qty=ast.qty.



        /* запись   в astjln */
           create astjln.
           astjln.ajh = s-jhs.
           astjln.aln = 1.
           astjln.awho = g-ofc.
           astjln.ajdt = g-today.
           astjln.arem[1]= v-arem[1].
           astjln.aamt = 0.
           astjln.dam = ?. 
           astjln.cam= ?.   
           astjln.adc = vidop.  
           astjln.d[1]= sumd1.       
           astjln.c[1]= sumc1.  
           astjln.d[3]= sumd3.       
           astjln.c[3]= sumc3.  
           astjln.d[4]= sumd4.       
           astjln.c[4]= sumc4.  
           astjln.agl = ast.gl.   
           astjln.aqty = v-qty.
           astjln.aast = ast.ast.
           astjln.afag = ast.fag.
           astjln.atrx= v-atrx.
           astjln.ak= ast.cont.
           astjln.apriz="".
           astjln.korgl=kor-gl.
           astjln.koracc=kor-acc.

       s-jh=s-jhs.
       run x-jlvouR.
       pause 0 .
       klud=false.
   end.
END.  /*transaction*/


if rcode = 0 and not klud then repeat:
  otv=false.
  message "  Повторить печать?  " UPDATE otv format "да/нет". 
 if  otv then do: 
    message "ПЕЧАТЬ ОРДЕРА # " + string(s-jh) + " ".
    run x-jlvouR.  pause 0.
 end.
 else leave.
end.








/*******************

 if astjln.ajdt=g-today then do:
  
   if  astjln.vop = 2 then 
   do:  /* kase */
       find jh where jh.jh = s-jh no-lock.
       if jh.sts<6 then do: message 'операция не акцептована. УДАЛИТЕ'.
                            pause 5. return.
                        end.  
   end.
   else
   do: message 'Операция выполнена сегодня. УДАЛИТЕ'. pause 5. return.
   end.
 end.

 v-ajh=s-jh.
 v-ajdt=astjln.ajdt.
  If astjln.atrx <> "1"  and
     astjln.atrx <> "11" and
     astjln.atrx <> "6"  and
     astjln.atrx <> "9"  and
     astjln.atrx <> "91" and
     astjln.atrx <> "2"  and
     astjln.atrx <> "3"  and
     astjln.atrx <> "31" and
     astjln.atrx <> "81" and
     astjln.atrx <> "86" and
     astjln.atrx <> "4"  and
     astjln.atrx <> "5" 
      then do: message "Выполните другую операцию.". pause 5. return. end.

 find first b-astjln where b-astjln.aast=vv-ast and b-astjln.ajh>s-jh
      use-index astajh  no-lock no-error.
  if avail b-astjln and
     year(astjln.ajdt)=year(g-today) and (astjln.atrx="1" or astjln.atrx="11"
                                       or astjln.atrx="3" or astjln.atrx="31")
    then do:   
    for each b-astjln where b-astjln.ajh>v-ajh and b-astjln.aast=vv-ast no-lock:
       if b-astjln.apriz<>"A" then  do: vop=0. leave. end.
                              else  do: vop=6. end.                  
    end.      
  end.
 if astjln.atrx<>"1" and astjln.atrx<>"11" and astjln.atrx<>"3" and astjln.atrx<>"31"
  then do:
  find first b-astjln where b-astjln.aast=vv-ast and b-astjln.ajh>s-jh 
       and b-astjln.atrx="9" no-lock no-error.
   if avail b-astjln  then do:
    message " Есть еще одна операция ИЗНОСА ". pause 5. return. 
   end.
 end.

if astjln.atrx="11" or astjln.atrx="31" then vop=6.
if astjln.atrx="81" or astjln.atrx="86" then vop=1.
if astjln.vop=2 then vop=1.


             v-atl=ast.dam[1] - ast.cam[1].
    displ   astjln.agl ast.rdt  v-atl ast.qty astjln.ajdt g-today
            astjln.awho  astjln.apriz astjln.cam astjln.dam
            astjln.aqty astjln.ajh astjln.arem[1] astjln.arem[2] astjln.arem[3]
            astjln.korgl astjln.koracc astjln.kpriz astjln.atrx 
            astjln.stdt astjln.stjh astjln.icost astjln.crline  
            with frame astjln. 
 otv=true.
 message "  ОПЕРАЦИЮ СТОРНИРОВАТЬ ?  " UPDATE otv format "да/нет".
 message "  Oper–ciju STORNЁT ?  " UPDATE otv format "J–/Ne".
   if not otv then return.

v-dam=astjln.cam.
v-cam=astjln.dam.
v-ast=astjln.aast.
v-gl=astjln.agl.
v-qty =astjln.aqty.         
v-fag =astjln.afag.
v-cont =astjln.ak.
v-crline =astjln.crline .
v-ydam5=astjln.prdec[1].
v-icost =astjln.icost .
if vop=0 and astjln.vop<>0 then vop=astjln.vop.

kor-gl=astjln.korgl.
kor-acc=astjln.koracc.

m1:
repeat on error undo,retry on endkey undo,return:

   v-arem[1]="Сторно опер." + string(v-ajh) + "  " + string(v-ajdt). 

    displ  astjln.agl  astjln.aast ast.name  astjln.dam  astjln.cam            
           kor-gl v-gldes  kor-acc v-kdes v-dam  v-cam
           v-arem[1] v-arem[2] v-arem[3]
    with frame kor. pause 0.
 message " 1 -ARP   3 -СЧЕТ КЛИЕНТА 4 -СЧЕТ ГЛ.КН. 5 -EPS 6 -AST"
          update vop auto-return format "9".
if vop <=0 or vop >6 or vop=2 then undo,next m1.

If vop=6 then do: run aststrp. return. 
End.
Else do:
  if ast.dam[1] - astjln.dam < ast.cam[1] - astjln.cam  then do:
         message "Выполнить нельзя. Остаток <0 ". pause. return.
  end.       
  if substring(astjln.atrx,1,1) ne "9" and 
       ((astjln.adc="D" and ast.qty - astjln.aqty < 0) or 
       (astjln.adc="C" and ast.qty + astjln.aqty < 0)) then do:
         message "Выполнить нельзя. Кол-во <0 ". pause. return.
  end.
  if (ast.dam[1] - astjln.dam) - (ast.cam[1] - astjln.cam) = 0 and
      (substring(astjln.atrx,1,1) ne "9" and 
       ((astjln.adc="D" and ast.qty - astjln.aqty ne 0) or 
       (astjln.adc="C" and ast.qty + astjln.aqty ne 0))) then do:
         message "Выполнить нельзя. Остаток=0 .Кол-во > 0 ". pause. return.
  end.
  if (ast.dam[1] - astjln.dam) - (ast.cam[1] - astjln.cam) ne 0 and
      (substring(astjln.atrx,1,1) ne "9" and 
       ((astjln.adc="D" and ast.qty - astjln.aqty = 0) or 
       (astjln.adc="C" and ast.qty + astjln.aqty = 0))) then do:
         message "Выполнить нельзя. Остаток > 0 .Кол-во 0 .". pause. return.
  end.
  
  
  if astjln.atrx="11" or astjln.atrx="31"  then do:
         message "Выберите 6 AST ". pause 5. return.
  end.       
  if astjln.atrx="11" or astjln.atrx="31"  then do:
         message "Выберите 6 AST ". undo,next m1.
  end.       
  if astjln.adc="D" then do: vidop="C". v-sum=v-cam. end.
                    else do: vidop="D". v-sum=v-dam. end.
    v-atrx=substring(astjln.atrx,1,1) + "0".
                      
{ast-jlk.i}

End.     

  update v-arem[1] v-arem[2] v-arem[3] with frame kor.
  klud=false.
leave.
end. /*repeat*/


 otv=true.
repeat on endkey undo,retry:
 message "  ОПЕРАЦИЮ ВЫПОЛНИТЬ ?  " UPDATE otv format "да/нет".
   if not otv then return.
leave.
end.



do transaction:
         run x-jhnew.
end.

otv=false.
 DO transaction:

     astjln.stdt=g-today. astjln.stjh=s-jh.                        

      find ast where ast.ast=vv-ast.
        ast.updt=g-today.
        ast.ofc=g-ofc.
    if astjln.apriz="A" then ast.amt[5]=ast.amt[5] + astjln.dam - astjln.cam.
    if astjln.atrx="1" or astjln.atrx="3" or astjln.atrx="81" then do:
                   ast.icost=ast.icost - astjln.icost.
                   ast.amt[3]=ast.amt[3] - astjln.dam.
                   ast.meth=ast.meth - astjln.aqty.  
                   ast.qty=ast.qty - astjln.aqty.
                   ast.crline=ast.crline - astjln.crline. 
                   ast.ydam[5]=ast.ydam[5] - astjln.prdec[1]. 
    end.
    if astjln.atrx="2" then do:
                   ast.icost=ast.icost - astjln.icost.
                   ast.qty=ast.qty - astjln.aqty.
                   ast.crline=ast.crline - astjln.crline. 
                   ast.ydam[5]=ast.ydam[5] - astjln.prdec[1]. 
     end.
     else if astjln.atrx="6" or astjln.atrx="5" or astjln.atrx="4" or
             astjln.atrx="86" then do:
                   ast.icost=ast.icost + astjln.icost.
                   ast.qty=ast.qty + astjln.aqty.
                   ast.crline=ast.crline + astjln.crline. 
                   ast.ydam[5]=ast.ydam[5] + astjln.prdec[1]. 
     end.
     else if astjln.atrx="9" then do:
            ast.ldd=ast.cdt[1].
            if ast.cdt[1]<>? then do:
               ast.cdt[1]= if month(ast.cdt[1])=1 
                          then date(12,28,year(ast.cdt[1]) - 1) 
                          else date(month(ast.cdt[1]) - 1,28,year(ast.cdt[1])). 
              if ast.rdt >ast.cdt[1] then ast.cdt[1]=?.
            end.
                    ast.amt[5]=ast.amt[5] - astjln.cam + astjln.dam.
     end.
                   run ast-jll(output otv).
                 if otv =false then undo,retry.
   
find first jl where jl.jh=s-jh no-lock no-error.
if available jl then do:
  message "ПЕЧАТЬ ОРДЕРА # " + string(s-jh) + " ".
  run x-jlvou. pause 0.
  find jh where jh.jh eq s-jh.
  if jh.sts ne 6 then do:
   for each jl of jh:
    jl.sts = 5.
   end.
   jh.sts = 5.  
  end.
end.
otv=true.

END.  /*transaction*/

if otv then run astst.

**************/

