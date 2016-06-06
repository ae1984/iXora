/* r-astina.p
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


/* r-astina.p
 инвентаризациoнная ведомость atb.per.
*/

{mainhead.i}
def var v-gl like ast.gl.
def var v-otv like ast.addr[2].
def var ipp as int init 0.
def var flg as int init 0.
def var flp as int init 0.
define new shared variable vdt as date.
define variable titl as character format "x(132)".
def var v-atl like ast.crline.
def var v-atlp like ast.crline.
def var v-atlg like ast.crline.
def var v-atlk like ast.crline.
def var v-addr like ast.addr[1].
def var vuzs like ast.crline.
def var vuzsp like ast.crline.
def var vuzsg like ast.crline.
def var vuzsk like ast.crline.
def var vsk like ast.crline.
def var vskp like ast.crline.
def var vskg like ast.crline.
def var vskk like ast.crline.
def  var vprn as logical.
vdt = g-today.
g-fname = "  ".
g-mdes = "  ".
form 
     skip(1)
     "        ИНВЕНТАРИЗАЦИЯ  НА ДАТУ   :" vdt  skip(1)
     " СВОД ПО ОТВЕТСТВЕННЫМ ЛИЦАМ  (да):" vprn  format "да/нет"  skip(1)
     "   или       КОД ОТВЕТСТВЕН.ЛИЦА  :" v-addr   gl.des skip(1)
  with row 8 frame ink centered no-labels 
 title " Введите данные об инвентаризации " .

  update vdt with frame ink. 
  update vprn with frame ink.
  if vprn then do: run r-astinb. return. end. 
  update  v-addr validate(can-find(astotv where astotv.kotv=v-addr and astotv.priz="A"),
                          "КОДА " + v-addr + " НЕТ В СЛОВАРЕ")
         with frame ink.
 find astotv where astotv.kotv=v-addr and astotv.priz="A" no-lock no-error.
 if avail astotv then  displ astotv.otvp with frame ink.
pause 0.

 /*  Atskaites druka*/
{image1.i inv.rpt}
{image2.i}
{report1.i 66}
Put  
  g-comp " " vtoday " " vtime skip

 "                    ВЕДОМОСТЬ ИНВЕНТАРИЗАЦИИ ОСНОВНЫХ СРЕДСТВ    "  skip(1) 
/*
 "  Pamatojoties uz prezidenta paveµi 199_ . g. '___'__________ Nr.______  " skip(1)
*/
 skip(1)
 "  Комиссия в составе председателя :________________  " skip
 "  членов комиссии   :____________________________________________________________" skip(1)
 "  матер.ответственного лица   " astotv.otvp skip(1)
 "  провела инвентаризацию основных средств на "  string(vdt)  
 "  и констатировала следующие остатки  : "skip(0)
  fill("=",118) format "x(118)" skip                                                            
 " Nr. |Карточки|                                |  Дата  |                    |      |                 | " skip
 " п/п |   Nr.  |           Название             |регистр.| Инвентарный номер  |Кол-во| Баланс.стоимость|Примечание" skip                 
  fill("=",118) format "x(118)" skip .                                                                                

vtitle =
"                 ВЕДОМОСТЬ ИНВЕНТАРИЗАЦИИ ОСНОВНЫХ СРЕДСТВ  " + string (vdt).

{report2.i 118 
"' Nr. |Карточки|                                |  Дата  |                    |      |                 | ' skip
 ' п/п |   Nr.  |           Название             |регистр.| Инвентарный номер  |Кол-во| Баланс.стоимость|Примечание' skip                 
  fill('=',118) format 'x(118)' skip "}                                                           

  For each ast where ast.addr[1] = v-addr no-lock 
	break by ast.gl by ast.fag by ast.ast :

/*   if vdt < g-today then do:
*/
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

/*   end.
   else do:
    v-atl=ast.dam[1] - ast.cam[1].  v-atlp=v-atlp + v-atl.  
    v-atlg=v-atlg + v-atl. v-atlk=v-atlk + v-atl.
     vuzs=ast.icost. vuzsp=vuzsp + vuzs. vuzsg=vuzsg + vuzs. 
     vuzsk=vuzsk + vuzs. 
     vsk=ast.qty.    vskp=vskp + vsk.    vskg=vskg + vsk.    
     vskk=vskk + vsk.  
   end.
*/

/*  if first-of(ast.gl) then do:
*/
    if (vuzsg ne 0 or v-atlg ne 0 or vskg ne 0) and flg ne 1 then do:
     find gl where gl.gl eq ast.gl no-lock.
     put " Счет  " ast.gl " " gl.des skip
         " ------------------------------------------------" skip.    
     flg=1.
  end.               

/*  if first-of(ast.fag) then do:
*/
    if (vuzsp ne 0 or v-atlp ne 0 or vskp ne 0) and flp ne 1 then do:
     find fagn where fagn.fag eq ast.fag no-lock.
     put " Гр." ast.fag " " fagn.naim skip(1).
     flp=1.
  end.               

    if vuzs ne 0 or v-atl ne 0 or vsk ne 0 then do :
	            ipp = ipp + 1.
  	        put ipp format "zzz9." " "
		    ast.ast format "x(8)" " "
		    ast.name format "x(32)" " "
		    ast.rdt " "
                    ast.addr[2] format "x(20)" " "
		    vsk  /* at 79 */ format "zzz9-"  
		    vuzs format "zzzzzz,zzz,zz9.99-" 
		   /* v-atl format "zzzzzzzzzz9.99-" */ skip
                   fill('-',118) format 'x(118)' skip.                                                           
          vuzs=0. v-atl=0. vsk=0.
    end.    
               
  if last-of(ast.fag) and (vuzsp ne 0 or v-atlp ne 0 or vskp ne 0) then do:
  	  
	   put "Всего по гр." ast.fag format "x(4)". 
               find fagn where fagn.fag = ast.fag no-lock no-error.
               if avail fagn then put fagn.naim.                                    
		
		 put vskp at 79 format "zzz9-" 
		     vuzsp format "zzzzzz,zzz,zz9.99-"  
		   /*  v-atlp format "zzzzzzzzzz9.99-"*/ skip.
                  put fill("-",118) format "x(118)" skip .                                                           
       	 
       	    vskp = 0.
       	    vuzsp = 0.   
       	    v-atlp =0.
            flp=0.
  end.
    if last-of(ast.gl) and (vuzsg ne 0 or v-atlg ne 0 or vskg ne 0) then do:
       	  
       	  find gl where gl.gl=ast.gl no-lock.
		put  "Всего по сч." ast.gl gl.des  
		     vskg at 79 format "zzz9-" 
		     vuzsg format "zzzzzz,zzz,zz9.99-" 
		  /*   v-atlg format "zzzzzzzzzz9.99-" */ skip
                     fill("=",118) format "x(118)" skip .                                                           
       	  vskg = 0.
       	  vuzsg = 0.   
       	  v-atlg =0.
          flg=0.
  end.
       	   
       	  
End.

put "Всего по ведом."
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
vprn=false.
  form
  "   ПЕЧАТАТЬ ведомость?   " vprn format "да/нет" "   " skip
  with row 6 no-label centered  color message frame druk.

  update vprn with frame druk.
  if vprn eq true then  unix silent prit inv.rpt.
  hide all.
