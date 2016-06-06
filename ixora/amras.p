/* amras.p
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


{mainhead.i}

define shared variable oneLs as integer initial 1.
define shared variable ddate as date.
define shared variable ddatm as integer format "99".
define shared variable ddaty as integer format "9999".
define shared variable dateldd like ast.ldd.
define shared variable v-gl like ast.gl.
define shared variable v-fag like ast.fag.
define shared variable v-ast like ast.ast format "x(8)".
define shared variable kor-gl like gl.gl.
define shared variable was as logical.
define variable sgldes like gl.des.
define variable depramt like ast.icost.
define variable Qdepramt like ast.icost.
define variable Vicost like ast.icost.
define variable Vost1 like ast.icost.
define variable Vost2 like ast.icost.
define variable Gqdepramt like ast.icost.
define variable Gvicost like ast.icost.
define variable Gvost1 like ast.icost.
define variable Gvost2 like ast.icost.
define variable Evost1 like ast.icost.
define variable vnaim like ast.name.
def var dd-a as char format "999999".
def shared temp-table aast  field ast like ast.ast
                     index ast ast.     
def var otv as logical.
{image1.i rpt.img}
{image2.i}
{report1.i 66}
vtitle= "           Начисление износа по счету " + string(v-gl) + " за " +
            string (year(ddate)) + " г."+ string (month (ddate)) + 
            " мес. " . 

{report2.i 120 
"' Карт.Nr  Название осн.средств          Срок износ.    Перв.ст.   Стоим. до    Начисл.износ  Остат.стоим.  ' skip 
  fill('=',105) format 'x(105)' skip "}

For each ast where (if v-ast<>"" then ast.ast=v-ast else ast.ast>"0") and 
            ast.gl = v-gl 
            and ast.dam[1] - ast.cam[1]  > ast.cam[3] - ast.dam[3] 
            and ast.noy > 0 break by ast.gl by ast.fag :

 if ast.ldd ne ? then dd-a=string(year(ast.ldd),"9999") +
                           string(month (ast.ldd),"99").
                 else dd-a=string(year(ast.rdt),"9999") +
                           string(month (ast.rdt),"99").
                         
   if year (ddate) lt year (ast.rdt) or 
       (year(ddate) eq year(ast.rdt) and month(ddate) le month(ast.rdt))
      then do: message string(ast.ast, "x(8)") + " Рег.дата   " + 
               string(ast.rdt) + ". В текущий расчет не включено".
         pause 0 . next.
   end.
  if dd-a >= string(year(ddate),"9999") + string(month(ddate),"99") then do:
    message string(ast.ast,"x(8)") + " АМОРТИЗАЦИЯ уже начислена за " +
     substring(dd-a,1,4) + "." + substring(dd-a,5,2)  +
      ". В текущий расчет не включено".
         pause 0. next.
  end. 


/****
 /* амортиз. не начисл. на cp-ва,у которых в данном м-це амор.уже начислена */
   if year (ddate) eq year (ast.ldd) and  month (ast.ldd) eq month (ddate) 
      and ast.ldd ne ? then do:
   message string(ast.ast, "x(8)") + " Износ уже начислен за " + 
        substring(string(ast.ldd),4,5) + ". В текущий расчет не включено".
         pause 0 . next.
   end. 
    
    if year (ddate) lt year (ast.rdt) or 
       (year(ddate) eq year(ast.rdt) and month(ddate) le month(ast.rdt))
      then do: message string(ast.ast, "x(8)") + " Рег.дата   " + 
               string(ast.rdt) + ". В текущий расчет не включено".
         pause 0 . next.
    end.
 
/* амортиз. не начисл. на не отработ. 1 месяц средства. */
    if year (ddate) eq year (ast.rdt) then
        if ast.ldd eq ? then
            if month (ast.rdt) eq month (ddate) then next.
****/ 
       Evost1 = ast.dam[1] - ast.cam[1] + ast.dam[3] - ast.cam[3].
       Vicost = Vicost + ast.dam[1] - ast.cam[1].
       Vost1 =  Vost1 + ast.dam[1] - ast.cam[1] + ast.dam[3] - ast.cam[3].
       Gvicost = Gvicost + ast.dam[1] - ast.cam[1].
       Gvost1  = Gvost1 + ast.dam[1] - ast.cam[1] + ast.dam[3] - ast.cam[3].
    depramt = round((ast.dam[1] - ast.cam[1]) / ast.noy / 12,0).
    if depramt ge (ast.dam[1] - ast.cam[1] + ast.dam[3] - ast.cam[3]) then do:
        ast.amt[1] = ast.dam[1] - ast.cam[1] + ast.dam[3] - ast.cam[3].
        ast.amt[2] = 0.
    end.
    else do:
        ast.amt[1] = depramt.                   /* сумма аморт.за 1 месяц */
        ast.amt[2] = (ast.dam[1] - ast.cam[1] + ast.dam[3] - ast.cam[3]) - depramt.
    end.                                        /* остаток после начисл.  */

    ast.updt = ddate.                   /* дата начисления      */
   Gqdepramt = Gqdepramt + ast.amt[1].
   Qdepramt = Qdepramt + ast.amt[1].
   Gvost2 = Gvost2 + ast.amt[2].
   Vost2 = Vost2 + ast.amt[2].


 PUT  ast.ast  format "x(10)" at 1 
      ast.name format "x(25)" AT 14 
      ast.noy  format "zz9" AT 43 
      ast.dam[1] - ast.cam[1] format "zzzzzzzzz9.99" AT 49 
      Evost1  format "zzzzzzzzz9.99" AT 62 
      ast.amt[1] format "zzzzzzzzz9.99" AT 76 
      ast.amt[2] format "zzzzzzzzz9.99-" at 92.
 create aast.
 aast.ast=ast.ast.

 
    If last-of(ast.fag) and v-ast = "" then do:
     
     find fagn where fagn.fag = ast.fag no-lock no-error.
        if available fagn then vnaim = fagn.naim. 

  PUT
 skip
"------------------------------------------------------------------------------------------------------------" 
      "  Всего " at 1
       ast.fag at 9
       vnaim  format "x(25)" at 14 
       Gvicost format "zzzzzzzzz9.99" at 49
       Gvost1  format "zzzzzzzzz9.99" at 62 
       Gqdepramt format "zzzzzzzzz9.99" at 76  
       Gvost2   format "zzzzzzzzz9.99" at 92 skip
"-------------------------------------------------------------------------------------------------------------" SKIP(1).

       Gvicost = 0.  
       Gvost1  = 0. 
       Gqdepramt =0.   
       Gvost2 = 0.
   end.
  
 was = true.  

END.  
  if v-ast = "" then do:
/*  
   If Qdepramt = 0 then do:
    message "Износ по счету " + string(v-gl) + " рассчитан раньше !!!".
    pause 5.
    return.
   end.
*/ 
    PUT  ".......................Всего: " at 1 v-gl
       Vicost format "zzzzzzzzz9.99"  at 49
       Vost1  format "zzzzzzzzz9.99"  at 62 
       Qdepramt format "zzzzzzzzz9.99" at 76  
       Vost2   format "zzzzzzzzz9.99" at 92. 
  end. 
{report3.i}
{image3.i}

repeat:
    otv=true.
    message "  Отчет печатать ?(да/нет) " UPDATE otv format "да/нет". 
    if otv then unix silent prit  rpt.img.
           else return.
end.
