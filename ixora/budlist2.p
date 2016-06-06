/* budlist2.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Ввод плана по позициям бюджета
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
def var v-year as int.
def var v-gl as int.
def var v-des as char.
def var v-name as char.
def var v-coder as char.
def var v-depname as char.
def var v-dep as char.
def var v-txb as char.
def var v-txbname as char.
def var v-access as int.
def var Pos as int.
def var v-plan1 as decimal.
def var v-fact1 as decimal.
def var v-budget1 as decimal.
def var v-overdraft1 as decimal.
def var v-id    as int.
def var newnom as int.
def var v-month as int.
def var v-monthname as char .
def var v-con as char.
def var v-ttt as char.
def var v-pr as logi init false.
def shared var g-today as date.
def shared var g-ofc as char.

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
find first budget use-index budyear where budget.year =  v-year no-lock no-error.
if available budget then v-access = budget.access.
else return.
/*------------------------------------------------------------------------------*/
v-month = month(today).
case v-month:
    when 1 then v-monthname = "Январь".
    when 2 then v-monthname = "Февраль".
    when 3 then v-monthname = "Март".
    when 4 then v-monthname = "Апрель".
    when 5 then v-monthname = "Май".
    when 6 then v-monthname = "Июнь".
    when 7 then v-monthname = "Июль".
    when 8 then v-monthname = "Август".
    when 9 then v-monthname = "Сентябрь".
    when 10 then v-monthname = "Октябрь".
    when 11 then v-monthname = "Ноябрь".
    when 12 then v-monthname = "Декабрь".
end case.

define temp-table t-gl no-undo
field gl as int
field des as char
field depname as char
index ind is primary  gl.

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

/*DECLARE nx CURSOR FOR
 select budget.txb, budget.txbname from budget where budget.year =  v-year group by budget.txb.

open nx.
repeat:
    FETCH nx INTO v-txb,v-txbname.
    create t-txb.
    t-txb.txb = v-txb.
    t-txb.txbname = v-txbname.
end.
close nx.*/
/***********************************************************************************************************/

define temp-table t-con no-undo
field cod as char
field dep as char.

find first budofc where budofc.ofc = g-ofc no-lock no-error.
if not available budofc then do:
    message "Сотрудник отсутствует в списке доступа!" view-as alert-box.
    return.
end.
if budofc.txb = "" then do:
    for each t-txb no-lock.
        create t-con.
        t-con.cod = t-txb.txb.
        t-con.dep = t-txb.txbname.
    end.
end.
else do:
    for each budofc where budofc.ofc = g-ofc no-lock.
        for each t-txb where t-txb.txb = budofc.txb no-lock.
            create t-con.
            t-con.cod = t-txb.txb.
            t-con.dep = t-txb.txbname.
        end.
    end.
end.

/*if budofc.txb = "" then do:
    DECLARE n CURSOR FOR
      select budget.remark[3], budget.dep from budget where budget.year =  v-year and budget.dep <> "" and substring(budget.coder,8,5) <> "" and substring(budget.coder,8,5) <> "TXB00" and substring(budget.coder,8,3) <> "___" group by budget.dep.
    open n.
    repeat:
        FETCH n INTO v-ttt, v-dep.
        create t-con.
        t-con.cod = v-ttt.
        t-con.dep = v-dep.
    end.
    close n.
end.
else do:
    DECLARE n22 CURSOR FOR
    select budget.remark[3], budget.dep from budget where budget.year =  v-year and budget.dep <> "" and substring(budget.coder,8,5) <> "" and substring(budget.coder,8,3) <> "___" and substring(budget.coder,8,5) <> "TXB00" and trim(budget.remark[3]) = trim(budofc.txb) group by budget.dep.
    open n22.
    repeat:
        FETCH n22 INTO v-ttt, v-dep.
        create t-con.
        t-con.cod = v-ttt.
        t-con.dep = v-dep.
    end.
    close n22.
end.*/

DEFINE QUERY q-con FOR t-con.

DEFINE BROWSE b-con QUERY q-con
    DISPLAY t-con.dep label "Департамент/филиал  "format "x(50)"  WITH  15 DOWN.
DEFINE FRAME f-con b-con  WITH overlay row 5 COLUMN 15 width 65 title "Выберите подразделение".
/***********************************************************************************************************/
def var help_l3 as char init "<TAB> - перейти к другому окну,  <ENTER> - редактировать,  <F2>-фильтр" label "" format "x(90)".

def var help_g3 as char init "<TAB> - перейти к другому окну,  <СТРЕЛКА ВПРАВО> - обновить список" label "" format "x(90)".

def var cnt as int.

DEFINE FRAME opt
    v-gl label " введите счет " format ">>>>>9"
with overlay row 10 column 15 side-label.
on "END-ERROR" of frame opt do:
  hide frame opt no-pause.
end.

