/* budlistp.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        бюджетные позиции фильтр по подраздел ввода плана
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
        14/07/2012 Luiza
 * CHANGES
            24/07/2012 Luiza - вывод суммы плана
*/


{comm-txb.i}
{yes-no.i}

def var flastgrp as int .
def var flastls as int.
def shared var v-year   as int.
def var fv-gl as int.
def var fvv-gl as int.
def var fv-des as char.
def var fv-name as char.
def var fvv-name as char.
def var fv-coder as char.
def var fvv-coder as char.
def var fv-depname as char.
def var fv-txbname as char.
def shared var v-txbname as char.
def shared var v-txb as char.
def var fv-txb as char.
def var fvv-txb as char.
def var fv-dep as char.
def var fv-access as int.
def var fPos as int.
def var fv-id    as int.
def var fnewnom as int.
def shared var v-month as int.
def var fv-month as int.
def var fv-mon as int.
def shared var v-monthname as char.
def var fv-monthname as char.
def var fv-txt as char.
def var fv-con as char.
def var fv-ret as char init "1".
def var frez as log.
def var fpoz as int.
def var fv-ttt as char.
def var fs-plan as decim.
def var fs-fact as decim.
def var fs-budget as decim.
def var fs-overdraft as decim.

def var i as int init 1.
/************************************************/
def var v-plan  as decimal extent 12 format "->>>>>>>>>9.99".
def var v-fact  as decimal extent 12 format "->>>>>>>>>9.99".
def var v-budget  as decimal extent 12 format "->>>>>>>>>9.99".
def var v-overdraft  as decimal extent 12 format "->>>>>>>>>9".

/*************************************************************/
def var v-planold  as decimal extent 12 format "->>>>>>>>>9.99".
def var v-factold  as decimal extent 12 format "->>>>>>>>>9.99".
def var v-budgetold  as decimal extent 12 format "->>>>>>>>>9.99".
def var v-overdraftold  as decimal extent 12 format "->>>>>>>>>9".


DEFINE QUERY fq-gl FOR gl.

DEFINE BROWSE fb-gl QUERY fq-gl
    DISPLAY gl.gl label "Счет " format "999999" gl.des label "Наименование   " format "x(60)"
    WITH  15 DOWN.
DEFINE FRAME ff-gl fb-gl  WITH overlay 1 COLUMN SIDE-LABELS row 5 COLUMN 25 width 85 NO-BOX.

DEFINE QUERY fq-code FOR cods.
DEFINE BROWSE fb-code QUERY fq-code
    DISPLAY cods.code label "Код расхода " format "x(7)" cods.des label "Наименование   " format "x(55)" cods.gl  label "Счет ГЛ"
    WITH  15 DOWN.
DEFINE FRAME ff-code fb-code  WITH overlay 1 COLUMN SIDE-LABELS row 7 COLUMN 25 width 85 NO-BOX.

/************************************************************************************************************/

define temp-table ft-gl no-undo
field gl as int
field des as char
field depname as char
field txbname as char
field plan as decim
field fact as decim
field budget as decim
field overdraft as decim
index ind is primary  gl.

DECLARE g2 CURSOR FOR
select budget.gl, budget.des, budget.remark[3],sum(budget.plan[v-month]),sum(budget.fact[v-month]),sum(budget.fact[v-month]),sum(budget.overdraft[v-month])
from budget where budget.year =  v-year and budget.remark[3] = v-txb and substring(budget.coder,8,5) <> "TXB00" group by budget.gl.
open g2.
repeat:
    FETCH g2 INTO fv-gl,fv-des,fvv-txb,fs-plan,fs-fact,fs-budget,fs-overdraft.
    create ft-gl.
    ft-gl.gl = fv-gl.
    ft-gl.des = fv-des.
    ft-gl.txbname = fvv-txb.
    ft-gl.plan = fs-plan.
    ft-gl.fact = fs-fact.
    ft-gl.budget = fs-budget.
    ft-gl.overdraft = fs-overdraft.
end.
close g2.

    define temp-table ft-month no-undo
    field num as int
    field month as char.
    create ft-month.
    ft-month.num = 1.
    ft-month.month = "Январь".
    create ft-month.
    ft-month.num = 2.
    ft-month.month = "Февраль".
    create ft-month.
    ft-month.num = 3.
    ft-month.month = "Март".
    create ft-month.
    ft-month.num = 4.
    ft-month.month = "Апрель".
    create ft-month.
    ft-month.num = 5.
    ft-month.month = "Май".
    create ft-month.
    ft-month.num = 6.
    ft-month.month = "Июнь".
    create ft-month.
    ft-month.num = 7.
    ft-month.month = "Июль".
    create ft-month.
    ft-month.num = 8.
    ft-month.month = "Август".
    create ft-month.
    ft-month.num = 9.
    ft-month.month = "Сентябрь".
    create ft-month.
    ft-month.num = 10.
    ft-month.month = "Октябрь".
    create ft-month.
    ft-month.num = 11.
    ft-month.month = "Ноябрь".
    create ft-month.
    ft-month.num = 12.
    ft-month.month = "Декабрь".

   DEFINE QUERY fq-month FOR ft-month.

    DEFINE BROWSE fb-month QUERY fq-month
        DISPLAY ft-month.month no-label format "x(10)" WITH  12 DOWN.
    DEFINE FRAME ff-month fb-month  WITH overlay row 5 COLUMN 25 width 25 title "Выберите месяц".


/***********************************************************************************************************/

def var help_l3 as char init "<TAB>-др.окно, <ENTER>-редактировать, <INS>-создать, <DEL>-удалить " label "" format "x(90)".

def var help_g3 as char init "<TAB>-др.окно, <СТРЕЛКА ВПРАВО>-обновить список, <F1>-Расчет, <DEL>-удалить " label "" format "x(90)".

def shared var g-today as date.
def shared var g-ofc as char.

def var cnt as int.

DEFINE FRAME fopt
    fv-gl label " введите счет " format ">>>>>9"
with overlay row 10 column 15 side-label.
on "END-ERROR" of frame fopt do:
  hide frame fopt no-pause.
end.
DEFINE FRAME fopt1
    fv-txb label " введите наименование филиала " format "x(15)"
with overlay row 10 column 15 side-label.
on "END-ERROR" of frame fopt1 do:
  hide frame fopt1 no-pause.
end.


def query  fq1 for ft-gl.
def browse fb1 query fq1
           displ ft-gl.gl label "Счет ГЛ" format "999999"
                 ft-gl.des label "Наименование счета" format "x(50)"
           with 19 down no-label width 50 .


def query  fq2 for budget.
def browse fb2 query fq2
           displ budget.coder   label "Код расхода" format "x(12)"
                 budget.name label "Наименование кода расхода" format "x(55)"
           with 23 down column 2  width 58. /*title "За " + v-monthname.*/

