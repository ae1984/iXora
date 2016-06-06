/* r-astpr.p
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

{global.i}
define variable v-icost as dec format "zzzzzz,zzz,zz9.99-".
define variable v-atl as dec   format "zzzzzz,zzz,zz9.99-".
define variable v-nol as dec   format "zzzzzz,zzz,zz9.99-".
define variable v-fond as dec   format "zzzzzz,zzz,zz9.99-".
define variable v-nach as dec format "zzzzzz9.99-" .
define variable v-ast like ast.ast.
define variable v-gl like ast.gl.
def new shared var v-gl3 like trxlevgl.glr.
def new shared var v-gl4 like trxlevgl.glr.
define variable v-fag like ast.fag.
define variable vib as integer format "9".
def var ic as dec extent 4     format "zzzzzz,zzz,zz9.99-".
def var atl as dec extent 4    format "zzzzzz,zzz,zz9.99-".
def var nol as dec extent    4 format "zzzzzz,zzz,zz9.99-".
def var s as dec extent 4 format "zzz9-".
def var sv as dec extent 4 format "zzzzzz9.99-".
def var a as dec extent 4 format "zzzzzz9.99-".
def var n as dec extent 4      format "zzzzzz,zzz,zz9.99-".
def var s1  as dec extent 4 format "zzz9".
def var nav  as dec extent 4   format "zzzzzz,zzz,zz9.99-".
def var v-fil as char.
def var v-fild as char.
def var vib1 as int init 0.
form
     skip(1)
     " Nr.КАРТОЧКИ         :" v-ast at 26 format "x(8)" ast.name
     " ФИЛИАЛ              :" V-fil format "x(4)" v-fild format "x(20)" skip
     " ГРУППА ОС           :" v-fag at 26 format "x(3)" fagn.naim at 35 skip
     " СЧЕТ   ОС           :" v-gl at 26  gl.des skip
  with row 8 frame amort centered no-labels title "{1}".

 update v-ast validate(can-find(ast where ast.ast=v-ast) or v-ast="",
                       "КАРТОЧКИ НЕТ") with frame amort.
 if v-ast ne "" then do:
   /*   find ast where ast.ast eq v-ast no-lock no-error.
      v-fag = ast.fag. v-gl = ast.gl. 
      find gl where gl.gl eq v-gl no-lock.
      find fagn where fagn.fag eq v-fag no-lock no-error.
      if avail fagn then displ fagn.naim with frame amort.
      display ast.name v-fag  v-gl gl.des with frame amort.
    */
      vib = 1.
 end.
 else do:
   update v-fil validate(can-find (codfr where codfr.codfr ="brnchs" and 
                        codfr.code = v-fil) or v-fil="", 
                          "ПРОВЕРЬТЕ KОД ФИЛИАЛА  ") with frame amort. 
 
   if v-fil ne " " then do:
     find codfr where codfr.codfr= "brnchs" and codfr.code = v-fil 
          use-index cdco_idx no-lock.
     v-fild = codfr.name[1]. 
     display v-fild with frame amort. 
    vib1=1.
   end.

  update v-fag validate(can-find (fagn where fagn.fag = v-fag) or v-fag="", 
                          "ПРОВЕРЬТЕ ГРУППУ") with frame amort. 
  if v-fag ne "" then do:
  /*    find fagn where fagn.fag = v-fag no-lock.   
      v-gl = fagn.gl.
      find gl where gl.gl eq v-gl no-lock.
      display fagn.naim v-gl gl.des with frame amort.
   */
      vib=2.
  end.
  else do:
   update v-gl validate(can-find(gl where gl.gl=v-gl ) or v-gl=0,
                       " ПРОВЕРЬТЕ СЧЕТ" ) with frame amort.
   if v-gl ne 0 then do:
    /* find gl where gl.gl eq v-gl no-lock.
     display gl.des with frame amort. 
     if gl.subled ne "ast" then do:
            message "P–rbaudiet kontu". pause 1. undo,retry.
     end.
    */
    vib=3.
   end. 
   else vib=4.

  end.
 end.



pause 0.
{image1.i rpt.img}
{image2.i}
{report1.i 66}

vtitle= "   AST КАРТОЧКИ " + string(g-today) + ".   " + v-fild. 

