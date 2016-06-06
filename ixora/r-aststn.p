/* r-aststn.p
 * MODULE
        Основные средства
 * DESCRIPTION
        Состояние основных средств
        с выводом инветнарного номера (отличие от r-aststa.p
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
        08/07/04 sasco Убрал из отчета условие на astatl.atl > 0 (выводим с любой остаточной стоимостью)
        09/07/04 sasco выводим только с ненулевой балансовой стоимостью
        27.06.06 sasco   - Переделал поиск в hist (по ындэксу opdate)
*/

{mainhead.i}

define variable oneLs as integer initial 1.
define variable v-gl like ast.gl.
def var v-gl3 like trxlevgl.glr.
def var v-gl4 like trxlevgl.glr.
define variable v-fag like ast.fag.
define variable sprav as logical.
define variable otv as logical.
define variable vprn as logical.
define var vmc1 like ast.ldd.
define var vmc2 like ast.ldd.
define var v-ldd like ast.ldd.
define variable v-ast like ast.ast.
define variable vib as integer format "9".
define variable fsak like ast.icost. 
define variable atlv like ast.icost.
define variable fatlv like ast.icost.
define variable fnol like ast.icost.
define variable gsak like ast.icost. 
define variable gatlv like ast.icost.
define variable gnol like ast.icost.
define variable gfond like ast.icost.
define variable kfond like ast.icost.
define variable ffond like ast.icost.
define variable ksak like ast.icost. 
define variable katlv like ast.icost.
define variable knol like ast.icost.
define variable vfagn like fagn.naim.
define variable vgln like gl.des.
def var vibk as integer format "z" init 1.
def new shared var v-fil like sub-cod.ccode.
def var v-fild like codfr.name[1].
def var vib1 as integ.
define new shared var helptmp as char.

form
     skip(1)
     " НА ДАТУ    :" vmc1   skip 
     " ФИЛИАЛ     :" V-fil format "x(4)" v-fild format "x(20)" skip
     " ГРУППА ОС  :" v-fag  format "x(3)" fagn.naim at 35 skip
     " СЧЕТ ОС    :" v-gl   gl.des skip
     with row 8 frame amort centered no-labels title "СОСТОЯНИЕ ОСНОВНЫХ СРЕДСТВ".

on help of v-fil do:
   run asth-fil.
  v-fil = helptmp.
  helptmp =" ".
 displ v-fil with frame amort.
end.

 vmc1=g-today. 
 Update  vmc1 validate(vmc1 ne ? and vmc1<=g-today , "ПРОВЕРЬТЕ ДАТУ ")  
   with frame amort 1 down.
  
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
                          "ПРОВЕРЬТЕ НОМЕР ГРУППЫ  ") with frame amort. 
    if v-fag ne "" then do:
      find fagn where fagn.fag = v-fag no-lock.   
      v-gl = fagn.gl.
      find gl where gl.gl eq v-gl no-lock.
      display fagn.naim v-gl gl.des with frame amort.
      vib=2.
  end.
  else do:
   update v-gl validate(can-find(gl where gl.gl=v-gl ) or v-gl=0,
                       " ПРОВЕРЬТЕ СЧЕТ  " ) with frame amort.
   if v-gl ne 0 then do:
     find gl where gl.gl eq v-gl no-lock.
     display gl.des with frame amort. 
     if gl.subled ne "ast" then do:
            message "СЧЕТ НЕ ОС ". pause 1. undo,retry.
     end.
    vib=3.
   end. 
   
  else vib=4.
  end.
pause 0.
/*  Message "NOTIEK ATSKAITES FORMЁ№ANA ". */
 
 For each ast  use-index ast no-lock:
   find first sub-cod where sub-cod.acc = ast.ast and sub-cod.sub = "ast"
     and sub-cod.d-cod = "brnchs" use-index dcod no-lock no-error.
   if not avail sub-cod then do: 
     find codfr where codfr.codfr = "brnchs" no-lock no-error.
      if avail codfr then run sub-codv(ast.ast, "ast", "brnchs", codfr.code).
      else do:   
       if ast.dam[1] - ast.cam[1] ne 0 then do:
        message "Для карточки " + ast.ast + " не определено значение филиала (brnchs)".  
        pause.  return.
       end.
       else next.
      end.
   end.
 end.
{image1.i rpt.img}
{image2.i}
 put chr(27) + chr(15) format "xx"  .

