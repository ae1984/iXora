/* r-ast410.p
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

/* 
21.11.02
KOVAL  
Убрал из отчета ремонт т.е для astjln добавил условие
- substr(astjln.atrx,1,1) ne "r"  and  
*/
/* last change : 5.11.2001 by sasco -> {report1 pagesize=0} */
{mainhead.i}

def new shared var v-fil like sub-cod.ccode.
def var v-fild like codfr.name[1].
def var helptmp as char.
def var vib1 as int.
/*
define variable v-gl3 like trxlevgl.glr.
define variable v-gl3d like gl.des.
define variable v-gl1d like gl.des.
define variable v-gl1  like ast.gl.
*/
define variable v-ast like ast.ast.
define variable v-gl like ast.gl.
define variable v-fag like ast.fag.
define variable otv as logical format "да/нет".
define var vmc1 like ast.ldd format "99/99/9999".
define var vmc2 like ast.ldd format "99/99/9999".
define variable vib as integer format "9".
define variable am8 like astjln.dam.
define variable am10 like astjln.cam.
define variable s31 like astjln.cam.
define variable s33 like astjln.cam.
define variable s38 like astjln.cam.
define variable s425 like astjln.cam.
define variable s54 like astjln.cam.
define variable s56 like astjln.cam.
define variable s57 like astjln.cam.
define variable am9 like astjln.cam.
define variable vfagn like fagn.naim.
define variable vgln like gl.des.
def var vop as log format "да/нет" init "да".
def var vibk as integer format "z" init 3.
 def temp-table    a  field ast like ast.ast
                      field fag like ast.fag
                      field gl  like ast.gl
                      field dat as date
                      field ss like astatl.atl format "zzz,zzz,zz9.99-" init 0
                      field s33 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field s31 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field s38 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field s425 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field s57 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field s56 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field s54 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field sb like astatl.atl format "zzz,zzz,zz9.99-" init 0
                      field ns like astatl.atl format "zzz,zzz,zz9.99-" init 0
                      field nb like astatl.atl format "zzz,zzz,zz9.99-" init 0
                      field ass like astatl.atl format "zzz,zzz,zz9.99-" 
                      field ab like astatl.atl format "zzz,zzz,zz9.99-" init 0
                      field am8 like astatl.atl format "zzz,zzz,zz9.99-" init 0
                      field am10 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field am9 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field am9p like astatl.atl format "zzz,zzz,zz9.99-" 
                      field rem as char 
                      field pkop like fagn.pkop
                      index ast is primary gl fag ast.
                      

{astvib.i " ОТЧЕТ О ДВИЖЕНИИ ОСНОВНЫХ СРЕДСТВ "}

pause 0.
/*
   message " С ОПЕРАЦИЯМИ? "
           view-as alert-box question buttons yes-no title "" update vop.
*/
update " С ОПЕРАЦИЯМИ? (да/нет) " vop with frame a no-label centered. 

pause 0.

/* выдаем только по карточкам
if vib=4 then  message " 1- по карточкам  2- по группам 3- по счетам " update vibk.  
if vib=3 then  message " 1- по карточкам  2- по группам 3- по счетам " update vibk.  
if vib=2 then  message " 1- по карточкам  2- по группам " update vibk.  

message vibk view-as alert-box buttons ok.
*/

vibk = 1.

{image1.i rpt.img}
{image2.i}

For each ast where (if vib=1 then ast.ast = v-ast 
              else (if vib=2 then ast.fag = v-fag                       
              else (if vib=3 then ast.gl  = v-gl
              else true))) no-lock ,
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
       a.ab = astatl.atl.
       a.sb = astatl.icost.
       a.nb = astatl.nol.
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
       a.sb = ast.dam[1] - ast.cam[1].
       a.nb = ast.cam[3] - ast.dam[3].
       a.ab = a.sb - a.nb.
     end. 
   end.

  Find last astatl where astatl.ast =ast.ast  and astatl.dt < vmc1
                use-index astdt no-lock no-error.
  if available astatl then do:
      find first a where a.ast = astatl.ast and a.fag= astatl.fag
                          and a.gl= astatl.agl use-index ast no-error.
      if not available a then do: 
        create a.
        a.ast = astatl.ast.
        a.fag = astatl.fag.
        a.gl = astatl.agl.
        find fagn where fagn.fag=ast.fag no-lock no-error.
        if avail fagn then a.pkop = fagn.pkop.
       end.
      a.ass = astatl.atl.
      a.ss = astatl.icost.
      a.ns = astatl.nol.
  end.

