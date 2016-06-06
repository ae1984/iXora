/* pla-r.p
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
        26/12/03 nataly  изменено редактирование remtrz.detpay[2], pla.summ
        22.08.2006 u00124 оптимизация
*/

/*  pla-r.p
    26/07/00 - редактирование платежки
    07/11/01 - sasco - update by parts; look for trx params
*/

DEF SHARED VAR v-nmb LIKE pla.nmb.
def shared var g-ofc LIKE ofc.ofc.
def shared var g-today AS date.
def shared var vld AS CHAR.
DEF SHARED FRAME platr.
{platr.f}

define variable v-sub  as integer  no-undo.
define variable v-bn   as char     no-undo.
define variable v-bn1  as char     no-undo.
define variable isRmz  as log init no no-undo.
define variable rmzDet as char     no-undo.


FIND FIRST pla WHERE pla.who EQ g-ofc AND pla.lang EQ vld NO-ERROR.
IF vld EQ "l" THEN
DO:
   v-nmb = pla.nmb.
END.
ELSE
DO:
  VIEW FRAME platr.
  update pla.nmb pla.regdt pla.ma1  pla.rs1  with frame platr.
  if pla.rs1 ne "" then
  do:
     find fun where fun.fun = pla.rs1 no-lock no-error.
     if avail fun then 
     do:
         pla.summ = fun.amt + fun.cam[2].
         pla.kb4 = fun.bank.
         pla.sa1 = fun.cst.  /* Бенефициар совпадает со своим Банком */
         pla.ba2 = pla.sa1.  /* поэтому pla.sa1 = pla.ba1 */
         /* Проверим тип платежа: 6 - исходящий, 7 - входящий */
         find remtrz where remtrz.remtrz = fun.remout no-error.
         if avail remtrz then
         do:
            isRmz = yes.
            pla.ap[5] = remtrz.remtrz.
            pla.summ = remtrz.amt. /*26/12/03 nataly*/
            if remtrz.rcvinfo[1] <> "" then 
               pla.ap[5] = trim(remtrz.rcvinfo[5]).
            if remtrz.ptype = "6" or remtrz.ptype = "3" then
            do:
               v-sub = index(remtrz.bn[3],'/RNN/',1).
               v-bn = substr(remtrz.bn[3],(v-sub + 5),13). /* RNN */
               if v-sub = 0 then do:
                  v-sub = index(remtrz.bn[1],'/RNN/',1). 
                  if v-sub > 0 then do:
                     v-bn = substr(remtrz.bn[1],(v-sub + 5),13). /* RNN  */
                     v-bn1 = substr(remtrz.bn[1],1,(v-sub - 1)). /* name */
                  end.   
               end.
            end.
            else do:
              v-sub = index(remtrz.ord,'/RNN/',1).
              if v-sub > 0 then do:
                 v-bn = substr(remtrz.ord,(v-sub + 5),12). /* RNN */
                 v-bn1 = substr(remtrz.ord,1,(v-sub - 1)). /* client's name */
              end.
            end.
            pla.sa2 = v-bn. /* RNN */
         end.
      end.  
   end.

   update pla.ve format 'x(2)' pla.summ
          pla.ma2
          pla.ba1  
          pla.kb2   
          pla.code format 'x(5)'
          pla.sa1   
          pla.rs2  
          pla.me
          pla.sa2
          pla.ba2   
          pla.kb4
          pla.ba3
          pla.ap[1] pla.rs3
          pla.ap[2] pla.ap[3] pla.rs4
          pla.ap[4] pla.ap[5] pla.ba4
          WITH FRAME platr .

  if isRmz then do:
     /* назначение платежа */
     rmzDet = trim (pla.ap[1]) + trim (pla.ap[2]) + trim (pla.ap[3]) + trim (pla.ap[4]) + " " + trim (pla.ap[5]).
     remtrz.detpay[1] = "". /*remtrz.detpay[2] = "".*/ remtrz.detpay[3] = "". remtrz.detpay[4] = "".
     remtrz.detpay[1] = substr (rmzDet, 1, 35).
     remtrz.detpay[2] = remtrz.detpay[2] + substr (rmzDet, 36, 35).
     remtrz.detpay[3] = substr (rmzDet, 71, 35).
     remtrz.detpay[4] = substr (rmzDet, 106).

     /* РНН бенефициара - для исходящих платежей! */
     if remtrz.ptype = "6" or remtrz.ptype = "3" then remtrz.bn[3] = "/RNN/" + trim(pla.sa2).

     /* ЕКНП */
     find first sub-cod where sub-cod.sub = "rmz" and sub-cod.d-cod = "eknp" and sub-cod.acc = remtrz.remtrz no-error.
     if not avail sub-cod then create sub-cod.
     assign sub-cod.acc = remtrz.remtrz
            sub-cod.sub = "rmz"
            sub-cod.d-cod = "eknp"
            sub-cod.ccode = "eknp"
            sub-cod.rdt = g-today
            sub-cod.rcode = trim(pla.ve) + "," + trim(pla.me) + "," + trim(pla.rs3).
     /* счет бенефициара */
     remtrz.ba = trim(pla.rs2).
  end.
  pla.tim = TIME. 
  v-nmb = pla.nmb.
END.
PAUSE 0.
.
