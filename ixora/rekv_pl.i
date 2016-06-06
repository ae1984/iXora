/* rekv_pl.i
 * MODULE

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
        25.05.2004 dpuchkov
 * CHANGES
        24/02/2005 u00568 Evgeniy сделал rekvin_1 теперь он возвращает результат выбора юр/физ
*/

def var v-jss as char format "x(12)" .
def var l-ind as logical.
l-ind = False.


procedure rekvin_1:
   def input parameter vrnnbn like commonls.rnnbn.
   def input parameter vknp like commonls.knp.
   def input parameter vkbe like commonls.kbe.
   def input parameter vkod like commonls.kod.
   def output parameter is_juridical_person as logical no-undo.
   /*run sel('Статус','Юридическое лицо|Физическое лицо').*/

   run rekv_pl_i_are_you_juridical_person.
   is_juridical_person = logical(return-value).
   if is_juridical_person then
   do:
     update v-jss label "Введите РНН отправителя" with centered side-label frame fjss.
     hide frame fjss.
        if vrnnbn = v-jss then do:
          l-ind = True.
          return .
        end.
        else
          if vknp = "" then do:
            message "РНН Отправителя и бенефициара не совпадают " view-as alert-box.
            l-ind = False.
            return.
           end.

      if vkod <> "" and vkbe <> "" and vknp <> ""  then
          if (vkod = "17" or vkod = "27") and (vknp = "911" or vknp = "010" or vknp = "013" or
          vknp = "019" or vknp = "912" or vknp = "913") and vkbe = "11" then do:
          l-ind = True.
          return.
        end.
        else
        do:
          l-ind = False.
          return.
        end.
   end.
   l-ind = True.
end procedure.




procedure rekvin:
   def input parameter vrnnbn like commonls.rnnbn.
   def input parameter vknp like commonls.knp.
   def input parameter vkbe like commonls.kbe.
   def input parameter vkod like commonls.kod.
   def var is_juridical_person as logical no-undo.
   run rekvin_1(vrnnbn, vknp, vkbe, vkod, output is_juridical_person).
end procedure.



procedure rekv_pl_i_are_you_juridical_person .
   run sel('Статус','Юридическое лицо|Физическое лицо').
   RETURN string(return-value = '1').
end procedure.
