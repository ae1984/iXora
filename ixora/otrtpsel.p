/* otrnnufd.p
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
        16/03/04 kanat
 * CHANGES
*/

def shared var v-bentype as integer.
def shared var v-kods as char.       
def shared var v-kbes as char.       
def shared var v-knps as char.       

   run sel ("Выберите тип операции", "1. Прочие       |" +
                                     "2. Коммунальные |" + 
                                     "3. Налоги        ").

       case return-value:
          when "1" then v-bentype = 1.
          when "2" then v-bentype = 2.
          when "3" then v-bentype = 3.
       end.

  if v-bentype = 1 then do:
  update v-kods = "14".
  update v-kbes = "17".
  update v-knps = "890".
  end.

  if v-bentype = 2 then do:
  update v-kods = "14".
  update v-kbes = "17".
  update v-knps = "856".
  end.

  if v-bentype = 3 then do:
  update v-kods = "14".
  update v-kbes = "11".
  update v-knps = "911".
  end.



