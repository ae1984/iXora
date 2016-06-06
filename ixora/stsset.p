/* stsset.p
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
 def var  v-sub like gl.sub init "jou" .
*/
def buffer b-sub for stsdic . 
def var v-old as int init 0 . 
h = 13 .
d = 60.
do:
       {browpnp.i
        &h = "h"
        &form = " stsdic.sts format 'x(3)' column-label 'Статус' 
          stsdic.des format 'x(50)' column-label 'Описание' " 
        &first = " 
         view frame frm . pause 0 . 
         form ' F9 - Добавить F10 - Удалить '          
        with no-label overlay centered row 21 no-box frame ddd .  
        view frame ddd . 
        " 
        &where = " stsdic.sub = v-sub use-index sbst "
        &frame-phrase = " row 1 centered scroll 1 h down overlay 
                          title v-sub "
        &predelete = 
              " find first b-sub  
                where b-sub.sub = v-sub use-index sbst no-lock no-error. 
                if not avail b-sub then leave. " 
        &predisp = " view frame ddd . "  
        &seldisp = "stsdic.sts "
        &file = "stsdic"
        &disp = " stsdic.sts stsdic.des "
        &poscreat = " stsdic.sub = v-sub ." 
        &addupd = " stsdic.sts stsdic.des "
        &postadd = " if avail stsdic then  
                     cur = recid(stsdic). else cur = 0 .   
                     leave .  " 
        &upd = " stsdic.sts stsdic.des " 
        &enderr = " " 
        &addcon = "true "
        &updcon = "true "
        &delcon = "true"
        &retcon = "false"
        &befret = " "
        &action = " "
       }

end.
