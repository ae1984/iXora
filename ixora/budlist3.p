/* budlist3.p
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
def var v-pr as logic.
def var x1 as int.


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

def shared var g-today as date.
def shared var g-ofc as char.

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

/***********************************************************************************************************/
define temp-table t-con1 no-undo
field cod as char
field dep as char.

/*DECLARE n1 CURSOR FOR
 select budget.remark[3], budget.dep from budget where budget.year = v-year and budget.dep <> "" and substring(budget.coder,8,5) <> "" and substring(budget.coder,8,3) <> "___" group by budget.dep.

open n1.
repeat:
    FETCH n1 INTO v-ttt, v-dep.
    create t-con1.
    t-con1.cod = v-ttt.
    t-con1.dep = v-dep.
end.
close n1.*/
for each codfr where codfr.codfr = "sproftcn" and codfr.child = false
              and codfr.code <> 'msc' and codfr.code matches '...' and substring(codfr.code,1,1) <> '0' and substring(codfr.code,1,1) <> 'a' no-lock.
    create t-con1.
    t-con1.cod = codfr.code.
    t-con1.dep = codfr.name[1].
end.
create t-con1.
t-con1.cod = "".
t-con1.dep = "Все филиалы и ЦО".

for each txb where txb.bank begins "TXB" no-lock.
    create t-con1.
    t-con1.cod = txb.bank.
    case txb.bank:
        when "TXB00" then t-con1.dep = "Центральный офис".
        when "TXB01" then t-con1.dep = "Актобе".
        when "TXB02" then t-con1.dep = "Костанай".
        when "TXB03" then t-con1.dep = "Тараз".
        when "TXB04" then t-con1.dep = "Уральск".
        when "TXB05" then t-con1.dep = "Караганда".
        when "TXB06" then t-con1.dep = "Семей".
        when "TXB07" then t-con1.dep = "Кокшетау".
        when "TXB08" then t-con1.dep = "Астана".
        when "TXB09" then t-con1.dep = "Павлодар".
        when "TXB10" then t-con1.dep = "Петропавловск".
        when "TXB11" then t-con1.dep = "Атырау".
        when "TXB12" then t-con1.dep = "Актау".
        when "TXB13" then t-con1.dep = "Жезказган".
        when "TXB14" then t-con1.dep = "Усть-Каменогорск".
        when "TXB15" then t-con1.dep = "Шымкент".
        when "TXB16" then t-con1.dep = "Алматы".
        OTHERWISE  t-con1.dep = txb.name.
    end case.
end.


define temp-table t-con no-undo
field cod as char
field dep as char
index ind1 is primary dep.

def var list as char.
define temp-table budhelp like budget.

find first budofc where budofc.ofc = g-ofc no-lock no-error.
if not available budofc then do:
    message "Сотрудник отсутствует в списке доступа!" view-as alert-box.
    return.
end.
if budofc.txb = "" then do:
    for each budofc where budofc.ofc = g-ofc no-lock.
        for each budget where budget.year = v-year and budget.dep <> "" and substring(budget.coder,8,5) <> "" and substring(budget.coder,8,3) <> "___" no-lock:
            create budhelp.
            buffer-copy budget to budhelp.
        end.
    end.
end.
else do:
    for each budofc where budofc.ofc = g-ofc no-lock.
        for each budget where budget.year = v-year and budget.dep <> "" and substring(budget.coder,8,5) <> "" and substring(budget.coder,8,3) <> "___" and lookup(budofc.txb,budget.depname) > 0  no-lock:
            create budhelp.
            buffer-copy budget to budhelp.
        end.
    end.
end.
for each budhelp no-lock.
    x1 = num-entries(budhelp.depname).
    do while x1 >= 1 :
        find first t-con where t-con.cod =  entry(x1,budhelp.depname) no-lock no-error.
        if not available t-con then do:
            v-ttt = entry(x1,budhelp.depname).
            find first t-con1 where t-con1.cod = v-ttt no-error.
            if available t-con1 then v-con = t-con1.dep.
            create t-con.
            t-con.dep = v-con.
            t-con.cod = v-ttt.
        end.
        x1 = x1 - 1.
    end.
