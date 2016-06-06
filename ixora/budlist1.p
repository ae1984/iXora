/* budlist.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Анализ данных БП
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
            24/07/2012 Luiza - изменила выбор департамента
*/


{comm-txb.i}
{yes-no.i}

def var lastgrp as int .
def var lastls as int.
def new shared var v-year   as int.
def var v-gl as int.
def var vv-gl as int.
def var v-des as char.
def var v-name as char.
def var vv-name as char.
def var v-coder as char.
def var vv-coder as char.
def var v-depname as char.
def new shared var v-txbname as char.
def new shared var v-txb as char.
def var v-dep as char.
def var v-access as int.
def var Pos as int.
def var v-id    as int.
def var newnom as int.
def new shared var v-month as int.
def var v-mon as int.
def new shared var v-monthname as char.
def var v-txt as char.
def var v-con as char.
def var v-ret as char init "1".
def var rez as log.
def var poz as int.
def var v-ttt as char.
def var i as int init 1.
/************************************************/
def var v-plan  as decimal extent 12 format "->>>>>>>>>9.99".
def var v-fact  as decimal extent 12 format "->>>>>>>>>9.99".
def var v-budget  as decimal extent 12 format "->>>>>>>>>9.99".
def var v-overdraft  as decimal extent 12 format "->>>>>>>>>9".


define temp-table t-year no-undo
field year as int
index ind2 is primary  year.

DECLARE c CURSOR FOR
 select budget.year from budget group by budget.year.

 open c.
 repeat:
    FETCH c INTO v-year.
    create t-year.
    t-year.year = v-year.
  end.
  close c.


find first t-year no-error.
if not available t-year then do:
    message "Данные для бюджетных позиций не сформированы!".
    return.
end.
DEFINE QUERY q-year FOR t-year.

DEFINE BROWSE b-year QUERY q-year
    DISPLAY t-year.year no-label format "9999" WITH  5 DOWN.
DEFINE FRAME f-year b-year  WITH overlay row 5 COLUMN 25 width 15 title "Выберите год".

/* выбор года -----------------------------------------------------------*/
OPEN QUERY  q-year FOR EACH t-year no-lock.
ENABLE ALL WITH FRAME f-year.
wait-for return of frame f-year
FOCUS b-year IN FRAME f-year.
v-year = t-year.year.
hide frame f-year.
/*------------------------------------------------------------------------------*/

DEFINE QUERY q-gl FOR gl.

DEFINE BROWSE b-gl QUERY q-gl
    DISPLAY gl.gl label "Счет " format "999999" gl.des label "Наименование   " format "x(60)"
    WITH  15 DOWN.
DEFINE FRAME f-gl b-gl  WITH overlay 1 COLUMN SIDE-LABELS row 5 COLUMN 25 width 85 NO-BOX.

DEFINE QUERY q-code FOR cods.
DEFINE BROWSE b-code QUERY q-code
    DISPLAY cods.code label "Код расхода " format "x(7)" cods.des label "Наименование   " format "x(55)" cods.gl  label "Счет ГЛ"
    WITH  15 DOWN.
DEFINE FRAME f-code b-code  WITH overlay 1 COLUMN SIDE-LABELS row 7 COLUMN 25 width 85 NO-BOX.

/************************************************************************************************************/
define temp-table t-txb no-undo
field txb as char
field txbname as char
index ind is primary  txb.


for each codfr where codfr.codfr = "sproftcn" and codfr.child = false
              and codfr.code <> 'msc' and codfr.code matches '...' and substring(codfr.code,1,1) <> '0' and substring(codfr.code,1,1) <> 'a' no-lock.
    create t-txb.
    t-txb.txb = codfr.code.
    t-txb.txbname = codfr.name[1].
end.
create t-txb.
t-txb.txb = "".
t-txb.txbname = "Все филиалы и ЦО".

for each txb where txb.bank begins "TXB" no-lock.
    create t-txb.
    t-txb.txb = txb.bank.
    case txb.bank:
        when "TXB00" then t-txb.txbname = "Центральный офис".
        when "TXB01" then t-txb.txbname = "Актобе".
        when "TXB02" then t-txb.txbname = "Костанай".
        when "TXB03" then t-txb.txbname = "Тараз".
        when "TXB04" then t-txb.txbname = "Уральск".
        when "TXB05" then t-txb.txbname = "Караганда".
        when "TXB06" then t-txb.txbname = "Семей".
        when "TXB07" then t-txb.txbname = "Кокшетау".
        when "TXB08" then t-txb.txbname = "Астана".
        when "TXB09" then t-txb.txbname = "Павлодар".
        when "TXB10" then t-txb.txbname = "Петропавловск".
        when "TXB11" then t-txb.txbname = "Атырау".
        when "TXB12" then t-txb.txbname = "Актау".
        when "TXB13" then t-txb.txbname = "Жезказган".
        when "TXB14" then t-txb.txbname = "Усть-Каменогорск".
        when "TXB15" then t-txb.txbname = "Шымкент".
        when "TXB16" then t-txb.txbname = "Алматы".
        OTHERWISE  t-txb.txbname = txb.name.
    end case.
