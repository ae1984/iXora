/* afn.p
 * MODULE
       Кредитный модуль
 * DESCRIPTION
       Отчеты по проверкам фин-хоз деятельности заемщиков и залогового обеспечения
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
       01/04/2011
 * BASES
	BANK, COMM
 * CHANGES

*/

def var v-sel      as   int.
run sel2 ("Выберите отчет:", " 1. Классификация кредитов  | 2. Кредиты по срокам размещения | 3. Кредиты по срокам до погашения
                             | 4. Кредиты по виду обеспечения | 5. Кредиты по разным ставкам вознаграждения | 6. Кредиты по субъектам кредитования
                             | 7. Кредиты по целевому назначению | 8. Кредиты по видам валют | 9. Кредиты резидентам/нерезидентам
                             | 10. Кредитные продукты | 11. Кредиты по срокам просрочки | 12. Сведения о выданных кредитах " , output v-sel).

case v-sel:
  when 1 then run afn_rpt1.
  when 2 then run afn_rpt2.
  when 3 then run afn_rpt3.
  when 4 then run afn_rpt4.
  when 5 then run afn_rpt5.
  when 6 then run afn_rpt6.
  when 7 then run afn_rpt7.
  when 8 then run afn_rpt8.
  when 9 then run afn_rpt9.
  when 10 then run afn_rpt10.
  when 11 then run afn_rpt11.
  when 12 then run afn_rpt12.
end case.



















































