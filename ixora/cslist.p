/* cslist.p
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
 * BASES
        BANK COMM
 * AUTHOR
        18.02.2012 k.gitalov
 * CHANGES
        09.11.2012 k.gitalov Перекомпиляция

*/

{global.i}


def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).
/***********************************************************************************************************/

def var rez as log.

/***********************************************************************************************************/
procedure ShowData:

     DEF input param  cs-name AS char.
     def var v-txb as char format "x(5)" init "TXB00".
     def var Nomer AS character FORMAT "x(7)".
     def var Des AS character FORMAT "x(40)".
     def var Ip AS character FORMAT "x(30)".
     def var Dep-id as int format ">9".
     def var Work1 AS character FORMAT "x(25)".
     def var Work2 AS character FORMAT "x(25)".
     def var ListBank as char format "x(40)".
    /* def var CheckCash AS LOGICAL INITIAL no VIEW-AS TOGGLE-BOX NO-UNDO.*/
     def buffer b-cslist for comm.cslist.

     DEFINE BUTTON save-button LABEL "Сохранить".
     DEFINE BUTTON cancel-button LABEL "Отмена".

     DEFINE QUERY q-sp FOR ppoint.
     DEFINE BROWSE b-sp QUERY q-sp
       DISPLAY ppoint.dep label "Номер  " format "99" ppoint.name label "Наименование   " format "x(59)"
       WITH  10 DOWN.
     DEFINE FRAME f-sp b-sp  WITH   column 20 row 8 TITLE "ВЫБЕРИТЕ СП" width 75 .

     define frame Form1
     ListBank   no-label /*"Филиал банка    " */ v-txb label "Код" skip
     Nomer      label "Номер ЭК        " skip
     Dep-id     label "Департамент"  ":" Des no-label    skip
     Ip         label "IP адрес ЭК     " skip
     Work1      label "Рабочее место №1"  "Левая cторона" skip
     Work2      label "Рабочее место №2"  "Правая cторона" skip
    /* space(16)  CheckCash  LABEL "Предварительный пересчет" skip*/

     "----------------------------------------------------------" skip
     space(18) save-button  cancel-button
     WITH SIDE-LABELS centered row 10 TITLE "Данные ЭК".


     find first b-cslist where b-cslist.nomer = cs-name no-lock no-error.
     if avail b-cslist then do:
       Dep-id = integer(b-cslist.info[1]).
       v-txb = b-cslist.bank.
       Nomer  = b-cslist.nomer.
       Des = b-cslist.des.
       Ip = b-cslist.ip.
       Work1 = b-cslist.work[1].
       Work2 = b-cslist.work[2].
      /* CheckCash = logical(b-cslist.info[2]).*/
     end.

     find first cmp no-lock no-error.
     if avail cmp then ListBank = cmp.name.

     Nomer  = cs-name.
     v-txb = s-ourbank.

     on help of Dep-id in frame Form1 do:
        ON END-ERROR OF b-sp in frame f-sp
        DO:
          apply "endkey" to frame f-sp.
          hide frame f-sp.
        END.
        OPEN QUERY  q-sp FOR EACH ppoint no-lock.
        ENABLE ALL WITH FRAME f-sp.
         wait-for return , endkey of frame f-sp
        FOCUS b-sp IN FRAME f-sp.
        Dep-id = ppoint.dep.
        Des = ppoint.name.
        hide frame f-sp.
        display  ListBank v-txb Nomer Dep-id Des Ip Work1 Work2 /*CheckCash */ with frame Form1.
     end.

     ON CHOOSE OF save-button
     DO:
       find first b-cslist where b-cslist.nomer = cs-name exclusive-lock no-error.
       if avail b-cslist then do:
        b-cslist.info[1] =  Dep-id:SCREEN-VALUE.
       /* b-cslist.bank = v-txb:SCREEN-VALUE.
        b-cslist.nomer = Nomer:SCREEN-VALUE.*/
        b-cslist.des = Des:SCREEN-VALUE.
        b-cslist.ip = Ip:SCREEN-VALUE.
        b-cslist.work[1] = Work1:SCREEN-VALUE.
        b-cslist.work[2] = Work2:SCREEN-VALUE.
        b-cslist.who = g-ofc.
        b-cslist.whn = g-today.
       /* b-cslist.side[1] = "new".
        b-cslist.side[2] = "new".*/
       /* b-cslist.info[2] = string(CheckCash:SCREEN-VALUE).*/
       end.
       else do:
        create cslist.
        cslist.info[1] =  Dep-id:SCREEN-VALUE.
        cslist.bank = v-txb:SCREEN-VALUE.
        cslist.nomer = Nomer:SCREEN-VALUE.
        cslist.des = Des:SCREEN-VALUE.
        cslist.ip = Ip:SCREEN-VALUE.
        cslist.work[1] = Work1:SCREEN-VALUE.
        cslist.work[2] = Work2:SCREEN-VALUE.
        cslist.who = g-ofc.
        cslist.whn = g-today.
        cslist.side[1] = "new".
        cslist.side[2] = "new".
       /* cslist.info[2] = string(CheckCash:SCREEN-VALUE).*/
       end.

        find first b-cslist where b-cslist.nomer = cs-name no-lock no-error.
        find first codfr where codfr.codfr = 'arptype' and codfr.code = cslist.nomer and codfr.level = 1 and codfr.child = no exclusive-lock no-error.
        if avail codfr then delete codfr.
        create codfr.
        assign codfr.codfr = 'arptype' codfr.code = cslist.nomer codfr.level = 1 codfr.child = no codfr.name[1] = "ЭК " + cslist.des .

       apply "endkey" to frame Form1.
     END.
     ON CHOOSE OF cancel-button
     DO:
        apply "endkey" to frame Form1.
     END.


    enable   Dep-id Des Ip Work1 Work2 /*CheckCash*/ save-button cancel-button with frame Form1.
    display  ListBank v-txb Nomer Dep-id Des Ip Work1 Work2 /*CheckCash*/   with frame Form1.

    WAIT-FOR endkey of frame Form1.
    hide frame Form1.


