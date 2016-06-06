/* r-astdruk.p
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

/* r-astdruk.p */

{mainhead.i }
define  shared variable v-atl like ast.icost .
define  shared variable v-nol like ast.icost .
define  shared variable v-icost like ast.icost .
define  shared variable v-nach like ast.icost format "zzzzzz,zzz,zz9.99-" .
define  shared variable v-fagn like ast.name.
define  shared variable v-addrn like ast.name.
define  shared variable v-attnn like ast.name.
define variable v-ddt like ast.ldd.
def shared var v-ast like ast.ast format "x(8)".
def shared var v-gl3 as int format "zzzzz9".
def shared var v-gl4 as int format "zzzzz9".
def shared var v-fil as char.
def shared var v-filn as char.
def shared var v-gl1d as char.
def shared var v-gl3d as char.
def shared var v-fond like ast.icost.



form
 "Nr.КАРТОЧКИ  :" ast.ast format "x(8)" "    ИНВЕНТ.Nr." ast.addr[2] format "x(8)" 
                                      " Откр."  ast.whn ast.who skip
 "НАЗВАНИЕ     :" ast.name      v-fil at 47 format "x(4)" " " v-filn format "x(24)" skip
 "СЧЕТ         :" ast.gl format "zzzzz9" v-gl1d format "x(20)" skip 
 "             :" v-gl3 format "zzzzz9"  v-gl3d format "x(20)"  
        "ГРУППА" ast.fag format "xxx" v-fagn format "x(24)" skip 

 "ДАТА РЕГИСТР.:" ast.rdt "-------->  С ПЕРВ.СТОИМ.:" at 26 v-nach ast.meth 
                         format "zzz9-" "шт." skip
 "КОЛ-ВО      :" ast.qty format "zzz9-"
            "    с ИЗНОСОМ  :" at 35 ast.salv format "zzzzzzz,zz9.99-"skip
 "ОСТАТ.СТОИМ.:" v-atl  format "zzzzzz,zzz,zz9.99-"
            "СРОК AMOPT.:" at 34 ast.noy format "zz9" "лет"
                        " МЕС.АМОРТ.:" ast.amt[1] format "zzzzzzz9.99" skip
  "КОД :" at 34  ast.ser format "x(6)" 
                                    "  ПОСЛЕД.РАСЧ.АМОРТ:"  ast.ldd skip
 "БАЛАНС.СТОИМ.:" v-icost format "zzzzzz,zzz,zz9.99"  
                  ":" ast.dam[1] format "zzzzzz,zzz,zz9.99-" "DR"
                      ast.cam[1] format "zzzzzz,zzz,zz9.99-" "CR"  skip

 "НАКОПЛ.АМОРТ.:" v-nol format "zzzzzz,zzz,zz9.99" 
                  ":"  ast.dam[3] format "zzzzzz,zzz,zz9.99-" "DR"
                       ast.cam[3] format "zzzzzz,zzz,zz9.99-" "CR" skip 
"--------------------------  Данные по переоценке  ---------------------------" SKIP
 "ФОНД ПЕРЕОЦЕН:" v-fond format "zzzzzz,zzz,zz9.99-" 
 ":" ast.dam[4] format "zzzzzzzzz,zz9.99-" "DR" 
              ast.cam[4] format "zzzzzz,zzz,zz9.99-" "CR" skip(1)
 /*
 "СУММА ПЕРЕОЦЕНКИ ОСНОВВНОЙ СТОИМОСТИ:"  ast.ydam[4] format "zzzzzz,zzz,zz9.99-" "DR" skip
 "СУММА ПЕРЕОЦЕНКИ ИЗНОСА             :" ast.ycam[4] format "zzzzzz,zzz,zz9.99-" "CR" skip 
*/
"------------------ Данные для расчета налогового износа ---------------------" SKIP
 "КАТЕГОРИЯ    :" ast.cont format "x(2)"   
        "СТАВКА ИЗНОСА  :" to 40 ast.ref format "x(2)" " % x 2 "skip
/* " НА " ast.ddt[1]  "ОСТ.НАЛОГ.СТОИМОСТЬ:" to 40 ast.crline format "zzz,zzz,zz9.99-" skip
 " НА " ast.ddt[4]  "ОСТ.НАЛОГ.СТОИМОСТЬ:" to 40 ast.amt[4] format "zzz,zzz,zz9.99-" skip    
*/
"-----------------------------------------------------------------------------"       

 "ОТВЕТСТВ.ЛИЦО:" ast.addr[1] format "x(5)" " " v-addrn format "x(25)"
                              "ИЗМЕНЕН.:" at 58 ast.updt   skip                
 "МЕСТО РАСПОЛ.:" ast.attn format "x(5)" " " v-attnn format "x(25)"
                                          ast.ofc at 67 skip
 "ПРИМЕЧАНИЕ   :"ast.rem skip 
 "ПАСПОР.ДАННЫЕ:" ast.mfc  skip
   
  with frame astp row 1 overlay centered no-labels no-hide.
 pause 0.  hide all. pause 0.	 
   
 /*  Atskaites druka*/
{image1.i rpt.img}
{image2.i}
{report1.i 0 } /* 66 */
vtitle =
"                КАРТОЧКА ОС Nr. " + v-ast.