def frame fmain
          v-txbname          at x 1 y  1 label "Фильтр по подразд ввода плана " view-as text format "x(62)"
          fb1   at x 1   y 8 help " "
          fb2   at x 400 y 8 help " "
          v-monthname                at x 8 y  220 label "Месяц        " view-as text format "x(15)"
          budget.name                at x 8 y  228 label "Наименование " view-as text format "x(90)"
          ft-gl.des                   at x 8 y  228 label "Наименование " view-as text format "x(90)"
          budget.plan[v-month]       at x 8 y  236 label "План         " view-as text format "->>>>>>>>>9.99"
          budget.fact[v-month]       at x 8 y  242 label "Факт         " view-as text format "->>>>>>>>>9.99"
          budget.budget[v-month]     at x 8 y  250 label "Сверх бюджет " view-as text format "->>>>>>>>>9.99"
          budget.overdraft[v-month]  at x 8 y  258 label "% исполнения "  view-as text format "->>>>>>>>>9"
          ft-gl.plan       at x 8 y  236 label "План         " view-as text format "->>>>>>>>>9.99"
          ft-gl.fact       at x 8 y  242 label "Факт         " view-as text format "->>>>>>>>>9.99"
          ft-gl.budget     at x 8 y  250 label "Сверх бюджет " view-as text format "->>>>>>>>>9.99"
          ft-gl.overdraft  at x 8 y  258 label "% исполнения "  view-as text format "->>>>>>>>>9"
          "____________________________________________________________________________________________" at x 8 y 266 view-as text

          with row 2  side-labels  no-box with size 110 by 35 .


/* обновление списка на правой панели */
on "cursor-right" of browse fb1 do:
   close query fq2.
   open query fq2 for each budget where budget.year = v-year and budget.gl = ft-gl.gl and budget.remark[3] = v-txb no-lock use-index budyear.
   /*if can-find (first budget where budget.year = v-year and budget.gl = ft-gl.gl  ) then */ browse fb2:refresh().
   flastgrp = ft-gl.gl.
end.


/* переход на панель расхода */
on "tab" of browse fb1 do:
   if avail ft-gl then do:
   if flastgrp <> ft-gl.gl then do:
      flastgrp = ft-gl.gl.
      close query fq2.
      open query fq2 for each budget where budget.year = v-year and budget.gl = ft-gl.gl and budget.remark[3] = v-txb no-lock use-index budyear.
      /*if can-find (first budget where budget.year = v-year and budget.gl = ft-gl.gl  ) then */ browse fb2:refresh().
   end.
   if avail budget then displ v-monthname budget.name budget.plan[v-month] budget.fact[v-month] budget.budget[v-month]  budget.overdraft[v-month] with frame fmain. else
   displ ft-gl.des ? @ budget.plan[v-month] ? @ budget.fact[v-month] ? @ budget.budget[v-month] ? @ budget.overdraft[v-month] with frame fmain.
   displ
         help_l3 at x 8 y 272 view-as text no-label  /*y 152*/
         with frame fmain.
   end.
end.

/* переход на панель счетов */
on "tab" of browse fb2 do:
   /*displ ? @ budget.name ? @ budget.plan[v-month] ? @ budget.fact[v-month] ? @ budget.budget[v-month] ? @ budget.overdraft[v-month]
         help_g3 at x 8 y 272 view-as text no-label /*y 152*/
         with frame fmain.*/
    displ ft-gl.des  ft-gl.plan  ft-gl.fact  ft-gl.budget  ft-gl.overdraft
          help_g3 at x 8 y 272 view-as text no-label
          with frame fmain.
end.

/* обновление сведений  суммы */
on value-changed of browse fb2 do:
   if avail budget then displ v-monthname budget.name budget.plan[v-month] budget.fact[v-month] budget.budget[v-month] budget.overdraft[v-month] with frame fmain.
   else
   displ ft-gl.des ? @ budget.plan[v-month] ? @ budget.fact[v-month] ? @ budget.budget[v-month] ? @ budget.overdraft[v-month] with frame fmain.
end.
/* обновление сведений  суммы */
on value-changed of browse fb1 do:
    displ ft-gl.des  ft-gl.plan  ft-gl.fact  ft-gl.budget  ft-gl.overdraft
          help_g3 at x 8 y 272 view-as text no-label
          with frame fmain.
end.


/*  */
on "help" of browse fb2 do:
   if not available budget then leave.
end.
/******************************************************************************/
ON INSERT-MODE OF  browse fb2 /*Добавить */
DO:
    frez = false.
    run yn("","Создать новую запись ?","","", output frez).
    if frez then do:
        fnewnom = 0.
        fvv-coder = budget.coder.
        fvv-name = budget.name.
        find last budget use-index id no-lock no-error.
        if available budget then fnewnom = budget.id.
        fnewnom = fnewnom + 1.
        fvv-gl = ft-gl.gl.
        run ShowData(string(fnewnom,">>>>9"),input-output fvv-gl,fvv-coder,fvv-name).

        find first ft-gl where ft-gl.gl = fvv-gl no-error.
        if not available ft-gl then do:
            create ft-gl.
            ft-gl.gl = fvv-gl.
            ft-gl.des = fv-des.
            ft-gl.depname = fv-depname.
        end.
        browse fb1:refresh().
        close query fq2.
        open query fq2 for each budget where budget.year = v-year and budget.gl = ft-gl.gl and budget.remark[3] = v-txb no-lock use-index budyear.
        displ v-monthname budget.name budget.plan[v-month] budget.fact[v-month] budget.budget[v-month] budget.overdraft[v-month] with frame fmain.
    end. /* if rez */
END.
/******************************************************************************/
ON DELETE-CHARACTER OF  browse fb2 /*Удалить*/
DO:
    /*Pos = b_list:focused-row.*/
    find current budget no-lock no-error.
    if not avail budget then return.
    frez = false.
    run yn("","Удалить код расхода " + budget.coder + "?","","", output frez).
    if frez then do:
        find current budget exclusive-lock.
        fv-gl = budget.gl.
        fv-coder = budget.coder.
        delete budget.

        run cortotal(fv-gl,fv-coder). /* корректировка total данных */
        browse fb1:refresh().
        browse fb2:refresh().
    end.
END.
/******************************************************************************/
ON DELETE-CHARACTER OF  browse fb1 /*Удалить*/
DO:
    /*Pos = fb1:focused-row.*/
    find current budget no-lock no-error.
    if not avail budget then return.
    frez = false.
    run yn("","Будут удалены все записи по счету " + string(ft-gl.gl) + ", вы уверены?","","", output frez).
    if frez then do:
        fpoz = ft-gl.gl.
        for each budget where budget.year = v-year and budget.gl = ft-gl.gl exclusive-lock.
            delete budget.
        end.
        for each ft-gl where ft-gl.gl = fpoz .
            delete ft-gl.
        end.
        release ft-gl.
        open query fq1 for each ft-gl no-lock.
        open query fq2 for each budget where budget.year = v-year and budget.gl = ft-gl.gl and budget.remark[3] = v-txb no-lock use-index budyear.
        /*displ ? @ budget.name ? @ budget.plan[v-month] ? @ budget.fact[v-month] ? @ budget.budget[v-month] ? @ budget.overdraft[v-month]
              help_g3 at x 8 y 272 view-as text no-label with frame fmain.*/
        displ ft-gl.des  ft-gl.plan  ft-gl.fact  ft-gl.budget  ft-gl.overdraft
              help_g3 at x 8 y 272 view-as text no-label
              with frame fmain.
    end.
END.
/******************************************************************************/
on return of browse fb2 do: /*Редактировать */
    /*Pos = fb2:focused-row.*/
    fvv-coder = budget.coder.
    fvv-name = budget.name.
    find current budget no-lock no-error.
    fvv-gl = ft-gl.gl.
    if avail budget then run ShowData(budget.id,input-output fvv-gl,fvv-coder,fvv-name).
    /*fb2:SELECT-ROW(Pos).
    display  fb2 WITH  FRAME fmain.*/
    displ ? @ budget.name ? @ budget.plan[v-month] ? @ budget.fact[v-month] ? @ budget.budget[v-month] ? @ budget.overdraft[v-month] with frame fmain.
    displ budget.plan[v-month] budget.fact[v-month] budget.budget[v-month] budget.overdraft[v-month]
        WITH FRAME fmain.
