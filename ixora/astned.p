/* astned.p
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

/* astned.p  */

{global.i}


{ddglob_def.i}
def  shared var s-astnal as int.
define shared var v-god like astnal.god.
def var v-otv as logical. 

def var vsele as cha form "x(18)" extent 2     
initial ["  Редактирование  ", "   Выход    "].

form vsele with frame vsele /*5 col*/ row 19 centered no-label overlay
     title "     Выбирите режим и нажмите <Enter>      " .

{astn.f}


mn:
Repeat on endkey undo,leave /*return */:
 
   
   find astnal where recid(astnal) = s-astnal .

   astnal.who = g-ofc. astnal.whn = g-today.   

   {astnal.i 1}
   displ astnal.whn astnal.who astnal.nrst astnal.grup astnal.dam4  
         astnal.ast astnal.amp astnal.amn astnal.ston astnal.sper 
         astnal.sieg astnal.sizs astnal.sbal astnal.snam astnal.sremk 
         astnal.srem10 astnal.sremos astnal.k astnal.l astnal.stok 
         astnal.damn2[1] astnal.damn3[1]
          WITH FRAME astn . 
  pause 0.
  display vsele with frame vsele.
  choose field vsele auto-return with frame vsele.
  hide frame vsele.
 

 if frame-value = "  Редактирование  " then 


   repeat :  
      {astnal.i 1}
      astnal.who = g-ofc. astnal.whn = g-today.   
    
      update astnal.nrst astnal.grup astnal.dam4 astnal.ast  
             astnal.amp astnal.amn  
              WITH FRAME astn .
   m1:
    repeat on endkey undo,next mn:
      {astnal.i 1}

      update astnal.ston  WITH FRAME astn .
      {astnal.i 1}
      
      update astnal.sper astnal.sieg astnal.damn2[1] astnal.sizs
              WITH FRAME astn .
      {astnal.i 1}
      leave.
     end.
        

    repeat on endkey undo,next mn:
      {astnal.i 1}
      update astnal.sremk astnal.damn3[1]  WITH FRAME astn. 
             
      astnal.srem10 = round(astnal.sbal * astnal.damn3[1] / 100,0).
      {astnal.i 1}

      update astnal.srem10 with frame astn. 
      {astnal.i 1}

     leave. 
    end.

    repeat on endkey undo,next mn:
      update astnal.k astnal.l   WITH FRAME astn .
      {astnal.i 1}

     leave. 
    end.

    leave.
 END. /*LaboЅana*/     

 else if frame-value = "   Выход    " then  leave.
    

end. /*repeat mn */
hide all no-pause.


