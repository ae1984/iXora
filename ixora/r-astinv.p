/* r-astinv.p
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


/* r-astinv.p
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
def var v-attn like ast.attn.
def var vuzs like ast.crline.
def var vuzsp like ast.crline.
def var vuzsg like ast.crline.
def var vuzsk like ast.crline.
def var vsk like ast.crline.
def var vskp like ast.crline.
def var vskg like ast.crline.
def var vskk like ast.crline.
def var vamt like ast.crline.
def var vamtp like ast.crline.
def var vamtg like ast.crline.
def var vamtk like ast.crline.
def  var vprn as logical.
vdt = g-today.
g-fname = "  ".
g-mdes = "  ".
form 
     skip(1)
     "        ИНВЕНТАРИЗАЦИЯ  НА ДАТУ   :" vdt  skip(1)
     " СВОД ПО МЕСТАМ РАСПОЛОЖЕНИЯ  (да):" vprn  format "да/нет"  skip(1)
     "   или      КОД МЕСТА РАСПОЛОЖЕНИЯ:" v-attn   gl.des skip(1)
  with row 8 frame ink centered no-labels 
 title " Введите данные об инвентаризации " .

  update vdt with frame ink. 
  update vprn with frame ink.
  if vprn then do: run r-astinw. return. end. 
  update  v-attn validate(can-find(codfr where codfr.codfr = "sproftcn" and 
         codfr.code = v-attn and codfr.code matches "..."),
                          "КОДА " + v-attn + " НЕТ В СЛОВАРЕ")
         with frame ink.
 find codfr where codfr.codfr = "sproftcn" and codfr.code = v-attn  no-lock no-error.
 if avail codfr then  displ codfr.name[1] with frame ink.
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
 "     по месту расположения: (" + trim(v-attn) + ") " format "x(35)" codfr.name[1] format "x(50)" skip(2)
 "  Комиссия в составе председателя :________________  " skip
 "  членов комиссии   :____________________________________________________________" skip(1)
 "  матер.ответственного лица   " skip(1)
 "  провела инвентаризацию основных средств на "  string(vdt)  
 "  и констатировала следующие остатки  : "skip(0)
  fill("=",132) format "x(132)" skip                                                            
 " Nr. |Карточки|                                |  Дата  |                    |      |                 |              |" skip
 " п/п |   Nr.  |           Название             |регистр.| Инвентарный номер  |Кол-во| Баланс.стоимость| Амортизация  |Примечание" skip                 
  fill("=",132) format "x(132)" skip .                                                                                

vtitle =
" ВЕДОМОСТЬ ИНВЕНТАРИЗАЦИИ ОС         НА : " + string (vdt) + "         ПО : (" + trim(v-attn) + ") " + codfr.name[1].

{report2.i 132                                              
"' Nr. |Карточки|                                |  Дата  |                    |      |                 |              |' skip
 ' п/п |   Nr.  |           Название             |регистр.| Инвентарный номер  |Кол-во| Баланс.стоимость| Амортизация  |Примечание' skip                 
  fill('=',132) format 'x(132)' skip "}                                                           

  For each ast where ast.attn = v-attn no-lock 
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
       vamt=ast.amt[1]. vamtp=vamtp + vamt. vamtg=vamtg + vamt.
       vamtk=vamtk + vamt.
     end.

/*  if first-of(ast.gl) then do:
*/
    if (vuzsg ne 0 or v-atlg ne 0 or vskg ne 0) and flg ne 1 then do:
     find gl where gl.gl eq ast.gl no-lock.
     put " Счет " ast.gl " " gl.des skip
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
                    vsk /* at 79 */ format "zzz9-"  
                    vuzs format "zzzzzz,zzz,zz9.99-"
                    vamt format "zzz,zzz,zz9.99-"
                   /* v-atl format "zzzzzzzzzz9.99-" */ skip
                   fill('-',132) format 'x(132)' skip.                                                           
              vuzs=0. v-atl=0. vsk=0. vamt=0.
    end.    
               
  if last-of(ast.fag) and (vuzsp ne 0 or v-atlp ne 0 or vskp ne 0) then do:
          
           put "Всего по гр." ast.fag format "x(4)". 
               find fagn where fagn.fag = ast.fag no-lock no-error.
               if avail fagn then put fagn.naim.                                    
                
                 put vskp at 79 format "zzz9-" 
                     vuzsp format "zzzzzz,zzz,zz9.99-"
                     vamtp format "zzz,zzz,zz9.99-"
                   /*  v-atlp format "zzzzzzzzzz9.99-"*/ skip.
                  put fill("-",132) format "x(132)" skip .                                                           
         
            vskp = 0.
            vuzsp = 0.   
            v-atlp =0.
            vamtp = 0.  flp=0.
  end.
    if last-of(ast.gl) and (vuzsg ne 0 or v-atlg ne 0 or vskg ne 0) then do:
          
          find gl where gl.gl=ast.gl no-lock.
                put  "Всего по сч." ast.gl gl.des  
                     vskg at 79 format "zzz9-" 
                     vuzsg format "zzzzzz,zzz,zz9.99-" 
                     vamtg format "zzz,zzz,zz9.99-"
                  /*   v-atlg format "zzzzzzzzzz9.99-" */ skip
                     fill("=",132) format "x(132)" skip .                                                           
          vskg = 0.
          vuzsg = 0.   
          v-atlg =0.
          vamtg = 0.  flg=0.
  end.
           
          
End.

put " ВСЕГО:"
     vskk at 79 format "zzz9-" 
     vuzsk format "zzzzzz,zzz,zz9.99-"  
     vamtk format "zzz,zzz,zz9.99-"
  /*   v-atlk format "zzzzzzzzzz9.99-" */ skip
     fill("=",132) format "x(132)" skip                                                            

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

