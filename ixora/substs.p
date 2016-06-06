/* substs.p
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
  def input parameter v-acc like aaa.aaa . 
  def var yn as log init false . 
  /*
  def var v-acc like aaa.aaa init "1111111111" . 
  def var v-sub like gl.sub  init "jou" . 
  */
  def var v-tim as cha .
  def var v-name as cha format "x(30)".  
  
  h = 13 .
  d = 60.

    {browpnp.i
        &h = "h"
        &form = " substs.rdt column-label 'Дата' 
         v-tim  column-label 'Время ' 
         substs.sts column-label 'Стс'
         v-name format 'x(30)' column-label ' Описание ' 
         substs.who column-label 'Пользов'"
        &predisp = " 
           v-tim = string(substs.rtim, 'hh:mm:ss').
          find first stsdic where stsdic.sub = v-sub and 
              stsdic.sts = substs.sts no-lock no-error .
          if avail stsdic then v-name = stsdic.des.
          else v-name = ''.    
        " 
        &where = " substs.acc = v-acc and substs.sub = v-sub 
                   use-index substs "
        &frame-phrase = "row 1 centered scroll 1 h down overlay 
         title v-acc + ' ' + v-sub "
        &seldisp = " substs.rdt v-tim substs.sts v-name substs.who "
        &file =    " substs "
        &disp =    " substs.rdt v-tim substs.sts v-name substs.who"
        &addupd =  " "
        &postadd = " "
        &addcon = "false"
        &updcon = "false"
        &delcon = "false"
        &retcon = "false"
        &befret = " "
        &enderr = "hide frame frm."
       }
