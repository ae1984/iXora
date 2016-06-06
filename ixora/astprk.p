/* astprk.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
	ПЕРЕОЦЕНКА ОСНОВНЫХ СРЕДСТВ
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
def new shared var s-jh1 like jh.jh.
def new shared var s-jh2 like jh.jh.
def var gg-crc as int.

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
define variable vousum1 like jl.dam initial 0.
define variable vousum2 like jl.dam initial 0.
define variable vousum like jl.dam initial 0.
def var crc-cod as char format "x(3)".

def var v-gldes as char.
def var v-gln like gl.des.
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
def var v-nos as char.
def var v-koef as decim format "zz9.99-".
def var gicost1 like ast.icost format "zzzzzz,zzz,zz9.99-".  
def var gicost2 like ast.icost format "zzzzzz,zzz,zz9.99-".
def var gicost3 like ast.icost format "zzzzzz,zzz,zz9.99-".
def var gnol1 like ast.icost format "zzzzzz,zzz,zz9.99-".
def var gnol2 like ast.icost  format "zzzzzz,zzz,zz9.99-".
def var gnol3 like ast.icost format "zzzzzz,zzz,zz9.99-".
def var gfond like ast.icost format "zzzzzz,zzz,zz9.99-".
def var vicost1 like ast.icost  format "zzzzzz,zzz,zz9.99-".  
def var vicost2 like ast.icost format "zzzzzz,zzz,zz9.99-".
def var vicost3 like ast.icost format "zzzzzz,zzz,zz9.99-".
def var vnol1 like ast.icost format "zzzzzz,zzz,zz9.99-".
def var vnol2 like ast.icost format "zzzzzz,zzz,zz9.99-".
def var vnol3 like ast.icost format "zzzzzz,zzz,zz9.99-".
def var vfond like ast.icost format "zzzzzz,zzz,zz9.99-".
def var vnaim as char.      
def var v-gr as char.
def var ddate as date.
def var was as logic.
def var tran as logic. 
def var i as integer.


 def temp-table   p   field ast like ast.ast 
                      field fag like ast.fag
                      field gl  like ast.gl
                      field icost like ast.dam format "zzzzzz,zzz,zz9.99-"
                      field nol  like ast.dam format "zzzzzz,zzz,zz9.99-"
                      field fond as decim format "zzzzzz,zzz,zz9.99-"
                      field astn like ast.name
                      index ast is primary gl fag ast.



{global.i}

form
 skip(1)
 "             ПО КАРТОЧКЕ            :"  v-ast skip
 "             ПО ГРУППЕ              :"  v-fag skip(1)
 "             ПО СЧЕТУ               :"  v-gl skip(1)
 " ВВЕДИТЕ КОЭФИЦЕНТ ПЕРЕОЦЕНКИ       :"  v-koef 
  with frame pereoc row 5 overlay centered no-label
       title " ПЕРЕОЦЕНКА ОСНОВНЫХ СРЕДСТВ  ".

for each p.
delete p.  
end.
 v-atrx=vo.  /* p */
 find asttr where asttr.asttr=v-atrx no-lock no-error.
 if avail asttr then v-arem[1]=asttr.atdes.


     update v-ast  with frame pereoc.
     if v-ast ne "" then do:
         find ast where ast.ast = v-ast  
           and  ast.dam[1] - ast.cam[1] > 0 no-lock no-error. 
       if not avail ast then do:  
         Message " Карточек с таким номером нет". Pause 4.
         undo, retry.
       end.
       else do:
          v-fag= ast.fag. 
          v-gl =ast.gl.
         displ v-ast v-fag v-gl  with frame pereoc.
       end.   

     end.          
     else do:
      update v-fag  with frame pereoc.
      
        find first ast where (if ast.fag ne " " then ast.fag = v-fag
                   else ast.fag > " ")  
                and  ast.dam[1] - ast.cam[1] > 0 no-lock no-error. 
        if v-fag ne " " then do:  
          v-fag= ast.fag. 
          v-gl =ast.gl.
          displ v-fag v-gl with frame pereoc.
         end.
     end. 
     if v-ast = "" and v-fag = "" then do:    
      update v-gl  with frame pereoc.
      find first ast where ast.gl = v-gl  
                 and  ast.dam[1] - ast.cam[1] > 0 no-lock no-error. 
       if not avail ast then do:  
         Message " Карточек с таким номером счета нет". Pause 4.
         undo, retry.
       end.
       else do:
         v-gl= ast.gl. 
         displ v-gl  with frame pereoc.
       end.
     end.
       update v-koef with frame pereoc.
       if v-koef = 0 then do:
         message "Проверьте коэфициент переоценки".           
         undo,retry.
       end.
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