def query  q1 for t-gl.
def browse b1 query q1
           displ t-gl.gl label "Счет ГЛ" format "999999"
                 t-gl.des label "Наименование счета" format "x(39)"
           with 19 down no-label width 49 .


def query  q2 for budget.
def browse b2 query q2
           displ budget.coder   label "Код расхода" format "x(12)"
                 budget.name    label "Наименование" format "x(45)"
                /* budget.name    label "Наимен расхода" format "x(38)"*/
           with 23 down column 2  width 58. /*title "За " + v-monthname.*/

def frame fmain
          v-con          at x 1 y  1 label " Подраздел" view-as text format "x(37)"
          budget.txbname at x 416 y 1 label "Деп." view-as text format "x(50)"
          b1   at x 8   y 8 help " "
          b2   at x 400 y 8 help " "
          v-monthname          at x 8 y  220 label "Месяц        " view-as text format "x(15)"
          budget.name          at x 8 y  228 label "Наименование " view-as text format "x(90)"
          budget.plan[v-month]       at x 8 y  236 label "План         " view-as text format "->>>>>>>>>9.99"
          budget.fact[v-month]       at x 8 y  242 label "Факт         " view-as text format "->>>>>>>>>9.99"
          budget.budget[v-month]     at x 8 y  250 label "Сверх бюджет " view-as text format "->>>>>>>>>9.99"
          budget.overdraft[v-month]  at x 8 y  258 label "% исполнения "  view-as text format "->>>>>>>>>9"
          "____________________________________________________________________________________________" at x 8 y 266 view-as text

          with row 2  side-labels  no-box with size 110 by 35 .


/* обновление списка на правой панели */
on "cursor-right" of browse b1 do:
   close query q2.
   open query q2 for each budget where budget.year = v-year and budget.gl = t-gl.gl and substring(budget.coder,8,5) <> "" and trim(budget.remark[3]) =  trim(v-ttt)
        and substring(budget.coder,8,3) <> "___" and substring(budget.coder,8,5) <> "TXB00" no-lock use-index budyear.
   if can-find (first budget where budget.year = v-year and budget.gl = t-gl.gl and budget.dep = v-con and substring(budget.coder,8,5) <> ""
        and substring(budget.coder,8,3) <> "___" and substring(budget.coder,8,5) <> "TXB00" ) then  browse b2:refresh().
   lastgrp = t-gl.gl.
end.


/* переход на панель счетов */
on "tab" of browse b1 do:
   if avail t-gl then do:
   if lastgrp <> t-gl.gl then do:
      lastgrp = t-gl.gl.
      close query q2.
      open query q2 for each budget where budget.year = v-year and budget.gl = t-gl.gl and substring(budget.coder,8,5) <> "" and trim(budget.remark[3]) =  trim(v-ttt)
        and substring(budget.coder,8,3) <> "___" and substring(budget.coder,8,5) <> "TXB00" no-lock use-index budyear.
      if can-find (first budget where budget.year = v-year and budget.gl = t-gl.gl and budget.dep = v-con and substring(budget.coder,8,5) <> ""
        and substring(budget.coder,8,3) <> "___" and substring(budget.coder,8,5) <> "TXB00" ) then  browse b2:refresh().
   end.
   if avail budget then displ v-monthname v-con budget.txbname budget.name budget.plan[v-month] budget.fact[v-month] budget.budget[v-month] budget.overdraft[v-month] with frame fmain. else
   displ ? @ budget.txbname ? @ budget.name ? @ budget.plan[v-month] ? @ budget.fact[v-month] ? @ budget.budget[v-month] ? @ budget.overdraft[v-month] with frame fmain.
   displ
         help_l3 at x 8 y 272 view-as text no-label  /*y 152*/
         with frame fmain.
   end.
end.

/* переход на панель групп */
on "tab" of browse b2 do:
   displ ? @ budget.txbname ? @ budget.name ? @ budget.plan[v-month] ? @ budget.fact[v-month] ? @ budget.budget[v-month] ? @ budget.overdraft[v-month]
         help_g3 at x 8 y 272 view-as text no-label /*y 152*/
         with frame fmain.
end.

/* обновление сведений  суммы */
on value-changed of browse b2 do:
   if avail budget then displ v-monthname v-con budget.txbname budget.name budget.plan[v-month] budget.fact[v-month] budget.budget[v-month] budget.overdraft[v-month] with frame fmain.
   else
   displ ? @ budget.name ? @ budget.plan[v-month] ? @ budget.fact[v-month] ? @ budget.budget[v-month] ? @ budget.overdraft[v-month] with frame fmain.
end.


/*  */
on "help" of browse b2 do:
   if not available budget then leave.
end.

ON HELP OF browse b1 /*F2*/
DO:
  def var Pos as int.
  /*Pos = b1:focused-row.*/
  v-gl = 0.
  update v-gl with  frame opt.
  hide frame opt.
  find first t-gl where string(t-gl.gl) begins string(v-gl) no-lock no-error.
  if not avail t-gl then open query q1 for each t-gl no-lock .
  else open query q1 for each t-gl where string(t-gl.gl) begins string(v-gl) no-lock .