end.
  /*DECLARE n CURSOR FOR
 select budget.txb, budget.txbname from budget where budget.year =  v-year group by budget.txb.

open n.
repeat:
    FETCH n INTO v-txb,v-txbname.
    create t-txb.
    t-txb.txb = v-txb.
    t-txb.txbname = v-txbname.
end.
close n.*/

DEFINE QUERY q-txb FOR t-txb.

DEFINE BROWSE b-txb QUERY q-txb
    DISPLAY t-txb.txb label "Код  "format "x(5)" t-txb.txbname label "Подразделение" format "x(55)"  WITH  15 DOWN.
DEFINE FRAME f-txb b-txb  WITH overlay row 8 COLUMN 25 width 80 title "Выберите подразделение".
/************************************************************************************************************/

/*--------------------------------------------------------------------------------*/
/*define temp-table t-con no-undo
field cod as char
field depname as char
index ind is primary  cod.

DECLARE nn CURSOR FOR
 select budget.remark[3], budget.dep from budget where budget.year =  v-year group by budget.dep.

open nn.
repeat:
    FETCH nn INTO v-ttt,v-depname.
    create t-con.
    t-con.cod = v-ttt.
    t-con.depname = v-depname.
end.
close nn.
DEFINE QUERY q-con FOR t-con.

DEFINE BROWSE b-con QUERY q-con
    DISPLAY t-con.cod label "Код" format "x(5)" t-con.depname label "Контрол. подразделение  "format "x(50)"  WITH  15 DOWN.
DEFINE FRAME f-con b-con  WITH overlay row 5 COLUMN 15 width 65 title "Выберите подразделение".*/
/*--------------------------------------------------------------------------------*/

define temp-table t-gl no-undo
field gl as int
field des as char
field depname as char
field txbname as char
field plan as decim
field fact as decim
field budget as decim
field overdraft as decim
index ind is primary  gl.

DECLARE g CURSOR FOR
 select budget.gl, budget.des, budget.depname from budget where budget.year =  v-year group by budget.gl.

 open g.
 repeat:
    FETCH g INTO v-gl,v-des,v-depname.
    create t-gl.
    t-gl.gl = v-gl.
    t-gl.des = v-des.
    t-gl.depname = v-depname.
  end.
  close g.

    define temp-table t-month no-undo
    field num as int
    field month as char.
    create t-month.
    t-month.num = 1.
    t-month.month = "Январь".
    create t-month.
    t-month.num = 2.
    t-month.month = "Февраль".
    create t-month.
    t-month.num = 3.
    t-month.month = "Март".
    create t-month.
    t-month.num = 4.
    t-month.month = "Апрель".
    create t-month.
    t-month.num = 5.
    t-month.month = "Май".
    create t-month.
    t-month.num = 6.
    t-month.month = "Июнь".
    create t-month.
    t-month.num = 7.
    t-month.month = "Июль".
    create t-month.
    t-month.num = 8.
    t-month.month = "Август".
    create t-month.
    t-month.num = 9.
    t-month.month = "Сентябрь".
    create t-month.
    t-month.num = 10.
    t-month.month = "Октябрь".
    create t-month.
    t-month.num = 11.
    t-month.month = "Ноябрь".
    create t-month.
    t-month.num = 12.
    t-month.month = "Декабрь".

   DEFINE QUERY q-month FOR t-month.

    DEFINE BROWSE b-month QUERY q-month
        DISPLAY t-month.month no-label format "x(10)" WITH  12 DOWN.
    DEFINE FRAME f-month b-month  WITH overlay row 5 COLUMN 25 width 25 title "Выберите месяц".


/***********************************************************************************************************/

def var help_l3 as char init "<TAB>-др.окно, <ENTER>-редактировать, <INS>-создать, <DEL>-удалить " label "" format "x(90)".

def var help_g3 as char init "<TAB>-др.окно, <СТРЕЛКА ВПРАВО>-обновить список, <F2>-фильтр, <F1>-Расчет, <DEL>-удалить " label "" format "x(90)".

def shared var g-today as date.
def shared var g-ofc as char.

def var cnt as int.

DEFINE FRAME opt
    v-gl label " введите счет " format ">>>>>9"
with overlay row 10 column 15 side-label.
on "END-ERROR" of frame opt do:
  hide frame opt no-pause.
end.
DEFINE FRAME opt1
    v-txb label " введите наименование филиала " format "x(15)"
with overlay row 10 column 15 side-label.
on "END-ERROR" of frame opt1 do:
  hide frame opt1 no-pause.
end.


