/* r-astink.p
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


/* r-astink.p
pёc grupas  свод по результатам инвентаризации
*/

{mainhead.i}
def  var vprn as logical.
def var v-gl like ast.gl.
def var v-fag like ast.fag.
def var ipp as int init 0.
def var flg as int init 0.
def var flp as int init 0.
def var vib as int.
define variable vdt as date.
define variable titl as character format "x(118)".
def var v-atl like ast.crline.
def var v-atlp like ast.crline.
def var v-atlg like ast.crline.
def var v-atlk like ast.crline.
def var vuzs like ast.crline.
def var vuzsp like ast.crline.
def var vuzsg like ast.crline.
def var vuzsk like ast.crline.
def var vsk like ast.crline.
def var vskp like ast.crline.
def var vskg like ast.crline.
def var vskk like ast.crline.
def var vop as log format "да/нет" init "да".

vdt = g-today.
g-fname = "  ".
g-mdes = "  ".
form
     skip(1)
     " ИНВЕНТАРИЗАЦИЯ  НА ДАТУ   :" vdt  skip(1)
     " ГРУППА ОС                 :" v-fag  format "x(3)" fagn.naim  skip(1)
     " СЧЕТ   ОС                 :" v-gl   gl.des skip(1)
  with row 8 frame inv centered no-labels 
 title " Введите данные об инвентаризации " .

  update vdt with frame inv. 

  update v-fag validate(can-find (fagn where fagn.fag = v-fag) or v-fag="", 
                          "ГРУППЫ НЕТ ") with frame inv. 
  if v-fag ne "" then do:
      find fagn where fagn.fag = v-fag no-lock.   
      v-gl = fagn.gl.
      find gl where gl.gl eq v-gl no-lock.
      display fagn.naim v-gl gl.des with frame amort.
      vib=2.
  end.
  else do:
   update v-gl validate(can-find(gl where gl.gl=v-gl ) or v-gl=0,
                       " СЧЕТА НЕТ " ) with frame inv.
   if v-gl ne 0 then do:
     find gl where gl.gl eq v-gl no-lock.
     display gl.des with frame amort. 
     if gl.subled ne "ast" then do:
            message "СЧЕТ НЕ ОС". pause 1. undo,retry.
     end.
    vib=3.
   end. 
   else vib=4.
  end.
pause 0.
update " ВЫВЕСТИ ВСЕ  КАРТОЧКИ ? (да/нет) " vop with frame a no-label centered. 

 /*  Atskaites druka*/
{image1.i inv.rpt}
{image2.i}
{report1.i 66}
if vop then
vtitle =
"                ВЕДОМОСТЬ ИНВЕНТАРИЗАЦИИ ОСНОВНЫХ СРЕДСТВ НА " + string (vdt).
else
vtitle =
"                СВОДНАЯ  ИНВЕНТАРИЗАЦИОННАЯ ВЕДОМОСТЬ ОСНОВНЫХ СРЕДСТВ НА " + string (vdt).     

