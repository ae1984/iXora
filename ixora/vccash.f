/* vccash.f
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Контроль кассовых операций.
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
        15/07/04 saltanat
 * CHANGES
*/

form 
	v-clname label "Наименование клиента" space(4) v-rnn label "РНН" skip
	v-ref label "НомерДок" space(6) v-who label "Исполнил" skip
	v-dracc label "СчетД" space(5)  v-cracc label "СчетК" skip
	v-dramt label "СуммаД" space(3) v-cramt label "СуммаК" skip
	v-drcrc label "ВалД" space(24) 	v-crcrc label "ВалК" 
with frame con  side-label row 9  centered  .
  
/***/