end.
DEFINE QUERY q-con FOR t-con.

DEFINE BROWSE b-con QUERY q-con
    DISPLAY t-con.dep label "Контрол. подразделение  "format "x(50)"  WITH  15 DOWN.
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


def query  q2 for budhelp.
def browse b2 query q2
           displ budhelp.coder   label "Код расхода" format "x(12)"
                 budhelp.name    label "Наименование" format "x(45)"
                /* budhelp.name    label "Наимен расхода" format "x(38)"*/
           with 23 down column 2  width 58. /*title "За " + v-monthname.*/

def frame fmain
          v-con          at x 1 y  1 label "  Контр.подразд" view-as text format "x(32)"
          budhelp.txbname at x 416 y 1 label "Деп." view-as text format "x(50)"
          b1   at x 8   y 8 help " "
          b2   at x 400 y 8 help " "
          v-monthname           at x 8 y  220 label "Месяц        " view-as text format "x(15)"
          budhelp.name          at x 8 y  228 label "Наименование " view-as text format "x(90)"
          budhelp.plan[v-month]       at x 8 y  236 label "План         " view-as text format "->>>>>>>>>9.99"
          budhelp.fact[v-month]       at x 8 y  242 label "Факт         " view-as text format "->>>>>>>>>9.99"
          budhelp.budget[v-month]     at x 8 y  250 label "Сверх бюджет " view-as text format "->>>>>>>>>9.99"
          budhelp.overdraft[v-month]  at x 8 y  258 label "% исполнения "  view-as text format "->>>>>>>>>9"
          "____________________________________________________________________________________________" at x 8 y 266 view-as text

          with row 2  side-labels  no-box with size 110 by 35 .


/* обновление списка на правой панели */
on "cursor-right" of browse b1 do:
   close query q2.
   open query q2 for each budhelp where budhelp.year = v-year and budhelp.gl = t-gl.gl and lookup(v-ttt,budhelp.depname) > 0  no-lock   use-index budyear.
   if can-find (first budhelp where budhelp.year = v-year and budhelp.gl = t-gl.gl and lookup(v-ttt,budhelp.depname) > 0) then  browse b2:refresh().
   lastgrp = t-gl.gl.
end.


/* переход на панель счетов */
on "tab" of browse b1 do:
   if avail t-gl then do:
   if lastgrp <> t-gl.gl then do:
      lastgrp = t-gl.gl.
      close query q2.
      open query q2 for each budhelp where budhelp.year = v-year and budhelp.gl = t-gl.gl and lookup(v-ttt,budhelp.depname) > 0  no-lock  use-index budyear.
      if can-find (first budhelp where budhelp.year = v-year and budhelp.gl = t-gl.gl and lookup(v-ttt,budhelp.depname) > 0)  then browse b2:refresh().
   end.
   if avail budhelp then displ v-monthname budhelp.txbname v-con budhelp.name budhelp.plan[v-month] budhelp.fact[v-month] budhelp.budget[v-month] budhelp.overdraft[v-month] with frame fmain. else
   displ ? @ budhelp.txbname ? @ budhelp.name ? @ budhelp.plan[v-month] ? @ budhelp.fact[v-month] ? @ budhelp.budget[v-month] ? @ budhelp.overdraft[v-month] with frame fmain.
   displ
         help_l3 at x 8 y 272 view-as text no-label  /*y 152*/
         with frame fmain.
   end.
end.

/* переход на панель групп */
on "tab" of browse b2 do:
   displ ? @ budhelp.txbname ? @ budhelp.name ? @ budhelp.plan[v-month] ? @ budhelp.fact[v-month] ? @ budhelp.budget[v-month] ? @ budhelp.overdraft[v-month]
         help_g3 at x 8 y 272 view-as text no-label /*y 152*/
         with frame fmain.
