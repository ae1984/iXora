/* r-astfon.p
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

/* last change - 5.11.2001 by sasco: {report1.i pagesize = 0} */
{mainhead.i}

define variable v-ast like ast.ast.
define variable v-gl like ast.gl.
define variable v-fag like ast.fag.
define variable otv as logical format "да/нет".
define var vmc1 like ast.ldd.
define var vmc2 like ast.ldd.
define variable vib as integer format "9".
define variable adam like astjln.dam.
define variable acam like astjln.cam.
define variable vfagn like fagn.naim.
define variable vgln like gl.des.
def var vibk as integer format "z" init 1.
def new shared var v-fil like sub-cod.ccode.
def var v-fild like codfr.name[1].
def var vib1 as integ.
define variable v-gl3 like trxlevgl.glr.
define variable v-am like trxlevgl.glr.
define variable v-gl3d like gl.des.
define variable v-gl1d like gl.des.
define variable v-gl4d like gl.des.
define variable v-gl1  like ast.gl.
define variable v-gl4 like ast.gl.
define new shared var helptmp as char.



 def temp-table   a   field ast like ast.ast 
                      field fag like ast.fag
                      field gl  like ast.gl
                      field d4 like astjln.d[4] format "zzzzzz,zzz,zz9.99-"
                      field c4 like astjln.c[4] format "zzzzzz,zzz,zz9.99-"
                      field gl4 like ast.gl
                      field satl like astatl.atl format "zzzzzz,zzz,zz9.99-"
                      field batl like astatl.atl format "zzzzzz,zzz,zz9.99-"
                      field sdata like astatl.dt
                      field bdata like astatl.dt
                      field pkop like fagn.pkop
                      index ast is primary gl fag ast.
 
{astvib.i " ОБОРОТЫ ПО ФОНДУ ПЕРЕОЦЕНКИ ОСНОВНЫХ СРЕДСТВ "}

pause 0.
if vib=4 then  message " 1- по карточкам  2- по группам 3- по счетам " update vibk.  
if vib=3 then  message " 1- по карточкам  2- по группам 3- по счетам " update vibk.  
if vib=2 then  message " 1- по карточкам  2- по группам " update vibk.  
{image1.i rpt.img}
{image2.i}

For each ast where (if vib=1 then ast.ast = v-ast 
              else (if vib=2 then ast.fag = v-fag                       
              else (if vib=3 then ast.gl  = v-gl
              else true))) no-lock, 
              each sub-cod where sub-cod.sub = "ast" and
                                 sub-cod.acc = ast.ast and  
                                 sub-cod.d-cod ="brnchs" and
                  (if vib1 =1 then sub-cod.ccode = v-fil else true)             
                  use-index dcod no-lock : 
              

   if vmc2<g-today then do:   
     Find last astatl where astatl.ast =ast.ast and astatl.dt < vmc2 + 1
               use-index astdt no-lock no-error.
      if available astatl then do:
       create a.
       a.ast = astatl.ast.
       a.fag = astatl.fag.
       find fagn where fagn.fag=astatl.fag no-lock no-error.
       if avail fagn then a.pkop = fagn.pkop.
       a.gl = astatl.agl.
       find first trxlevgl where trxlevgl.gl eq astatl.agl and trxlevgl.lev = 4 
        no-lock no-error.
       if available trxlevgl  then a.gl4 = trxlevgl.glr.
                                                   
       a.batl = astatl.fatl[4].
      end.
   end.
   else do:  /* vmc2=g-today */
     if ast.dam[1] - ast.cam[1] <>0 then do:
       create a.
       a.ast = ast.ast.
       a.fag = ast.fag.
       find fagn where fagn.fag=ast.fag no-lock no-error.
       if avail fagn then a.pkop = fagn.pkop.
       a.gl = ast.gl.
       find first trxlevgl where trxlevgl.gl eq ast.gl and trxlevgl.lev = 4 no-lock.
       if available trxlevgl and trxlevgl.glr>0 then a.gl4 = trxlevgl.glr.
       a.batl = ast.cam[4] - ast.dam[4].
     end.
   end.

End.   
For each astjln where astjln.ajdt > vmc1 - 1  and  astjln.ajdt < vmc2 + 1  and 
    astjln.atrx ne "0" and
    (if vib=1 then astjln.aast = v-ast 
              else (if vib=2  then astjln.afag = v-fag                       
              else (if vib=3 then astjln.agl = v-gl
              else true))) use-index dtajh, 
              each sub-cod where sub-cod.sub = "ast" and
                                 sub-cod.acc = astjln.aast and  
                                 sub-cod.d-cod ="brnchs" and
                  (if vib1 =1 then sub-cod.ccode = v-fil else true)             
                  use-index dcod no-lock break by astjln.agl 
                  by astjln.afag  by astjln.aast: 
             

 adam= adam + astjln.d[4].
 acam= acam + astjln.c[4].

 if last-of(astjln.aast) then do:
   
   Find first a where a.ast =astjln.aast and a.fag=astjln.afag and
                          a.gl  =astjln.agl no-error.
   if not available a then do:
       create a.
       a.ast = astjln.aast.
       a.fag = astjln.afag.
       find fagn where fagn.fag=astjln.afag no-lock no-error.
       if avail fagn then a.pkop = fagn.pkop.
       a.gl = astjln.agl.
      find first trxlevgl where trxlevgl.gl eq astjln.agl and trxlevgl.lev = 4 no-lock.
      if available trxlevgl and trxlevgl.glr>0 then a.gl4 = trxlevgl.glr.
       a.batl = 0.
   end.   
   a.d4 = adam.
   a.c4 = acam.

 adam=0. acam=0.
 end. 
