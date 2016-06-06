/* r-astnum.p
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

{global.i}
define variable v-atl as dec .
define variable v-icost as dec .
define variable v-ast like ast.ast.
define variable v1-ast like ast.ast.
define variable v-gl like ast.gl.
define variable v-fag like ast.fag.
define variable vib as integer format "9".
form
     skip(1)
     "  НОВЫЙ Nr.карточки  :" v-ast at 26 format "x(8)" ast.name skip
     "     или       " skip
     "ИНВЕНТАРНЫЙ Nr.карт. :" v1-ast at 26 format "x(20)" skip(1) 
     "  ГРУППА ОС          :" v-fag at 26 format "x(3)" fagn.naim at 35 skip
     "  СЧЕТ   ОС          :" v-gl at 26  gl.des skip
  with row 8 frame am centered no-labels title "{1}".

 update v-ast validate(can-find(ast where ast.ast=v-ast) or v-ast="",
                       "Nr. КАРТ.НЕТ ") with frame am.
 if v-ast = "" then update v1-ast with frame am. 

 if v1-ast ne "" then do: 
     find ast where ast.addr[2]=v1-ast and ast.qty > 0 no-lock no-error.
     if avail ast then displ ast.ast @ v-ast ast.name ast.fag @ v-fag
        ast.gl @ v-gl with frame am.  
     else do: message v1-ast " номера  нет   ". v1-ast="". undo,retry. end.
 end.
 else
 if v-ast ne "" then do:
      find ast where ast.ast eq v-ast no-lock no-error.
      v-fag = ast.fag. v-gl = ast.gl. 
      find gl where gl.gl eq v-gl no-lock.
      find fagn where fagn.fag eq v-fag no-lock no-error.
      if avail fagn then displ fagn.naim with frame am.
      display ast.addr[2] @ v1-ast ast.name v-fag  v-gl gl.des with frame am.
      vib = 1.
 end.
 else do:
  update v-fag validate(can-find (fagn where fagn.fag = v-fag) or v-fag="", 
                          "Проверьте номер группы  ") with frame am. 
  if v-fag ne "" then do:
      find fagn where fagn.fag = v-fag no-lock.   
      v-gl = fagn.gl.
      find gl where gl.gl eq v-gl no-lock.
      display fagn.naim v-gl gl.des with frame am.
      vib=2.
  end.
  else do:
   update v-gl validate(can-find(gl where gl.gl=v-gl ) or v-gl=0,
                       " Проверьте счет  " ) with frame am.
   if v-gl ne 0 then do:
     find gl where gl.gl eq v-gl no-lock.
     display gl.des with frame am. 
     if gl.subled ne "ast" then do:
            message "Проверьте счет  ". pause 1. undo,retry.
     end.
    vib=3.
   end. 
   else vib=4.
  end.
 end.

pause 0.

{image1.i rpt.img}
{image2.i}
{report1.i 66}

vtitle= "  Номера карточек AST  " . 

{report2.i 104 
"'Счет   Nr.карт.  Стар.Nr.               Перв.стоим.      Ост.ст. Дата рег. Название' skip 
  fill('=',104) format 'x(104)' skip "}
if v1-ast ne "" then do:
For each ast where ast.addr[2]=v1-ast no-lock:
  put ast.gl ast.ast "     " ast.addr[2] ast.icost v-atl ast.qty ast.name skip. 
End.
end.
else do:
For each ast where (if vib=1 then ast.ast = v-ast 
              else (if vib=2 then ast.fag = v-fag                       
              else (if vib=3 then ast.gl  = v-gl
              else true))) no-lock break by ast.gl by ast.fag by ast.ast :
   v-icost = ast.dam[1] - ast.cam[1].
   v-atl = ast.dam[1] - ast.cam[1] + ast.dam[3] - ast.cam[3].
   put ast.gl " " ast.ast format "x(10)" ast.addr[2] format "x(20)" 
   v-icost format "zzzzzzzzz9.99-" v-atl format "zzzzzzzzz9.99-"
   ast.rdt " " ast.name format 'x(30)' skip. 
   if last-of(ast.fag) then put skip(1) .
   if last-of(ast.gl)  then put fill('=',104) format 'x(104)' skip.

end.  /*for */
end. /* do */
{report3.i}
{image3.i}

