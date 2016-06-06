/* pla-j.p
 * MODULE
        Название Программного Модуля
        Платежная система
 * DESCRIPTION
        Назначение программы, описание процедур и функций
        создание новой платежки
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
        30.06.2000 pragma
 * CHANGES
        05.11.2001, sasco: ve=me="14", ba4=date, kb4 = bank`s MFO sa1 = ba1 = benef.bank
        26/12/03 nataly  изменено редактирование remtrz.detpay[2], pla.summ
        05/09/06 u00121  добавил no-undo
*/

DEF SHARED VAR v-nmb LIKE pla.nmb.
DEF SHARED VAR vld AS CHAR.
DEF SHARED FRAME platr.
DEF SHARED VAR g-ofc LIKE ofc.ofc.
DEF SHARED VAR g-today AS DATE.

define variable v-sub as integer no-undo.
define variable v-bn as char no-undo.
define variable v-bn1 as char no-undo.
define var isRmz as log init no no-undo.
define var rmzDet as char no-undo.

{platr.f}
FIND FIRST cmp NO-LOCK.
FIND FIRST point NO-LOCK.
FIND FIRST sysc WHERE sysc.sysc EQ "CLECOD" NO-LOCK.

FIND FIRST pla WHERE pla.who EQ g-ofc AND pla.lang EQ vld EXCLUSIVE-LOCK.
assign    
	pla.nmb = "0001"
	pla.regdt = g-today
	pla.who = g-ofc
	pla.tim = TIME
	pla.ma1 = cmp.name
	pla.ma2 = point.regno
	pla.ba1 = cmp.name
	pla.ba2 = ""
	pla.kb2 = sysc.chval
	pla.code = "тенге"
	pla.rs2 = ""
	pla.summ = 0
	pla.sa1 = ""
	pla.sa2 = ""
	pla.ba3 = ""
	pla.ba4 = string(pla.regdt)
	pla.kb4 = ""
	pla.rs1 = ""
	pla.rs3 = ""
	pla.rs4 = ""
	pla.ve  = "14"
	pla.me  = "14"
	pla.ap  = "".

IF vld = "l" THEN
DO:
  VIEW FRAME plat.
     DISP pla.nmb pla.regdt
          pla.ma1  pla.rs1  pla.ve format 'x(2)' pla.summ
          pla.ma2
          pla.ba1  pla.kb2   pla.code format 'x(5)'
          pla.sa1   pla.rs2  pla.me
          pla.sa2
          pla.ba2   pla.kb4
          pla.ba3
          pla.ap[1] pla.rs3
          pla.ap[2] pla.ap[3] pla.rs4
          pla.ap[4] pla.ap[5] pla.ba4
          WITH FRAME plat .
  PAUSE 0.

   update pla.nmb pla.regdt
          pla.ma1  pla.rs1
          pla.ve format 'x(2)' pla.summ
          pla.ma2
          pla.ba1  pla.kb2   pla.code format 'x(5)'
          pla.sa1   pla.rs2  pla.me
          pla.sa2
          pla.ba2   pla.kb4
          pla.ba3
          pla.ap[1] pla.rs3
          pla.ap[2] pla.ap[3] pla.rs4
          pla.ap[4] pla.ap[5] pla.ba4
          WITH FRAME plat .
  pla.tim = TIME. 
  v-nmb = pla.nmb.
  PAUSE 0.
END.
ELSE
DO:

  VIEW FRAME platr.
  DISP pla.nmb pla.regdt
       pla.ma1  pla.rs1  pla.ve format 'x(2)' pla.summ
       pla.ma2
       pla.ba1  pla.kb2   pla.code format 'x(5)'
       pla.sa1   pla.rs2  pla.me
       pla.sa2
       pla.ba2   pla.kb4
       pla.ba3
       pla.ap[1] pla.rs3
       pla.ap[2] pla.ap[3] pla.rs4
       pla.ap[4] pla.ap[5] pla.ba4
       WITH FRAME platr .
  PAUSE 0.

  update pla.nmb pla.regdt
          pla.ma1  pla.rs1  with frame platr.

/* 5.11.2001, sasco - search for deals */
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
                   /* incoming */
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
                   /* outgoing */
                   v-sub = index(remtrz.ord,'/RNN/',1).
      
                   if v-sub > 0 then do:
                   v-bn = substr(remtrz.ord,(v-sub + 5),12). /* RNN */
                   v-bn1 = substr(remtrz.ord,1,(v-sub - 1)). /* client's name */
                   end.
                end.

                pla.sa2 = v-bn. /* RNN */
                end. /*avail remtrz*/
      end.  
   end.

   update        
          pla.ve format 'x(2)' pla.summ
          pla.ma2
          pla.ba1  pla.kb2   pla.code format 'x(5)'
          pla.sa1   pla.rs2  pla.me
          pla.sa2
          pla.ba2   pla.kb4
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
     remtrz.detpay[2] = remtrz.detpay[2] +  substr (rmzDet, 36, 35).
     remtrz.detpay[3] = substr (rmzDet, 71, 35).
     remtrz.detpay[4] = substr (rmzDet, 106).

     /* РНН бенефициара - для исходящих платежей! */
     if remtrz.ptype = "6" or remtrz.ptype = "3" then remtrz.bn[3] = "/RNN/" + trim(pla.sa2).

     /* ЕКНП */
     find first sub-cod where sub-cod.sub = "rmz" and 
                              sub-cod.d-cod = "eknp" and
                              sub-cod.acc = remtrz.remtrz
                              no-error.
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
  PAUSE 0.

END.