{report2.i 132 
"' Nr.карт. Дата рег.Шт.     Баланс.стоим.            Износ         Ост.стоим.     Фонд переоц.|Нал.г.%|  '  skip 
  fill('=',132) format 'x(132)' skip "}
For each ast where (if vib=1 then ast.ast = v-ast 
              else (if vib=2 then ast.fag = v-fag                       
              else (if vib=3 then ast.gl  = v-gl
              else true))),
              each sub-cod where sub-cod.sub = "ast" and
                                 sub-cod.acc = ast.ast and  
                                 sub-cod.d-cod ="brnchs" and
                  (if vib1 =1 then sub-cod.ccode = v-fil else true)             
                                   use-index dcod no-lock
              break  by ast.gl by ast.fag by ast.ast: 

    v-icost = ast.dam[1] - ast.cam[1].
    v-nol =   ast.cam[3] - ast.dam[3].
    v-atl =   v-icost - v-nol.
    v-fond =  ast.cam[4] - ast.dam[4].

    v-nach = ast.amt[3] + ast.salv.

ic[3]=ic[3] + v-icost. ic[2]=ic[2] + v-icost. ic[1]=ic[1] + v-icost.
atl[3]=atl[3] + v-atl.   atl[2]=atl[2] + v-atl.   atl[1]=atl[1] + v-atl.
nol[3]= nol[3] + v-nol.  nol[2]=nol[2] + v-nol.   nol[1]=nol[1] + v-nol.
s[3]=s[3] + ast.qty.     s[2]=s[2] + ast.qty.     s[1]=s[1] + ast.qty. 
sv[3]=sv[3] + v-nach.    sv[2]=sv[2] + v-nach.    sv[1]=sv[1] + v-nach.
a[3]=a[3] + ast.amt[3].  a[2]=a[2] + ast.amt[3].  a[1]=a[1] + ast.amt[3]. 
n[3]=n[3] + ast.ydam[5]. n[2]=n[2] + ast.ydam[5]. n[1]=n[1] + ydam[5].
s1[3]=s1[3] + ast.meth.  s1[2]=s1[2] + ast.meth.  s1[1]=s1[1] + ast.meth.
nav[3]=nav[3] + v-fond. nav[2]=nav[2] + v-fond. nav[1]=nav[1] + v-fond.

/*
if v-atl=0 and  ast.icost ne 0 then 
 put "?  ст.".
else if (v-atl ne 0 and ast.qty=0) or (v-atl=0 and ast.qty ne 0) then 
 put "?  Кл.".
else */ 

if first-of(ast.gl) then do:

 find first trxlevgl where trxlevgl.gl = ast.gl and trxlevgl.lev = 3 no-lock no-error.
 if available trxlevgl then v-gl3 = trxlevgl.glr. else v-gl3=?.   
  /* find gl where gl.gl eq v-gl3 no-lock no-error.
    if available gl then v-gl3d =gl.des. else v-gl3d="".
  */
 find first trxlevgl where trxlevgl.gl = ast.gl and trxlevgl.lev = 4 no-lock no-error.
 if available trxlevgl then v-gl4 = trxlevgl.glr. else v-gl4=?.   
  /*find gl where gl.gl eq v-gl4 no-lock no-error.
    if available gl then v-gl4d =gl.des. else v-gl4d="".
  */

 put "===== " at 23 ast.gl format "zzzzz9" " ====="
     "==== " at 43 v-gl3 format "zzzzz9" " ===="
     "===== " at 77 v-gl4 format "zzzzz9" " ====="
     skip.  
end.


put " " ast.ast format "x(9)"  
    ast.rdt ast.qty format "zz9-" v-icost  v-nol  v-atl v-fond  
  "|"   
  ast.cont format "x(2)" ast.ref format "x(3)" "|" sub-cod.ccode format "x(7)"
  /*ast.addr[1]  format "x(4)"  ast.attn  format "x(4)" */ 
  ast.name format "x(24)" .    

  
  if length(ast.name)> 24 then 
    put skip substring(ast.name,25,10) at 109 format "x(24)". 

/* 
  if ast.ydam[5] ne 0 then
   put skip ast.ydam[5] to 108 format "zzzzzz,zzz,zz9.99-" "  +/- тек.г.изм.".   
*/  

  put skip.

if last-of(ast.fag) and vib > 1 then do:
  put skip(1) "Гр." at 4 ast.fag at 8 s[1] to 22 ic[1]  nol[1] atl[1] 
        nav[1]  to 94  skip  
 fill('-',132) format 'x(132)' skip.
 s[1]=0. ic[1]=0. atl[1]=0. nol[1]=0. sv[1]=0. s1[1]=0. a[1]=0. n[1]=0. nav[1]=0.    
end.

if last-of(ast.gl) and vib>2 then do: 
 put skip(1) ast.gl s[2] to 22 ic[2]  nol[2] atl[2] 
         nav[2] to 94  skip
 fill('=',132) format 'x(132)' skip.
 s[2]=0. ic[2]=0. atl[2]=0. nol[2]=0. sv[2]=0. s1[2]=0. a[2]=0. n[2]=0. nav[2]=0.    
end.

end.

if vib >3 then  
put skip(1) "Всего" at 7 s[3] to 22 ic[3]  nol[3] atl[3] 
        nav[3] to 94   skip 
 fill('=',132) format 'x(132)' skip.
{report3.i}
{image3.i}
		 
		 