End.
For each a:
   a.satl = a.batl - a.c4 + a.d4.
   if a.satl=0 and a.batl=0 and a.d4=0 and a.c4=0 then delete a.
End.

find first a where true no-lock no-error.
if not avail a then do: Message "ОТЧЕТ ПУСТОЙ ". pause 10. return. end. 


 /*  Atskaites druka*/
/* comment 5.11.2001 by sasco {report1.i 131} */
{report1.i 131}
find first ofc where ofc.ofc = userid('bank').
if ofc.mday[1] = 1 then do:
output close.
output to value(vimgfname) page-size 0 append.
end.

vtitle= "                   Обороты за период с  " + string (vmc1) + 
          " по " + string (vmc2) + " " + v-fild. 
{report2.i 131 
"'Nr.карточ.     Остаток на начало           Дебет             Кредит  Остаток на конец |      Название              '  skip 
  fill('=',131) format 'x(131)' skip "}

 For each a break by a.pkop by a.gl4 by a.gl by a.fag by a.ast :
  
 accumulate a.satl (total by a.pkop by a.gl4 by a.gl by a.fag by a.ast). 
 accumulate a.d4  (total by a.pkop by a.gl4 by a.gl by a.fag by a.ast).
 accumulate a.c4  (total by a.pkop by a.gl4 by a.gl by a.fag by a.ast).
 accumulate a.batl (total by a.pkop by a.gl4 by a.gl by a.fag by a.ast).
   
if first-of(a.fag) and vibk=1 then
        Put   " Группа " a.fag "(cчет " a.gl ")" skip. 

 if vibk=1 and last-of(a.ast) then do: 
    find ast where ast.ast = a.ast no-lock no-error. 
    
    PUT a.ast 
        a.satl at 14 
        a.d4  
        a.c4 
        a.batl " |".

    if avail ast then PUT " " ast.name  format "x(30)".
    PUT  skip.
 end. 

 if vib > 1 and vibk < 3 and last-of(a.fag) then do:
     find fagn  where fagn.fag = a.fag no-lock no-error. 
      if available fagn then vfagn = fagn.naim. else vfagn = " ".    
    
  if vibk=1 then PUT skip(1) "Всего г.". else Put "Группа".
  Put  a.fag format "x(3)"    
     accum total by a.fag a.satl at 14 format "zzzzzz,zzz,zz9.99-"
     accum total by a.fag a.d4  format "zzzzzz,zzz,zz9.99-"
     accum total by a.fag a.c4  format "zzzzzz,zzz,zz9.99-"
     accum total by a.fag a.batl  format "zzzzzz,zzz,zz9.99-" " |"
     " " vfagn  format "x(28)" skip.

   if vibk=1 then Put fill('-',131) format 'x(131)' skip.
     
 end.
 if vib > 2 and last-of(a.gl) then do:
     find gl  where gl.gl = a.gl no-lock. 
       vgln = gl.des. 
   if vibk=2 then Put fill('-',131) format 'x(131)' skip.     
     PUT 
     "Счет  " a.gl    
     accum total by a.gl a.satl at 14 format "zzzzzz,zzz,zz9.99-" 
     accum total by a.gl a.d4 format "zzzzzz,zzz,zz9.99-"
     accum total by a.gl a.c4 format "zzzzzz,zzz,zz9.99-"
     accum total by a.gl a.batl format "zzzzzz,zzz,zz9.99-" " |"   
     " " vgln  format "x(28)" skip
  fill('=',131) format 'x(131)' skip(1).
   
 end.

 if last-of(a.gl4) then do: 
   find gl  where gl.gl = a.gl4 no-lock. 
   v-gl4d = gl.des. 
   Put  fill('=',131) format 'x(131)' skip.
   Put "ВСЕГО ПО СЧЕТУ " a.gl4
     accum total by a.gl4 a.satl at 14 format "zzzzzz,zzz,zz9.99-" 
     accum total by a.gl4 a.d4 format "zzzzzz,zzz,zz9.99-"
     accum total by a.gl4 a.c4 format "zzzzzz,zzz,zz9.99-"
     accum total by a.gl4 a.batl format "zzzzzz,zzz,zz9.99-" " |"   
     " " v-gl4d format "x(28)"  
   skip.
   Put  fill('=',131) format 'x(131)' skip(1).
 end.
 if last-of(a.pkop) then do: 

/*   Put  fill('=',131) format 'x(131)' skip. */
   Put "ВСЕГО"
     accum total by a.pkop a.satl at 14 format "zzzzzz,zzz,zz9.99-" 
     accum total by a.pkop a.d4 format "zzzzzz,zzz,zz9.99-"
     accum total by a.pkop a.c4 format "zzzzzz,zzz,zz9.99-"
     accum total by a.pkop a.batl format "zzzzzz,zzz,zz9.99-" " |"   
   skip.
   Put  fill('=',131) format 'x(131)' skip(1).

 end.

END.

/* if  vib = 4 then do:
  PUT 
      " Kop–:"  
           accum total a.satl at 14 format "zzzzzz,zzz,zz9.99-"
           accum total a.d4  format "zzzzzz,zzz,zz9.99-"
           accum total a.c4  format "zzzzzz,zzz,zz9.99-"
           accum total a.batl  format "zzzzzz,zzz,zz9.99-" " |".
/*           accum total a.damor format "zzzzz,zz9.99-"
             accum total a.camor format "zzzzz,zz9.99-" "|".
*/
 end.
*/
{report3.i}
{image3.i}