def query  q1 for t-gl.
def browse b1 query q1
           displ t-gl.gl label "Счет ГЛ" format "999999"
                 t-gl.des label "Наименование счета" format "x(50)"
           with 20 down no-label width 50 .


def query  q2 for budget.
def browse b2 query q2
           displ budget.coder   label "Код расхода" format "x(12)"
                 budget.txbname label "Подразделение" format "x(55)"
                 /*budget.name label "Наименование кода расхода" format "x(26)"*/
           with 24 down column 2  width 58. /*title "За " + v-monthname.*/

def frame fmain
          b1   at x 1   y 1 help " "
          b2   at x 400 y 1 help " "
          v-monthname                at x 8 y  220 label "Месяц        " view-as text format "x(15)"
          budget.name                at x 8 y  228 label "Наименование " view-as text format "x(90)"
          t-gl.des                   at x 8 y  228 label "Наименование " view-as text format "x(90)"
          budget.plan[v-month]       at x 8 y  236 label "План         " view-as text format "->>>>>>>>>9.99"
          budget.fact[v-month]       at x 8 y  242 label "Факт         " view-as text format "->>>>>>>>>9.99"
          budget.budget[v-month]     at x 8 y  250 label "Сверх бюджет " view-as text format "->>>>>>>>>9.99"
          budget.overdraft[v-month]  at x 8 y  258 label "% исполнения "  view-as text format "->>>>>>>>>9"
          t-gl.plan       at x 8 y  236 label "План         " view-as text format "->>>>>>>>>9.99"
          t-gl.fact       at x 8 y  242 label "Факт         " view-as text format "->>>>>>>>>9.99"
          t-gl.budget     at x 8 y  250 label "Сверх бюджет " view-as text format "->>>>>>>>>9.99"
          t-gl.overdraft  at x 8 y  258 label "% исполнения "  view-as text format "->>>>>>>>>9"
          "____________________________________________________________________________________________" at x 8 y 266 view-as text

          with row 2  side-labels  no-box with size 110 by 35 .


/* обновление списка на правой панели */
on "cursor-right" of browse b1 do:
   close query q2.
    open query q2 for each budget where budget.year = v-year and budget.gl = t-gl.gl /* and budget.coder ne "" */ no-lock use-index budyear.
   /*if can-find (first budget where budget.year = v-year and budget.gl = t-gl.gl  ) then */ browse b2:refresh().
   lastgrp = t-gl.gl.
end.


/* переход на панель расхода */
on "tab" of browse b1 do:
   if avail t-gl then do:
   if lastgrp <> t-gl.gl then do:
      lastgrp = t-gl.gl.
      close query q2.
      open query q2 for each budget where budget.year = v-year and budget.gl = t-gl.gl /* and budget.coder ne "" */ no-lock use-index budyear.
      /*if can-find (first budget where budget.year = v-year and budget.gl = t-gl.gl  ) then */ browse b2:refresh().
   end.
   if avail budget then displ v-monthname budget.name budget.plan[v-month] budget.fact[v-month] budget.budget[v-month]  budget.overdraft[v-month] with frame fmain. else
   displ t-gl.des ? @ budget.plan[v-month] ? @ budget.fact[v-month] ? @ budget.budget[v-month] ? @ budget.overdraft[v-month] with frame fmain.
   displ
         help_l3 at x 8 y 272 view-as text no-label  /*y 152*/
         with frame fmain.
   end.
end.

/* переход на панель счетов */
on "tab" of browse b2 do:
   /*displ ? @ budget.name ? @ budget.plan[v-month] ? @ budget.fact[v-month] ? @ budget.budget[v-month] ? @ budget.overdraft[v-month]
         help_g3 at x 8 y 272 view-as text no-label /*y 152*/
         with frame fmain.*/
    displ t-gl.des  t-gl.plan  t-gl.fact  t-gl.budget  t-gl.overdraft
          help_g3 at x 8 y 272 view-as text no-label
          with frame fmain.
end.

/* обновление сведений  суммы */
on value-changed of browse b2 do:
   if avail budget then displ v-monthname budget.name budget.plan[v-month] budget.fact[v-month] budget.budget[v-month] budget.overdraft[v-month] with frame fmain.
   else
   displ t-gl.des ? @ budget.plan[v-month] ? @ budget.fact[v-month] ? @ budget.budget[v-month] ? @ budget.overdraft[v-month] with frame fmain.
end.
/* обновление сведений  суммы */
on value-changed of browse b1 do:
    displ t-gl.des  t-gl.plan  t-gl.fact  t-gl.budget  t-gl.overdraft
          help_g3 at x 8 y 272 view-as text no-label
          with frame fmain.
end.


/*  */
on "help" of browse b2 do:
   if not available budget then leave.
end.
/*on BACKSPACE  of browse b2 do:
    run budrep.
end.*/

