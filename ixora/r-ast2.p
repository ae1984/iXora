/* r-ast2.p
 * MODULE
        Основные средства
 * DESCRIPTION
        Отчет - операции с ОС за период, включая передвижения ОС
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
        5.11.2001 sasco {report1.i pagesize=0 }
        22/05/03 nataly была добавлена сортировка по департаментам
        27.06.06 sasco   - Переделал поиск в hist (по ындэксу opdate) а также вывод истории по индексу op
*/

{mainhead.i}
 	
define variable v-gl like ast.gl.
define variable v-fag like ast.fag.
define variable otv as logical.
define var vmc1 like ast.ldd.
define var vmc2 like ast.ldd.
define variable vib as integer format "9".
define variable adam1 as dec format "zzzzzz,zzz,zz9.99-".
define variable acam1 as dec format "zzzzzz,zzz,zz9.99-".
define variable bdam1 as dec format "zzzzzz,zzz,zz9.99-".
define variable bcam1 as dec format "zzzzzz,zzz,zz9.99-".
define variabl  adam3 as dec format "zzzzzz,zzz,zz9.99-".
define variable acam3 as dec format "zzzzzz,zzz,zz9.99-".
define variable bdam3 as dec format "zzzzzz,zzz,zz9.99-".
define variable bcam3 as dec format "zzzzzz,zzz,zz9.99-".
define variable vt as char.
def var v-asttr as char.
def new shared var v-fil like sub-cod.ccode.
define new shared var helptmp as char.
def var vib1 as integ.
define variable v-gl3 like trxlevgl.glr.
define variable v-am like trxlevgl.glr.
define variable v-gl3d like gl.des.
define variable v-gl1d like gl.des.
define variable v-gl1  like ast.gl.
def var v-fild like codfr.name[1].
def var v-x as logic.

def var v-attn as char format "x(3)".
def var v-dep as char format "x(3)".
def var v-ast as char format "x(15)".

/*{astvib.i " Операции с основными средствами"}*/
form
     skip(1)
     "          С    : "  vmc1 at 20  validate(vmc1 ne ? and vmc1>=01/01/96 and vmc1<=g-today, "")  
     " ПО  : "  vmc2 at 40 validate(vmc2 ne ? and vmc2<=g-today ," Неверно задана 2-я дата") skip
     " ПОДРАЗДЕЛЕНИЕ : " v-attn at 20 format "x(3)"
  with row 10 frame am centered no-label title 'ЗАДАЙТЕ ОТЧЕТНЫЙ ПЕРИОД И ПОДРАЗДЕЛЕНИЕ ' .

 update vmc1 
        vmc2 
/*        v-asttr validate(can-find(asttr where asttr.asttr=v-asttr) or v-asttr="",
                       "проверьте код опер. ") */
        v-attn validate(can-find(codfr where codfr = "sproftcn" and codfr.code = v-attn) ,
                       "неверно задан департамент ")  with frame am.

 if  vmc2 < vmc1 
   then do: 
      message '2-я дата меньше первой!!!' skip 
     'Невозможно сформировать  отчет!!!' view-as alert-box .
      return.
    end.

/* if v-asttr ne "" then do:
       find asttr where asttr.asttr=v-asttr no-lock no-error.
       if avail asttr then displ asttr.atdes with frame am.
 end.
  */

pause 0.

{image1.i rpt.img}
{image2.i}

/*comment 5.11.2001 by sasco: {report1.i 66} */
{report1.i 66}
find first ofc where ofc.ofc = userid('bank').
if ofc.mday[1] = 1 then
do:
output close.
output to value(vimgfname) page-size 0 append.
end.


vtitle= "      Операции с основными средствами за период с  " + string (vmc1) + 
          " по " + string (vmc2) + vt + " " + ". Подразделение " + v-attn. 

