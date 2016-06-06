/* subdic.p
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

/* h-quetyp.p */

  {global.i} 

/*
 {ps-prmt.i}    
*/

def var h as int .
def var i as int .
def var d as int .


 def input parameter v-sub like gl.sub .
/*
 def var  v-sub like gl.sub init "aaa" .
*/
 def var dicname as cha . 
 def new shared var v-d-cod like sub-dic.d-cod . 
def buffer b-sub for sub-dic . 
def var v-old as int init 0 . 
h = 13 .
d = 60.
do:
       {browpnp.i
        &h = "h"
        &form = " sub-dic.d-cod format 'x(10)' column-label 'Код' 
          dicname format 'x(50)' column-label 'Описание' " 
        &first = " 
         view frame frm . pause 0 . 
         find first sub-dic where sub-dic.sub = v-sub use-index dcod 
         no-lock no-error . 
         if not avail sub-dic then 
         do transact :
          create sub-dic . 
          sub-dic.sub = v-sub . 
          cur = recid(sub-dic).
          run adddic .
          if not keyfunction(lastkey) = 'end-error'  then
           do:
            find current sub-dic exclusive-lock no-error  .
                if avail sub-dic and sub-dic.d-cod = ''
            then delete sub-dic .
           end.
           else 
           do:
            for each sub-dic where sub-dic.d-cod eq '' .
             delete sub-dic . 
            end .
      find first b-sub where b-sub.sub = v-sub use-index dcod
                               no-lock no-error .
         if not avail b-sub then cur = 0 .
           end.
         end.
        form ' F9 - Добавить F10 - Удалить '          
        with no-label overlay centered row 21 no-box frame ddd .  
        " 
        &where = " sub-dic.sub = v-sub use-index dcod "
        &frame-phrase = "row 1 centered scroll 1 h down overlay 
         title  v-sub "
        &predelete = " "
        &predisp =
        " find first b-sub where b-sub.sub = v-sub use-index dcod
                 no-lock no-error . 
                 if not avail b-sub
                  then return .
         view frame ddd .   
         dicname = '' .  
         find first codific where codific.codfr = sub-dic.d-cod 
            no-lock   no-error. 
         if avail codific then dicname = codific.name . 
        v-old = cur . " 
        &seldisp = "sub-dic.d-cod"
        &file = "sub-dic"
        &disp = " sub-dic.d-cod dicname  "
        &poscreat = " sub-dic.sub = v-sub .  
           run adddic .
           if not keyfunction(lastkey) = 'end-error'  then 
           do:
            find current sub-dic exclusive-lock no-error  .
            if avail sub-dic and sub-dic.d-cod = '' 
             then do: delete sub-dic  . 
             cur = v-old .
             end. else cur = recid(sub-dic) .
           end. 
           " 
        &addupd = " "
        &postadd = "
            find first sub-dic where sub-dic.sub = v-sub
                     use-index dcod
                     no-lock no-error . 
         if avail sub-dic then cur = recid(sub-dic) .              
         leave . "
        &enderr = " for each sub-dic where sub-dic.d-cod eq '' . 
        delete sub-dic . end . " 
        &addcon = "true "
        &updcon = "false "
        &delcon = "true"
        &retcon = "false"
        &befret = "  "
        &action = " "
       }

end.
procedure adddic . 
          v-d-cod = sub-dic.d-cod  .
          run h-ccode1.
          if  v-d-cod ne '' then do:
           find first b-sub where b-sub.d-cod = v-d-cod 
           and b-sub.sub = v-sub use-index dcod
           no-lock no-error . 
           if avail b-sub and recid(b-sub) 
             ne recid(sub-dic) then 
           do :
            repeat : 
            Message " Справочник уже используется ". pause . 
            leave .
            end. 
           end.
           else 
           do:
           find current sub-dic exclusive-lock .
           sub-dic.d-cod = v-d-cod .
           find current sub-dic no-lock .
           end.
          end.
          return . 
end procedure .          
