/* astopr.p
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

def new global shared var vv-ast like ast.ast format "x(8)".
def new shared var v-ast like ast.ast format "x(8)".
def new shared var s-jh like jh.jh.
def var v-astn like ast.name.
def var v-atl as dec format "zzzzzz,zzz,zz9.99-".
def var v-icost as dec format "zzzzzz,zzz,zz9.99-".
def var v-nol as dec format "zzzzzz,zzz,zz9.99-".
def new shared var v-dt1 as date .
def new shared var v-dt2 as date .
def var flag as int.
def var v-gl3 like trxlevgl.glr.
def new shared var v-gl4 like trxlevgl.glr.
def var v-am like trxlevgl.glr.
def var v-gl like astjln.agl.
def var v-gl1 like astjln.agl.
def var r-kod as log.
{mainhead.i}
{astjln.f}
form
    " Период  с  " v-dt1  " по " v-dt2 " Nr.Карточки :" v-ast  skip                            
     with frame per row 4 overlay centered no-label
                 title "  В Ы Б Е Р И Т Е       ".
  form "   
  <Enter>-Просмотр, печать 1- История, 2- Сторно, 4- Удаление    "
       with overlay column 5 row 21 no-box color messages frame msgp.
/*form "<Enter>- Гл.журнал (Печать, Акцепт, Удаление) 1- История 2- Сторно "
       with overlay column 5 row 21 no-box color messages frame msgp.
*/

form
   
       astjln.d[1] format "zzzzzz,zzz,zz9.99"      
        astjln.c[1] format "zzzzzz,zzz,zz9.99"  
       astjln.d[3] format "zzzzzz,zzz,zz9.99" 
       astjln.c[3] format "zzzzzz,zzz,zz9.99" 
            WITH FRAME astjln3 row 18
title "           DR      " + string(v-gl) + "      CR        " +
      "       DR    " + string(v-gl3) + "     CR     "
              centered scroll 1 1 down overlay no-labels.



v-dt1 = g-today.
v-dt2 = g-today.


repeat on endkey undo,return:
update v-dt1 v-dt2 v-ast with frame per.
 find ast where ast.ast=v-ast no-lock no-error.
  if not avail ast and v-ast ne "" then undo,retry.
  if v-ast="" then v-astn=" Операции с ОС ".
              else v-astn= " " + ast.name + " ".
leave.
end.

main:
repeat:
view frame msgp.