END.

on return of browse b2 do: /*Редактировать */
    /*Pos = b2:focused-row.*/
    find current budget no-lock no-error.
    if available budget then do:
        v-coder = budget.coder.
        v-depname = budget.depname.
        v-txbname = budget.txbname.
        v-plan1 = budget.plan[v-month].
        v-fact1 = budget.fact[v-month].
        v-budget1 = budget.budget[v-month].
        v-overdraft1 = budget.overdraft[v-month].
        if avail budget then run ShowData(budget.id).
        /*b2:SELECT-ROW(Pos).
        display  b2 WITH  FRAME fmain.*/
        displ budget.name budget.plan[v-month] budget.fact[v-month] budget.budget[v-month] budget.overdraft[v-month] with frame fmain.
    end.
end.


OPEN QUERY  q-con FOR EACH t-con no-lock.
ENABLE ALL WITH FRAME f-con.
wait-for return of frame f-con
FOCUS b-con IN FRAME f-con.
v-con = t-con.dep.
v-ttt = t-con.cod.
hide frame f-con.
/*v-pr = false.
for each budofc where budofc.ofc = g-ofc no-lock .
    if budofc.txb = v-ttt or budofc.txb = "" then v-pr = true.
end.
if not v-pr then do:
    message "Не ваш департамент!" view-as alert-box.
    return.
end.*/

DECLARE g CURSOR FOR
 select budget.gl, budget.des from budget where budget.year =  v-year and budget.dep = v-con and substring(budget.coder,8,5) <> ""
        and substring(budget.coder,8,3) <> "___" and substring(budget.coder,8,5) <> "TXB00" group by budget.gl.

 open g.
 repeat:
    FETCH g INTO v-gl,v-des.
    create t-gl.
    t-gl.gl = v-gl.
    t-gl.des = v-des.
  end.
  close g.


open query q1 for each t-gl no-lock.
open query q2 for each budget where budget.year = v-year and budget.gl = t-gl.gl and substring(budget.coder,8,5) <> "" and trim(budget.remark[3]) =  trim(v-ttt)
        and substring(budget.coder,8,3) <> "___" and substring(budget.coder,8,5) <> "TXB00" no-lock use-index budyear.
enable all with frame fmain.

displ v-con ? @ budget.txbname v-monthname ? @ budget.name ? @ budget.plan[v-month] ? @ budget.fact[v-month] ? @ budget.budget[v-month] ? @ budget.overdraft[v-month]
      help_g3 at x 8 y 272 view-as text no-label  /*y 152*/
      with frame fmain.

{wait.i}