end.

/* обновление сведений  суммы */
on value-changed of browse b2 do:
   if avail budhelp then displ v-monthname budhelp.txbname v-con budhelp.name budhelp.plan[v-month] budhelp.fact[v-month] budhelp.budget[v-month] budhelp.overdraft[v-month] with frame fmain.
   else
   displ ? @ budhelp.txbname ? @ budhelp.name ? @ budhelp.plan[v-month] ? @ budhelp.fact[v-month] ? @ budhelp.budget[v-month] ? @ budhelp.overdraft[v-month] with frame fmain.
end.


/*  */
on "help" of browse b2 do:
   if not available budhelp then leave.
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
    find current budhelp no-lock no-error.
    if available budhelp then do:
        v-coder = budhelp.coder.
        v-depname = budhelp.depname.
        v-txbname = budhelp.txbname.
        v-plan1 = budhelp.plan[v-month].
        v-fact1 = budhelp.fact[v-month].
        v-budget1 = budhelp.budget[v-month].
        v-overdraft1 = budhelp.overdraft[v-month].
        if avail budhelp then run ShowData(budhelp.id).
        /*b2:SELECT-ROW(Pos).
        display  b2 WITH  FRAME fmain.*/
        displ budhelp.name budhelp.plan[v-month] budhelp.fact[v-month] budhelp.budget[v-month] budhelp.overdraft[v-month] with frame fmain.
    end.
end.


OPEN QUERY  q-con FOR EACH t-con no-lock.
ENABLE ALL WITH FRAME f-con.
wait-for return of frame f-con
FOCUS b-con IN FRAME f-con.
v-con = t-con.dep.
v-ttt = t-con.cod.
hide frame f-con.

find first budhelp where lookup(v-ttt,budhelp.depname) > 0 /*use-index budyear*/  no-lock no-error.
if available budhelp then do:
    v-gl = budhelp.gl.
    v-des = budhelp.des.

    create t-gl.
    t-gl.gl = v-gl.
    t-gl.des = v-des.
    for each budhelp where lookup(v-ttt,budhelp.depname) > 0 no-lock.
        find first t-gl where t-gl.gl = budhelp.gl no-error.
        if not available t-gl then do:
            v-gl = budhelp.gl.
            v-des = budhelp.des.
            create t-gl.
            t-gl.gl = v-gl.
            t-gl.des = v-des.
        end.
    end.
end.

open query q1 for each t-gl no-lock.
open query q2 for each budhelp where budhelp.year = v-year and budhelp.gl = t-gl.gl and lookup(v-ttt,budhelp.depname) > 0 no-lock use-index budyear.
enable all with frame fmain.

