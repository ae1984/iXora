
/* debarh.p
 * MODULE
        Дебиторы - архив
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
        01/06/2006 - u00600
 * CHANGES
        04.12.09   marinav - добавились поля debls.acc bic

*/

{yes-no.i}
{debls.f}

def var help_l1 as char init "<TAB> - перейти к другому окну <F1> - активный "  label "" format "x(70)". 

def var help_g1 as char init "<TAB> - перейти к другому окну <СТРЕЛКА ВПРАВО> - обновить список" label "" format "x(70)".

def var lastgrp as int init 1 no-undo.
def var lastls as int no-undo.
def var t_f as logi initial false no-undo.

def temp-table t-grp no-undo
    field grp like debgrp.grp
    field des like debgrp.des
    field arp like debgrp.arp.      

/*формирование списка архива*/
for each debls where debls.sts = 'C' break by debls.grp.
  if first-of(debls.grp) then do:
    create t-grp.
      assign t-grp.grp = debls.grp.
  find first debgrp where debgrp.grp = t-grp.grp no-lock no-error.
  if avail debgrp then do: t-grp.des = debgrp.des. t-grp.arp = debgrp.arp. end.
  t_f = true.
  end.
end.

if t_f = true then do: /*если нет ни одного дебитора в архиве, то выдаем соответствующее сообщение*/
/*def query  q1 for debgrp.*/
def query q1 for t-grp.
def browse b1 query q1
           displ t-grp.grp format ">>9" 
                 t-grp.des format "x(20)"
           with 7 down no-label title "Группы".

 
def query  q2 for debls.
def browse b2 query q2
           displ debls.ls
                 debls.name
           with 15 down no-label title "Дебиторы".

def frame fmain
          b1   at x 1   y 1 help " "
          b2   at x 240 y 1 help " " 
          t-grp.arp        at x 8 y  74 label "АРП" view-as text
          debls.created     at x 8 y  82 label "Создан" view-as text
          debls.last_opened at x 8 y  90 label "Открыт" view-as text
          debls.last_closed at x 8 y  98 label "Закрыт" view-as text
          debls.amt         at x 8 y 106 label "Сумма"  view-as text 
          debls.rnn         at x 8 y 114 label "РНН"  view-as text 
          debls.acc         at x 8 y 122 label "ИИК"  view-as text
          "_________________________" at x 8 y 130 view-as text

          with row 2 column 2 side-labels no-box. 

/* обновление списка дебиторов на правой панели */
on "cursor-right" of browse b1 do:
   close query q2.
   open query q2 for each debls where debls.grp = t-grp.grp and debls.ls ne 0 and debls.sts = 'C' no-lock    /*debls.sts = 'C'*/
                 use-index ls.
   if can-find (first debls where debls.grp = t-grp.grp and debls.ls ne 0) then
   browse b2:refresh().
   lastgrp = t-grp.grp.
end.

/* переход на панель дебиторов */
on "tab" of browse b1 do:
   if avail t-grp then do:
   if lastgrp <> t-grp.grp then do:
      lastgrp = t-grp.grp.
      close query q2.
      open query q2 for each debls where debls.grp = t-grp.grp and debls.ls ne 0 and debls.sts = 'C' no-lock    /*debls.sts = 'C'*/
                    use-index ls.
      if can-find (first debls where debls.grp = t-grp.grp and debls.ls ne 0) then
      browse b2:refresh().
   end.
   if avail debls then displ debls.amt debls.created debls.last_opened debls.last_closed
                             debls.rnn debls.acc with frame fmain. else
   displ ? @ debls.amt ? @ debls.created ? @ debls.last_opened ? @ debls.last_closed
         ? @ debls.rnn ? @ debls.acc with frame fmain.
   displ help_l1 at x 8 y 138 view-as text no-label
         with frame fmain. 
   end.
end.

/* переход на панель групп */
on "tab" of browse b2 do:
   displ ? @ debls.amt ? @ debls.created ? @ debls.last_opened ? @ debls.last_closed
         ? @ debls.rnn ? @ debls.acc
         help_g1 at x 8 y 138 view-as text no-label
         with frame fmain.
end.

/* обновление сведений о карточке дебитора - даты и суммы */
on value-changed of browse b2 do:
   if avail debls then displ debls.amt debls.created debls.last_opened debls.last_closed
                             debls.rnn debls.acc debls.rnn debls.acc with frame fmain.
   else
   displ ? @ debls.amt ? @ debls.created ? @ debls.last_opened ? @ debls.last_closed
         ? @ debls.rnn ? @ debls.acc with frame fmain.
end.

/*присвоение дебитору статуса - активный, клавиша F1*/
on "go" of browse b2 do:
  find current debls no-error.
  if avail debls then do:
    if yes-no ("Статус - активный","Вы уверены?") then debls.sts = "".  /*debls.sts = "" */
    release debls. 
  end.

  close query q2.
  open query q2 for each debls where debls.grp = debgrp.grp and debls.ls ne 0  and debls.sts = 'C' no-lock  /*debls.sts = 'C'*/
       use-index ls.
  if can-find (first debls where debls.grp = debgrp.grp and debls.ls ne 0) then 
  browse b2:refresh().

end.

/* обновление сведений о группе дебиторов - АРП */
on value-changed of browse b1 do:
   if avail t-grp then displ t-grp.arp with frame fmain.
   else displ ? @ t-grp.arp with frame fmain.
end.

/*open query q1 for each debgrp where debgrp.grp ne 0 no-lock.*/
open query q1 for each t-grp where t-grp.grp ne 0 no-lock.
open query q2 for each debls where debls.grp = t-grp.grp and debls.ls ne 0 and debls.sts = 'C' no-lock    /*debls.sts = 'C'*/
                  use-index ls.
enable all with frame fmain.

/*if avail debgrp then displ debgrp.arp with frame fmain.
                else displ ? @ debgrp.arp with frame fmain.*/

if avail t-grp then displ t-grp.arp with frame fmain.
                else displ ? @ t-grp.arp with frame fmain.

displ ? @ debls.amt ? @ debls.created ? @ debls.last_opened ? @ debls.last_closed ? @ debls.rnn ? @ debls.acc
      help_g1 at x 8 y 138 view-as text no-label 
      with frame fmain.

{wait.i}
end. /*t_f = true*/
else message "Архив пуст!!!" view-as alert-box buttons ok title "" .
