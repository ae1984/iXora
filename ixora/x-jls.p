/* x-jls.p
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
        24.11.09 marinav - увеличена форма
        12/07/2012 Luiza - добавила вывод переменной v-rmzdoc номер rmz документа
*/

def new shared var s-jh  like jh.jh.
def new shared var s-consol like jh.consol initial false.
def var i as int.
{mainhead.i}  /* GENERAL ENTRY - SINGLE */

def var vbal like jl.bal.
def var vdam like jl.dam.
def var vcam like jl.cam.
def var vop  as int format "z".
def var oldround as log.
{jhjl.f new}

main:
repeat: /* 1 */

  {x-jlcf.i} /* clearing frame */
  {x-jlvf.i} /* view frame */
  vop = 2.

   if vop = 2
        then do:
          {x-jlol.i}
          s-jh = jh.jh.
          v-rmzdoc = "".
          if available jh then do:
            find first joudop where joudop.docnum = jh.party no-lock no-error.
            if available joudop and lookup(joudop.type,"FR1,RF1") > 0 then if NUM-ENTRIES(joudop.doc1,"^") >= 1 then v-rmzdoc = entry(1,joudop.doc1,"^").
            if available joudop and lookup(joudop.type,"TN3,NT3") > 0 then if NUM-ENTRIES(joudop.lname,"^") > 9 then v-rmzdoc = entry(10,joudop.lname,"^").
            if available joudop and lookup(joudop.type,"TN4,NT4") > 0 then if NUM-ENTRIES(joudop.lname,"^") > 8 then v-rmzdoc = entry(9,joudop.lname,"^").
            if v-rmzdoc <> "" then displ v-rmzdoc with frame party.
          end.
       end.
      {x-jllis.i}
      run x-jlgens.
    end. /* 12 */
