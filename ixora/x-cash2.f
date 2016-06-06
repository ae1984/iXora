/* x-cash2.f
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
        10/11/2011 dmitriy - добавил frame x1
        30/11/2011 lyubov - переход на ИИН/БИН (изменяется надпись на формах)

*/

  /*display
   crc.code label "Валюта" jl.dam label "Дебет  " jl.cam label "Кредит  "
  jl.rem[1] + jl.rem[2]
  format "x(27)" label "     Примечание" .*/


def var v-rem as char.

v-rem = jl.rem[1] + jl.rem[2].

if v-bin = no then do:
    define frame x1
        crc.code   format "x(10)"              label "Валюта "
        jl.dam     format ">>>,>>>,>>>,>>9.99" label "Дебет "
        jl.cam     format ">>>,>>>,>>>,>>9.99" label "Кредит " skip skip
        v-rem      format "x(50)"              label "Примечание" skip
        v-cifname  format "x(50)"              label "Получил   " skip
        v-pass     format "x(50)"              label "Паспорт   " skip
        v-rnn      format "x(50)"              label "РНН       " skip
    with side-labels centered row 8.

    display crc.code jl.dam jl.cam v-rem v-cifname v-pass v-rnn with frame x1.
end.

else do:
    define frame x2
        crc.code   format "x(10)"              label "Валюта "
        jl.dam     format ">>>,>>>,>>>,>>9.99" label "Дебет "
        jl.cam     format ">>>,>>>,>>>,>>9.99" label "Кредит " skip skip
        v-rem      format "x(50)"              label "Примечание" skip
        v-cifname  format "x(50)"              label "Получил   " skip
        v-pass     format "x(50)"              label "Паспорт   " skip
        v-rnn      format "x(50)"              label "ИИН       " skip
    with side-labels centered row 8.

    display crc.code jl.dam jl.cam v-rem v-cifname v-pass v-rnn with frame x2.
end.