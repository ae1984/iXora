/* amtran.p
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

/* amtran.p
    tranz.formёЅana amort.apr.
*/

{global.i}
def var crc-cod as char format "x(3)".
def var gg-crc as int.
define shared variable oneLs as integer.
define variable vcha1 as character format "x(50)".
define variable vcha2 as character format "x(50)".
define variable vcha3 as character format "x(50)".
define shared variable kor-gl like gl.gl1.
define var am-gl like trxlevgl.glr.
define var v-piez like asttr.atdes.
define new shared variable s-jh like jh.jh.
define var  s-jh1 like jh.jh.
define var  s-jh2 like jh.jh.
define new shared variable s-consol like jh.consol initial false.
define variable vln as integer.
define shared variable v-gl like ast.gl.
define shared variable astfag like ast.fag.
define shared variable ddate as date.
define variable vousum like jl.dam initial 0.
define shared variable v-ast like ast.ast format "x(8)".
define shared variable v-lddn as char format "x(7)".
def var otv as log.
def var i as int init 0.
def var vdel as cha initial "^" .
def var rdes   as cha .
def var rcode   as int .
def var vparam as cha .
def var shcode as cha .
def shared temp-table aast  field ast like ast.ast
                     index ast ast.     


{x-jlvou.f}

find gl where gl.gl eq v-gl no-lock.
 if available gl and gl.gl1>0 then kor-gl = gl.gl1.
   else do: 
    message " Для  " + string(gl.gl) + " нет счета затрат !!!". 
    return. 
   end.

find asttr where asttr.asttr = "9" no-lock.
 if available asttr then v-piez = asttr.atdes.
                    else  v-piez = "Амортизация " . 

m1:
For each aast :

find ast where ast.ast=aast.ast exclusive-lock.
if not avail ast then next.

/***
ast where(if v-ast<>"" then ast.ast=v-ast else ast.ast>"0") and 
            ast.gl = v-gl 
            and ast.dam[1] - ast.cam[1] > ast.dam[3] - ast.cam[3] 
            and ast.noy > 0 break by ast.gl by ast.fag :
 /* амортиз. не начисл. на cp-ва,у которых в данном м-це амор.уже начислена */
   if year (ddate) eq year (ast.ldd) and  month (ast.ldd) eq month (ddate) 
      and ast.ldd ne ? then do:
                  /*  message "Karti‡a " + ast.ast + "amortiz–cija jau tiek aprё±in–ta
                    (pёd.aprё±." + string(ast.ldd) + " tekoЅa aprё±ina nav ieslёgta)".
                     pause 4 .
                   */ 
      next.
   end. 

    /* амортиз. не начисл. на не отработ. 1 месяц средства. */
    if year (ddate) eq year (ast.rdt) then
        if ast.ldd eq ? then
            if month (ast.rdt) eq month (ddate) then next.
***/

    gg-crc=ast.crc. 
   
 /*******jaunas tranzakcijas sakums***************/
 
 
    hide message  no-pause.

 /*   do transaction: */
  
    
   shcode="AST0001".
   vdel="^".
   vparam=string(ast.amt[1]) + vdel +
          string(kor-gl)     + vdel +
          ast.ast            + vdel + 
          v-piez + v-lddn    + vdel +
          string(0).  
   s-jh = 0.
   run trxgen(shcode,vdel,vparam,"","",output rcode,output rdes,
              input-output s-jh).
 /*displ s-jh.*/  

   if rcode > 0  then
   do:
        Message " Error: " + string(rcode) + ":" +  rdes .
        pause .
        undo, next m1 . 
   end.
   else 
   do:

      /*.   run ast-jln(output otv).
         if otv =false then undo,next m1.
      tagad zdes .*/
    i = i + 1. if i=1 then s-jh1=s-jh.

 



        ast.cdt[1] = ast.ldd.
        ast.ldd = ast.updt.
        ast.amt[5] = ast.amt[5] + ast.amt[1].
        ast.ofc=g-ofc.
        ast.updt=g-today.
        vousum = vousum + ast.amt[1].



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
           astjln.arem[1]= v-piez + v-lddn.
           astjln.aamt = ast.amt[1].
           astjln.cam= ast.amt[1].   
           astjln.adc = "C".  
           astjln.c[3]= ast.amt[1].  
           astjln.agl = ast.gl.   
           astjln.aqty = ast.qty.
           astjln.aast = ast.ast.
           astjln.afag = ast.fag.
           astjln.atrx= "9".
           astjln.ak= ast.cont.
           astjln.apriz="A".
           astjln.korgl=kor-gl.
           astjln.koracc="".
           astjln.vop=4. /* gl.gr */


   end. 

end.    /* for */
s-jh2=s-jh.   
otv=true.


IF v-ast ="" then do:

find first trxlevgl where trxlevgl.gl eq v-gl and trxlevgl.lev = 3 no-lock.
 if available trxlevgl and trxlevgl.glr>0 then am-gl = trxlevgl.glr.
 else do: 
  am-gl = 0. 
 end.

find crc where crc.crc=gg-crc no-lock.
if avail crc then crc-cod=crc.code.
/* message " Включите принтер ". pause 20. */

output to vou.img page-size 0.
Put skip(3)
fill('=',78) format 'x(78)'  skip
" " cmp.name skip
"                 Ордер по начислению амортизации                " SKIP                
"        " g-today  " " string(time,"HH:MM") "               AST"
                                                       g-ofc at 70 skip
fill('-',78) format 'x(78)'  skip.

find gl where gl.gl eq kor-gl no-lock.
put kor-gl "  " gl.des " " crc-cod vousum " DR " skip.
find gl where gl.gl eq v-gl no-lock.
put v-gl "  " gl.des " " crc-cod  vousum "  CR " skip
    vcha2 vousum skip
    vcha3 vousum skip
    fill('-',78) format 'x(78)' skip  
    "   Начисление амортизации за "  v-lddn ".  Счет " v-gl skip
    "   Амортизация начислена для " trim(string(i)) + " карт." format "x(15)" skip
    " Номера транзакц.: " s-jh1 " ... " s-jh2 skip
    fill('=',78) format 'x(78)' skip(20).
output close.
unix silent prit -t vou.img.
end.
ELSE do:
/*  find first jl where jl.jh=s-jh no-lock no-error.
  if available jl then do:
    message "Ордера # " + string(s-jh) + " печать".*/

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
