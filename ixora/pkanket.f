/* pkanket.f
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
        25/10/2006 madiyar - добавил параметр s-credtype в вызов процедуры valid-krit
*/

/* 
   Форма редактирования настроек
*/


def {1} shared temp-table t-anket like pkanketh.

{pkvalidkrit.i}

def var v-msgerr as char.
def var v-cod as char.

form
     pkkrit.kritname format "x(23)" label "Код "
     t-anket.value1 validate (valid-krit (t-anket.kritcod, t-anket.value1, s-credtype, output v-msgerr), v-msgerr) 
                   format "x(25)" label " Данные анкеты"
     t-anket.value2 format "x(25)" label " Пров. данные"
     t-anket.value3 format "x" label "Пр"
     with row 1 centered scroll 1 down title " АНКЕТА КЛИЕНТА ДЛЯ ОЦЕНКИ ЭКСПРЕСС-КРЕДИТА "
     frame pkanket.


on help of t-anket.value1 in frame pkanket do: 
  run pkh-krit (t-anket.kritcod, output v-cod).
  if v-cod <> "" then t-anket.value1 = entry(1, v-cod).
  displ t-anket.value1 with frame pkanket. 
end.

