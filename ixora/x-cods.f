/* x-cods.f
 * MODULE
        Редактирование кодов доходов/расходов по заданной транзакции
 * DESCRIPTION
         Форма для меню редактирования кодов доходов/расходов по заданной транзакции
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
        01/04/05 nataly
 * CHANGES
        13/12/05 nataly добавлен ввод кода доходов
*/

vcha3 = " Проводка  не связана со счетом доходов или расходов !!!! ".


def var v-log as log init true format "Да/Нет".
def var v-yes as log initial true format "Да/Нет".

form  " Номер проводки :"
    p-pjh 
    with centered no-label frame qqq.


form
      tcash.ln label '#' format 'zzz'  
      tcash.code label 'Код'
      tcash.dep label 'Деп-т' format '999'
      tcash.gl label 'Счет ГК' format 'zzzzzz'
      tcash.des label ' Описание        ' format 'x(38)'  
          with centered no-label frame frm.
