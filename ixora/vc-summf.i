/* vc-summf.i
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
        22.04.2008 galina - изменен формат фрейма
        13.05.2008 galina - добавлен вывод полей "СУММА ЗАЙМ.%" и "СРОК ДВИЖ.КАП."
        06.06.2008 galina - добавления поля остаток непереведенных средств
        14.08.2009 galina - подвинула вниз на одну строку
        27.12.2010 aigul - вывод суммы залогов
*/

/* vc-summf.i Валютный контроль
   форма выводы общих сумм при просмотре документов

   05.12.2002 nadejda выделена из форм документов
*/


def shared var v-sumgtd as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def shared var v-suminv as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def shared var v-suminv% as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def shared var v-sumplat as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def shared var v-sumkon as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def shared var v-sumost as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def shared var v-sumexc as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def shared var v-sumakt as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def new shared var v-sumexc% as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def new shared var v-sumzalog as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def new shared var v-sumexc_6 as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def var v-term as integer format "zzzzzzzzzzzzzzzzzzzzz9".
def new shared var v-sumost1 as deci format "zzz,zzz,zzz,zzz,zz9.99-".

form
  skip(1)
  v-sumost1 label "ОСТ.НЕПЕР.СР." colon 15      v-sumgtd label  "СУММА ГТД" colon 55 skip
  v-suminv label  "ИНВ,СПЕЦ,УСЛ" colon 15   v-sumkon label  "КОНТРОЛ" colon 55 skip
  v-sumexc label  "ЗАЕМНЫЕ СР-ВА" colon 15       v-sumplat label "ОПЛАТЫ" colon 55 skip
  v-sumakt label  "СУММА АКТОВ" colon 15       v-sumost label  "ОСТАТОК" colon 55 skip
  v-sumexc% label "СУММА ЗАЙМ.%" colon 15   v-term label "СРОК ДВИЖ.КАП." colon 55 skip
  v-sumzalog label "Залоги" colon 14

  with side-label row 20 width 80 no-box overlay frame vcctsumm.