end.
/******************************************************************************/
ON GO OF browse fb1 /*Расчет*/
DO:
  run yn("","Произвести расчет? ","","", output frez).
  if frez then do:
    OPEN QUERY  fq-month FOR EACH ft-month no-lock.
    ENABLE ALL WITH FRAME ff-month.
    wait-for return of frame ff-month
    FOCUS fb-month IN FRAME ff-month.
    fv-mon = ft-month.num.
    fv-txt = ft-month.month.
    hide frame ff-month.
        for each budget use-index budyear where budget.year = v-year and
            (lookup(substring(string(budget.gl),1,4),"5781,5782,5783,5787,5788,5761,5763,5764,5765,5766,5768,5767,5799") > 0
            or lookup(string(budget.gl),"572151,572161,572171,572153,572940,572910,572930,572210") > 0) exclusive-lock.
            budget.fact[fv-mon] = 0.
            budget.budget[fv-mon] = 0.
            budget.overdraft[fv-mon] = 0.
        end.
    {r-branch.i &proc = "budf1(DATE(fv-mon, 1, v-year ),DATE(fv-mon + 1, 1, v-year ) - 1,fv-txt)"}
    for each budget use-index budyear where budget.year = v-year and
        (lookup(substring(string(budget.gl),1,4),"5781,5782,5783,5787,5788,5761,5763,5764,5765,5766,5768,5767,5799") > 0
        or lookup(string(budget.gl),"572151,572161,572171,572153,572940,572910,572930,572210") > 0) exclusive-lock.
        if budget.plan[fv-mon] <> 0 then budget.overdraft[fv-mon] = ((budget.fact[fv-mon] + budget.budget[fv-mon]) / budget.plan[fv-mon]) * 100 .
    end.
    /*расчет сумм для ft-gl*/
        for each ft-gl.
            ft-gl.plan = 0.
            ft-gl.fact = 0.
            ft-gl.budget = 0.
            ft-gl.overdraft = 0.
        end.
        for each ft-gl.
            for each budget where budget.year =  v-year and budget.gl = ft-gl.gl and substring(budget.coder,8,3) begins "___"  no-lock.
                ft-gl.plan = ft-gl.plan + budget.plan[v-month].
                ft-gl.fact = ft-gl.fact + budget.fact[v-month].
                ft-gl.budget = ft-gl.budget + budget.budget[v-month].
            end.
            if ft-gl.plan <=0 then ft-gl.overdraft = ?.
            else ft-gl.overdraft = ((ft-gl.fact + ft-gl.budget) / ft-gl.plan) * 100 .
        end.
    /**************************************************************************************/
    find first ft-gl.
    displ ft-gl.des  ft-gl.plan  ft-gl.fact  ft-gl.budget  ft-gl.overdraft
      help_g3 at x 8 y 272 view-as text no-label
      with frame fmain.
  end.
END.
/******************************************************************************/
/*--------------------------------------------------------------------------------*/
define temp-table ft-con no-undo
field cod as char
field depname as char
index ind is primary  cod.

DECLARE nn CURSOR FOR
 select budget.remark[3], budget.dep from budget where budget.year =  v-year group by budget.dep.

open nn.
repeat:
    FETCH nn INTO fv-ttt,fv-depname.
    create ft-con.
    ft-con.cod = fv-ttt.
    ft-con.depname = fv-depname.
end.
close nn.
DEFINE QUERY fq-con FOR ft-con.

DEFINE BROWSE fb-con QUERY fq-con
    DISPLAY ft-con.cod label "Код" format "x(5)" ft-con.depname label "Контрол. подразделение  "format "x(50)"  WITH  15 DOWN.
DEFINE FRAME ff-con fb-con  WITH overlay row 5 COLUMN 15 width 65 title "Выберите подразделение".
/*--------------------------------------------------------------------------------*/
define temp-table ft-txb no-undo
field txb as char
field txbname as char
index ind is primary  txb.


DECLARE n CURSOR FOR
 select budget.txb, budget.txbname from budget where budget.year =  v-year group by budget.txb.

open n.
repeat:
    FETCH n INTO fvv-txb,fv-txbname.
    create ft-txb.
    ft-txb.txb = fvv-txb.
    ft-txb.txbname = fv-txbname.
end.
close n.

DEFINE QUERY fq-txb FOR ft-txb.

DEFINE BROWSE fb-txb QUERY fq-txb
    DISPLAY ft-txb.txb label "Код  "format "x(5)" ft-txb.txbname label "Подразделение" format "x(55)"  WITH  15 DOWN.
DEFINE FRAME ff-txb fb-txb  WITH overlay row 8 COLUMN 25 width 80 title "Выберите подразделение".
/************************************************************************************************************/
open query fq1 for each ft-gl where  ft-gl.txbname begins v-txb .
open query fq2 for each budget where budget.year = v-year and budget.gl = ft-gl.gl and budget.remark[3] begins v-txb no-lock use-index budyear.
enable all with frame fmain.

displ v-txbname v-monthname ft-gl.des  ft-gl.plan  ft-gl.fact  ft-gl.budget  ft-gl.overdraft
      help_g3 at x 8 y 272 view-as text no-label
      with frame fmain.
{wait.i}


