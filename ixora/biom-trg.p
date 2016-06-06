/* biom-trg.p
 * MODULE
        КЛИЕНТЫ И ИХ СЧЕТА
 * DESCRIPTION
	Тригер для поля CIF.biom:
	При смене признака тригер формирует запись в истории, которая хранится в таблице biomprz, 
	запись включает следующие поля: 
			cif - код клиента, равный коду из таблицы CIF поле cif; 
			ofc - логин менеджера, который внес изменение; 
			dt - дата внесения изменения; 
			tm - время изменения; 
			motive - причина изменения, заполняется только в случае отключения признака (пользователю предлагается ввести причину).
 * RUN
	СУБД PROGRESS
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        27/08/2005 u00121
 * BASE`s
	BANK
 * CHANGES
*/

TRIGGER PROCEDURE FOR Assign OF cif.biom.
create biomprz.
        biomprz.cif = cif.cif. /*код клиента*/
        biomprz.ofc = user('bank'). /*логин пользователя*/
        biomprz.dt = today. /*дата изменения*/
        biomprz.tm = time. /*время изменения*/
        biomprz.sts = cif.biom. /*признак изменения*/
        if not cif.biom then /*если признак снимается*/
        do: /*предлагаем ввести причину снятия*/
                update biomprz.motive validate (trim(biomprz.motive) <> '',"Причина должна быть обязательно указана!!!") with side-label centered row 10.
        end.