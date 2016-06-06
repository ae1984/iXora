/* r-astinw.p
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
  свод по результатам инвентаризации
*/

{mainhead.i}
def var v-gl like ast.gl.
def var v-otv like ast.addr[2].
def var ipp as int init 0.
def var flg as int init 0.
define shared variable vdt as date.
define variable titl as character format "x(132)".
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
def  var vprn as logical.
vop=false.
/*  Atskaites druka*/
{image1.i inv.rpt}
{image2.i}
{report1.i 66}
vtitle =
"           СВОДНАЯ ИНВЕНТАРИЗАЦИОННАЯ ВЕДОМОСТЬ ПО ОСНОВНЫМ СРЕДСТВАМ НА " + string (vdt).

{report2.i 118 
"' Nr. |Карточки|                                |  Дата  |                    |      |                 | ' skip
 ' п/п |   Nr.  |           Название             |регистр.| Инвентарный номер  |Кол-во| Баланс.стоимость|Примечание' skip                 
  fill('=',118) format 'x(118)' skip "}                                                           

  For each ast where (if v-gl ne  0 then ast.gl = v-gl else true) no-lock 
        break by ast.gl by ast.attn  by ast.ast :

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
     put " Счет  " ast.gl " " gl.des skip
         " ------------------------------------------------" skip.    
     flg=1.
  end.               

      if vop=true and (vuzs ne 0 or v-atl ne 0 or vsk ne 0) then do :
                    ipp = ipp + 1.
                put ipp format "zzz9" " "
                    ast.ast format "x(8)" " "
                    ast.name format "x(33)" " "
                    ast.rdt " "
                    ast.addr[2] format "x(20)" " "
                    vsk  /* at 79 */ format "zzz9-"  
                    vuzs format "zzzzzz,zzz,zz9.99-" 
                   /* v-atl format "zzzzzzzzzz9.99-" */ skip.
            end.    
               
  if last-of(ast.attn) and (vuzsp ne 0 or v-atlp ne 0 or vskp ne 0) then do:
          
            if vop =true then
           put fill("=",118) format "x(118)" skip                                                            
               skip(1).   

           put  ast.attn format "x(4)". 
               find codfr where codfr.codfr = "sproftcn" and codfr.code = ast.attn no-lock no-error.
               if avail codfr then put codfr.name[1].                                    
                put "  Всего :".
                 put vskp at 79 format "zzz9-" 
                     vuzsp format "zzzzzz,zzz,zz9.99-"  
                   /*  v-atlp format "zzzzzzzzzz9.99-"*/ skip.
                  put fill("-",118) format "x(118)" skip .                                                           
         
            vskp = 0.
            vuzsp = 0.   
            v-atlp =0.
  end.
          
  if last-of(ast.gl) and (vuzsg ne 0 or v-atlg ne 0 or vskg ne 0) then do:
          
          find gl where gl.gl=ast.gl no-lock.
                 put skip(1) 
                     "Всего по сч." ast.gl gl.des  
                     vskg at 79 format "zzz9-" 
                     vuzsg format "zzzzzz,zzz,zz9.99-" 
                  /*   v-atlg format "zzzzzzzzzz9.99-" */ skip
                     fill("=",118) format "x(118)" skip .                                                           
          vskg = 0.
          vuzsg = 0.   
          v-atlg =0.  flg=0.
  end.
           

End.

put "ВСЕГО :"
     vskk at 79 format "zzz9-" 
     vuzsk format "zzzzzz,zzz,zz9.99-"  
  /*   v-atlk format "zzzzzzzzzz9.99-" */ skip
     fill("=",118) format "x(118)" skip                                                            

  "Всего по ведомости :" skip
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