End.   

For each astjln where astjln.ajdt > vmc1 - 1 and  astjln.ajdt < vmc2 + 1 and 
       substr(astjln.atrx,1,1) ne "r"  and  
      (if vib=1 then astjln.aast = v-ast 
              else (if vib=2  then astjln.afag = v-fag                       
              else (if vib=3 then astjln.agl = v-gl
              else true))) use-index astdt no-lock
    break by astjln.agl by astjln.afag  by astjln.aast:   

  if astjln.atrx eq "0" then next.
  

 if /*substring(astjln.apriz,1,1)="A" and*/ substring(astjln.atrx,1,1)="9" then
      am8=am8 + astjln.c[3] - astjln.d[3].
 else do:
  create a.
   a.dat=astjln.ajdt.
   a.ast = astjln.aast.
   a.fag = astjln.afag.
   find fagn where fagn.fag=astjln.afag no-lock no-error.
   if avail fagn then a.pkop = fagn.pkop.
   a.gl = astjln.agl.
   a.rem=astjln.arem[1].
  if substring(astjln.atrx,1,1)="1" then do:
    
      a.s31=astjln.d[1] - astjln.c[1].
      a.am9=astjln.c[3] - astjln.d[3].
    
    /*  if astjln.adc="D" then do: a.s31 = astjln.icost.
                                   a.am9 = astjln.icost - astjln.dam. 
                              end.                                      
                          else do: a.s31 = astjln.icost * (-1).
                                   a.am9 = (astjln.icost - astjln.cam) * (-1). 
                                        end.
    */
  end.
  else
  if substring(astjln.atrx,1,1)="3" then do:
      a.s57 =astjln.d[1] - astjln.c[1].
      a.am9 =astjln.c[3] - astjln.d[3].
  /*
        if astjln.adc="D" then do: a.s33 = astjln.icost.
                                   a.am9p = astjln.icost - astjln.dam. 
                              end.                                      
                          else do: a.s33 = astjln.icost * (-1).
                                   a.am9p=(astjln.icost - astjln.cam) * (-1). 
                              end.     
  */
  end.
  else
  if substring(astjln.atrx,1,1)="8" then do:
      a.s57=astjln.d[1] - astjln.c[1].
      a.am9=astjln.c[3] - astjln.d[3].
 
   /*
         if astjln.adc="D" then do: a.s38 = astjln.icost.
                                    a.am9 = astjln.icost - astjln.dam. 
                               end.                                      
                           else do: a.s38 = astjln.icost * (-1).
                                    a.am9 =(astjln.icost - astjln.cam) * (-1). 
                               end.     
    */
 end.
 else
 if substring(astjln.atrx,1,1)="2" or
    substring(astjln.atrx,1,1)="5" 
                    then do:
      a.s57=astjln.d[1] - astjln.c[1].
      a.am9=astjln.c[3] - astjln.d[3].

   /*                  if astjln.adc="D" then do: a.s425 = astjln.icost.
                                         end.      
                                         else do: a.s425 = astjln.icost * (-1).
                                         end.
   */
 end.
  if substring(astjln.atrx,1,1)="p" then do:
      a.s38  =astjln.d[1] - astjln.c[1].
      a.am9p =astjln.c[3] - astjln.d[3].
 end.
 else
  if substring(astjln.atrx,1,1)="4" then do:
      a.s57 =astjln.d[1] - astjln.c[1].
      a.am9 =astjln.c[3] - astjln.d[3].
       /*
         if astjln.adc="D" then do: a.s54 = astjln.icost * (-1).
                                    a.am9p = astjln.icost - astjln.dam. 
                                end.                                      
                           else do: a.s54 = astjln.icost .
                                    a.am9p = (astjln.icost - astjln.cam) * (-1) . 
                                end.     
        */
  end.
  else
  if substring(astjln.atrx,1,1)="6" then do:
      a.s56  =astjln.c[1] - astjln.d[1].
      a.am10 =astjln.d[3] - astjln.c[3].
    /*
          if astjln.adc="D" then do: a.s56 = astjln.icost * (-1).
                                     a.am10=(astjln.icost -  astjln.dam) * (-1). 
                                end.                                      
                            else do: a.s56 = astjln.icost .
                                     a.am10 = astjln.icost - astjln.cam. 
                                end.     
     if substring(astjln.apriz,1,1)="A"  then do:
             am8=am8 + astjln.cam - astjln.dam.
             a.am10=a.am10 + (astjln.cam - astjln.dam).
     end.
     */
 end.
 else
  if substring(astjln.atrx,1,1)="7" then do:
      a.s57 =astjln.d[1] - astjln.c[1].
      a.am9 =astjln.c[3] - astjln.d[3].
  /*
          if astjln.adc="D" then do: a.s57 = astjln.icost.
                                     a.am9 = astjln.icost - astjln.dam. 
                                end.                                      
                            else do: a.s57 = astjln.icost * (-1) .
                                     a.am9 =(astjln.icost - astjln.cam) * (-1). 
                                end.     
  */
 end.
                             
 end.

 if last-of(astjln.aast) then do:
   
   Find first a where a.ast =astjln.aast and a.fag=astjln.afag and
                      a.gl  =astjln.agl and a.dat=? use-index ast
                      no-error .
   if not available a then do:
       create a.
       a.ast = astjln.aast.
       a.fag = astjln.afag.
       find fagn where fagn.fag=astjln.afag no-lock no-error.
       if avail fagn then a.pkop = fagn.pkop.
       a.gl = astjln.agl.
       a.ab = 0.
       a.sb = 0.
       a.nb = 0.
   end.   
   a.am8 =am8.
   am8=0. 
 end. 