ON HELP OF browse b1 /*F2*/
DO:
    run sel("Выбор фильтра :", " 1. По счету | 2. По подразделению | 3. По подразд-ю ввода плана").
    v-ret = substring(return-value,1,1).
    v-gl = 0.
    if v-ret = "1" then do: /* по счету----------------------------------------------*/
        update v-gl help "0 - все счета "with  frame opt.
        if v-gl = 0 then do: /* все счета *****************************************************/
            empty temp-table t-gl.
            DECLARE dc CURSOR FOR
            select budget.gl, budget.des, budget.depname from budget where budget.year =  v-year group by budget.gl.
            open dc.
            repeat:
                FETCH dc INTO v-gl,v-des,v-depname.
                create t-gl.
                t-gl.gl = v-gl.
                t-gl.des = v-des.
                t-gl.depname = v-depname.
            end.
            v-ret = "1".
            close dc.
            open query q1 for each t-gl no-lock.
            open query q2 for each budget where budget.year = v-year and budget.gl = t-gl.gl /* and budget.coder ne ""*/ no-lock use-index budyear.
            displ t-gl.des  t-gl.plan  t-gl.fact  t-gl.budget  t-gl.overdraft
                  help_g3 at x 8 y 272 view-as text no-label
                  with frame fmain.

        end.
        else do: /* фильтр по счету  ********************************************************/
            hide frame opt.
            find first t-gl where string(t-gl.gl) begins string(v-gl) no-lock no-error.
            if not avail t-gl then return.
            empty temp-table t-gl.
            DECLARE r1 CURSOR FOR
            select budget.gl, budget.des, budget.depname from budget where budget.year =  v-year and substring(string(budget.gl),1,length(string(v-gl))) = string(v-gl) group by budget.gl.
            open r1.
            repeat:
                FETCH r1 INTO v-gl,v-des,v-depname.
                create t-gl.
                t-gl.gl = v-gl.
                t-gl.des = v-des.
                t-gl.depname = v-depname.
            end.
            close r1.
            open query q1 for each t-gl /*where string(t-gl.gl) begins string(v-gl)*/ no-lock .
            displ t-gl.des  t-gl.plan  t-gl.fact  t-gl.budget  t-gl.overdraft
                  help_g3 at x 8 y 272 view-as text no-label
                  with frame fmain.
        end.
    end.
    if v-ret = "2" then do: /* фильтр по подразделению **********************************/
        OPEN QUERY  q-txb FOR EACH t-txb no-lock.
        ENABLE ALL WITH FRAME f-txb.
        wait-for return of frame f-txb
        FOCUS b-txb IN FRAME f-txb.
        v-txb = t-txb.txb.
        v-txbname = t-txb.txbname.
        hide frame f-txb.
        update v-txb help "пустая строка - все счета" with  frame opt1.
        hide frame opt1.
        if trim(v-txb) <> "" then run budlistf.
    end.
    if v-ret = "3" then do: /* фильтр по подразделению ввода плана**********************************/
        OPEN QUERY  q-txb FOR EACH t-txb no-lock.
        ENABLE ALL WITH FRAME f-txb.
        wait-for return of frame f-txb
        FOCUS b-txb IN FRAME f-txb.
        v-txb = t-txb.txb.
        v-txbname = t-txb.txbname.
        hide frame f-txb.
        update v-txb help "пустая строка - все счета" with  frame opt1.
        hide frame opt1.
        if trim(v-txb) <> "" then run budlistp.
    end.
END.
/******************************************************************************/
ON INSERT-MODE OF  browse b2 /*Добавить */
DO:
    rez = false.
    run yn("","Создать новую запись ?","","", output rez).
    if rez then do:
        newnom = 0.
        vv-coder = budget.coder.
        vv-name = budget.name.
        find last budget use-index id no-lock no-error.
        if available budget then newnom = budget.id.
        newnom = newnom + 1.
        vv-gl = t-gl.gl.
        run ShowData(string(newnom,">>>>9"),input-output vv-gl,vv-coder,vv-name).

        find first t-gl where t-gl.gl = vv-gl no-error.
        if not available t-gl then do:
            create t-gl.
            t-gl.gl = vv-gl.
            t-gl.des = v-des.
            t-gl.depname = v-depname.
        end.
        find first t-gl where t-gl.gl = vv-gl no-error.
        if available t-gl then do:
            for each budget where budget.year =  v-year and budget.gl = t-gl.gl and substring(budget.coder,8,3) begins "___"  no-lock.
                t-gl.plan = t-gl.plan + budget.plan[v-month].
                t-gl.fact = t-gl.fact + budget.fact[v-month].
                t-gl.budget = t-gl.budget + budget.budget[v-month].
            end.
            if t-gl.plan <=0 then t-gl.overdraft = ?.
            else t-gl.overdraft = ((t-gl.fact + t-gl.budget) / t-gl.plan) * 100 .
        end.
        browse b1:refresh().
        close query q2.
        open query q2 for each budget where budget.year = v-year and budget.gl = t-gl.gl no-lock use-index budyear.
        displ v-monthname budget.name budget.plan[v-month] budget.fact[v-month] budget.budget[v-month] budget.overdraft[v-month] with frame fmain.
    end. /* if rez */