{report2.i 136 
"' Дата   Оп. Деп. Nr.карточки   Инв.Nr.               Дебет           Кредит    Шт. Nr.опер. Исполн.  Операция  '  skip 
  fill('=',136) format 'x(136)' skip "}

For each astjln where astjln.ajdt ge vmc1 and  astjln.ajdt le vmc2 and 
                ( astjln.atrx begins '1' or astjln.atrx begins '6' )    
                use-index astdt no-lock, 
               each sub-cod where sub-cod.sub = "ast" and
                                 sub-cod.acc = astjln.aast and  
                                 sub-cod.d-cod ="brnchs" 

                  use-index dcod no-lock break  
                  by substring(astjln.atrx,1,1) by astjln.agl by astjln.atrx
                  by astjln.ajh by astjln.aast:   




if astjln.agl=0 then next.

 /* ------------- 22/05/03  nataly --------------- */
  find last hist where hist.pkey = "AST" and hist.skey = astjln.aast and 
                       hist.date <= astjln.ajdt no-lock use-index opdate no-error.
  if not avail hist then do:
     if vmc1 < g-today then do:
        find first hist where hist.pkey = "AST" and hist.skey = astjln.aast and
                              hist.date >= astjln.ajdt no-lock use-index opdate no-error.
     end.
  end.
  if not avail hist then find first ast where ast.ast = astjln.aast no-lock  no-error.

   if avail hist then  do: 
    if hist.date <= astjln.ajdt then  v-dep = hist.chval[1].
     else hist.chval[2].
  end.
  else  v-dep = ast.attn . 

   /*message astjln.ajdt astjln.aast v-dep  astjln.d[1] astjln.c[1]  v-attn.*/
                                          
  if v-dep <> v-attn then next.
 /* --------------   22/05/03  nataly  ---------------*/

    accumulate astjln.d[1] (total by astjln.agl ) . 
    accumulate astjln.c[1] (total by astjln.agl ).
    accumulate astjln.d[3] (total by astjln.agl ) . 
    accumulate astjln.c[3] (total by astjln.agl ).

    adam1=adam1 + astjln.d[1].
    acam1=acam1 + astjln.c[1].
    bdam1=bdam1 + astjln.d[1].
    bcam1=bcam1 + astjln.c[1].
    adam3=adam3 + astjln.d[3].
    acam3=acam3 + astjln.c[3].
    bdam3=bdam3 + astjln.d[3].
    bcam3=bcam3 + astjln.c[3].

if first-of(substring(astjln.atrx,1,1)) then do: 
       Put substring(astjln.atrx,1,1) format "x" ".  ".
       find asttr where asttr.asttr=substring(astjln.atrx,1,1) no-lock no-error.
       if avail asttr then Put  asttr.atdes. 
       Put skip "----------------------------------------" skip.
end.

/*      find asttr where asttr.asttr=v-asttr no-lock no-error.
       if avail asttr then displ asttr.atdes with frame am.
  */

If first-of(astjln.agl) then do:
    find gl where gl.gl=astjln.agl no-lock no-error.
     Put "  " astjln.agl gl.des skip
         "=======================================" skip.
end.

/* if substring(v-asttr,1,1)="9" or vib = 1 or
    (substring(astjln.atrx,1,1) ne "9" and vib ne 1) then do:
  */
  /* sasco */
/*  find last hist where hist.pkey = "AST" and hist.skey = astjln.aast and 
                       hist.date <= astjln.ajdt no-lock use-index opdate no-error.
  if not avail hist then do:
     if vmc1 < g-today then do:
        find first hist where hist.pkey = "AST" and hist.skey = astjln.aast and
                              hist.date >= astjln.ajdt no-lock use-index opdate no-error.
     end.
  end.
  if not avail hist then find first ast where ast.ast = astjln.aast no-lock no-error.
  */
/*инвентарный номер*/
    find ast where ast.ast = astjln.aast no-lock no-error.
    if avail ast then v-ast = ast.addr[2]. else v-ast = "".

  Put skip(1)  astjln.ajdt " " astjln.atrx " " 
/*      if avail hist then (if hist.date <= astjln.ajdt then hist.chval[1] else hist.chval[2]) else ast.attn form "x(3)" "  " */
      v-dep form "x(3)" " " 
      astjln.aast format "x(10)" "   "
      v-ast format "x(15)"
      astjln.d[1] format "zzzzzz,zzz,zz9.99-"
      astjln.c[1] format "zzzzzz,zzz,zz9.99-"
      astjln.aqty format "zz9" " "
      astjln.ajh " " astjln.awho " "
      astjln.arem[1]
      skip. 
   v-x= false.
  if astjln.d[3] ne 0 or astjln.c[3] ne 0 then do: 
    put astjln.d[3] to 40 format "zzzzzz,zzz,zz9.99-"
      astjln.c[3]  format "zzzzzz,zzz,zz9.99-". 
      v-x = true.
  end.
  if astjln.arem[2] ne " " then do: 
    Put astjln.arem[2] at 81.
    v-x = true.
  end. 
    if v-x = true then put skip.
  if astjln.stdt ne ? then Put "сторнир. " at 55 astjln.stdt " " astjln.stjh skip.

/* end.*/

 if last-of(astjln.atrx) then Put skip(1).
 if last-of(astjln.agl) then do:
       find asttr where asttr.asttr=substring(astjln.atrx,1,1) no-lock no-error.
    if avail asttr then Put  asttr.atdes "-"skip. 
    Put astjln.agl  " Обороты   :" to 20  adam1 to 40 acam1  skip.
      if adam3 ne 0 or acam3 ne 0 then  
       put adam3 to 40 format "zzzzzz,zzz,zz9.99-"
           acam3  format "zzzzzz,zzz,zz9.99-" skip. 
  
    adam1=0. acam1=0. adam3=0. acam3=0. 
   otv=true.
 end. 
 if last-of(substring(astjln.atrx,1,1)) then do: 
       find asttr where asttr.asttr=substring(astjln.atrx,1,1) no-lock no-error.
       if avail asttr then Put  asttr.atdes "-"skip. 
    Put  " обороты всего   :" to 20   bdam1 to 40 bcam1 skip.
         if bdam3 ne 0 or bcam3 ne 0 then  
          put bdam3 to 40 format "zzzzzz,zzz,zz9.99-"
              bcam3  format "zzzzzz,zzz,zz9.99-" skip. 
  
    Put fill('-',136) format 'x(136)' skip(1).
     bdam1=0. bcam1=0. bdam3=0. bcam3=0. 

 end.
 
End.  /* for each astjln */
/*  if v-asttr="" then */

    Put " ОБОРОТЫ ВСЕГО    : " to 20 
    accum total astjln.d[1] to 40 format "zzzzzz,zzz,zz9.99-"
    accum total astjln.c[1]  format "zzzzzz,zzz,zz9.99-"
    skip
    accum total astjln.d[3] to 40 format "zzzzzz,zzz,zz9.99-"
    accum total astjln.c[3]  format "zzzzzz,zzz,zz9.99-"
                skip.

put skip "Передвижение по департаментам" skip. 
put fill("=",110) format "x(110)" skip.
put "|Дата     |Nr. Карточка |Инв.Nr.          |Наименование                  |Откуда ...       |Куда ... " skip.
put fill("=",110) format "x(110)" skip.

for each hist where hist.pkey = "AST" and hist.op = "MOVEDEP"
  and (hist.chval[1] =  v-attn  or hist.chval[2] = v-attn) and 
  date >= vmc1 and date <= vmc2 no-lock use-index op:
   /* if date < vmc1 or  date > vmc2 then next. */
   find ast where ast.ast = hist.skey  no-lock no-error.
   put  skip 
    date  "   "  
    skey  to 24  format "x(8)" 
    ast.addr[2] to 40 format "x(8)"  
    ast.name  to 75   format "x(20)"  
    hist.chval[2]  to 85 format "x(8)" 
    hist.chval[1]  to 105 format "x(8)"  . 
end.

  /* if not otv  then do: Message "Отчет пуст". pause 10. return. end. 
    */
{report3.i}
hide all no-pause . 
run menu-prt('rpt.img').

/*{image3.i}*/