{report2.i 80} 

 find ast where ast.ast = v-ast no-lock no-error.
  if available ast then do:

    display ast.ast ast.addr[2] ast.name ast.fag v-fagn ast.gl 
    ast.rdt ast.noy ast.qty ast.ser ast.icost ast.whn ast.who 
    v-fond /* ast.ydam[4] ast.ycam[4] */ ast.dam[4] ast.cam[4]
  /*  ast.ddt[1] ast.crline ast.ddt[4] ast.amt[4] */  ast.cont ast.ref
    ast.salv v-icost v-atl v-nol v-nach ast.meth ast.ldd ast.noy ast.amt[1]  
    ast.addr[1] v-addrn ast.attn v-attnn ast.mfc ast.rem ast.updt ast.ofc
    ast.dam[1] ast.cam[1] ast.dam[3] ast.cam[3] v-gl3 v-gl3d v-gl1d
    v-fil v-filn
	with frame astp.

     put  fill("=",80) format "x(80)" skip .                                                           
  end.
put " ДАТА  СЧЕТ                  КOЛ. ОПЕРАЦИЯ                      " skip.


   for each astjln where astjln.aast = v-ast 
       use-index astdt no-lock : 
    put astjln.ajdt "                     "
             astjln.aqty  format "zz9-" 
             astjln.ajh " "
             astjln.awho " " 
             astjln.atrx format "xx"
             astjln.arem[1] format "x(55)".
              
    put skip "    " astjln.agl 
             astjln.d[1] format "zzzzzz,zzz,zz9.99-" " DR" 
             astjln.c[1] format "zzzzzz,zzz,zz9.99-" " CR". 

       if astjln.arem[2] ne " " then 
        put astjln.arem[2] format "x(55)" at 54 . 
    
   if  (astjln.d[3] ne 0 or astjln.c[3] ne 0) then
    put skip
        "    " v-gl3 
             astjln.d[3] format "zzzzzz,zzz,zz9.99-" " DR"
             astjln.c[3] format "zzzzzz,zzz,zz9.99-" " CR".

       if astjln.arem[3] ne " " then 
        put astjln.arem[3] format "x(55)" at 54 . 
              
   if  (astjln.d[4] ne 0 or astjln.c[4] ne 0) then
    put skip "    " v-gl4 
             astjln.d[4] format "zzzzzz,zzz,zz9.99-" " DR"
             astjln.c[4] format "zzzzzz,zzz,zz9.99-" " CR"
             skip.

   
       if astjln.arem[4] ne " " then 
        put astjln.arem[4] format "x(55)" at 54 . 
         
     put skip.
   end.



/*
   for each astjln where astjln.aast = v-ast and 
            (astjln.d[1] ne 0 or astjln.c[1] ne 0)
       use-index astdt no-lock : 
    put "         " astjln.agl skip.
    put      astjln.ajdt 
             astjln.d[1] format "zzzzzz,zzz,zz9.99-" 
             astjln.c[1] format "zzzzzz,zzz,zz9.99-" 
             astjln.apriz format "x" " "
             astjln.aqty  format "zz9-" 
             astjln.ajh " "
             astjln.awho " " 
             astjln.arem[1] format "x(55)"
             astjln.atrx format "xx" skip. 
       if astjln.arem[2] ne " " then 
        put astjln.arem[2] at 51 skip. 
       if astjln.arem[3] ne " " then 
        put astjln.arem[3] at 51 skip. 
       if astjln.arem[4] ne " " then 
        put astjln.arem[4] at 51 skip. 
         
   end.
   for each astjln where astjln.aast = v-ast and 
             (astjln.d[3] ne 0 or astjln.c[3] ne 0)
    use-index astdt no-lock : 
    put "         " v-gl3 format "zzzzz9" skip.
    put      astjln.ajdt 
             astjln.d[3] format "zzzzzz,zzz,zz9.99-" 
             astjln.c[3] format "zzzzzz,zzz,zz9.99-" 
             astjln.apriz format "x" " "
             astjln.aqty  format "zz9-" 
             astjln.ajh " "
             astjln.awho " " 
             astjln.arem[1] format "x(55)"
             astjln.atrx format "xx" skip. 
       if astjln.arem[2] ne " " then 
        put astjln.arem[2] at 51 skip. 
       if astjln.arem[3] ne " " then 
        put astjln.arem[3] at 51 skip. 
       if astjln.arem[4] ne " " then 
        put astjln.arem[4] at 51 skip. 
         
   end.
*/
{report3.i}
{image3.i}
hide all no-pause.

