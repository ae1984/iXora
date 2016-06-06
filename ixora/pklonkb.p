/* pklonkb.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Проставить признак есть ли согласие в КБ
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
        07/12/07 marinav
 * CHANGES
*/

{global.i}
{pk.i}


if s-pkankln = 0 then return.


find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and 
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln "не найдена !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

def var v-ans as logical no-undo.

find first sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = pkanketa.lon and sub-cod.d-cod = 'lonkb' exclusive-lock.
  if avail sub-cod then do:
      if sub-cod.ccode = '01' then message skip " Признак отправки в Кредитное бюро уже проставлен !" skip(1) view-as alert-box buttons ok .
      else do:
         v-ans = false.
         message skip " Клиент подписал согласие об отправке информации в Кредитное бюро?" skip(1) view-as alert-box buttons yes-no title "" update v-ans.
         if v-ans then sub-cod.ccode = '01'.   
      end.
  end.
  if not avail sub-cod then message skip " Нет признака Кредитного бюро !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".