procedure ShowData:

    DEF input param  fcs-name AS int.
    DEF input-output param  fvvv-gl AS int.
    DEF input param fvvv-coder AS char.
    DEF input param fvvv-name AS char.

     def buffer b-budget for budget.

     DEFINE BUTTON save-button LABEL "Сохранить".
     DEFINE BUTTON cancel-button LABEL "Отмена".

     DEFINE QUERY q-sp FOR ppoint.
     DEFINE BROWSE b-sp QUERY q-sp
       DISPLAY ppoint.dep label "Номер  " format "99" ppoint.name label "Наименование   " format "x(59)"
       WITH  10 DOWN.
     DEFINE FRAME f-sp b-sp  WITH   column 20 row 8 TITLE "ВЫБЕРИТЕ СП" width 75 .

     define frame form1
        /*v-year label "Год"  skip*/
        fv-gl     label  "Счет ГК             "  format "999999" validate(can-find(first gl where string(gl.gl) begins string(fv-gl) no-lock),"Неверный счет!") skip
        fv-des    label  "Наименование счета  "  format "x(60)"  skip
        fv-coder  label  "Код расхода         "  format "x(12)"  skip
        fv-name   label  "Наименование        "  format "x(60)"  skip
        fv-txbname label  "Наимен. подраздел   "  format "x(60)"  skip
        fv-dep     label "Подразд. ввода плана"  format "x(60)"  skip
        fv-depname label "Контрол.департамент "  format "x(60)"  /*validate(can-find(first t-con where t-con.cod = v-depname no-lock),"Неверный код контрол. департамента!")*/ skip(1)
        "           ПЛАН                     ФАКТ                   СВЕРХ БЮДЖЕТ            % ИСПОЛНЕНИЯ" skip
        "-----------------------------------------------------------------------------------------------------" skip
        v-plan[1]      label " Январь  " format "->>>>>>>>>9.99"
        v-fact[1]      label " Январь  " format "->>>>>>>>>9.99" validate(v-fact[1] <= decimal(v-plan[1]:SCREEN-VALUE), "Факт не может превышать план!")
        v-budget[1]    label " Январь  " format "->>>>>>>>>9.99"
        v-overdraft[1] label " Январь  " format "->>>>>>>>>9" skip(1)

        v-plan[2]      label " Февраль " format "->>>>>>>>>9.99"
        v-fact[2]      label " Февраль " format "->>>>>>>>>9.99" validate(v-fact[2] <= decimal(v-plan[2]:SCREEN-VALUE), "Факт не может превышать план!")
        v-budget[2]    label " Февраль " format "->>>>>>>>>9.99"
        v-overdraft[2] label " Февраль " format "->>>>>>>>>9"  skip(1)

        v-plan[3]      label " Март    " format "->>>>>>>>>9.99"
        v-fact[3]      label " Март    " format "->>>>>>>>>9.99" validate(v-fact[3] <= decimal(v-plan[3]:SCREEN-VALUE), "Факт не может превышать план!")
        v-budget[3]    label " Март    " format "->>>>>>>>>9.99"
        v-overdraft[3] label " Март    " format "->>>>>>>>>9"  skip(1)

        v-plan[4]      label " Апрель  " format "->>>>>>>>>9.99"
        v-fact[4]      label " Апрель  " format "->>>>>>>>>9.99" validate(v-fact[4] <= decimal(v-plan[4]:SCREEN-VALUE), "Факт не может превышать план!")
        v-budget[4]    label " Апрель  " format "->>>>>>>>>9.99"
        v-overdraft[4] label " Апрель  " format "->>>>>>>>>9"  skip(1)

        v-plan[5]      label " Май     " format "->>>>>>>>>9.99"
        v-fact[5]      label " Май     " format "->>>>>>>>>9.99" validate(v-fact[5] <= decimal(v-plan[5]:SCREEN-VALUE), "Факт не может превышать план!")
        v-budget[5]    label " Май     " format "->>>>>>>>>9.99"
        v-overdraft[5] label " Май     " format "->>>>>>>>>9"  skip(1)

        v-plan[6]      label " Июнь    " format "->>>>>>>>>9.99"
        v-fact[6]      label " Июнь    " format "->>>>>>>>>9.99" validate(v-fact[6] <= decimal(v-plan[6]:SCREEN-VALUE), "Факт не может превышать план!")
        v-budget[6]    label " Июнь    " format "->>>>>>>>>9.99"
        v-overdraft[6] label " Июнь    " format "->>>>>>>>>9"  skip(1)

        v-plan[7]      label " Июль    " format "->>>>>>>>>9.99"
        v-fact[7]      label " Июль    " format "->>>>>>>>>9.99" validate(v-fact[7] <= decimal(v-plan[7]:SCREEN-VALUE), "Факт не может превышать план!")
        v-budget[7]    label " Июль    " format "->>>>>>>>>9.99"
        v-overdraft[7] label " Июль    " format "->>>>>>>>>9"  skip(1)

        v-plan[8]      label " Август  " format "->>>>>>>>>9.99"
        v-fact[8]      label " Август  " format "->>>>>>>>>9.99" validate(v-fact[8] <= decimal(v-plan[8]:SCREEN-VALUE), "Факт не может превышать план!")
        v-budget[8]    label " Август  " format "->>>>>>>>>9.99"
        v-overdraft[8] label " Август  " format "->>>>>>>>>9"  skip(1)

        v-plan[9]      label " Сентябрь" format "->>>>>>>>>9.99"
        v-fact[9]      label " Сентябрь" format "->>>>>>>>>9.99" validate(v-fact[9] <= decimal(v-plan[9]:SCREEN-VALUE), "Факт не может превышать план!")
        v-budget[9]    label " Сентябрь" format "->>>>>>>>>9.99"
        v-overdraft[9] label " Сентябрь" format "->>>>>>>>>9"  skip(1)

        v-plan[10]      label " Октябрь " format "->>>>>>>>>9.99"
        v-fact[10]      label " Октябрь " format "->>>>>>>>>9.99" validate(v-fact[10] <= decimal(v-plan[10]:SCREEN-VALUE), "Факт не может превышать план!")
        v-budget[10]    label " Октябрь " format "->>>>>>>>>9.99"
        v-overdraft[10] label " Октябрь " format "->>>>>>>>>9"  skip(1)

        v-plan[11]      label " Ноябрь  " format "->>>>>>>>>9.99"
        v-fact[11]      label " Ноябрь  " format "->>>>>>>>>9.99" validate(v-fact[11] <= decimal(v-plan[11]:SCREEN-VALUE), "Факт не может превышать план!")
        v-budget[11]    label " Ноябрь  " format "->>>>>>>>>9.99"
        v-overdraft[11] label " Ноябрь  " format "->>>>>>>>>9"  skip(1)

        v-plan[12]      label " Декабрь " format "->>>>>>>>>9.99"
        v-fact[12]      label " Декабрь " format "->>>>>>>>>9.99" validate(v-fact[12] <= decimal(v-plan[12]:SCREEN-VALUE), "Факт не может превышать план!")
        v-budget[12]    label " Декабрь " format "->>>>>>>>>9.99"
        v-overdraft[12] label " Декабрь " format "->>>>>>>>>9"  skip(1)

     space(18) save-button  cancel-button
     WITH SIDE-LABELS centered row 1 width 110 TITLE "Данные ".

    on help of fv-gl in frame form1 do:
        OPEN QUERY  fq-gl FOR EACH gl where gl.gl >= 500000 and gl.gl < 600000 no-lock.
        ENABLE ALL WITH FRAME ff-gl.
        wait-for return of frame ff-gl
        FOCUS fb-gl IN FRAME ff-gl.
        fv-gl = gl.gl.
        fv-des = gl.des.
        hide frame ff-gl.
        displ fv-gl fv-des with frame form1.
    end.
    on "END-ERROR" of frame ff-gl do:
      hide frame ff-gl no-pause.
    end.
    on "END-ERROR" of frame ff-txb do:
      hide frame ff-txb no-pause.
    end.

    on help of fv-coder in frame form1 do:
        OPEN QUERY  fq-code FOR EACH cods where cods.gl = fv-gl no-lock.
        ENABLE ALL WITH FRAME ff-code.
        wait-for return of frame ff-code
        FOCUS fb-code IN FRAME ff-code.
        fv-coder = cods.code.
        fv-name = cods.des.
        hide frame ff-code.
        displ fv-coder fv-name with frame form1.
        pause 0.
        OPEN QUERY  fq-txb FOR EACH ft-txb no-lock.
        ENABLE ALL WITH FRAME ff-txb.
        wait-for return of frame ff-txb
        FOCUS fb-txb IN FRAME ff-txb.
        fv-txbname = ft-txb.txbname.
        fv-coder = substring(fv-coder,1,7) + ft-txb.txb.
        hide frame ff-txb.
        displ fv-coder fv-txbname with frame form1.
    end.
    on help of fv-txbname in frame form1 do:
        OPEN QUERY  fq-txb FOR EACH ft-txb no-lock.
        ENABLE ALL WITH FRAME ff-txb.
        wait-for return of frame ff-txb
        FOCUS fb-txb IN FRAME ff-txb.
        fv-txbname = ft-txb.txbname.
        if fv-coder <> "" then fv-coder = substring(fv-coder,1,7) + ft-txb.txb.
        hide frame ff-txb.
        displ fv-coder fv-txbname with frame form1.
    end.
    on help of fv-depname in frame form1 do:
        OPEN QUERY  fq-con FOR EACH ft-con no-lock.
        ENABLE ALL WITH FRAME ff-con.
        wait-for return of frame ff-con
        FOCUS fb-con IN FRAME ff-con.
        if trim(fv-depname) = "" then  fv-depname = ft-con.cod.
        else fv-depname = fv-depname + "," + ft-con.cod.
        hide frame ff-con.
        displ fv-depname with frame form1.
    end.
    on help of fv-dep in frame form1 do:
        OPEN QUERY  fq-con FOR EACH ft-con no-lock.
        ENABLE ALL WITH FRAME ff-con.
        wait-for return of frame ff-con
        FOCUS fb-con IN FRAME ff-con.
        fv-dep = ft-con.depname.
        fv-ttt = ft-con.cod.
        hide frame ff-con.
        displ fv-dep with frame form1.
    end.
    on "END-ERROR" of frame ff-con do:
      hide frame ff-con no-pause.
    end.
    on "END-ERROR" of frame ff-code do:
      hide frame ff-code no-pause.
    end.

    find first b-budget where b-budget.id = fcs-name no-lock no-error.
    if avail b-budget then do:
        /*v-year = budget.year.*/
        fv-gl = budget.gl.
        fv-des = budget.des.
        fv-coder = budget.coder.
        fv-name = budget.name.
        fv-txbname = budget.txbname.
        fv-dep = budget.dep.
        fvv-txb = substring(fvvv-coder,8,5).
        fv-ttt = budget.remark[3].
        fv-depname = budget.depname.
        i = 1.
        do while  i <= 12.
            v-plan[i] = budget.plan[i].
            v-fact[i] = budget.fact[i].
            v-budget[i] = budget.budget[i].
            v-overdraft[i] = budget.overdraft[i].
            i = i + 1.
        end.
        /*******************************************************************************/
        i = 1.
        do while  i <= 12.
            v-planold[i] = budget.plan[i].
            v-factold[i] = budget.fact[i].
            v-budgetold[i] = budget.budget[i].
            v-overdraftold[i] = budget.overdraft[i].
            i = i + 1.
        end.
    end.
    else do:
        fv-gl = fvvv-gl.
        fv-des = "".
        fv-coder = substring(fvvv-coder,1,7).
        fv-name = fvvv-name.
        fv-txbname = "".
        fv-dep = "".
        fvv-txb = "".
        fv-ttt = "".
        fv-depname = "".
        i = 1.
        do while  i <= 12.
            v-plan[i] = 0.
            v-fact[i] = 0.
            v-budget[i] = 0.
            v-overdraft[i] = 0.
            i = i + 1.
        end.
        /*******************************************************************************/
        i = 1.
        do while  i <= 12.
            v-planold[i] = 0.
            v-factold[i] = 0.
            v-budgetold[i] = 0.
            v-overdraftold[i] = 0.
            i = i + 1.
        end.
    end.

     fv-id  = fcs-name.
    /*displ fv-gl fv-des fv-coder fv-name fv-txbname fv-dep fv-depname with frame form1.*/
    display  /*v-year*/ fv-gl fv-des  fv-coder  fv-name  fv-txbname fv-dep fv-depname  v-plan[1] v-fact[1]
    v-budget[1] v-overdraft[1] v-plan[2]  v-fact[2] v-budget[2] v-overdraft[2] v-plan[3] v-fact[3] v-budget[3]  v-overdraft[3]
    v-plan[4] v-fact[4] v-budget[4] v-overdraft[4] v-plan[5] v-fact[5] v-budget[5]  v-overdraft[5]
    v-plan[6]  v-fact[6] v-budget[6]  v-overdraft[6] v-plan[7] v-fact[7]  v-budget[7] v-overdraft[7]
    v-plan[8] v-fact[8] v-budget[8] v-overdraft[8]  v-plan[9] v-fact[9] v-budget[9] v-overdraft[9]
    v-plan[10] v-fact[10] v-budget[10]  v-overdraft[10]  v-plan[11] v-fact[11] v-budget[11] v-overdraft[11]
    v-plan[12] v-fact[12]  v-budget[12] v-overdraft[12]  with frame form1.

    update fv-gl with frame form1.
    find first gl where gl.gl = fv-gl no-lock no-error.
    if available gl then fv-des = gl.des.
    update fv-des fv-coder with frame form1.
    if fv-name = "" then do:
        find first cods where cods.code begins substring(fv-coder,1,7) no-lock no-error.
        if available cods then fv-name = cods.des.
    end.
    update fv-name fv-txbname fv-dep fv-depname with frame form1.

     ON CHOOSE OF save-button
     DO:
       find first b-budget where b-budget.id = fcs-name exclusive-lock no-error.
       if avail b-budget then do:
        b-budget.year = v-year.
        b-budget.gl = int(fv-gl:SCREEN-VALUE).
        fvvv-gl = int(fv-gl:SCREEN-VALUE).
        b-budget.des = fv-des:SCREEN-VALUE.
        b-budget.coder = fv-coder:SCREEN-VALUE.
        b-budget.code = substring(fv-coder:SCREEN-VALUE,1,7).
        /*b-budget.txb = substring(fv-coder:SCREEN-VALUE,8,5).*/
        b-budget.name = fv-name:SCREEN-VALUE.
        b-budget.txbname = fv-txbname:SCREEN-VALUE.
        if substring(fv-coder:SCREEN-VALUE,8,5) <> "" then b-budget.txb = substring(fv-coder:SCREEN-VALUE,8,5).
        else do:
            find first ft-txb where ft-txb.txbname begins fv-txbname:SCREEN-VALUE no-error.
            if available ft-txb then b-budget.txb = ft-txb.txb.
        end.
        b-budget.dep = fv-dep:SCREEN-VALUE.
        b-budget.depname = fv-depname:SCREEN-VALUE.
        b-budget.remark[3] = fv-ttt.

        b-budget.plan[1] = decimal(v-plan[1]:SCREEN-VALUE).
        b-budget.fact[1] = decimal(v-fact[1]:SCREEN-VALUE).
        b-budget.budget[1] = decimal(v-budget[1]:SCREEN-VALUE).
        if   b-budget.plan[1] <= 0 then b-budget.overdraft[1] = ?.
        else b-budget.overdraft[1] = ((decimal(v-fact[1]:SCREEN-VALUE) + decimal(v-budget[1]:SCREEN-VALUE)) / decimal(v-plan[1]:SCREEN-VALUE)) * 100. /*decimal(v-overdraft1:SCREEN-VALUE).*/

        b-budget.plan[2] = decimal(v-plan[2]:SCREEN-VALUE).
        b-budget.fact[2] = decimal(v-fact[2]:SCREEN-VALUE).
        b-budget.budget[2] = decimal(v-budget[2]:SCREEN-VALUE).
        if   b-budget.plan[2] <= 0 then b-budget.overdraft[2] = ?.
        else b-budget.overdraft[2] = ((decimal(v-fact[2]:SCREEN-VALUE) + decimal(v-budget[2]:SCREEN-VALUE)) / decimal(v-plan[2]:SCREEN-VALUE)) * 100.  /*decimal(v-overdraft2:SCREEN-VALUE).*/

        b-budget.plan[3] = decimal(v-plan[3]:SCREEN-VALUE).
        b-budget.fact[3] = decimal(v-fact[3]:SCREEN-VALUE).
        b-budget.budget[3] = decimal(v-budget[3]:SCREEN-VALUE).
        if   b-budget.plan[3] <= 0 then b-budget.overdraft[3] = ?.
        else b-budget.overdraft[3] = ((decimal(v-fact[3]:SCREEN-VALUE) + decimal(v-budget[3]:SCREEN-VALUE)) / decimal(v-plan[3]:SCREEN-VALUE)) * 100. /*decimal(v-overdraft3:SCREEN-VALUE).*/

        b-budget.plan[4] = decimal(v-plan[4]:SCREEN-VALUE).
        b-budget.fact[4] = decimal(v-fact[4]:SCREEN-VALUE).
        b-budget.budget[4] = decimal(v-budget[4]:SCREEN-VALUE).
        if   b-budget.plan[4] <= 0 then b-budget.overdraft[4] = ?.
        else b-budget.overdraft[4] = ((decimal(v-fact[4]:SCREEN-VALUE) + decimal(v-budget[4]:SCREEN-VALUE)) / decimal(v-plan[4]:SCREEN-VALUE)) * 100. /*decimal(v-overdraft4:SCREEN-VALUE).*/

        b-budget.plan[5] = decimal(v-plan[5]:SCREEN-VALUE).
        b-budget.fact[5] = decimal(v-fact[5]:SCREEN-VALUE).
        b-budget.budget[5] = decimal(v-budget[5]:SCREEN-VALUE).
        if   b-budget.plan[5] <= 0 then b-budget.overdraft[5] = ?.
        else b-budget.overdraft[5] = ((decimal(v-fact[5]:SCREEN-VALUE) + decimal(v-budget[5]:SCREEN-VALUE)) / decimal(v-plan[5]:SCREEN-VALUE)) * 100. /*decimal(v-overdraft5:SCREEN-VALUE).*/

        b-budget.plan[6] = decimal(v-plan[6]:SCREEN-VALUE).
        b-budget.fact[6] = decimal(v-fact[6]:SCREEN-VALUE).
        b-budget.budget[6] = decimal(v-budget[6]:SCREEN-VALUE).
        if   b-budget.plan[6] <= 0 then b-budget.overdraft[6] = ?.
        else b-budget.overdraft[6] = ((decimal(v-fact[6]:SCREEN-VALUE) + decimal(v-budget[6]:SCREEN-VALUE)) / decimal(v-plan[6]:SCREEN-VALUE)) * 100. /*decimal(v-overdraft6:SCREEN-VALUE).*/

        b-budget.plan[7] = decimal(v-plan[7]:SCREEN-VALUE).
        b-budget.fact[7] = decimal(v-fact[7]:SCREEN-VALUE).
        b-budget.budget[7] = decimal(v-budget[7]:SCREEN-VALUE).
        if   b-budget.plan[7] <= 0 then b-budget.overdraft[7] = ?.
        else b-budget.overdraft[7] = ((decimal(v-fact[7]:SCREEN-VALUE) + decimal(v-budget[7]:SCREEN-VALUE)) / decimal(v-plan[7]:SCREEN-VALUE)) * 100. /*decimal(v-overdraft7:SCREEN-VALUE).*/

        b-budget.plan[8] = decimal(v-plan[8]:SCREEN-VALUE).
        b-budget.fact[8] = decimal(v-fact[8]:SCREEN-VALUE).
        b-budget.budget[8] = decimal(v-budget[8]:SCREEN-VALUE).
        if   b-budget.plan[8] <= 0 then b-budget.overdraft[8] = ?.
        else b-budget.overdraft[8] = ((decimal(v-fact[8]:SCREEN-VALUE) + decimal(v-budget[8]:SCREEN-VALUE)) / decimal(v-plan[8]:SCREEN-VALUE)) * 100. /*decimal(v-overdraft8:SCREEN-VALUE).*/

        b-budget.plan[9] = decimal(v-plan[9]:SCREEN-VALUE).
        b-budget.fact[9] = decimal(v-fact[9]:SCREEN-VALUE).
        b-budget.budget[9] = decimal(v-budget[9]:SCREEN-VALUE).
        if   b-budget.plan[9] <= 0 then b-budget.overdraft[9] = ?.
        else b-budget.overdraft[9] = ((decimal(v-fact[9]:SCREEN-VALUE) + decimal(v-budget[9]:SCREEN-VALUE)) / decimal(v-plan[9]:SCREEN-VALUE)) * 100. /*decimal(v-overdraft9:SCREEN-VALUE).*/

        b-budget.plan[10] = decimal(v-plan[10]:SCREEN-VALUE).
        b-budget.fact[10] = decimal(v-fact[10]:SCREEN-VALUE).
        b-budget.budget[10] = decimal(v-budget[10]:SCREEN-VALUE).
        if   b-budget.plan[10] <= 0 then b-budget.overdraft[10] = ?.
        else b-budget.overdraft[10] = ((decimal(v-fact[10]:SCREEN-VALUE) + decimal(v-budget[10]:SCREEN-VALUE)) / decimal(v-plan[10]:SCREEN-VALUE)) * 100. /*decimal(v-overdraft10:SCREEN-VALUE).*/

        b-budget.plan[11] = decimal(v-plan[11]:SCREEN-VALUE).
        b-budget.fact[11] = decimal(v-fact[11]:SCREEN-VALUE).
        b-budget.budget[11] = decimal(v-budget[11]:SCREEN-VALUE).
        if   b-budget.plan[11] <= 0 then b-budget.overdraft[11] = ?.
        else b-budget.overdraft[11] = ((decimal(v-fact[11]:SCREEN-VALUE) + decimal(v-budget[11]:SCREEN-VALUE)) / decimal(v-plan[11]:SCREEN-VALUE)) * 100. /*decimal(v-overdraft11:SCREEN-VALUE).*/

        b-budget.plan[12] = decimal(v-plan[12]:SCREEN-VALUE).
        b-budget.fact[12] = decimal(v-fact[12]:SCREEN-VALUE).
        b-budget.budget[12] = decimal(v-budget[12]:SCREEN-VALUE).
        if   b-budget.plan[12] <= 0 then b-budget.overdraft[12] = ?.
        else b-budget.overdraft[12] = ((decimal(v-fact[12]:SCREEN-VALUE) + decimal(v-budget[12]:SCREEN-VALUE)) / decimal(v-plan[12]:SCREEN-VALUE)) * 100. /*decimal(v-overdraft12:SCREEN-VALUE).*/

        b-budget.who = g-ofc.
        b-budget.whn = g-today.
       end.
       else do:
        create budget.
        budget.id = fnewnom.
        budget.year = v-year.
        budget.gl = int(fv-gl:SCREEN-VALUE).
        budget.des = fv-des:SCREEN-VALUE.
        budget.coder = fv-coder:SCREEN-VALUE.
        budget.code = substring(fv-coder:SCREEN-VALUE,1,7).
        /*budget.txb = substring(fv-coder:SCREEN-VALUE,8,5).*/
        budget.name = fv-name:SCREEN-VALUE.
        budget.txbname = fv-txbname:SCREEN-VALUE.
        if substring(fv-coder:SCREEN-VALUE,8,5) <> "" then budget.txb = substring(fv-coder:SCREEN-VALUE,8,5).
        else do:
            find first ft-txb where ft-txb.txbname begins fv-txbname:SCREEN-VALUE no-error.
            if available ft-txb then budget.txb = ft-txb.txb.
        end.
        budget.dep = fv-dep:SCREEN-VALUE.
        budget.depname = fv-depname:SCREEN-VALUE.
        budget.remark[3] = fv-ttt.

        budget.plan[1] = decimal(v-plan[1]:SCREEN-VALUE).
        budget.fact[1] = decimal(v-fact[1]:SCREEN-VALUE).
        budget.budget[1] = decimal(v-budget[1]:SCREEN-VALUE).
        if   budget.plan[1] <= 0 then budget.overdraft[1] = ?.
        else budget.overdraft[1] = ((decimal(v-fact[1]:SCREEN-VALUE) + decimal(v-budget[1]:SCREEN-VALUE)) / decimal(v-plan[1]:SCREEN-VALUE)) * 100. /*decimal(v-overdraft1:SCREEN-VALUE).*/

        budget.plan[2] = decimal(v-plan[2]:SCREEN-VALUE).
        budget.fact[2] = decimal(v-fact[2]:SCREEN-VALUE).
        budget.budget[2] = decimal(v-budget[2]:SCREEN-VALUE).
        if   budget.plan[2] <= 0 then budget.overdraft[2] = ?.
        else budget.overdraft[2] = ((decimal(v-fact[2]:SCREEN-VALUE) + decimal(v-budget[2]:SCREEN-VALUE)) / decimal(v-plan[2]:SCREEN-VALUE)) * 100.  /*decimal(v-overdraft2:SCREEN-VALUE).*/

        budget.plan[3] = decimal(v-plan[3]:SCREEN-VALUE).
        budget.fact[3] = decimal(v-fact[3]:SCREEN-VALUE).
        budget.budget[3] = decimal(v-budget[3]:SCREEN-VALUE).
        if   budget.plan[3] <= 0 then budget.overdraft[3] = ?.
        else budget.overdraft[3] = ((decimal(v-fact[3]:SCREEN-VALUE) + decimal(v-budget[3]:SCREEN-VALUE)) / decimal(v-plan[3]:SCREEN-VALUE)) * 100. /*decimal(v-overdraft3:SCREEN-VALUE).*/

        budget.plan[4] = decimal(v-plan[4]:SCREEN-VALUE).
        budget.fact[4] = decimal(v-fact[4]:SCREEN-VALUE).
        budget.budget[4] = decimal(v-budget[4]:SCREEN-VALUE).
        if   budget.plan[4] <= 0 then budget.overdraft[4] = ?.
        else budget.overdraft[4] = ((decimal(v-fact[4]:SCREEN-VALUE) + decimal(v-budget[4]:SCREEN-VALUE)) / decimal(v-plan[4]:SCREEN-VALUE)) * 100. /*decimal(v-overdraft4:SCREEN-VALUE).*/

        budget.plan[5] = decimal(v-plan[5]:SCREEN-VALUE).
        budget.fact[5] = decimal(v-fact[5]:SCREEN-VALUE).
        budget.budget[5] = decimal(v-budget[5]:SCREEN-VALUE).
        if   budget.plan[5] <= 0 then budget.overdraft[5] = ?.
        else budget.overdraft[5] = ((decimal(v-fact[5]:SCREEN-VALUE) + decimal(v-budget[5]:SCREEN-VALUE)) / decimal(v-plan[5]:SCREEN-VALUE)) * 100. /*decimal(v-overdraft5:SCREEN-VALUE).*/

        budget.plan[6] = decimal(v-plan[6]:SCREEN-VALUE).
        budget.fact[6] = decimal(v-fact[6]:SCREEN-VALUE).
        budget.budget[6] = decimal(v-budget[6]:SCREEN-VALUE).
        if   budget.plan[6] <= 0 then budget.overdraft[6] = ?.
        else budget.overdraft[6] = ((decimal(v-fact[6]:SCREEN-VALUE) + decimal(v-budget[6]:SCREEN-VALUE)) / decimal(v-plan[6]:SCREEN-VALUE)) * 100. /*decimal(v-overdraft6:SCREEN-VALUE).*/

        budget.plan[7] = decimal(v-plan[7]:SCREEN-VALUE).
        budget.fact[7] = decimal(v-fact[7]:SCREEN-VALUE).
        budget.budget[7] = decimal(v-budget[7]:SCREEN-VALUE).
        if   budget.plan[7] <= 0 then budget.overdraft[7] = ?.
        else budget.overdraft[7] = ((decimal(v-fact[7]:SCREEN-VALUE) + decimal(v-budget[7]:SCREEN-VALUE)) / decimal(v-plan[7]:SCREEN-VALUE)) * 100. /*decimal(v-overdraft7:SCREEN-VALUE).*/

        budget.plan[8] = decimal(v-plan[8]:SCREEN-VALUE).
        budget.fact[8] = decimal(v-fact[8]:SCREEN-VALUE).
        budget.budget[8] = decimal(v-budget[8]:SCREEN-VALUE).
        if   budget.plan[8] <= 0 then budget.overdraft[8] = ?.
        else budget.overdraft[8] = ((decimal(v-fact[8]:SCREEN-VALUE) + decimal(v-budget[8]:SCREEN-VALUE)) / decimal(v-plan[8]:SCREEN-VALUE)) * 100. /*decimal(v-overdraft8:SCREEN-VALUE).*/

        budget.plan[9] = decimal(v-plan[9]:SCREEN-VALUE).
        budget.fact[9] = decimal(v-fact[9]:SCREEN-VALUE).
        budget.budget[9] = decimal(v-budget[9]:SCREEN-VALUE).
        if   budget.plan[9] <= 0 then budget.overdraft[9] = ?.
        else budget.overdraft[9] = ((decimal(v-fact[9]:SCREEN-VALUE) + decimal(v-budget[9]:SCREEN-VALUE)) / decimal(v-plan[9]:SCREEN-VALUE)) * 100. /*decimal(v-overdraft9:SCREEN-VALUE).*/

        budget.plan[10] = decimal(v-plan[10]:SCREEN-VALUE).
        budget.fact[10] = decimal(v-fact[10]:SCREEN-VALUE).
        budget.budget[10] = decimal(v-budget[10]:SCREEN-VALUE).
        if   budget.plan[10] <= 0 then budget.overdraft[10] = ?.
        else budget.overdraft[10] = ((decimal(v-fact[10]:SCREEN-VALUE) + decimal(v-budget[10]:SCREEN-VALUE)) / decimal(v-plan[10]:SCREEN-VALUE)) * 100. /*decimal(v-overdraft10:SCREEN-VALUE).*/

        budget.plan[11] = decimal(v-plan[11]:SCREEN-VALUE).
        budget.fact[11] = decimal(v-fact[11]:SCREEN-VALUE).
        budget.budget[11] = decimal(v-budget[11]:SCREEN-VALUE).
        if   budget.plan[11] <= 0 then budget.overdraft[11] = ?.
        else budget.overdraft[11] = ((decimal(v-fact[11]:SCREEN-VALUE) + decimal(v-budget[11]:SCREEN-VALUE)) / decimal(v-plan[11]:SCREEN-VALUE)) * 100. /*decimal(v-overdraft11:SCREEN-VALUE).*/

        budget.plan[12] = decimal(v-plan[12]:SCREEN-VALUE).
        budget.fact[12] = decimal(v-fact[12]:SCREEN-VALUE).
        budget.budget[12] = decimal(v-budget[12]:SCREEN-VALUE).
        if   budget.plan[12] <= 0 then budget.overdraft[12] = ?.
        else budget.overdraft[12] = ((decimal(v-fact[12]:SCREEN-VALUE) + decimal(v-budget[12]:SCREEN-VALUE)) / decimal(v-plan[12]:SCREEN-VALUE)) * 100. /*decimal(v-overdraft12:SCREEN-VALUE).*/

        budget.who = g-ofc.
        budget.whn = g-today.
       end.

       fv-gl = int(fv-gl:SCREEN-VALUE).
       fv-coder = fv-coder:SCREEN-VALUE.
       run cortotal(fv-gl,fv-coder). /* корректировка total данных */

       find first b-budget where b-budget.id = fcs-name no-lock no-error.
       find first budget where budget.id = fcs-name no-lock no-error.

       apply "endkey" to frame form1.
     END.


     ON CHOOSE OF cancel-button
     DO:
        apply "endkey" to frame form1.
     END.


    enable   /*v-year fv-gl fv-des  fv-coder  fv-name  fv-txbname fv-depname */ v-plan[1] v-fact[1]
    v-budget[1] /* v-overdraft[1] */ v-plan[2]  v-fact[2] v-budget[2] /* v-overdraft[2] */ v-plan[3] v-fact[3] v-budget[3]  /* v-overdraft[3]
    */ v-plan[4] v-fact[4] v-budget[4] /* v-overdraft[4] */ v-plan[5] v-fact[5] v-budget[5]  /* v-overdraft[5]
    */ v-plan[6]  v-fact[6] v-budget[6]  /* v-overdraft[6] */ v-plan[7] v-fact[7]  v-budget[7] /* v-overdraft[7]
    */ v-plan[8] v-fact[8] v-budget[8] /* v-overdraft[8]  */ v-plan[9] v-fact[9] v-budget[9] /* v-overdraft[9]
    */ v-plan[10] v-fact[10] v-budget[10]  /* v-overdraft[10]  */ v-plan[11] v-fact[11] v-budget[11] /* v-overdraft[11]
    */ v-plan[12] v-fact[12]  v-budget[12] /* v-overdraft[12]*/  save-button cancel-button with frame form1.

    display  /*v-year*/ fv-gl fv-des  fv-coder  fv-name  fv-txbname fv-dep fv-depname  v-plan[1] v-fact[1]
    v-budget[1] v-overdraft[1] v-plan[2]  v-fact[2] v-budget[2] v-overdraft[2] v-plan[3] v-fact[3] v-budget[3]  v-overdraft[3]
    v-plan[4] v-fact[4] v-budget[4] v-overdraft[4] v-plan[5] v-fact[5] v-budget[5]  v-overdraft[5]
    v-plan[6]  v-fact[6] v-budget[6]  v-overdraft[6] v-plan[7] v-fact[7]  v-budget[7] v-overdraft[7]
    v-plan[8] v-fact[8] v-budget[8] v-overdraft[8]  v-plan[9] v-fact[9] v-budget[9] v-overdraft[9]
    v-plan[10] v-fact[10] v-budget[10]  v-overdraft[10]  v-plan[11] v-fact[11] v-budget[11] v-overdraft[11]
    v-plan[12] v-fact[12]  v-budget[12] v-overdraft[12]   with frame form1.

    WAIT-FOR endkey of frame form1.
    hide frame form1.


