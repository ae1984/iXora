/* ast-jls.p
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

def shared var s-jh like jh.jh.
def shared var s-aah as int.
def shared var s-force as log init false.
def shared var s-consol like jh.consol.
def shared var s-line as int.

def input parameter vln like jl.ln.
def input parameter vgl like jl.gl.
def input parameter vacc like jl.acc.
def input parameter vdam like jl.dam.
def input parameter vcam like jl.cam.
def input parameter v-icost like ast.icost.
def input parameter v-crline like ast.crline.
def input parameter v-ydam5  like ast.crline.
def output parameter otv as log init false.


def shared var v-qty like ast.qty format "zzz,zz9".         
def shared var v-atrx as char.
def shared var v-arem as char extent 5 format "x(55)".
{global.i}


find jh where jh.jh eq s-jh no-lock.

create jl.
jl.jh = jh.jh.
jl.ln = vln.
jl.sts= 0.
jl.crc = 1.
jl.who = jh.who.
jl.jdt = jh.jdt.
jl.whn = jh.whn.
jl.rem[1]=substring(v-arem[1],1,55).
jl.rem[2]=substring(v-arem[2],1,55).
jl.rem[3]=substring(v-arem[3],1,55).
jl.rem[4]=substring(v-arem[4],1,55).
jl.rem[5]=substring(v-arem[5],1,55).
if vdam>0 then do: 
jl.dam = vdam.  
jl.dc = "D".    
end.
else do:
jl.cam = vcam. 
jl.dc = "C".    
end.
jl.gl = vgl.
jl.acc = vacc.
  find gl where gl.gl eq jl.gl.
 {jlupd-r.i}

if gl.subled="ast" then do:

find ast where ast.ast=vacc no-lock.
create astjln.
astjln.ajh = s-jh.
astjln.aln = vln.
astjln.awho = jh.who.
astjln.ajdt = jh.jdt.
astjln.arem[1]=substring(v-arem[1],1,55).
astjln.arem[2]=substring(v-arem[2],1,55).
astjln.arem[3]=substring(v-arem[3],1,55).
astjln.arem[4]=substring(v-arem[4],1,55).
if vdam>0 then do: astjln.aamt = vdam. 
                   astjln.dam= vdam.   
                   astjln.adc = "D".   
               end.
          else do: astjln.aamt = vcam. 
                   astjln.cam= vcam.   
                   astjln.adc = "C".   
          end.
astjln.agl = vgl.
astjln.aqty= v-qty.
astjln.aast = vacc.
astjln.afag = ast.fag.
astjln.atrx= v-atrx.
astjln.ak=ast.cont.
astjln.crline=v-crline.
astjln.prdec[1]=v-ydam5.
astjln.icost=v-icost.
/*astjln.kpriz= " " + string(vop) + " " + string(kor-gl) + " " + kor-acc.
*/
if  v-atrx="91" then
astjln.apriz="A".

find first astatl where astatl.agl=vgl and astatl.ast=vacc and
           astatl.dt=jh.jdt no-error. 
             if not available astatl then create astatl. 
             astatl.ast=ast.ast.
             astatl.agl=ast.gl.
             astatl.fag=ast.fag.
             astatl.dt=jh.jdt.
             astatl.icost=ast.icost.
             astatl.atl=ast.dam[1] - ast.cam[1].
             astatl.nol=ast.icost - astatl.atl.
             astatl.qty=ast.qty.
end.               

otv=true.