END.
/******************************************************************************/
ON DELETE-CHARACTER OF  browse b2 /*Удалить*/
DO:
    /*Pos = b_list:focused-row.*/
    find current budget no-lock no-error.
    if not avail budget then return.
    rez = false.
    run yn("","Удалить код расхода " + budget.coder + "?","","", output rez).
    if rez then do:
        find current budget exclusive-lock.
        v-gl = budget.gl.
        v-coder = budget.coder.
        delete budget.
        run cortotal(v-gl,v-coder). /* корректировка total данных */
        browse b1:refresh().
        browse b2:refresh().
    end.
END.
/******************************************************************************/
ON DELETE-CHARACTER OF  browse b1 /*Удалить*/
DO:
    /*Pos = b1:focused-row.*/
    find current budget no-lock no-error.
    if not avail budget then return.
    rez = false.
    run yn("","Будут удалены все записи по счету " + string(t-gl.gl) + ", вы уверены?","","", output rez).
    if rez then do:
        poz = t-gl.gl.
        for each budget where budget.year = v-year and budget.gl = t-gl.gl exclusive-lock.
            delete budget.
        end.
        for each t-gl where t-gl.gl = poz .
            delete t-gl.
        end.
        release t-gl.
        open query q1 for each t-gl no-lock.
        open query q2 for each budget where budget.year = v-year and budget.gl = t-gl.gl /* and budget.coder ne "" */ no-lock use-index budyear.
        /*displ ? @ budget.name ? @ budget.plan[v-month] ? @ budget.fact[v-month] ? @ budget.budget[v-month] ? @ budget.overdraft[v-month]
              help_g3 at x 8 y 272 view-as text no-label with frame fmain.*/
        displ t-gl.des  t-gl.plan  t-gl.fact  t-gl.budget  t-gl.overdraft
              help_g3 at x 8 y 272 view-as text no-label
              with frame fmain.
    end.
END.
/******************************************************************************/
on return of browse b2 do: /*Редактировать */
    /*Pos = b2:focused-row.*/
    vv-coder = budget.coder.
    vv-name = budget.name.
    find current budget no-lock no-error.
    vv-gl = t-gl.gl.
    if avail budget then run ShowData(budget.id,input-output vv-gl,vv-coder,vv-name).
    /*b2:SELECT-ROW(Pos).
    display  b2 WITH  FRAME fmain.*/
    displ ? @ budget.name ? @ budget.plan[v-month] ? @ budget.fact[v-month] ? @ budget.budget[v-month] ? @ budget.overdraft[v-month] with frame fmain.
    displ budget.plan[v-month] budget.fact[v-month] budget.budget[v-month] budget.overdraft[v-month]
        WITH FRAME fmain.
end.
/******************************************************************************/
ON GO OF browse b1 /*Расчет*/
DO:
  run yn("","Произвести расчет? ","","", output rez).
  if rez then do:
    OPEN QUERY  q-month FOR EACH t-month no-lock.
    ENABLE ALL WITH FRAME f-month.
    wait-for return of frame f-month
    FOCUS b-month IN FRAME f-month.
    v-mon = t-month.num.
    v-txt = t-month.month.
    hide frame f-month.
        for each budget use-index budyear where budget.year = v-year and
            (lookup(substring(string(budget.gl),1,4),"5781,5782,5783,5787,5788,5761,5763,5764,5765,5766,5768,5767,5799") > 0
            or lookup(string(budget.gl),"572151,572161,572171,572153,572940,572910,572930,572210") > 0) exclusive-lock.
            budget.fact[v-mon] = 0.
            budget.budget[v-mon] = 0.
            budget.overdraft[v-mon] = 0.
        end.
    {r-branch.i &proc = "budf1(DATE(v-mon, 1, v-year ),DATE(v-mon + 1, 1, v-year ) - 1,v-txt)"}
    for each budget use-index budyear where budget.year = v-year and
        (lookup(substring(string(budget.gl),1,4),"5781,5782,5783,5787,5788,5761,5763,5764,5765,5766,5768,5767,5799") > 0
        or lookup(string(budget.gl),"572151,572161,572171,572153,572940,572910,572930,572210") > 0) exclusive-lock.
        if budget.plan[v-mon] <> 0 then budget.overdraft[v-mon] = ((budget.fact[v-mon] + budget.budget[v-mon]) / budget.plan[v-mon]) * 100 .
    end.
    /*расчет сумм для t-gl*/
        for each t-gl.
            t-gl.plan = 0.
            t-gl.fact = 0.
            t-gl.budget = 0.
            t-gl.overdraft = 0.
        end.
        for each t-gl.
            for each budget where budget.year =  v-year and budget.gl = t-gl.gl and substring(budget.coder,8,3) begins "___"  no-lock.
                t-gl.plan = t-gl.plan + budget.plan[v-month].
                t-gl.fact = t-gl.fact + budget.fact[v-month].
                t-gl.budget = t-gl.budget + budget.budget[v-month].
            end.
            if t-gl.plan <=0 then t-gl.overdraft = ?.
            else t-gl.overdraft = ((t-gl.fact + t-gl.budget) / t-gl.plan) * 100 .
        end.
    /**************************************************************************************/
    find first t-gl.
    displ t-gl.des  t-gl.plan  t-gl.fact  t-gl.budget  t-gl.overdraft
      help_g3 at x 8 y 272 view-as text no-label
      with frame fmain.
  end.
