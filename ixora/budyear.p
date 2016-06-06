/* budyear.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        добавление бюджетных позиций для нового года
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

 * CHANGES
        14/07/2012 Luiza
*/


{mainhead.i}

def variable v-year as int no-undo.
def variable v-id as int no-undo.
v-year = year(today).
def frame f-date
   v-year label "Формирование бюджетных позиций на" format "9999" validate(v-year >= year(today), "Некорректный год!") skip
with side-labels centered row 7 title "Укажите год".
update  v-year  with frame f-date.

find first budget where budget.year = v-year no-lock no-error.
if available budget then do:
    message "На " + string(v-year) + "данные уже сформированы!" view-as alert-box.
    return.
end.

define buffer b-budget for budget.
def var i        as integer init 0.
def var rez as log.

v-id = 1.
rez = false.
run yn("","Формировать записи ?","","", output rez).
if  not rez then return.
find last budget use-index id no-lock no-error.
if available budget then v-id = budget.id + 1.
for each b-budget  where b-budget.year = v-year - 1 no-lock use-index budyear.
    create budget.
    budget.id            = v-id.
    budget.access        = 0.
    budget.gl            = b-budget.gl.
    budget.des           = b-budget.des.
    budget.who           = g-ofc.
    budget.whn           = g-today.
    budget.coder         = b-budget.coder.
    budget.name          = b-budget.name.
    budget.code          = b-budget.code.
    budget.txb           = b-budget.txb.
    budget.txbname       = b-budget.txbname.
    budget.dep           = b-budget.dep.
    budget.depname       = b-budget.depname.
    /*budget.plan[1]       = b-budget.plan[1].
    budget.plan[2]       = b-budget.plan[2].
    budget.plan[3]       = b-budget.plan[3].
    budget.plan[4]       = b-budget.plan[4].
    budget.plan[5]       = b-budget.plan[5].
    budget.plan[6]       = b-budget.plan[6].
    budget.plan[7]       = b-budget.plan[7].
    budget.plan[8]       = b-budget.plan[8].
    budget.plan[9]       = b-budget.plan[9].
    budget.plan[10]      = b-budget.plan[10].
    budget.plan[11]      = b-budget.plan[11].
    budget.plan[12]      = b-budget.plan[12].
    budget.fact[1]       = b-budget.fact[1].
    budget.fact[2]       = b-budget.fact[2].
    budget.fact[3]       = b-budget.fact[3].
    budget.fact[4]       = b-budget.fact[4].
    budget.fact[5]       = b-budget.fact[5].
    budget.fact[6]       = b-budget.fact[6].
    budget.fact[7]       = b-budget.fact[7].
    budget.fact[8]       = b-budget.fact[8].
    budget.fact[9]       = b-budget.fact[9].
    budget.fact[10]      = b-budget.fact[10].
    budget.fact[11]      = b-budget.fact[11].
    budget.fact[12]      = b-budget.fact[12].
    budget.budget[1]     = b-budget.budget[1].
    budget.budget[2]     = b-budget.budget[2].
    budget.budget[3]     = b-budget.budget[3].
    budget.budget[4]     = b-budget.budget[4].
    budget.budget[5]     = b-budget.budget[5].
    budget.budget[6]     = b-budget.budget[6].
    budget.budget[7]     = b-budget.budget[7].
    budget.budget[8]     = b-budget.budget[8].
    budget.budget[9]     = b-budget.budget[9].
    budget.budget[10]    = b-budget.budget[10].
    budget.budget[11]    = b-budget.budget[11].
    budget.budget[12]    = b-budget.budget[12].
    budget.overdraft[1]  = b-budget.overdraft[1].
    budget.overdraft[2]  = b-budget.overdraft[2].
    budget.overdraft[3]  = b-budget.overdraft[3].
    budget.overdraft[4]  = b-budget.overdraft[4].
    budget.overdraft[5]  = b-budget.overdraft[5].
    budget.overdraft[6]  = b-budget.overdraft[6].
    budget.overdraft[7]  = b-budget.overdraft[7].
    budget.overdraft[8]  = b-budget.overdraft[8].
    budget.overdraft[9]  = b-budget.overdraft[9].
    budget.overdraft[10] = b-budget.overdraft[10].
    budget.overdraft[11] = b-budget.overdraft[11].
    budget.overdraft[12] = b-budget.overdraft[12].*/
    budget.year          = v-year.
    budget.number        = b-budget.number.
    budget.remark[1]        = b-budget.remark[1].
    budget.remark[2]        = b-budget.remark[2].
    budget.remark[3]        = b-budget.remark[3].
    v-id = v-id + 1.
    i = i + 1 .
end.
hide message no-pause.
message "Добавлено "  + string (i) + " записей"  view-as alert-box.