procedure ShowData:

    DEF input param  cs-name AS int.

    def var v-plan1  as decimal format ">>>>>>>>>9.99".
    def var v-fact1  as decimal format ">>>>>>>>>9.99".
    def var v-budget1  as decimal format ">>>>>>>>>9.99".
    def var v-overdraft1  as decimal format ">>>>>>>>>9".

    def var v-plan2  as decimal format ">>>>>>>>>9.99".
    def var v-fact2  as decimal format ">>>>>>>>>9.99".
    def var v-budget2  as decimal format ">>>>>>>>>9.99".
    def var v-overdraft2  as decimal format ">>>>>>>>>9".

    def var v-plan3  as decimal format ">>>>>>>>>9.99".
    def var v-fact3  as decimal format ">>>>>>>>>9.99".
    def var v-budget3  as decimal format ">>>>>>>>>9.99".
    def var v-overdraft3  as decimal format ">>>>>>>>>9".

    def var v-plan4  as decimal format ">>>>>>>>>9.99".
    def var v-fact4  as decimal format ">>>>>>>>>9.99".
    def var v-budget4  as decimal format ">>>>>>>>>9.99".
    def var v-overdraft4  as decimal format ">>>>>>>>>9".

    def var v-plan5  as decimal format ">>>>>>>>>9.99".
    def var v-fact5  as decimal format ">>>>>>>>>9.99".
    def var v-budget5  as decimal format ">>>>>>>>>9.99".
    def var v-overdraft5  as decimal format ">>>>>>>>>9".

    def var v-plan6  as decimal format ">>>>>>>>>9.99".
    def var v-fact6  as decimal format ">>>>>>>>>9.99".
    def var v-budget6  as decimal format ">>>>>>>>>9.99".
    def var v-overdraft6  as decimal format ">>>>>>>>>9".

    def var v-plan7  as decimal format ">>>>>>>>>9.99".
    def var v-fact7  as decimal format ">>>>>>>>>9.99".
    def var v-budget7  as decimal format ">>>>>>>>>9.99".
    def var v-overdraft7  as decimal format ">>>>>>>>>9".

    def var v-plan8  as decimal format ">>>>>>>>>9.99".
    def var v-fact8  as decimal format ">>>>>>>>>9.99".
    def var v-budget8  as decimal format ">>>>>>>>>9.99".
    def var v-overdraft8  as decimal format ">>>>>>>>>9".

    def var v-plan9  as decimal format ">>>>>>>>>9.99".
    def var v-fact9  as decimal format ">>>>>>>>>9.99".
    def var v-budget9  as decimal format ">>>>>>>>>9.99".
    def var v-overdraft9  as decimal format ">>>>>>>>>9".

    def var v-plan10  as decimal format ">>>>>>>>>9.99".
    def var v-fact10  as decimal format ">>>>>>>>>9.99".
    def var v-budget10  as decimal format ">>>>>>>>>9.99".
    def var v-overdraft10  as decimal format ">>>>>>>>>9".

    def var v-plan11  as decimal format ">>>>>>>>>9.99".
    def var v-fact11  as decimal format ">>>>>>>>>9.99".
    def var v-budget11  as decimal format ">>>>>>>>>9.99".
    def var v-overdraft11  as decimal format ">>>>>>>>>9".

    def var v-plan12  as decimal format ">>>>>>>>>9.99".
    def var v-fact12  as decimal format ">>>>>>>>>9.99".
    def var v-budget12  as decimal format ">>>>>>>>>9.99".
    def var v-overdraft12  as decimal format ">>>>>>>>>9".
    /*************************************************************/
    def var v-planold1  as decimal format "->>>>>>>>>9.99".
    def var v-planold2  as decimal format "->>>>>>>>>9.99".
    def var v-planold3  as decimal format "->>>>>>>>>9.99".
    def var v-planold4  as decimal format "->>>>>>>>>9.99".
    def var v-planold5  as decimal format "->>>>>>>>>9.99".
    def var v-planold6  as decimal format "->>>>>>>>>9.99".
    def var v-planold7  as decimal format "->>>>>>>>>9.99".
    def var v-planold8  as decimal format "->>>>>>>>>9.99".
    def var v-planold9  as decimal format "->>>>>>>>>9.99".
    def var v-planold10  as decimal format "->>>>>>>>>9.99".
    def var v-planold11  as decimal format "->>>>>>>>>9.99".
    def var v-planold12  as decimal format "->>>>>>>>>9.99".

     def buffer b-budget for budget.

     DEFINE BUTTON save-button LABEL "Сохранить".
     DEFINE BUTTON cancel-button LABEL "Отмена".


     define frame form1
        /*v-year label "Год"  skip*/
        v-gl     label "Счет ГК           "  format "999999" validate(can-find(first gl where string(gl.gl) begins string(v-gl) no-lock),"Неверный счет!") skip
        v-des    label "Наименование счета"  format "x(60)"  skip
        v-coder  label "Код расхода       "  format "x(12)"  skip
        v-name   label "Наименование      "  format "x(60)"  skip
        v-txbname label "Подразделение     "  format "x(60)"  skip
        v-depname label "Контр. департамент"  format "x(60)"  skip(1)
        /*"           ПЛАН                     ФАКТ                   СВЕРХ БЮДЖЕТ                 % ПРЕВЫШЕНИЕ" skip*/
        "           ПЛАН        " skip
        "-----------------------------------------------------------------------------------------------------" skip
        v-plan1      label " Январь  " format ">>>>>>>>>9.99" skip(1)
        /* v-fact1      label " Январь  " format ">>>>>>>>>9.99"
        v-budget1    label " Январь  " format ">>>>>>>>>9.99"
        v-overdraft1 label " Январь  " format ">>>>>>>>>9.99" skip(1)*/

        v-plan2      label " Февраль " format ">>>>>>>>>9.99" skip(1)
        /* v-fact2      label " Февраль " format ">>>>>>>>>9.99"
        v-budget2    label " Февраль " format ">>>>>>>>>9.99"
        v-overdraft2 label " Февраль " format ">>>>>>>>>9.99"  skip(1)*/

        v-plan3      label " Март    " format ">>>>>>>>>9.99" skip(1)
        /* v-fact3      label " Март    " format ">>>>>>>>>9.99"
        v-budget3    label " Март    " format ">>>>>>>>>9.99"
        v-overdraft3 label " Март    " format ">>>>>>>>>9.99"  skip(1)*/

        v-plan4      label " Апрель  " format ">>>>>>>>>9.99" skip(1)
        /* v-fact4      label " Апр     " format ">>>>>>>>>9.99"
        v-budget4    label " Апр     " format ">>>>>>>>>9.99"
        v-overdraft4 label " Апр     " format ">>>>>>>>>9.99"  skip(1)*/

        v-plan5      label " Май     " format ">>>>>>>>>9.99" skip(1)
        /* v-fact5      label " Май     " format ">>>>>>>>>9.99"
        v-budget5    label " Май     " format ">>>>>>>>>9.99"
        v-overdraft5 label " Май     " format ">>>>>>>>>9.99"  skip(1)*/

        v-plan6      label " Июнь    " format ">>>>>>>>>9.99" skip(1)
        /* v-fact6      label " Июнь    " format ">>>>>>>>>9.99"
        v-budget6    label " Июнь    " format ">>>>>>>>>9.99"
        v-overdraft6 label " Июнь    " format ">>>>>>>>>9.99"  skip(1)*/

        v-plan7      label " Июль    " format ">>>>>>>>>9.99" skip(1)
        /* v-fact7      label " Июль    " format ">>>>>>>>>9.99"
        v-budget7    label " Июль    " format ">>>>>>>>>9.99"
        v-overdraft7 label " Июль    " format ">>>>>>>>>9.99"  skip(1)*/

        v-plan8      label " Август  " format ">>>>>>>>>9.99" skip(1)
        /* v-fact8      label " Август  " format ">>>>>>>>>9.99"
        v-budget8    label " Август  " format ">>>>>>>>>9.99"
        v-overdraft8 label " Август  " format ">>>>>>>>>9.99"  skip(1)*/

        v-plan9      label " Сентябрь" format ">>>>>>>>>9.99" skip(1)
        /* v-fact9      label " Сентябрь" format ">>>>>>>>>9.99"
        v-budget9    label " Сентябрь" format ">>>>>>>>>9.99"
        v-overdraft9 label " Сентябрь" format ">>>>>>>>>9.99"  skip(1)*/

        v-plan10      label " Октябрь " format ">>>>>>>>>9.99" skip(1)
        /* v-fact10      label " Октябрь " format ">>>>>>>>>9.99"
        v-budget10    label " Октябрь " format ">>>>>>>>>9.99"
        v-overdraft10 label " Октябрь " format ">>>>>>>>>9.99"  skip(1)*/

        v-plan11      label " Ноябрь  " format ">>>>>>>>>9.99" skip(1)
        /* v-fact11      label " Ноябрь  " format ">>>>>>>>>9.99"
        v-budget11    label " Ноябрь  " format ">>>>>>>>>9.99"
        v-overdraft11 label " Ноябрь  " format ">>>>>>>>>9.99"  skip(1)*/

        v-plan12      label " Декабрь " format ">>>>>>>>>9.99" skip(1)
        /* v-fact12      label " Декабрь " format ">>>>>>>>>9.99"
        v-budget12    label " Декабрь " format ">>>>>>>>>9.99"
        v-overdraft12 label " Декабрь " format ">>>>>>>>>9.99"  skip(1)*/

     space(18) save-button  cancel-button
     WITH SIDE-LABELS centered row 1 width 110 TITLE "Данные ".

    find first b-budget where b-budget.id = cs-name no-lock no-error.
    if avail b-budget then do:
        /*v-year = budget.year.*/
        v-gl = budget.gl.
        v-des = budget.des.
        v-coder = budget.coder.
        v-name = budget.name.
        v-txbname = budget.txbname.
        v-depname = budget.depname.
        v-plan1 = budget.plan[1].
        /* v-fact1 = budget.fact[v-month].
        v-budget1 = budget.budget[v-month].
        v-overdraft1 = budget.overdraft[v-month].*/
        v-plan2 = budget.plan[2].
        /* v-fact2 = budget.fact[2].
        v-budget2 = budget.budget[2].
        v-overdraft2 = budget.overdraft[2].*/

        v-plan3 = budget.plan[3].
        /* v-fact3 = budget.fact[3].
        v-budget3 = budget.budget[3].
        v-overdraft3 = budget.overdraft[3].*/

        v-plan4 = budget.plan[4].
        /* v-fact4 = budget.fact[4].
        v-budget4 = budget.budget[4].
        v-overdraft4 = budget.overdraft[4].*/

        v-plan5 = budget.plan[5].
        /* v-fact5 = budget.fact[5].
        v-budget5 = budget.budget[5].
        v-overdraft5 = budget.overdraft[5].*/

        v-plan6 = budget.plan[6].
        /* v-fact6 = budget.fact[6].
        v-budget6 = budget.budget[6].
        v-overdraft6 = budget.overdraft[6].*/

        v-plan7 = budget.plan[7].
        /* v-fact7 = budget.fact[7].
        v-budget7 = budget.budget[7].
        v-overdraft7 = budget.overdraft[7].*/

        v-plan8 = budget.plan[8].
        /* v-fact8 = budget.fact[8].
        v-budget8 = budget.budget[8].
        v-overdraft8 = budget.overdraft[8].*/

        v-plan9 = budget.plan[9].
        /* v-fact9 = budget.fact[9].
        v-budget9 = budget.budget[9].
        v-overdraft9 = budget.overdraft[9].*/

        v-plan10 = budget.plan[10].
        /* v-fact10 = budget.fact[10].
        v-budget10 = budget.budget[10].
        v-overdraft10 = budget.overdraft[10].*/

        v-plan11 = budget.plan[11].
        /* v-fact11 = budget.fact[11].
        v-budget11 = budget.budget[11].
        v-overdraft11 = budget.overdraft[11].*/

        v-plan12 = budget.plan[12].
        /* v-fact12 = budget.fact[12].
        v-budget12 = budget.budget[12].
        v-overdraft12 = budget.overdraft[12].*/
        /*******************************************************************************/
        v-planold1 = budget.plan[1].
        v-planold2 = budget.plan[2].
        v-planold3 = budget.plan[3].
        v-planold4 = budget.plan[4].
        v-planold5 = budget.plan[5].
        v-planold6 = budget.plan[6].
        v-planold7 = budget.plan[7].
        v-planold8 = budget.plan[8].
        v-planold9 = budget.plan[9].
        v-planold10 = budget.plan[10].
        v-planold11 = budget.plan[11].
        v-planold12 = budget.plan[12].

    end.


     v-id  = cs-name.

     ON CHOOSE OF save-button
     DO:
       find first b-budget where b-budget.id = cs-name exclusive-lock no-error.
       if avail b-budget then do:
       /* b-budget.year = v-year.
        b-budget.gl = int(v-gl:SCREEN-VALUE).
        b-budget.des = v-des:SCREEN-VALUE.
        b-budget.coder = v-coder:SCREEN-VALUE.
        b-budget.code = substring(v-coder:SCREEN-VALUE,1,7).
        b-budget.txb = v-coder:SCREEN-VALUE.
        b-budget.name = v-name:SCREEN-VALUE.
        b-budget.txbname = v-txbname:SCREEN-VALUE.
        b-budget.depname = v-depname:SCREEN-VALUE.*/

        b-budget.plan[1] = decimal(v-plan1:SCREEN-VALUE).
        /* b-budget.fact[v-month] = decimal(v-fact1:SCREEN-VALUE).
        b-budget.budget[v-month] = decimal(v-budget1:SCREEN-VALUE).
        b-budget.overdraft[v-month] = decimal(v-overdraft1:SCREEN-VALUE).*/

        b-budget.plan[2] = decimal(v-plan2:SCREEN-VALUE).
        /* b-budget.fact[2] = decimal(v-fact2:SCREEN-VALUE).
        b-budget.budget[2] = decimal(v-budget2:SCREEN-VALUE).
        b-budget.overdraft[2] = decimal(v-overdraft2:SCREEN-VALUE).*/

        b-budget.plan[3] = decimal(v-plan3:SCREEN-VALUE).
        /* b-budget.fact[3] = decimal(v-fact3:SCREEN-VALUE).
        b-budget.budget[3] = decimal(v-budget3:SCREEN-VALUE).
        b-budget.overdraft[3] = decimal(v-overdraft3:SCREEN-VALUE).*/

        b-budget.plan[4] = decimal(v-plan4:SCREEN-VALUE).
        /* b-budget.fact[4] = decimal(v-fact4:SCREEN-VALUE).
        b-budget.budget[4] = decimal(v-budget4:SCREEN-VALUE).
        b-budget.overdraft[4] = decimal(v-overdraft4:SCREEN-VALUE).*/

        b-budget.plan[5] = decimal(v-plan5:SCREEN-VALUE).
        /* b-budget.fact[5] = decimal(v-fact5:SCREEN-VALUE).
        b-budget.budget[5] = decimal(v-budget5:SCREEN-VALUE).
        b-budget.overdraft[5] = decimal(v-overdraft5:SCREEN-VALUE).*/

        b-budget.plan[6] = decimal(v-plan6:SCREEN-VALUE).
        /* b-budget.fact[6] = decimal(v-fact6:SCREEN-VALUE).
        b-budget.budget[6] = decimal(v-budget6:SCREEN-VALUE).
        b-budget.overdraft[6] = decimal(v-overdraft6:SCREEN-VALUE).*/

        b-budget.plan[7] = decimal(v-plan7:SCREEN-VALUE).
        /* b-budget.fact[7] = decimal(v-fact7:SCREEN-VALUE).
        b-budget.budget[7] = decimal(v-budget7:SCREEN-VALUE).
        b-budget.overdraft[7] = decimal(v-overdraft7:SCREEN-VALUE).*/

        b-budget.plan[8] = decimal(v-plan8:SCREEN-VALUE).
        /* b-budget.fact[8] = decimal(v-fact8:SCREEN-VALUE).
        b-budget.budget[8] = decimal(v-budget8:SCREEN-VALUE).
        b-budget.overdraft[8] = decimal(v-overdraft8:SCREEN-VALUE).*/

        b-budget.plan[9] = decimal(v-plan9:SCREEN-VALUE).
        /* b-budget.fact[9] = decimal(v-fact9:SCREEN-VALUE).
        b-budget.budget[9] = decimal(v-budget9:SCREEN-VALUE).
        b-budget.overdraft[9] = decimal(v-overdraft9:SCREEN-VALUE).*/

        b-budget.plan[10] = decimal(v-plan10:SCREEN-VALUE).
        /* b-budget.fact[10] = decimal(v-fact10:SCREEN-VALUE).
        b-budget.budget[10] = decimal(v-budget10:SCREEN-VALUE).
        b-budget.overdraft[10] = decimal(v-overdraft10:SCREEN-VALUE).*/

        b-budget.plan[11] = decimal(v-plan11:SCREEN-VALUE).
        /* b-budget.fact[11] = decimal(v-fact11:SCREEN-VALUE).
        b-budget.budget[11] = decimal(v-budget11:SCREEN-VALUE).
        b-budget.overdraft[11] = decimal(v-overdraft11:SCREEN-VALUE).*/

        b-budget.plan[12] = decimal(v-plan12:SCREEN-VALUE).
        /* b-budget.fact[12] = decimal(v-fact12:SCREEN-VALUE).
        b-budget.budget[12] = decimal(v-budget12:SCREEN-VALUE).
        b-budget.overdraft[12] = decimal(v-overdraft12:SCREEN-VALUE).*/

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
        budget.name = v-name:SCREEN-VALUE.
        budget.txbname = v-txbname:SCREEN-VALUE.
        if substring(v-coder:SCREEN-VALUE,8,5) <> "" then budget.txb = substring(v-coder:SCREEN-VALUE,8,5).
        else do:
            find first t-txb where t-txb.txbname begins v-txbname:SCREEN-VALUE no-error.
            if available t-txb then budget.txb = t-txb.txb.
        end.
        budget.txbname = v-txbname:SCREEN-VALUE.
        budget.depname = v-depname:SCREEN-VALUE.

        budget.plan[1] = decimal(v-plan1:SCREEN-VALUE).
        /* budget.fact[v-month] = decimal(v-fact1:SCREEN-VALUE).
        budget.budget[v-month] = decimal(v-budget1:SCREEN-VALUE).
        budget.overdraft[v-month] = decimal(v-overdraft1:SCREEN-VALUE).*/

        budget.plan[2] = decimal(v-plan2:SCREEN-VALUE).
        /*budget.fact[2] = decimal(v-fact2:SCREEN-VALUE).
        budget.budget[2] = decimal(v-budget2:SCREEN-VALUE).
        budget.overdraft[2] = decimal(v-overdraft2:SCREEN-VALUE).*/

        budget.plan[3] = decimal(v-plan3:SCREEN-VALUE).
       /* budget.fact[3] = decimal(v-fact3:SCREEN-VALUE).
        budget.budget[3] = decimal(v-budget3:SCREEN-VALUE).
        budget.overdraft[3] = decimal(v-overdraft3:SCREEN-VALUE).*/

        budget.plan[4] = decimal(v-plan4:SCREEN-VALUE).
        /*budget.fact[4] = decimal(v-fact4:SCREEN-VALUE).
        budget.budget[4] = decimal(v-budget4:SCREEN-VALUE).
        budget.overdraft[4] = decimal(v-overdraft4:SCREEN-VALUE).*/

        budget.plan[5] = decimal(v-plan5:SCREEN-VALUE).
        /*budget.fact[5] = decimal(v-fact5:SCREEN-VALUE).
        budget.budget[5] = decimal(v-budget5:SCREEN-VALUE).
        budget.overdraft[5] = decimal(v-overdraft5:SCREEN-VALUE).*/

        budget.plan[6] = decimal(v-plan6:SCREEN-VALUE).
        /*budget.fact[6] = decimal(v-fact6:SCREEN-VALUE).
        budget.budget[6] = decimal(v-budget6:SCREEN-VALUE).
        budget.overdraft[6] = decimal(v-overdraft6:SCREEN-VALUE).*/

        budget.plan[7] = decimal(v-plan7:SCREEN-VALUE).
        /*budget.fact[7] = decimal(v-fact7:SCREEN-VALUE).
        budget.budget[7] = decimal(v-budget7:SCREEN-VALUE).
        budget.overdraft[7] = decimal(v-overdraft7:SCREEN-VALUE).*/

        budget.plan[8] = decimal(v-plan8:SCREEN-VALUE).
       /* budget.fact[8] = decimal(v-fact8:SCREEN-VALUE).
        budget.budget[8] = decimal(v-budget8:SCREEN-VALUE).
        budget.overdraft[8] = decimal(v-overdraft8:SCREEN-VALUE).*/

        budget.plan[9] = decimal(v-plan9:SCREEN-VALUE).
        /*budget.fact[9] = decimal(v-fact9:SCREEN-VALUE).
        budget.budget[9] = decimal(v-budget9:SCREEN-VALUE).
        budget.overdraft[9] = decimal(v-overdraft9:SCREEN-VALUE).*/

        budget.plan[10] = decimal(v-plan10:SCREEN-VALUE).
        /*budget.fact[10] = decimal(v-fact10:SCREEN-VALUE).
        budget.budget[10] = decimal(v-budget10:SCREEN-VALUE).
        budget.overdraft[10] = decimal(v-overdraft10:SCREEN-VALUE).*/

        budget.plan[11] = decimal(v-plan11:SCREEN-VALUE).
        /*budget.fact[11] = decimal(v-fact11:SCREEN-VALUE).
        budget.budget[11] = decimal(v-budget11:SCREEN-VALUE).
        budget.overdraft[11] = decimal(v-overdraft11:SCREEN-VALUE).*/

        budget.plan[12] = decimal(v-plan12:SCREEN-VALUE).
        /*budget.fact[12] = decimal(v-fact12:SCREEN-VALUE).
        budget.budget[12] = decimal(v-budget12:SCREEN-VALUE).
        budget.overdraft[12] = decimal(v-overdraft12:SCREEN-VALUE).*/

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


        if v-access = 1 then
        enable   /* v-gl v-des  v-coder  v-name  v-txbname v-depname */ v-plan1 /* v-fact1
    v-budget1 v-overdraft1*/ v-plan2  /* v-fact2 v-budget2 v-overdraft2*/ v-plan3 /* v-fact3 v-budget3  v-overdraft3*/
    v-plan4 /*v-fact4 v-budget4 v-overdraft4*/ v-plan5 /* v-fact5 v-budget5  v-overdraft5*/
    v-plan6  /* v-fact6 v-budget6  v-overdraft6*/ v-plan7 /* v-fact7  v-budget7 v-overdraft7*/
    v-plan8 /*v-fact8 v-budget8 v-overdraft8*/  v-plan9 /* v-fact9 v-budget9 v-overdraft9*/
    v-plan10 /*v-fact10 v-budget10  v-overdraft10*/  v-plan11 /*v-fact11 v-budget11 v-overdraft11*/
    v-plan12 /*v-fact12  v-budget12 v-overdraft12*/ save-button cancel-button with frame form1.
    display  /*v-year*/ v-gl v-des  v-coder  v-name  v-txbname v-depname  v-plan1 v-plan1 /* v-fact1
    v-budget1 v-overdraft1*/ v-plan2  /* v-fact2 v-budget2 v-overdraft2*/ v-plan3 /* v-fact3 v-budget3  v-overdraft3*/
    v-plan4 /*v-fact4 v-budget4 v-overdraft4*/ v-plan5 /* v-fact5 v-budget5  v-overdraft5*/
    v-plan6  /* v-fact6 v-budget6  v-overdraft6*/ v-plan7 /* v-fact7  v-budget7 v-overdraft7*/
    v-plan8 /*v-fact8 v-budget8 v-overdraft8*/  v-plan9 /* v-fact9 v-budget9 v-overdraft9*/
    v-plan10 /*v-fact10 v-budget10  v-overdraft10*/  v-plan11 /*v-fact11 v-budget11 v-overdraft11*/
    v-plan12 /*v-fact12  v-budget12 v-overdraft12*/ with frame form1.

    WAIT-FOR endkey of frame form1.
    hide frame form1.