End.
/*
for each a:
     displ a.dat a.sb a.ast a.s31 a.s425 a.s56 a.s57 a.pkop. pause 100.
end.  
*/

for each a where a.dat = ?:
   if a.ss=0 and a.ns=0 and a.ass=0 and a.s31=0 and a.s56=0 and a.s33=0 and
      a.s57=0 and a.s54=0 and a.s38=0 and a.s425=0 and a.am9=0 and a.am10=0 and
      a.am8=0 and a.sb=0 and a.nb=0 and a.ab=0 then delete a.
End.

find first a where true no-lock no-error.
if not avail a then do: Message "ОТЧЕТ ПУСТОЙ ". pause 10. return. end. 

def var vmc1-s as char format "x(10)".
def var vmc2-s as char format "x(10)".
vmc1-s=string(vmc1,"99/99/9999").
vmc2-s=string(vmc2,"99/99/9999").

/* comment 5.11.2001 by sasco, {report1.i 66} */
{report1.i 66}
find first ofc where ofc.ofc = userid('bank').
if ofc.mday[1] = 1 then do:
 output close.
 output to value(vimgfname) page-size 0 append.
end.
                       
  
vtitle= "    ОТЧЕТ О ДВИЖЕНИИ ОСНОВНЫХ СРЕДСТВ  за период с " + vmc1-s + 
          " по " + vmc2-s. 
{report2.i 250
"'Nr.карт. ---------------------------------------------------- Балансовая  стоимость ------------------------------|------------------------  Амортизация  -----------------------------------------|------- Остаточная стоимость -----------------' skip     
 'группа      дата      '   vmc1   '        Приход      Переоценка   Корректировка         Выбытие      '   vmc2   '|    '  vmc1-s  '    Начисленная   Корректировка         Выбытие     '  vmc2-s  '|    ' string(vmc1,'99/99/9999') format 'x(10)' '    ' string(vmc2,'99/99/9999') format 'x(10)' skip 
 'счет     регистрации                       (1)          (p) +/-         +/-               (6) -                   |                        +              +/-                -                     |  ' skip
 '------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------|----------------------------------------------' skip
"}
 /* fill('=',145) format 'x(145)' skip "} */

 For each a break by a.pkop by a.gl by a.fag by a.ast :
  
 accumulate a.ss   (total by a.pkop by a.gl by a.fag by a.ast). 
 accumulate a.sb   (total by a.pkop by a.gl by a.fag by a.ast).
 accumulate a.ns   (total by a.pkop by a.gl by a.fag by a.ast).
 accumulate a.nb   (total by a.pkop by a.gl by a.fag by a.ast).
 accumulate a.ass   (total by a.pkop by a.gl by a.fag by a.ast).
 accumulate a.ab   (total by a.pkop by a.gl by a.fag by a.ast).
 accumulate a.am8   (total by a.pkop by a.gl by a.fag by a.ast).
 accumulate a.am9   (total by a.pkop by a.gl by a.fag by a.ast).
 accumulate a.am9p   (total by a.pkop by a.gl by a.fag by a.ast).
 accumulate a.am10   (total by a.pkop by a.gl by a.fag by a.ast).
 accumulate a.s31   (total by a.pkop by a.gl by a.fag by a.ast).
 accumulate a.s33   (total by a.pkop by a.gl by a.fag by a.ast).
 accumulate a.s38   (total by a.pkop by a.gl by a.fag by a.ast).
 accumulate a.s425   (total by a.pkop by a.gl by a.fag by a.ast).
 accumulate a.s54   (total by a.pkop by a.gl by a.fag by a.ast).
 accumulate a.s56   (total by a.pkop by a.gl by a.fag by a.ast).
 accumulate a.s57   (total by a.pkop by a.gl by a.fag by a.ast).
 
 

 if vop=true and a.dat ne ? then do:
    PUT  " " a.ast format "x(8)" " " a.dat. 
    if a.s31 ne 0 then Put a.s31 format "zzzzzzzzzzz9.99-" to 41.
    if a.s38 ne 0 then Put a.s38 format "zzzzzzzzzzz9.99-" to 57.
    if a.s57 ne 0 then  Put a.s57 format "zzzzzzzzzzz9.99-" to 73.
    if a.s56 ne 0 then Put  a.s56 format "zzzzzzzzzzz9.99-" to 89.
  /*
    if a.s33 ne 0 then Put a.s33 format "zzzzzzzz9.99-" to 34.
    if a.s425 ne 0 then Put a.s425 format "zzzzzzzz9.99-" to 73.
    if a.s54 ne 0 then Put  a.s54 format "zzzzzzzz9.99-" to 112. 
  */
    Put "|" to 106.
    if a.am9 ne 0 then Put a.am9 + a.am9p format "zzzzzzzzzzz9.99-"  to 154.
    if a.am9p ne 0 then Put a.am9p + a.am9 format "zzzzzzzzzzz9.99-"  to 154.
    if a.am10 ne 0 then Put  a.am10  format "zzzzzzzzzzz9.99-" to 170.
    Put "|" to 187 a.rem format "x(45)" skip.
 
 end.


/*if first-of(a.fag) and vibk=1 then
        Put " Konts " a.gl  " grupa " a.fag skip. 
*/
 if vibk=1 and last-of(a.ast) then do: 
    
    PUT a.ast format "x(8)" " ".  
    find ast where ast.ast = a.ast no-lock no-error. 
    if avail ast then PUT " " ast.rdt. else PUT space(9).
    PUT accum total by a.ast a.ss  format "zzzzzzzzzzz9.99-"

/*   accum total by a.ast a.s33 format "zzzzzzzz9.99-" */

     accum total by a.ast a.s31 format "zzzzzzzzzzz9.99-"
     accum total by a.ast a.s38 format "zzzzzzzzzzz9.99-"
/*   accum total by a.ast a.s425 format "zzzzzzzz9.99-" */
     accum total by a.ast a.s57 format "zzzzzzzzzzz9.99-" 
     accum total by a.ast a.s56 format "zzzzzzzzzzz9.99-" 
  
/*   accum total by a.ast a.s54 format "zzzzzzzz9.99-" */

     accum total by a.ast a.sb  format "zzzzzzzzzzz9.99-" "|"
     accum total by a.ast a.ns  format "zzzzzzzzzzz9.99-"
     accum total by a.ast a.am8 format "zzzzzzzzzzz9.99-" 
     accum total by a.ast a.am9 format "zzzzzzzzzzz9.99-" 
     accum total by a.ast a.am10 format "zzzzzzzzzzz9.99-"
     accum total by a.ast a.nb  format "zzzzzzzzzzz9.99-" "|"
     accum total by a.ast a.ass format "zzzzzzzzzzz9.99-"
     accum total by a.ast a.ab  format "zzzzzzzzzzz9.99-".

    if avail ast then PUT ast.name format "x(14)".
    PUT  skip.
   if (accum total by a.ast a.am9p) <> 0 then 
   Put  accum total by a.ast a.am9p format "zzzzzzzzzzz9.99-" to 154 "(переоц.)" skip. 

        if (accum total by a.ast a.ss) + (accum total by a.ast a.s33) +
           (accum total by a.ast a.s31) + (accum total by a.ast a.s38) +
           (accum total by a.ast a.s425) + (accum total by a.ast a.s57) -
           (accum total by a.ast a.s56) -  (accum total by a.ast a.s54) ne 
           (accum total by a.ast a.sb) then
          Put "!!!!! P–rbaudiet s–k.vёrt." skip. 
        if (accum total by a.ast a.ns) + (accum total by a.ast a.am8) +
           (accum total by a.ast a.am9) + (accum total by a.ast a.am9p) -
           (accum total by a.ast a.am10) ne (accum total by a.ast a.nb) then
          Put "!!!!! P–rbaudiet nolietojumu." skip. 
      
 end. 

 if vib > 1 and vibk < 3 and last-of(a.fag) then do:
     find fagn  where fagn.fag = a.fag no-lock no-error. 
      if available fagn then vfagn = fagn.naim. else vfagn = " ".    
    
  if vibk=1 then PUT skip(1) "Гр.  ". else Put "Гр.  ".
  Put  a.fag format "x(3)" " "   
     accum total by a.fag a.ss  format "zzzzzzzzzzz9.99-"
     accum total by a.fag a.s31 format "zzzzzzzzzzz9.99-"
     accum total by a.fag a.s38 format "zzzzzzzzzzz9.99-"
     accum total by a.fag a.s57 format "zzzzzzzzzzz9.99-" 
     accum total by a.fag a.s56 format "zzzzzzzzzzz9.99-" 
/*
     accum total by a.fag a.s33 format "zzzzzzzz9.99-"
     accum total by a.fag a.s425 format "zzzzzzzz9.99-"
     accum total by a.fag a.s54 format "zzzzzzzz9.99-" 
*/
     accum total by a.fag a.sb  format "zzzzzzzzzzz9.99-" "|"
     accum total by a.fag a.ns  format "zzzzzzzzzzz9.99-"
     accum total by a.fag a.am8 format "zzzzzzzzzzz9.99-" 
     accum total by a.fag a.am9 format "zzzzzzzzzzz9.99-" 
     accum total by a.fag a.am10  format "zzzzzzzzzzz9.99-"
     accum total by a.fag a.nb format "zzzzzzzzzzz9.99-"  "|"
     accum total by a.fag a.ass  format "zzzzzzzzzzz9.99-"
     accum total by a.fag a.ab  format "zzzzzzzzzzz9.99-"
     vfagn format "x(17)" skip.
   if (accum total by a.fag a.am9p) <>0 then 
   Put  accum total by a.fag a.am9p format "zzzzzzzzzzz9.99-" to 154 "(переоц.)" skip. 

        if (accum total by a.fag a.ss) + (accum total by a.fag a.s33) +
           (accum total by a.fag a.s31) + (accum total by a.fag a.s38) +
           (accum total by a.fag a.s425) + (accum total by a.fag a.s57) -
           (accum total by a.fag a.s56) -  (accum total by a.fag a.s54) ne 
           (accum total by a.fag a.sb) then
          Put "!!!!! P–rbaudiet s–k.vёrt." skip. 
        if (accum total by a.fag a.ns) + (accum total by a.fag a.am8) +
           (accum total by a.fag a.am9) + (accum total by a.fag a.am9p) -
           (accum total by a.fag a.am10) ne (accum total by a.fag a.nb) then
          Put "!!!!! P–rbaudiet nolietojumu." skip. 

   if vibk=1 then Put fill('-',233) format 'x(233)' skip.
     
 end.
 if vib > 2 and last-of(a.gl) then do:
     find gl  where gl.gl = a.gl no-lock. 
       vgln = gl.des. 
   if vibk=2 then Put fill('-',233) format 'x(233)' skip.     
   if vibk=3 then Put skip(1).
     PUT "  " a.gl format "zzzzz9" " "  
     accum total by a.gl a.ss  format "zzzzzzzzzzz9.99-"
     accum total by a.gl a.s31 format "zzzzzzzzzzz9.99-"
     accum total by a.gl a.s38 format "zzzzzzzzzzz9.99-"
     accum total by a.gl a.s57 format "zzzzzzzzzzz9.99-" 
     accum total by a.gl a.s56 format "zzzzzzzzzzz9.99-" 
/*
     accum total by a.gl a.s33 format "zzzzzzzz9.99-"
     accum total by a.gl a.s425 format "zzzzzzzz9.99-"
     accum total by a.gl a.s54 format "zzzzzzzz9.99-" 
*/
     accum total by a.gl a.sb  format "zzzzzzzzzzz9.99-" "|"
     accum total by a.gl a.ns  format "zzzzzzzzzzz9.99-"
     accum total by a.gl a.am8 format "zzzzzzzzzzz9.99-" 
     accum total by a.gl a.am9 format "zzzzzzzzzzz9.99-" 
     accum total by a.gl a.am10  format "zzzzzzzzzzz9.99-"
     accum total by a.gl a.nb format "zzzzzzzzzzz9.99-"  "|"
     accum total by a.gl a.ass  format "zzzzzzzzzzz9.99-"
     accum total by a.gl a.ab  format "zzzzzzzzzzz9.99-".
    Put trim(vgln)  format "x(17)" skip.
   if (accum total by a.gl a.am9p) <>0 then 
   Put  accum total by a.gl a.am9p format "zzzzzzzzzzz9.99-" to 154 "(переоц.)" skip. 

        if (accum total by a.gl a.ss) + (accum total by a.gl a.s33) +
           (accum total by a.gl a.s31) + (accum total by a.gl a.s38) +
           (accum total by a.gl a.s425) + (accum total by a.gl a.s57) -
           (accum total by a.gl a.s56) -  (accum total by a.gl a.s54) ne 
           (accum total by a.gl a.sb) then
          Put "!!!!! P–rbaudiet s–k.vёrt." skip. 
        if (accum total by a.gl a.ns) + (accum total by a.gl a.am8) +
           (accum total by a.gl a.am9) + (accum total by a.gl a.am9p) -
           (accum total by a.gl a.am10) ne (accum total by a.gl a.nb) then
          Put "!!!!! P–rbaudiet nolietojumu." skip. 

  Put fill('-',233) format 'x(233)' skip(1).

 end.

 if last-of(a.pkop) then do: 
   Put  fill('=',233) format 'x(233)' skip.
   Put "  ВСЕГО: " 
     accum total by a.pkop a.ss  format "zzzzzzzzzzz9.99-"
     accum total by a.pkop a.s31 format "zzzzzzzzzzz9.99-"
     accum total by a.pkop a.s38 format "zzzzzzzzzzz9.99-"
     accum total by a.pkop a.s57 format "zzzzzzzzzzz9.99-" 
     accum total by a.pkop a.s56 format "zzzzzzzzzzz9.99-" 
/*
     accum total by a.pkop a.s33 format "zzzzzzzz9.99-"
     accum total by a.pkop a.s425 format "zzzzzzzz9.99-"
     accum total by a.pkop a.s54 format "zzzzzzzz9.99-" 
*/
     accum total by a.pkop a.sb  format "zzzzzzzzzzz9.99-" "|"
     accum total by a.pkop a.ns  format "zzzzzzzzzzz9.99-" 
     accum total by a.pkop a.am8 format "zzzzzzzzzzz9.99-" 
     accum total by a.pkop a.am9 format "zzzzzzzzzzz9.99-" 
     accum total by a.pkop a.am10 format "zzzzzzzzzzz9.99-" 
     accum total by a.pkop a.nb  format "zzzzzzzzzzz9.99-" "|"
     accum total by a.pkop a.ass  format "zzzzzzzzzzz9.99-"
     accum total by a.pkop a.ab  format "zzzzzzzzzz9.99-"
   skip.
   if (accum total by a.pkop a.am9p) <>0 then 
   Put  accum total by a.pkop a.am9p format "zzzzzzzzzzz9.99-" to 154 "(переоц.)" skip. 

   Put  fill('=',233) format 'x(233)' skip(1).

 end.


END.
/*
 if  vib = 4 then do:
  PUT 
      " Kop–: "  
           accum total a.satl at 14 format "zzz,zzz,zz9.99-"
           accum total a.dam at 32 format "zzz,zzz,zz9.99-"
           accum total a.cam at 50 format "zzz,zzz,zz9.99-"
           accum total a.amort at 66 format "zzz,zzz,zz9.99-"
           accum total a.batl at 82 format "zzz,zzz,zz9.99-".
 end.
*/
{report3.i}
{image3.i}
pause 0.