{jabrw.i
&head = "astjln"
&headkey = "aast"
&index = "dtajh" 
&where = "astjln.ajdt<=v-dt2 and astjln.ajdt>=v-dt1 and 
          (If v-ast ne '' then astjln.aast=v-ast else true)"
&formname = "astjln1"
&framename = "astjln1"
&addcon = "false"
&prechoose = " find trxlevgl where trxlevgl.gl = astjln.agl and 
               trxlevgl.lev = 3 no-lock no-error.
          if available trxlevgl then v-gl3 = trxlevgl.glr. else v-gl3=0. 
          find trxlevgl where trxlevgl.gl=astjln.agl and trxlevgl.lev = 4 no-lock no-error.
          if available trxlevgl then v-gl4=trxlevgl.glr. else v-gl4=0. 
          v-gl=astjln.agl. pause 0.
          displ  astjln.d[1] astjln.c[1] astjln.d[3] astjln.c[3]       
                     with frame astjln3. pause 0. "   
&deletecon ="false"
&start = " "
&highlight = "astjln.aast astjln.ajdt astjln.apriz  astjln.aqty astjln.ajh"
&display = "astjln.aast astjln.ajdt  astjln.apriz astjln.aqty astjln.ajh 
            astjln.arem[1] astjln.atrx" 
&postdisplay = " "
&postkey = "else if keyfunction(lastkey) = '1' then do  /*transaction*/ /* 49 */ 
             on endkey undo,next:
             find ast where ast.ast=astjln.aast no-lock no-error.
             v-atl=ast.dam[1] - ast.cam[1] + ast.dam[3] - ast.cam[3].
             v-icost = ast.dam[1] - ast.cam[1].
             v-nol = ast.cam[3] - ast.dam[3]. 
             v-gl1 = astjln.agl. 
             v-am =v-gl3.
    displ   v-gl1 astjln.agl ast.rdt  v-atl v-am v-icost v-nol v-gl3 v-gl4
            ast.qty astjln.ajdt g-today
            astjln.awho astjln.c[1] astjln.d[1] astjln.d[3] astjln.c[3]
            astjln.d[4] astjln.c[4] astjln.aqty astjln.ajh astjln.arem[1] 
            astjln.arem[2] astjln.korgl astjln.koracc astjln.kpriz astjln.atrx 
            astjln.stdt astjln.stjh /* astjln.crline  astjln.prdec[1] */
            with frame astjln. 
            hide frame astjln .
            view frame msgp.  
      end.         
      else if keyfunction(lastkey) = '2' then do on endkey undo,leave: /* 50 */
             s-jh=astjln.ajh. vv-ast=astjln.aast.
        if astjln.stjh<=0 then run aststr.
        else do: message 'Операция сторнирована'. pause 5. end.
        find first astjln where astjln.ajh=s-jh no-lock.
        displ astjln.aast astjln.ajdt  astjln.apriz astjln.aqty astjln.ajh
              astjln.arem[1] astjln.atrx with frame astjln1.
        view frame msgp.
        next upper. 
        end.
        else if keyfunction(lastkey) = '4' then 
        do on endkey undo, leave:  /* Enter */
          s-jh=astjln.ajh. vv-ast=astjln.aast.
          if astjln.stjh>0 then  do: message 'Операция сторнирована'. pause 5.
           next upper.
          end.
          find jh where jh.jh=s-jh no-lock  no-error.
          if available jh then do: 
           find first jl where jl.jh=s-jh no-lock no-error.
            if available jl then do transaction:
            run astdel(s-jh,vv-ast,jl.jdt,output r-kod).
            end.    
          end.    
           find first jl where jl.jh=s-jh no-lock no-error.
            if not available jl then do:
              message ' ОПЕРАЦИЯ  '  s-jh  ' УДАЛЕНА !'. pause 5.
             end.
         if clin = 1 then clin = 0.
         next upper. 
        end.
        else if keyfunction(lastkey) = 'return' then 
                    do on endkey undo, leave:  /* Enter */
             s-jh=astjln.ajh. vv-ast=astjln.aast.
          find jh where jh.jh=s-jh no-lock  no-error.
          if available jh then do: 
           find first jl where jl.jh=s-jh no-error.
            if available jl then do:
             run ast-jlvouR.   /* run asts-jls(s-jh,vv-ast).*/
            end.    
          end.    
        find first astjln where astjln.ajh=s-jh no-lock.
        displ astjln.aast astjln.ajdt  astjln.apriz astjln.aqty astjln.ajh
              astjln.arem[1] astjln.atrx with frame astjln1.
        view frame msgp.  
      end."
&postadd = " "
&end = "leave main."
}
end.
/***********************************************
{jabra.i
&head = "astjln"
&headkey = "aast"
&index = "dtajh" 
&where = "astjln.ajdt<=v-dt2 and astjln.ajdt>=v-dt1 and 
          (If v-ast ne '' then astjln.aast=v-ast else true)"
&formname = "astjln1"
&framename = "astjln1"
&addcon = "false"
&deletecon ="false"
&start = " "
&highlight = "astjln.aast astjln.ajdt astjln.aamt astjln.adc  astjln.apriz
              astjln.aqty astjln.ajh"
&display = "astjln.aast astjln.ajdt astjln.aamt astjln.adc  astjln.apriz
            astjln.aqty astjln.ajh astjln.arem[1] astjln.atrx" 
&postdisplay = " "
&postkey = "else if keyfunction(lastkey) = '1' then do  /*transaction*/ /* 49 */ 
            on endkey undo,next:
             find ast where ast.ast=astjln.aast no-lock no-error.
             v-atl=ast.dam[1] - ast.cam[1].
    displ   astjln.agl ast.rdt  v-atl ast.qty astjln.ajdt g-today
            astjln.awho  astjln.apriz astjln.cam astjln.dam
            astjln.aqty astjln.ajh astjln.arem[1] astjln.arem[2]
            astjln.korgl astjln.koracc astjln.kpriz astjln.atrx 
            astjln.stdt astjln.stjh astjln.icost astjln.crline  
            astjln.prdec[1]
            with frame astjln. 
            hide frame astjln .
            view frame msgp.  
         next upper.
      end.         

      else if keyfunction(lastkey) = '2' then do on endkey undo,leave: /* 50 */
          
             s-jh=astjln.ajh. vv-ast=astjln.aast.

        if astjln.stjh<=0 then run aststr.
        else do: message 'Операция сторнирована'. pause 5. end.
        next upper. 
        end.

        else if keyfunction(lastkey) = 'return' then 
                    do on endkey undo, leave:  /* Enter */
             s-jh=astjln.ajh. vv-ast=astjln.aast.

          find jh where jh.jh=s-jh no-lock  no-error.
          if available jh then do: 
           find first jl where jl.jh=s-jh no-error.
            if available jl then do:
               run asts-jls(s-jh,vv-ast).
            end.    
          end.    
         if clin = 1 then clin = 0.
         next upper. 
        end."
&postadd = " "
&end = "leave main."
}
*****************************************************/
 

  