For each ast where (if v-ast<> "" then ast.ast=v-ast else ast.ast>"0") and  
   (if v-fag  ne " " then ast.fag =v-fag else ast.fag ne " ") and  
   (if v-gl ne 0 then ast.gl=v-gl  else ast.gl > 0) and  
    ast.dam[1] - ast.cam[1] > 0 no-lock on endkey undo, retry: 

 gg-crc = ast.crc.
  create p.
     
     p.ast      = ast.ast.
     p.fag      = ast.fag.
     p.gl       = ast.gl.
     p.icost[1] = ast.dam[1] - ast.cam[1].
     p.icost[2] = (ast.dam[1] - ast.cam[1]) * v-koef. 
     p.icost[3] = p.icost[1] + p.icost[2].
     p.nol[1]   = ast.cam[3] - ast.dam[3].
     p.nol[2]   = (ast.cam[3] - ast.dam[3]) * v-koef.
     p.nol[3]   = p.nol[1] + p.nol[2].
     p.fond     = p.icost[2] - p.nol[2]. 
     p.astn     = ast.name. 
end.

 find first p  no-lock no-error.
   if not avail p then do:
      message " Данных нет ".  pause 6.          
      return.
   end. 

   
{image1.i rpt.img}
{image2.i}
{report1.i 132}
vtitle= "       Переоценка основных средсв  на "  + string(g-today).