/* comment 5.11.2001by sasco:  {report1.i 66} */
{report1.i 66}
find first ofc where ofc.ofc = userid('bank').
if ofc.mday[1] = 1 then
do: output close.
output to value(vimgfname) page-size 0 append.
end.

vtitle= "        Состояние основных средств  " + string (vmc1) + "  /  " + string(time,"HH:MM:SS") + "  " + v-fild. 

{report2.i 157 
"' Счет  Гр. Nr.карт. Деп. Инв.Nr              Кол.Дата рег.Срок изн.  Баланс.стоим. Начисл.аморт.      Остат.стоим.  Фонд переоценки   Название '  skip 
  fill('=',157) format 'x(157)' skip "}


FOR each ast where (if vib=2 then ast.fag = v-fag                       
              else (if vib=3 then ast.gl  = v-gl 
              else true)) no-lock, 
              each sub-cod where sub-cod.sub = "ast" and
                                 sub-cod.acc = ast.ast and  
                                 sub-cod.d-cod ="brnchs" and
                  (if vib1 =1 then sub-cod.ccode = v-fil else true)             
                  use-index dcod no-lock break  by ast.gl 
                  by ast.fag /*by sub-cod.ccode*/ by ast.ast: 


if first-of(ast.gl) then do:

 find first trxlevgl where trxlevgl.gl = ast.gl and trxlevgl.lev = 3 no-lock no-error.
 if available trxlevgl then v-gl3 = trxlevgl.glr. else v-gl3=?.   
 find first trxlevgl where trxlevgl.gl = ast.gl and trxlevgl.lev = 4 no-lock no-error.
 if available trxlevgl then v-gl4 = trxlevgl.glr. else v-gl4=?.   

 put "===== " at 50 ast.gl format "zzzzz9" " ====="
     "==== " at 69 v-gl3 format "zzzzz9" " ===="
     "===== " at 104 v-gl4 format "zzzzz9" " ====="
     skip.  
end.



 IF vmc1 = g-today  then do: 
  find last hist where hist.pkey = "AST" and hist.skey = ast.ast and hist.op = "MOVEDEP" and 
                       hist.date <= vmc1 no-lock use-index opdate no-error.
  if not avail hist then do:
     if vmc1 < g-today then do:
        find first hist where hist.pkey = "AST" and hist.skey = ast.ast and hist.op = "MOVEDEP" and
                              hist.date >= vmc1 no-lock use-index opdate no-error.
     end.
  end.

  if (ast.dam[1] - ast.cam[1]) ne 0 or (ast.dam[3] - ast.cam[3] ) ne 0 then DO:          
      
        put ast.gl  format "zzzzzz"  " " 
            ast.fag  format "x(3)" " "
            ast.ast  format "x(8)" " "
            (if avail hist then /*(if hist.date <= vmc1 then hist.chval[1] else hist.chval[2])*/ hist.chval[1] else ast.attn) form "x(3)" " " 
            ast.addr[2] format "x(20)"
            ast.qty  format "zzz-" " " 
            ast.rdt  
            ast.noy  format "zzz" 
            ast.dam[1] - ast.cam[1]  format "zzzzzz,zzz,zz9.99-"
            ast.cam[3] - ast.dam[3]  format "zzzzzz,zzz,zz9.99-"
            ast.dam[1] - ast.cam[1] + ast.dam[3] - ast.cam[3] 
                                               format "zzzzzz,zzz,zz9.99-"
            ast.cam[4] - ast.dam[4]  format "zzzzzz,zzz,zz9.99-"
            " "
            ast.name format "x(23)" .
  
            if length(ast.name)> 23 then
            put skip substring(ast.name,24,10) at 120 format "x(23)".
            
            put skip.
        
        fsak = fsak + ast.dam[1] - ast.cam[1]. 
        fatlv = fatlv + (ast.dam[1] - ast.cam[1] + ast.dam[3] - ast.cam[3] ).
        fnol = fnol + (ast.cam[3] - ast.dam[3]).
        ffond = ffond + (ast.cam[4] - ast.dam[4]).
        gsak =gsak + ast.dam[1] - ast.cam[1]. 
        gatlv = gatlv + ast.dam[1] - ast.cam[1] + ast.dam[3] - ast.cam[3].
        gnol = gnol + (ast.cam[3] - ast.dam[3]).
        gfond = gfond + (ast.cam[4] - ast.dam[4]).
        ksak =ksak + ast.dam[1] - ast.cam[1]. 
        katlv = katlv + ast.dam[1] - ast.cam[1] + ast.dam[3] - ast.cam[3] .
        knol = knol + ast.cam[3] - ast.dam[3].
        kfond = kfond + (ast.cam[4] - ast.dam[4]).
  end. 
 end.
 ELSE DO:

  find last hist where hist.pkey = "AST" and hist.skey = ast.ast and 
                       hist.date <= vmc1 no-lock use-index opdate no-error.
  if not avail hist then do:
     if vmc1 < g-today then do:
        find first hist where hist.pkey = "AST" and hist.skey = ast.ast and
                              hist.date >= vmc1 no-lock use-index opdate no-error.
     end.
  end.
       
         Find last astatl where astatl.ast =ast.ast  and astatl.dt <= vmc1
                use-index astdt no-lock no-error.
  if available astatl  and astatl.icost <> 0 /* and astatl.atl > 0 */ then do:
            
            put astatl.agl  format "zzzzzz" " " 
                astatl.fag  format "x(3)"   " "
                astatl.ast format "x(8)"    " "
                (if avail hist then (/*if hist.date <= vmc1 then hist.chval[1] else */ hist.chval[1]) else ast.attn) form "x(3)" " " 
                ast.addr[2] format "x(20)"
                astatl.qty format "zzz-"  
                ast.rdt  format "99/99/99" 
                ast.noy  format "zzz" 
                astatl.icost format "zzzzzz,zzz,zz9.99-"
                astatl.nol  format "zzzzzz,zzz,zz9.99-"
                astatl.atl  format "zzzzzz,zzz,zz9.99-"
                astatl.fatl[4]  format "zzzzzz,zzz,zz9.99-"
                ast.name format "x(23)" .
                if length(ast.name)> 23 then
                put skip substring(ast.name,24,10) at 120 format "x(23)".
                put skip.
        

        fsak = fsak + astatl.icost. 
        fatlv = fatlv + astatl.atl.
        fnol = fnol + astatl.nol.
        ffond = ffond + astatl.fatl[4].
        gsak =gsak + astatl.icost. 
        gatlv = gatlv + astatl.atl.
        gnol = gnol + astatl.nol.
        gfond = gfond + astatl.fatl[4].
        ksak =ksak + astatl.icost. 
        katlv = katlv + astatl.atl.
        knol = knol + astatl.nol.
        kfond = kfond + astatl.fatl[4].
  end.
 END.
  if vib >= 2 and fsak ne 0 and last-of (ast.fag) then do:
     find fagn where fagn.fag = ast.fag no-lock no-error. 

        put skip(1)
            "Всего( гр.  " ast.fag ")"   
            fsak  to 64 format "zzzzzz,zzz,zz9.99-"
            fnol   format "zzzzzz,zzz,zz9.99-"  
            fatlv  format "zzzzzz,zzz,zz9.99-"
            ffond  format "zzzzzz,zzz,zz9.99-"
            fagn.naim  format "x(23)" skip(1).
        fsak = 0. 
        fatlv = 0.
        fnol = 0.
  end.
  if vib >= 3 and gsak ne 0 and last-of (ast.gl) then do:
        find gl where gl.gl =ast.gl no-lock no-error.
        put "Всего(счет  " ast.gl ")"  
             gsak to 64 format "zzzzzz,zzz,zz9.99-"
             gnol  format "zzzzzz,zzz,zz9.99-"  
             gatlv  format "zzzzzz,zzz,zz9.99-"
             gfond  format "zzzzzz,zzz,zz9.99-"
             gl.des  format "x(23)" skip
             fill("-",157) format "x(157)" skip.
         gsak = 0. 
        gatlv = 0.
        gnol = 0.
  end.
END.

 if vib >= 4 and ksak ne 0 then do: 
   put /* fill("=",132) format "x(132)" */ skip
       "Всего" space(3) 
       ksak to 64 format "zzzzzz,zzz,zz9.99-"
       knol  format "zzzzzz,zzz,zz9.99-" 
       katlv format "zzzzzz,zzz,zz9.99-"
       kfond format "zzzzzz,zzz,zz9.99-"
       skip
       fill("=",132) format "x(132)" skip.
       end.

{report3.i}
{image3.i}