END.
/******************************************************************************/

OPEN QUERY  q-month FOR EACH t-month no-lock.
ENABLE ALL WITH FRAME f-month.
wait-for return of frame f-month
FOCUS b-month IN FRAME f-month.
v-month = t-month.num.
v-monthname = t-month.month.
hide frame f-month.

/*расчет сумм для t-gl*/
    for each t-gl.
        t-gl.plan = 0.
        t-gl.fact = 0.
        t-gl.budget = 0.
        t-gl.overdraft = 0.
    end.
    for each t-gl.
        for each budget where budget.year =  v-year and budget.gl = t-gl.gl and substring(budget.coder,8,3) begins "___"  no-lock.
            t-gl.plan = t-gl.plan + budget.plan[v-month].
            t-gl.fact = t-gl.fact + budget.fact[v-month].
            t-gl.budget = t-gl.budget + budget.budget[v-month].
        end.
        if t-gl.plan <=0 then t-gl.overdraft = ?.
        else t-gl.overdraft = ((t-gl.fact + t-gl.budget) / t-gl.plan) * 100 .
    end.
/**************************************************************************************/

open query q1 for each t-gl /*where t-gl.gl ne 0*/ no-lock.
open query q2 for each budget where budget.year = v-year and budget.gl = t-gl.gl /* and budget.coder ne ""*/ no-lock use-index budyear.
enable all with frame fmain.

/*displ ? @ budget.name ? @ budget.plan[v-month] ? @ budget.fact[v-month] ? @ budget.budget[v-month] ? @ budget.overdraft[v-month]
      help_g3 at x 8 y 272 view-as text no-label
      with frame fmain.*/
displ v-monthname t-gl.des  t-gl.plan  t-gl.fact  t-gl.budget  t-gl.overdraft
      help_g3 at x 8 y 272 view-as text no-label
      with frame fmain.
{wait.i}