end procedure.
/***********************************************************************************************************/


procedure cortotal:
    DEF input param cor-gl AS int.
    DEF input param cor-coder AS char.
    i = 1.
    do while i <= 12:
        v-plan[i] = 0.
        v-fact[i] = 0.
        v-budget[i] = 0.
        i = i + 1.
    end.
    /*********** для ___________*****************************************************/

    find first budget where budget.year = v-year and budget.gl = cor-gl and budget.coder begins substring(cor-coder,1,7)
        and substring(budget.coder,8,5) begins "___" no-error.
    if available budget then do:
        for each budget  where budget.year = v-year and budget.gl = cor-gl and budget.coder begins substring(cor-coder,1,7)
            and not substring(budget.coder,8,5) begins "___" and not substring(budget.coder,8,5) begins "TXB00" .
            i = 1.
            do while i <= 12:
                v-plan[i] = v-plan[i] + budget.plan[i].
                v-fact[i] = v-fact[i] + budget.fact[i].
                v-budget[i] = v-budget[i] + budget.budget[i].
                i = i + 1.
            end.
        end.
    end.
    find first budget where budget.year = v-year and budget.gl = cor-gl and budget.coder begins substring(cor-coder,1,7)
    and substring(budget.coder,8,5) begins "___" no-error.
    if available budget then do:
        i = 1.
        do while i <= 12:
            budget.plan[i] = v-plan[i].
            budget.fact[i] = v-fact[i].
            budget.budget[i] = v-budget[i].
            if budget.plan[i] <= 0 then budget.overdraft[i] = 0.
            else budget.overdraft[i] = ((budget.fact[i] + budget.budget[i]) / budget.plan[i]) * 100.
            i = i + 1.
        end.
    end.

    i = 1.
    do while i <= 12:
        v-plan[i] = 0.
        v-fact[i] = 0.
        v-budget[i] = 0.
        i = i + 1.
    end.
    /*********** для TXB00 *****************************************************/
    find first budget where budget.year = v-year and budget.gl = cor-gl and budget.coder begins substring(cor-coder,1,7)
        and substring(budget.coder,8,5) = "TXB00" no-error.
    if available budget then do:
        for each budget  where budget.year = v-year and budget.gl = cor-gl and budget.coder begins substring(cor-coder,1,7)
            and not substring(budget.coder,8,5) begins "___" and not substring(budget.coder,8,5) begins "TXB" .
            i = 1.
            do while i <= 12:
                v-plan[i] = v-plan[i] + budget.plan[i].
                v-fact[i] = v-fact[i] + budget.fact[i].
                v-budget[i] = v-budget[i] + budget.budget[i].
                i = i + 1.
            end.
        end.
    end.
    find first budget where budget.year = v-year and budget.gl = cor-gl and budget.coder begins substring(cor-coder,1,7)
    and substring(budget.coder,8,5) = "TXB00" no-error.
    if available budget then do:
        i = 1.
        do while i <= 12:
            budget.plan[i] = v-plan[i].
            budget.fact[i] = v-fact[i].
            budget.budget[i] = v-budget[i].
            if budget.plan[i] <= 0 then budget.overdraft[i] = 0.
            else budget.overdraft[i] = ((budget.fact[i] + budget.budget[i]) / budget.plan[i]) * 100.
            i = i + 1.
        end.
    end.
   /**********************************************************************************************/
   for each ft-gl.
        ft-gl.plan = 0.
        ft-gl.fact = 0.
        ft-gl.budget = 0.
        ft-gl.overdraft = 0.
    end.
    for each ft-gl.
        for each budget where budget.year =  v-year and budget.gl = ft-gl.gl and substring(budget.coder,8,3) begins "___"  no-lock.
            ft-gl.plan = ft-gl.plan + budget.plan[v-month].
            ft-gl.fact = ft-gl.fact + budget.fact[v-month].
            ft-gl.budget = ft-gl.budget + budget.budget[v-month].
            ft-gl.overdraft = ((ft-gl.fact + ft-gl.budget) / ft-gl.plan) * 100 .
        end.
    end.
end procedure.