end procedure.

procedure cortotal:
    DEF input param cor-gl AS int.
    DEF input param cor-coder AS char.

    def var i as int.
    def var v-plann  as decimal extent 12 format "->>>>>>>>>9.99".

    i = 1.
    do while i <= 12:
        v-plann[i] = 0.
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
                v-plann[i] = v-plann[i] + budget.plan[i].
                i = i + 1.
            end.
        end.
    end.
    find first budget where budget.year = v-year and budget.gl = cor-gl and budget.coder begins substring(cor-coder,1,7)
    and substring(budget.coder,8,5) begins "___" no-error.
    if available budget then do:
        i = 1.
        do while i <= 12:
            budget.plan[i] = v-plann[i].
            if budget.plan[i] <= 0 then budget.overdraft[i] = 0.
            else budget.overdraft[i] = ((budget.fact[i] + budget.budget[i]) / budget.plan[i]) * 100.
            i = i + 1.
        end.
    end.

    i = 1.
    do while i <= 12:
        v-plann[i] = 0.
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
                v-plann[i] = v-plann[i] + budget.plan[i].
                i = i + 1.
            end.
        end.
    end.
    find first budget where budget.year = v-year and budget.gl = cor-gl and budget.coder begins substring(cor-coder,1,7)
    and substring(budget.coder,8,5) = "TXB00" no-error.
    if available budget then do:
        i = 1.
        do while i <= 12:
            budget.plan[i] = v-plann[i].
            if budget.plan[i] <= 0 then budget.overdraft[i] = 0.
            else budget.overdraft[i] = ((budget.fact[i] + budget.budget[i]) / budget.plan[i]) * 100.
            i = i + 1.
        end.
    end.
   /**********************************************************************************************/
end procedure.