{report2.i 118 
"' Nr. |Карточки|                                |  Дата  |                    |      |                 |          ' skip
 ' п/п |   Nr.  |           Название             |регистр.| Инвентарный номер  |Кол-во| Баланс.стоимость|Примечание' skip                 
  fill('=',118) format 'x(118)' skip "}                                                           


For each ast where (if vib=2 then ast.fag = v-fag                       
              else (if vib=3 then ast.gl  = v-gl
              else true)) no-lock
	break by ast.gl by ast.fag by ast.ast :

     find last astatl where astatl.ast = ast.ast and astatl.dt < vdt 
              use-index astdt no-lock no-error.   
     if  avail astatl then do:
       v-atl=astatl.atl.   v-atlp=v-atlp + v-atl. v-atlg=v-atlg + v-atl. 
       v-atlk=v-atlk + v-atl.
       vuzs=astatl.icost. vuzsp=vuzsp + vuzs. vuzsg=vuzsg + vuzs. 
       vuzsk=vuzsk + vuzs. 
       vsk=astatl.qty.    vskp=vskp + vsk.    vskg=vskg + vsk.    
       vskk=vskk + vsk.  
     end.

/*  if first-of(ast.gl) then do:
*/
    if (vuzsg ne 0 or v-atlg ne 0 or vskg ne 0) and flg ne 1 then do:
     find gl where gl.gl eq ast.gl no-lock.
     put " Счет " ast.gl " " gl.des skip
         " ------------------------------------------------" skip.    
     flg=1.
  end.               

/*  if first-of(ast.fag) and vop then do:
*/
    if (vuzsp ne 0 or v-atlp ne 0 or vskp ne 0) and flp ne 1 and vop then do:
     find fagn where fagn.fag eq ast.fag no-lock.
     put " Гр." ast.fag " " fagn.naim skip(1).
     flp=1.
  end.               

      if vop=true and (vuzs ne 0 or v-atl ne 0 or vsk ne 0) then do :
	            ipp = ipp + 1.
		put ipp format "zzz9." " "
		    ast.ast format "x(8)" " "
		    ast.name format "x(32)" " "
		    ast.rdt " "
                    ast.addr[2] format "x(20)" " "
		    vsk  /* at 79 */ format "zzz9-"  
		    vuzs format "zzzzzz,zzz,zz9.99-" 
		   /* v-atl format "zzzzzzzzzz9.99-" */ skip.
               put fill("-",118) format "x(118)" skip .                                                           
          vuzs=0. v-atl=0. vsk=0. 
      end.    

  if last-of(ast.fag) and (vuzsp ne 0 or v-atlp ne 0 or vskp ne 0) then do:
  	   if vop then put skip(1).
	   put "Всего по гр." ast.fag format "x(4)". 
               find fagn where fagn.fag = ast.fag no-lock no-error.
               if avail fagn then put fagn.naim.                                    
		
		 put vskp at 79 format "zzz9-" 
		     vuzsp format "zzzzzz,zzz,zz9.99-"  
		   /*  v-atlp format "zzzzzzzzzz9.99-"*/ skip
                     fill("-",118) format "x(118)"   skip .                                                           
       	 
       	    vskp = 0.
       	    vuzsp = 0.   
       	    v-atlp =0.  flp=0.
  end.
       	  
  if last-of(ast.gl) and vib ne 2 and (vuzsg ne 0 or v-atlg ne 0 or vskg ne 0) then do:
       	  find gl where gl.gl=ast.gl no-lock.
		 put skip(1) 
		     "Всего по сч." ast.gl gl.des  
		     vskg at 79 format "zzz9-" 
		     vuzsg format "zzzzzz,zzz,zz9.99-" 
		  /*   v-atlg format "zzzzzzzzzz9.99-" */ skip
                     fill("=",118) format "x(118)" skip .                                                           
       	 
       	  vskg = 0.
       	  vuzsg = 0.   
       	  v-atlg =0.   flg=0.
  end.
       	   

End.

put " Всего :"
     vskk at 79 format "zzz9-" 
     vuzsk format "zzzzzz,zzz,zz9.99-"  
  /*   v-atlk format "zzzzzzzzzz9.99-" */ skip
     fill("=",118) format "x(118)" skip                                                            

  "Всего по ведомости номеров по порядку   ______________________________________________________" skip
  " (прописью) фактически кол-во  _______________________________________________" skip
  "            фактически сумма _________________________________________________________" skip   
  "                             _________________________________________________________" skip(1)
   
  "Председатель комиссии   :  __________________  _________________ " skip
  "                                подпись            фамилия        " skip        
  "Члены комиссии   :         __________________  _________________ "  skip 
  "                           __________________  _________________ "  skip
  "                           __________________  _________________ "  skip
  "                           __________________  _________________ "  skip.

{report3.i}
{image3.i}

  form
  "   ПЕЧАТАТЬ ведомость?   " vprn format "да/нет" "   " skip
  with row 6 no-label centered  color message frame druk.

  update vprn with frame druk.
  if vprn eq true then  unix silent prit inv.rpt.
  hide all.