{report2.i 172 
" ' Карт.Nr    Баланс.стоимость   Cумма переоценки   Стоимость ОС после    Износ ОС          Cумма переоценки   Износ ОС после    Фонд переоценки   Название осн.средств ' skip 
 '              до переоценки     баланс.стоимости      переоценки         до переоценки          износа          переоценки ' skip                
  fill('=',172) format 'x(172)' skip "}


For each p no-lock  break by p.gl by p.fag by p.ast :

       vicost1 = vicost1 + p.icost[1].
       vicost2 = vicost2 + p.icost[2].
       vicost3 = vicost3 + p.icost[3].
       vnol1   = vnol1   + p.nol[1].
       vnol2   = vnol2   + p.nol[2].
       vnol3   = vnol3   + p.nol[3].
       vfond   = vfond   + p.fond.
       gicost1 = gicost1 + p.icost[1].  
       gicost2 = gicost2 + p.icost[2].
       gicost3 = gicost3 + p.icost[3].
       gnol1   = gnol1   + p.nol[1].
       gnol2   = gnol2   + p.nol[2].
       gnol3   = gnol3   + p.nol[3].
       gfond   = gfond   + p.fond.

 PUT  p.ast  format "x(10)" at 1 
      p.icost[1] format "zzzzzz,zzz,zz9.99-" " "
      p.icost[2] format "zzzzzz,zzz,zz9.99-" " " 
      p.icost[3]  format "zzzzzz,zzz,zz9.99-" " "
      p.nol[1]  format "zzzzzz,zzz,zz9.99-" " "
      p.nol[2] format "zzzzzz,zzz,zz9.99-" " " 
      p.nol[3] format "zzzzzz,zzz,zz9.99-" " " 
      p.fond   format "zzzzzz,zzz,zz9.99-" " "  
      p.astn  format "x(30)" skip. 

 
    If last-of(p.fag) and v-ast = "" then do:
     
     find fagn where fagn.fag = p.fag no-lock no-error.
        if available fagn then vnaim = fagn.naim. 

  PUT
  fill('-',172) format 'x(172)' skip .
 put
 skip
      " Всего по группе: " at 1
       p.fag " " skip 
       gicost1 at 11 format "zzzzzz,zzz,zz9.99-" " "  
       gicost2 format "zzzzzz,zzz,zz9.99-" " "
       gicost3 format "zzzzzz,zzz,zz9.99-" " "
       gnol1 format "zzzzzz,zzz,zz9.99-" " "
       gnol2 format "zzzzzz,zzz,zz9.99-" " "
       gnol3 format "zzzzzz,zzz,zz9.99-" " " 
       gfond format "zzzzzz,zzz,zz9.99-" " "
       vnaim format "x(30)" skip 
fill('-',172) format 'x(172)' skip .

       gicost1 = 0.  
       gicost2 = 0.
       gicost3 = 0.
       gnol1   = 0.
       gnol2   = 0.
       gnol3   = 0.
       gfond   = 0.
   end.
  

END.  /* for each */

  if v-ast = "" and 
     v-fag = " " then do:
    PUT  "Всего по счету : " at 1 v-gl skip
       vicost1 at 11 format "zzzzzz,zzz,zz9.99-" " "  
       vicost2 format "zzzzzz,zzz,zz9.99-" " "
       vicost3 format "zzzzzz,zzz,zz9.99-" " "
       vnol1 format "zzzzzz,zzz,zz9.99-" " "
       vnol2 format "zzzzzz,zzz,zz9.99-" " "
       vnol3 format "zzzzzz,zzz,zz9.99-" " " 
       vfond format "zzzzzz,zzz,zz9.99-" " ".
  end. 

{report3.i}
{image3.i}

 was = true.  

repeat:
    otv=true.
/*    message "  Отчет печатать ?  " UPDATE otv  format "да/нет". 
*/
    hide all.
    message "  Отчет печатать ?  "  
      view-as alert-box question buttons yes-no title "" update otv.

    if otv then unix silent prit -t rpt.img.
     else leave.
 end.


hide all no-pause.
if   was = false then return.
   message "Тразакции по переоценке OC выполнить ?  " update tran  format "да/нет".
if  tran  then do:   /* run astptr.*/
         hide all.   
 
  vousum1 = 0. vousum2 = 0.

 find asttr where asttr.asttr= v-atrx no-lock no-error.
 if avail asttr then v-arem[1]= asttr.atdes + 
 " (кф."  + trim(string(v-koef)) + ")". 

   if  v-ast = "" and  v-fag ne "" then v-gr = " по группе " + v-fag. 
   else v-gr = " по счету " + string(v-gl).  
 

m1:
For each p no-lock on endkey undo,return: 


  if p.icost[2] > 0 then do: sumd1=p.icost[2].   sumc1=0.
                                         vidop="D". arem1=arem.
                    end. 
                    else do: sumc1=p.icost[2] * (-1). sumd1=0.
                                         vidop="C". arem2=arem. 
                    end.

  if p.nol[2]   < 0 then do: sumd3=p.nol[2] * (-1).   sumc3=0. end. 
                    else do: sumc3=p.nol[2] .         sumd3=0. end.

  
 vop=1.
 
   shcode="AST0004".
   vdel="^".
   vparam=string(sumd1)   + vdel +
          p.ast         + vdel + 
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
          undo, next m1 . 
   end.

   else do:
      i = i + 1. if i=1 then s-jh1=s-jh.

        find ast where ast.ast=p.ast exclusive-lock.
                   ast.ofc=g-ofc.
                   ast.updt=g-today.
                   ast.ydam[4]=ast.ydam[4] + sumd1 - sumc1.
                   ast.ycam[4]=ast.ycam[4] + sumc3 - sumd3.
                   vousum1 = vousum1 + sumd1 - sumc1.  
                   vousum2 = vousum2 + sumc3 - sumd3.
                   vousum  = vousum + vousum1 + vousum2.
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
           astjln.c[4]= sumd1 - sumd3.
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
   end.

end.  /* For each */
      
s-jh2 = s-jh.
 
if v-ast = " " then do:
    find first cmp.

   find crc where crc.crc=gg-crc no-lock.
   if avail crc then crc-cod=crc.code.
   message " Включите принтер ". pause 20.

   output to vou.img page-size 0.
   Put skip(3)
   fill('=',78) format 'x(78)'  skip
    cmp.name "         Ордер по переоценке оновных средств" SKIP                
   "        " g-today  " " string(time,"HH:MM") "               AST"
                                                       g-ofc at 70 skip
    fill('-',78) format 'x(78)'  skip.
  
   If vousum1 < 1 then do:
     vousum1 =  vousum1 * -1.  
     vousum2 =  vousum2 * -1.
     vousum  =  vousum  * -1.
     put v-gl4 "  " v-gl4d " "  crc-cod vousum1 "  DR " skip.
     put v-gl  "  " v-gln  " "  crc-cod vousum1 "  CR " skip.
     put v-gl3 "  " v-gl3d " "  crc-cod vousum2 "  DR " skip.   
     put v-gl4 "  " v-gl4d " "  crc-cod vousum2 "  CR " skip.  
   end.
   else do:
     put v-gl  "  " v-gln   " "  crc-cod vousum1 "  DR " skip.
     put v-gl4 "  " v-gl4d " "  crc-cod vousum1 "  CR " skip.
     put v-gl4 "  " v-gl4d " "  crc-cod vousum2 "  DR " skip.   
     put v-gl3 "  " v-gl3d " "  crc-cod vousum2 "  CR " skip.  
   end.
    
   
   put "                         ВСЕГО ДЕБЕТ  "     vousum skip
       "                         ВСЕГО КРЕДИТ "     vousum skip 
    fill('-',78) format 'x(78)' skip  
    "   Переоцена основных средств для " trim(string(i)) + 
        " карт." + v-gr format "x(25)" skip
    " Номера транзакц.: " s-jh1 " ... " s-jh2 skip
    fill('=',78) format 'x(78)' skip(20).
   output close.
   unix silent prit -t vou.img.
end.
ELSE do:
    run x-jlvouR. pause 0.
END.

release ast.
release astatl.
release astjln.

repeat:
    otv=true.
    message "  Печать повторить?  " UPDATE otv /*format "J–/Ne"*/. 
    if otv then unix silent prit -t vou.img.
           else return.
end.

end.


     
     
     