procedure ShowData:

    DEF input param  cs-name AS int.
    DEF input-output param  vvv-gl AS int.
    DEF input param vvv-coder AS char.
    DEF input param vvv-name AS char.

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
        v-gl     label  "Счет ГК             "  format "999999" validate(can-find(first gl where string(gl.gl) begins string(v-gl) no-lock),"Неверный счет!") skip
        v-des    label  "Наименование счета  "  format "x(60)"  skip
        v-coder  label  "Код расхода         "  format "x(12)"  skip
        v-name   label  "Наименование        "  format "x(60)"  skip
        v-txbname label  "Наимен. подраздел   "  format "x(60)"  skip
        v-dep     label "Подразд. ввода плана"  format "x(60)"  skip
        v-depname label "Контрол.департамент "  format "x(60)"  /*validate(can-find(first t-con where t-con.cod = v-depname no-lock),"Неверный код контрол. департамента!")*/ skip(1)
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

    on help of v-gl in frame form1 do:
        OPEN QUERY  q-gl FOR EACH gl where gl.gl >= 500000 and gl.gl < 600000 no-lock.
        ENABLE ALL WITH FRAME f-gl.
        wait-for return of frame f-gl
        FOCUS b-gl IN FRAME f-gl.
        v-gl = gl.gl.
        v-des = gl.des.
        hide frame f-gl.
        displ v-gl v-des with frame form1.
    end.
    on "END-ERROR" of frame f-gl do:
      hide frame f-gl no-pause.
    end.
    on "END-ERROR" of frame f-txb do:
      hide frame f-txb no-pause.
    end.

    on help of v-coder in frame form1 do:
        OPEN QUERY  q-code FOR EACH cods where cods.gl = v-gl no-lock.
        ENABLE ALL WITH FRAME f-code.
        wait-for return of frame f-code
        FOCUS b-code IN FRAME f-code.
        v-coder = cods.code.
        v-name = cods.des.
        hide frame f-code.
        displ v-coder v-name with frame form1.
        pause 0.
        OPEN QUERY  q-txb FOR EACH t-txb no-lock.
        ENABLE ALL WITH FRAME f-txb.
        wait-for return of frame f-txb
        FOCUS b-txb IN FRAME f-txb.
        v-txbname = t-txb.txbname.
        v-coder = substring(v-coder,1,7) + t-txb.txb.
        hide frame f-txb.
        displ v-coder v-txbname with frame form1.
    end.
    on help of v-txbname in frame form1 do:
        OPEN QUERY  q-txb FOR EACH t-txb no-lock.
        ENABLE ALL WITH FRAME f-txb.
        wait-for return of frame f-txb
        FOCUS b-txb IN FRAME f-txb.
        v-txbname = t-txb.txbname.
        if v-coder <> "" then v-coder = substring(v-coder,1,7) + t-txb.txb.
        hide frame f-txb.
        displ v-coder v-txbname with frame form1.
    end.
    on help of v-depname in frame form1 do:
        /*OPEN QUERY  q-con FOR EACH t-con no-lock.
        ENABLE ALL WITH FRAME f-con.
        wait-for return of frame f-con
        FOCUS b-con IN FRAME f-con.*/
        OPEN QUERY  q-txb FOR EACH t-txb no-lock.
        ENABLE ALL WITH FRAME f-txb.
        wait-for return of frame f-txb
        FOCUS b-txb IN FRAME f-txb.
        if trim(v-depname) = "" then  v-depname = t-txb.txb.
        else v-depname = v-depname + "," + t-txb.txb.
        hide frame f-txb.
        displ v-depname with frame form1.
    end.
    on help of v-dep in frame form1 do:
        /*OPEN QUERY  q-con FOR EACH t-con no-lock.
        ENABLE ALL WITH FRAME f-con.
        wait-for return of frame f-con
        FOCUS b-con IN FRAME f-con.
        v-dep = t-con.depname.
        v-ttt = t-con.cod.
        hide frame f-con.*/
        OPEN QUERY  q-txb FOR EACH t-txb no-lock.
        ENABLE ALL WITH FRAME f-txb.
        wait-for return of frame f-txb
        FOCUS b-txb IN FRAME f-txb.
        v-dep = t-txb.txbname.
        v-ttt = t-txb.txb.
        displ v-dep with frame form1.

    end.
    on "END-ERROR" of frame f-txb do:
      hide frame f-txb no-pause.
    end.
    on "END-ERROR" of frame f-code do:
      hide frame f-code no-pause.
    end.

    find first b-budget where b-budget.id = cs-name no-lock no-error.
    if avail b-budget then do:
        /*v-year = budget.year.*/
        v-gl = budget.gl.
        v-des = budget.des.
        v-coder = budget.coder.
        v-name = budget.name.
        v-txbname = budget.txbname.
        v-dep = budget.dep.
        v-txb = substring(v-coder,8,5).
        v-ttt = budget.remark[3].
        v-depname = budget.depname.
        i = 1.
        do while  i <= 12.
            v-plan[i] = budget.plan[i].
            v-fact[i] = budget.fact[i].
            v-budget[i] = budget.budget[i].
            v-overdraft[i] = budget.overdraft[i].
            i = i + 1.
        end.
    end.
    else do:
        v-gl = vvv-gl.
        v-des = "".
        v-coder = substring(vvv-coder,1,7).
        v-name = vvv-name.
        v-txbname = "".
        v-dep = "".
        v-txb = "".
        v-ttt = "".
        v-depname = "".
        i = 1.
        do while  i <= 12.
            v-plan[i] = 0.
            v-fact[i] = 0.
            v-budget[i] = 0.
            v-overdraft[i] = 0.
            i = i + 1.
        end.
    end.

     v-id  = cs-name.
    /*displ v-gl v-des v-coder v-name v-txbname v-dep v-depname with frame form1.*/
    display  /*v-year*/ v-gl v-des  v-coder  v-name  v-txbname v-dep v-depname  v-plan[1] v-fact[1]
    v-budget[1] v-overdraft[1] v-plan[2]  v-fact[2] v-budget[2] v-overdraft[2] v-plan[3] v-fact[3] v-budget[3]  v-overdraft[3]
    v-plan[4] v-fact[4] v-budget[4] v-overdraft[4] v-plan[5] v-fact[5] v-budget[5]  v-overdraft[5]
    v-plan[6]  v-fact[6] v-budget[6]  v-overdraft[6] v-plan[7] v-fact[7]  v-budget[7] v-overdraft[7]
    v-plan[8] v-fact[8] v-budget[8] v-overdraft[8]  v-plan[9] v-fact[9] v-budget[9] v-overdraft[9]
    v-plan[10] v-fact[10] v-budget[10]  v-overdraft[10]  v-plan[11] v-fact[11] v-budget[11] v-overdraft[11]
    v-plan[12] v-fact[12]  v-budget[12] v-overdraft[12]  with frame form1.

    update v-gl with frame form1.
    find first gl where gl.gl = v-gl no-lock no-error.
    if available gl then v-des = gl.des.
    update v-des v-coder with frame form1.
    if v-name = "" then do:
        find first cods where cods.code begins substring(v-coder,1,7) no-lock no-error.
        if available cods then v-name = cods.des.
    end.
    update v-name v-txbname v-dep v-depname with frame form1.

     ON CHOOSE OF save-button
     DO:
       find first b-budget where b-budget.id = cs-name exclusive-lock no-error.
       if avail b-budget then do:
            b-budget.year = v-year.
            b-budget.gl = int(v-gl:SCREEN-VALUE).
            vvv-gl = int(v-gl:SCREEN-VALUE).
            b-budget.des = v-des:SCREEN-VALUE.
            b-budget.coder = v-coder:SCREEN-VALUE.
            b-budget.code = substring(v-coder:SCREEN-VALUE,1,7).
            b-budget.name = v-name:SCREEN-VALUE.
            b-budget.txbname = v-txbname:SCREEN-VALUE.
            if substring(v-coder:SCREEN-VALUE,8,5) <> "" then b-budget.txb = substring(v-coder:SCREEN-VALUE,8,5).
            else do:
                find first t-txb where t-txb.txbname begins v-txbname:SCREEN-VALUE no-error.
                if available t-txb then b-budget.txb = t-txb.txb.
            end.
            b-budget.dep = v-dep:SCREEN-VALUE.
            b-budget.depname = v-depname:SCREEN-VALUE.
            b-budget.remark[3] = v-ttt.

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
            budget.id = newnom.
            budget.year = v-year.
            budget.gl = int(v-gl:SCREEN-VALUE).
            budget.des = v-des:SCREEN-VALUE.
            budget.coder = v-coder:SCREEN-VALUE.
            budget.code = substring(v-coder:SCREEN-VALUE,1,7).
            /*budget.txb = substring(v-coder:SCREEN-VALUE,8,5).*/
            budget.name = v-name:SCREEN-VALUE.
            budget.txbname = v-txbname:SCREEN-VALUE.
            if substring(v-coder:SCREEN-VALUE,8,5) <> "" then budget.txb = substring(v-coder:SCREEN-VALUE,8,5).
            else do:
                find first t-txb where t-txb.txbname begins v-txbname:SCREEN-VALUE no-error.
                if available t-txb then budget.txb = t-txb.txb.
            end.
            budget.dep = v-dep:SCREEN-VALUE.
            budget.depname = v-depname:SCREEN-VALUE.
            budget.remark[3] = v-ttt.

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
       v-gl = int(v-gl:SCREEN-VALUE).
       v-coder = v-coder:SCREEN-VALUE.
       run cortotal(v-gl,v-coder). /* корректировка total данных */

       find first b-budget where b-budget.id = cs-name no-lock no-error.
       find first budget where budget.id = cs-name no-lock no-error.

       apply "endkey" to frame form1.
     END.


     ON CHOOSE OF cancel-button
     DO:
        apply "endkey" to frame form1.
     END.


    enable   /*v-year v-gl v-des  v-coder  v-name  v-txbname v-depname */ v-plan[1] v-fact[1]
    v-budget[1] /* v-overdraft[1] */ v-plan[2]  v-fact[2] v-budget[2] /* v-overdraft[2] */ v-plan[3] v-fact[3] v-budget[3]  /* v-overdraft[3]
    */ v-plan[4] v-fact[4] v-budget[4] /* v-overdraft[4] */ v-plan[5] v-fact[5] v-budget[5]  /* v-overdraft[5]
    */ v-plan[6]  v-fact[6] v-budget[6]  /* v-overdraft[6] */ v-plan[7] v-fact[7]  v-budget[7] /* v-overdraft[7]
    */ v-plan[8] v-fact[8] v-budget[8] /* v-overdraft[8]  */ v-plan[9] v-fact[9] v-budget[9] /* v-overdraft[9]
    */ v-plan[10] v-fact[10] v-budget[10]  /* v-overdraft[10]  */ v-plan[11] v-fact[11] v-budget[11] /* v-overdraft[11]
    */ v-plan[12] v-fact[12]  v-budget[12] /* v-overdraft[12]*/  save-button cancel-button with frame form1.

    display  /*v-year*/ v-gl v-des  v-coder  v-name  v-txbname v-dep v-depname  v-plan[1] v-fact[1]
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
   for each t-gl.
        t-gl.plan = 0.
        t-gl.fact = 0.
        t-gl.budget = 0.
        t-gl.overdraft = 0.
    end.
    for each t-gl.
        for each budget where budget.year =  v-year and budget.gl = t-gl.gl and substring(budget.coder,8,3) begins "___"  no-lock.
            t-gl.plan = t-gl.plan + budget.plan[v-month].
            t-gl.fact = t-gl.fact + budget.fact[v-month].
            t-gl.budget = t-gl.budget + budget.budget[v-month].
            t-gl.overdraft = ((t-gl.fact + t-gl.budget) / t-gl.plan) * 100 .
        end.
    end.
end procedure.