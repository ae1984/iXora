/* astdel.p
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
        13/05/2004 madiar - добавил второй входной пар-р (true/false) в trxdel - показывать запрос причины удаления транзакции или нет.
        25.03.2005 saltanat - удаление занесла в одну транзакцию, внесла выход без отката при rcod=50.
        13.05.2005 saltanat - Внесла проставление старого статуса при передачи на акцепт.
*/

{global.i}
def input parameter vjh like jh.jh.
def input parameter vacc like ast.ast.
def input parameter vjdt like jl.jdt.
def output parameter r-kod as log init false.
/*
def input parameter vgl like jl.gl.
def input parameter vln like jl.ln.
def input parameter vjdt like jl.jdt.
def input parameter vdam like jl.dam.
def input parameter vcam like jl.cam.
def var stdt like jl.jdt.
def var stjh like jl.jh.
*/
def buffer b-astjln for astjln.
def var rcod as int.
def var rdes as char.
def var otv as log init false.
def var v-prstor as log init false.
def var v-sts like jh.sts.

 message " ОПЕРАЦИЮ  "  vjh  " УДАЛИТЬ ?" update otv format "Да/Нет" .
if  not otv then return.



Do TRANSACTION on error undo, return:

find jh where jh.jh = vjh no-error.
if avail jh then v-sts = jh.sts.
else v-sts = 0.

run trxsts(vjh,0,output rcod,output rdes).
run trxdel(vjh,true,output rcod,output rdes). 
if rcod ne 0 then do: 
   message " Error:" rcod  ":" rdes. pause.
   if rcod = 50 then do:
                     run trxstsdel(vjh,v-sts,output rcod,output rdes).
                     return. 
                end.     
   else undo,return.
end.


               /*do on error undo,return on endkey undo,return:*/
 
 message "УДАЛЕНИЕ ОПЕРАЦИИ  "  vjh  "  " .

 For each  astjln where astjln.ajdt=vjdt and astjln.ajh=vjh 
                 use-index dtajh exclusive-lock :

    if substring(astjln.atrx,2,1)="0" then v-prstor=true.
    find ast where ast.ast=astjln.aast exclusive-lock no-error.
                   ast.ofc=g-ofc.
                   ast.updt=g-today.
                   ast.icost=ast.dam[1] - ast.cam[1].

    if substring(astjln.apriz,1,1) = "A" then
              ast.amt[5]=ast.amt[5] - astjln.c[3] + astjln.d[3].

    ast.ydam[5]= ast.ydam[5] -  astjln.prdec[1]. /* 80 ? */

    if astjln.adc = "D"   then do:     
              ast.crline= ast.crline -  astjln.crline.

           if substring(astjln.apriz,1,1) ne "A" then
              ast.qty =ast.qty  - astjln.aqty.
    end.           
    else if astjln.adc="C"  then do:

              ast.crline= ast.crline +  astjln.crline.

           if substring(astjln.apriz,1,1) ne "A" then
              ast.qty =ast.qty  + astjln.aqty.
    end.
    
    
   if astjln.atrx="1" or astjln.atrx="3" or astjln.atrx="81" then do:
                   ast.amt[3]=ast.amt[3] - (astjln.d[1] - astjln.c[1] + /*vdam.*/
                                            astjln.d[3] - astjln.c[3]).
                                /* ast.amt[3]=ast.amt[3] - vdam. */
                   ast.meth=ast.meth - astjln.aqty.  
    end.
    else if astjln.atrx="10" or astjln.atrx="30" then do:
                   ast.amt[3]=ast.amt[3] + (astjln.d[1] - astjln.c[1] + /*vcam.*/
                                            astjln.d[3] - astjln.c[3]).
                   ast.meth=ast.meth + astjln.aqty.  
    end.
    

    if astjln.atrx="11" or astjln.atrx="31" or astjln.atrx="71" then do:
                   ast.meth=ast.meth - astjln.aqty.  
    end.
    else if astjln.atrx="9"  then do:
            ast.ldd=ast.cdt[1].
            if ast.cdt[1]<>? then do:
               ast.cdt[1]= if month(ast.cdt[1])=1 
                          then date(12,28,year(ast.cdt[1]) - 1) 
                          else date(month(ast.cdt[1]) - 1,28,year(ast.cdt[1])). 
              if ast.rdt >ast.cdt[1] then ast.cdt[1]=?.
            end.
    end.
    else if astjln.atrx="90" then do:
            ast.cdt[1]=ast.ldd.
               ast.ldd= if month(ast.cdt[1])=12 
                          then date(01,28,year(ast.cdt[1]) + 1) 
                          else date(month(ast.cdt[1]) + 1,28,year(ast.cdt[1])). 
    end.


   if substring(astjln.atrx,1,1) = "p"  then do:
             ast.ydam[4]=ast.ydam[4] - (astjln.d[1] - astjln.c[1]).
             ast.ycam[4]=ast.ycam[4] - (astjln.c[3] - astjln.d[3]).
   end.
   else do:

      ast.ydam[4]=ast.ydam[4] - astjln.c[4].
      ast.ycam[4]=ast.ycam[4] - astjln.d[4].
   end.

   if ast.qty<0 or ast.dam[1] - ast.cam[1]<0 then 
   do:  message "minus". pause 100.  end.


     find first astatl where astatl.agl=ast.gl and astatl.ast=ast.ast and
                astatl.dt=astjln.ajdt exclusive-lock no-error. 
             if not available astatl then create astatl. 
             astatl.ast=ast.ast.
             astatl.agl=ast.gl.
             astatl.fag=ast.fag.
             astatl.dt=g-today.
             astatl.icost=ast.dam[1] - ast.cam[1].
             astatl.nol  =ast.cam[3] - ast.dam[3].
             astatl.fatl[4] =ast.cam[4] - ast.dam[4].
             astatl.atl  =astatl.icost - astatl.nol.
             astatl.qty=ast.qty.
         if astatl.atl=0 and astatl.nol=0 and astatl.qty=0 then delete astatl.     
   delete astjln.
   r-kod=true.
 End.

     if v-prstor then do:
       find first b-astjln where  b-astjln.stjh=vjh   
            use-index dtajh exclusive-lock no-error.
       if avail b-astjln then do: b-astjln.stdt=?. b-astjln.stjh=0. end.
     end.                           

End. /* TRANSACTION */

if r-kod=false then do: undo,return. end.

     if /*ast.rdt=vjdt and*/ ast.dam[1]=0 and ast.cam[1]=0 then do:
             find fagn where fagn.fag=ast.fag exclusive-lock no-error.
             if ast.ast=string(ast.fag + string(fagn.pednr - 1, "99999")) then
             do:
               fagn.pednr= fagn.pednr - 1.
             end.
                 release fagn.
     end.