displ ? @ budhelp.txbname v-con v-monthname ? @ budhelp.name ? @ budhelp.plan[v-month] ? @ budhelp.fact[v-month] ? @ budhelp.budget[v-month] ? @ budhelp.overdraft[v-month]
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

    /*def var Dep-id as int format ">9".
     def var ListBank as char format "x(40)".
     def var v-txb as char format "x(5)" init "TXB00".*/

     def buffer b-budhelp for budhelp.


     define frame form1
        /*v-year label "Год"  skip*/
        v-gl     label "Счет ГК           "  format "999999" validate(can-find(first gl where string(gl.gl) begins string(v-gl) no-lock),"Неверный счет!") skip
        v-des    label "Наименование счета"  format "x(60)"  skip
        v-coder  label "Код расхода       "  format "x(12)"  skip
        v-name   label "Наименование      "  format "x(60)"  skip
        v-txbname label "Подразделение     "  format "x(60)"  skip
        v-depname label "Контр. департамент"  format "x(60)"  skip(1)
        "           ПЛАН                     ФАКТ                   СВЕРХ БЮДЖЕТ             % ИСПОЛНЕНИЯ" skip
        "-----------------------------------------------------------------------------------------------------" skip
        v-plan1      label " Январь  " format ">>>>>>>>>9.99"
        v-fact1      label " Январь  " format ">>>>>>>>>9.99"
        v-budget1    label " Январь  " format ">>>>>>>>>9.99"
        v-overdraft1 label " Январь  " format ">>>>>>>>>9" skip(1)

        v-plan2      label " Февраль " format ">>>>>>>>>9.99"
        v-fact2      label " Февраль " format ">>>>>>>>>9.99"
        v-budget2    label " Февраль " format ">>>>>>>>>9.99"
        v-overdraft2 label " Февраль " format ">>>>>>>>>9"  skip(1)

        v-plan3      label " Март    " format ">>>>>>>>>9.99"
        v-fact3      label " Март    " format ">>>>>>>>>9.99"
        v-budget3    label " Март    " format ">>>>>>>>>9.99"
        v-overdraft3 label " Март    " format ">>>>>>>>>9"  skip(1)

        v-plan4      label " Апрель  " format ">>>>>>>>>9.99"
        v-fact4      label " Апрель  " format ">>>>>>>>>9.99"
        v-budget4    label " Апрель  " format ">>>>>>>>>9.99"
        v-overdraft4 label " Апрель  " format ">>>>>>>>>9.99"  skip(1)

        v-plan5      label " Май     " format ">>>>>>>>>9.99"
        v-fact5      label " Май     " format ">>>>>>>>>9.99"
        v-budget5    label " Май     " format ">>>>>>>>>9.99"
        v-overdraft5 label " Май     " format ">>>>>>>>>9"  skip(1)

        v-plan6      label " Июнь    " format ">>>>>>>>>9.99"
        v-fact6      label " Июнь    " format ">>>>>>>>>9.99"
        v-budget6    label " Июнь    " format ">>>>>>>>>9.99"
        v-overdraft6 label " Июнь    " format ">>>>>>>>>9"  skip(1)

        v-plan7      label " Июль    " format ">>>>>>>>>9.99"
        v-fact7      label " Июль    " format ">>>>>>>>>9.99"
        v-budget7    label " Июль    " format ">>>>>>>>>9.99"
        v-overdraft7 label " Июль    " format ">>>>>>>>>9"  skip(1)

        v-plan8      label " Август  " format ">>>>>>>>>9.99"
        v-fact8      label " Август  " format ">>>>>>>>>9.99"
        v-budget8    label " Август  " format ">>>>>>>>>9.99"
        v-overdraft8 label " Август  " format ">>>>>>>>>9"  skip(1)

        v-plan9      label " Сентябрь" format ">>>>>>>>>9.99"
        v-fact9      label " Сентябрь" format ">>>>>>>>>9.99"
        v-budget9    label " Сентябрь" format ">>>>>>>>>9.99"
        v-overdraft9 label " Сентябрь" format ">>>>>>>>>9"  skip(1)

        v-plan10      label " Октябрь " format ">>>>>>>>>9.99"
        v-fact10      label " Октябрь " format ">>>>>>>>>9.99"
        v-budget10    label " Октябрь " format ">>>>>>>>>9.99"
        v-overdraft10 label " Октябрь " format ">>>>>>>>>9"  skip(1)

        v-plan11      label " Ноябрь  " format ">>>>>>>>>9.99"
        v-fact11      label " Ноябрь  " format ">>>>>>>>>9.99"
        v-budget11    label " Ноябрь  " format ">>>>>>>>>9.99"
        v-overdraft11 label " Ноябрь  " format ">>>>>>>>>9"  skip(1)

        v-plan12      label " Декабрь " format ">>>>>>>>>9.99"
        v-fact12      label " Декабрь " format ">>>>>>>>>9.99"
        v-budget12    label " Декабрь " format ">>>>>>>>>9.99"
        v-overdraft12 label " Декабрь " format ">>>>>>>>>9"  skip(1)

     /*space(18) save-button  cancel-button*/
     WITH SIDE-LABELS centered row 1 width 110 TITLE "Данные ".

    find first b-budhelp where b-budhelp.id = cs-name no-lock no-error.
    if avail b-budhelp then do:
        /*v-year = budhelp.year.*/
        v-gl = budhelp.gl.
        v-des = budhelp.des.
        v-coder = budhelp.coder.
        v-name = budhelp.name.
        v-txbname = budhelp.txbname.
        v-depname = budhelp.depname.
        v-plan1 = budhelp.plan[1].
         v-fact1 = budhelp.fact[v-month].
        v-budget1 = budhelp.budget[v-month].
        v-overdraft1 = budhelp.overdraft[v-month].
        v-plan2 = budhelp.plan[2].
         v-fact2 = budhelp.fact[2].
        v-budget2 = budhelp.budget[2].
        v-overdraft2 = budhelp.overdraft[2].

        v-plan3 = budhelp.plan[3].
        v-fact3 = budhelp.fact[3].
        v-budget3 = budhelp.budget[3].
        v-overdraft3 = budhelp.overdraft[3].

        v-plan4 = budhelp.plan[4].
        v-fact4 = budhelp.fact[4].
        v-budget4 = budhelp.budget[4].
        v-overdraft4 = budhelp.overdraft[4].

        v-plan5 = budhelp.plan[5].
        v-fact5 = budhelp.fact[5].
        v-budget5 = budhelp.budget[5].
        v-overdraft5 = budhelp.overdraft[5].

        v-plan6 = budhelp.plan[6].
        v-fact6 = budhelp.fact[6].
        v-budget6 = budhelp.budget[6].
        v-overdraft6 = budhelp.overdraft[6].

        v-plan7 = budhelp.plan[7].
        v-fact7 = budhelp.fact[7].
        v-budget7 = budhelp.budget[7].
        v-overdraft7 = budhelp.overdraft[7].

        v-plan8 = budhelp.plan[8].
        v-fact8 = budhelp.fact[8].
        v-budget8 = budhelp.budget[8].
        v-overdraft8 = budhelp.overdraft[8].

        v-plan9 = budhelp.plan[9].
        v-fact9 = budhelp.fact[9].
        v-budget9 = budhelp.budget[9].
        v-overdraft9 = budhelp.overdraft[9].

        v-plan10 = budhelp.plan[10].
        v-fact10 = budhelp.fact[10].
        v-budget10 = budhelp.budget[10].
        v-overdraft10 = budhelp.overdraft[10].

        v-plan11 = budhelp.plan[11].
        v-fact11 = budhelp.fact[11].
        v-budget11 = budhelp.budget[11].
        v-overdraft11 = budhelp.overdraft[11].

        v-plan12 = budhelp.plan[12].
        v-fact12 = budhelp.fact[12].
        v-budget12 = budhelp.budget[12].
        v-overdraft12 = budhelp.overdraft[12].

    end.


     v-id  = cs-name.
    display  /*v-year*/ v-gl v-des  v-coder  v-name  v-txbname v-depname  v-plan1 v-plan1  v-fact1
    v-budget1 v-overdraft1 v-plan2   v-fact2 v-budget2 v-overdraft2  v-plan3  v-fact3 v-budget3  v-overdraft3
    v-plan4 v-fact4 v-budget4 v-overdraft4  v-plan5  v-fact5 v-budget5  v-overdraft5
    v-plan6   v-fact6 v-budget6  v-overdraft6  v-plan7  v-fact7  v-budget7 v-overdraft7
    v-plan8 v-fact8 v-budget8 v-overdraft8   v-plan9  v-fact9 v-budget9 v-overdraft9
    v-plan10 v-fact10 v-budget10  v-overdraft10   v-plan11 v-fact11 v-budget11 v-overdraft11
    v-plan12 v-fact12  v-budget12 v-overdraft12  with frame form1.

    WAIT-FOR endkey of frame form1.
    hide frame form1.


end procedure.
