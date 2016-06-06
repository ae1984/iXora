/* astvib.i
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
        29.04.10 marinav - убран выбор филиала
*/

form skip(1)
     " ЗА ПЕРИОД         С :" vmc1 at 26 "  ПО :" vmc2 skip 
     " Nr. КАРТОЧКИ        :" v-ast at 26 format "x(8)" ast.name skip
     " ГРУППА ОСН.СРЕДСТВ  :" v-fag at 26 format "x(3)" fagn.naim at 35 skip
     " СЧЕТ ОСН.СРЕДСТВ    :" v-gl at 26  gl.des skip
     with row 8 frame amort centered no-labels title "{1}".

 vmc2=g-today. 
 Update  vmc1 validate(vmc1 ne ? and vmc1 <= g-today, "") with frame amort 1 down.
 update  vmc2 validate(vmc2 ne ? and vmc2 <= g-today and vmc2 >= vmc1, "") with frame amort 1 down.

 update v-ast validate(can-find(ast where ast.ast=v-ast) or v-ast="", "КАРТ. НЕТ ") with frame amort.
 if v-ast ne "" then do:
      find ast where ast.ast eq v-ast no-lock no-error.
      v-fag = ast.fag. v-gl = ast.gl. 
      find gl where gl.gl eq v-gl no-lock.
      find fagn where fagn.fag eq v-fag no-lock no-error.
      if avail fagn then displ fagn.naim with frame amort.
      display ast.name v-fag  v-gl gl.des with frame amort.
      vib = 1.
 end.
 else do:
  update v-fag validate(can-find (fagn where fagn.fag = v-fag) or v-fag="", "ГРУППЫ НЕТ ") with frame amort. 
  if v-fag ne "" then do:
      find fagn where fagn.fag = v-fag no-lock.   
      v-gl = fagn.gl.
      find gl where gl.gl eq v-gl no-lock.
      display fagn.naim v-gl gl.des with frame amort.
      vib=2.
  end.
  else do:
   update v-gl validate(can-find(gl where gl.gl=v-gl ) or v-gl=0, " СЧЕТА НЕТ ") with frame amort.
   if v-gl ne 0 then do:
     find gl where gl.gl eq v-gl no-lock.
     display gl.des with frame amort. 
     if gl.subled ne "ast" then do:
            message "ПРОВЕРЬТЕ СЧЕТ  ". pause 1. undo,retry.
     end.
    vib=3.
   end. 
   else vib=4.
  end.
 end.

 pause 0.