end procedure.
/***********************************************************************************************************/

   define query q_list for comm.cslist.
   define browse b_list query q_list no-lock
   display comm.cslist.nomer label "ЭК" comm.cslist.des format "x(40)" label "Описание" comm.cslist.bank label "Код филиала"
   with 15 down centered overlay  NO-ASSIGN SEPARATORS no-row-markers.

   define frame f1
   b_list skip space(10) "<INS>-Создать,  <DEL>-Удалить,  <F4> Выход"
   WITH SIDE-LABELS centered  row 5 WIDTH 70 title "Список Электронных кассиров".

    /******************************************************************************/
    on return of b_list in frame f1  /*Редактировать ЭК*/
    do:
     def var Pos as int.
     Pos = b_list:focused-row.
     find current comm.cslist no-lock no-error.
     if avail comm.cslist then run ShowData(comm.cslist.nomer).
     b_list:SELECT-ROW(Pos).
     display  b_list WITH  FRAME f1.
    end.
    /******************************************************************************/
    ON DELETE-CHARACTER OF b_list in frame f1 /*Удалить ЭК*/
    DO:
      def var Pos as int.
      Pos = b_list:focused-row.
      find current comm.cslist no-lock no-error.
      if not avail comm.cslist then return.
      run yn("","Удалить ЭК " + comm.cslist.nomer + "?","","", output rez).
      if rez then
      do:
       find current comm.cslist exclusive-lock.
       delete comm.cslist.
       open query q_list for each comm.cslist By comm.cslist.nomer .
      end.
      else do:
       b_list:SELECT-ROW(Pos).
      end.
    END.
    /******************************************************************************/
    ON INSERT-MODE OF b_list in frame f1 /*Добавить ЭК*/
    DO:
      rez = false.
      run yn("","Создать запись для нового ЭК ?","","", output rez).
      if rez then
      do:
        def var newnom as int.
        newnom = 0.
        for each comm.cslist no-lock.
           newnom = newnom + 1.
        end.
        newnom = newnom + 1.
        run ShowData(string(newnom,"CASH999")).
        open query q_list for each comm.cslist where comm.cslist.bank = s-ourbank By comm.cslist.nomer .
      end.
    END.
    /******************************************************************************/
    ON END-ERROR OF b_list in frame f1
    DO:
      apply "endkey" to frame f1.
      hide frame f1.
    END.
    /******************************************************************************/

    open query q_list for each comm.cslist where comm.cslist.bank = s-ourbank By comm.cslist.nomer .
    enable  b_list with frame f1.
    WAIT-FOR endkey /*, INSERT-MODE*/ of frame f1.
    hide frame f1.
/***********************************************************************************************************/
